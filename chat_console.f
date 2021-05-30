cd c:\repos\forth\ 
include sdl
include ds


\ to start with this console will be a standalone app, but later it will be a window that is part of a larger
\ sdl window management system

12 CONSTANT FONT_SIZE

64 CONSTANT WINDOW_CHARS_Y

800 CONSTANT WINDOW_WIDTH
WINDOW_CHARS_Y FONT_SIZE * CONSTANT WINDOW_HEIGHT


0 VALUE window 
z" zchat" 100 100 WINDOW_WIDTH WINDOW_HEIGHT 0 SDL_CreateWindow TO window  

0 VALUE renderer 
window -1 SDL_RENDERER_ACCELERATED SDL_CreateRenderer TO renderer 

0 VALUE surf
0 VALUE font_tex
0 VALUE console_tex

z" font.png" IMG_Load TO surf 

surf 1
    surf CELL+ @ 0 0 0 SDL_MapRGB 
    SDL_SetColorKey THROW

renderer surf SDL_CreateTextureFromSurface TO font_tex 

surf SDL_FreeSurface

renderer SDL_PIXELFORMAT_RGBA8888 SDL_TEXTUREACCESS_TARGET WINDOW_WIDTH WINDOW_HEIGHT SDL_CreateTexture TO console_tex 


variable cursor_x
variable cursor_vis
1 cursor_vis !
0 cursor_x !
variable cursor_flash_frame
15 CONSTANT cursor_flash_frames

WINDOW_HEIGHT FONT_SIZE - CONSTANT cursor_y_loc

DEFER OnFrame
:noname noop ; IS OnFrame

VALUE text_buffer       \ used as a circular buffer
variable text_head      \ pointer to current head of buffer
CELL 64 ra-new TO text_buffer
text_buffer ra.data @ text_head !

CELL 256 ra-new VALUE input_buffer

\ 64 lines of 256 chars each

: init-buffer 
    64 0 DO 
        CELL 256 ra-new 
            text_buffer ra-append-val \ we use 4 bytes per char since its easier
    LOOP
; init-buffer

: advance-head 
    \ check if this is the last cell    
    text_head @  text_buffer ra.data @  63 CELLS + = IF
        text_buffer ra.data @ text_head !  \ wrap back to zero
    ELSE
        CELL text_head +!                  \ next buffer 
    THEN
;

: push-buffer ( ra-src-addr ) \ copy the contents of the buffer into the current head, and advance head
    ra.data @ text_head @ @ ra.data @ 256 MOVE    
    text_head @ @ ra.length 255 SWAP !
;

: update 
    1 cursor_flash_frame +! 
    cursor_flash_frame @ cursor_flash_frames = IF
        0 cursor_flash_frame !
        cursor_vis @ NEGATE cursor_vis !
    THEN
;



12 12 0 0 create-rect char-src-rect
12 12 0 0 create-rect char-targ-rect
: render-char-at ( char x y -- )
    char-targ-rect SDL_RECT.Y !
    char-targ-rect SDL_RECT.X !

    \  font texture has 16 per line
    DUP 16 MOD FONT_SIZE * char-src-rect SDL_RECT.X !
    16 / FONT_SIZE * char-src-rect SDL_RECT.Y !

    renderer font_tex char-src-rect char-targ-rect SDL_RenderCopy THROW    
;

: clear-input-buffer 
    0 input_buffer ra.length !
    input_buffer ra.data @ 256 erase
    0 cursor_x !
;

\ -------------------------------------------------------------------------------------
\ moving text on the console texture 
\ -------------------------------------------------------------------------------------
WINDOW_HEIGHT FONT_SIZE 2 * -  \ height, all but 2 rows (top row, and input buffer)
WINDOW_WIDTH                    \ width 
FONT_SIZE 0 create-rect text-up-src \ + font_size Y

WINDOW_HEIGHT FONT_SIZE 2 * - 
WINDOW_WIDTH 0 0 create-rect text-up-dest

: move-text-up 
    renderer console_tex text-up-src text-up-dest SDL_RenderCopy THROW
;

FONT_SIZE 
WINDOW_WIDTH 
WINDOW_HEIGHT FONT_SIZE 2 * -  
0 create-rect text_input_buff_rect
: clear-bottom-text 
    renderer text_input_buff_rect SDL_RenderFillRect THROW
;

: test 
    text_head @ @ foreach
        @ .
    next    
    ;

: push-text-tex ( -- )
    \ text_head has a newly added buffer entry.  we need to render this out to the bottom of the console
    \ texture, above the input buffer area.  First, we must move all the existing text except the top row
    \ up one row.  We can do this simply by copying a large rect from Y = 1 -> Y = MAX, to Y = 0. Then 
    \ replace Y = Max with a blank rect, then finally copy the buffer text into it.
    renderer console_tex SDL_SetRenderTarget THROW
    renderer 0 0 0 255 SDL_SetRenderDrawColor THROW
    move-text-up
    clear-bottom-text 
    0  WINDOW_HEIGHT FONT_SIZE 2 * - locals| y x |
    text_head @ @ foreach
        @ x y render-char-at
        x FONT_SIZE + TO x
    next    
    renderer 0 SDL_SetRenderTarget THROW
;

\ -------------------------------------------------------------------------------------
\ -------------------------------------------------------------------------------------
\ -------------------------------------------------------------------------------------

12 12 cursor_y_loc 0 create-rect cursor-rect
: render-cursor ( -- )
    cursor_vis @ 1 = IF 
        renderer 255 255 255 255 SDL_SetRenderDrawColor THROW
        \ render at bottom of screen - FONT-SIZE,  + x * FONT_SIZE
        cursor_x @ FONT_SIZE *   
            cursor-rect SDL_RECT.X !
        renderer cursor-rect SDL_RenderFillRect THROW       
    THEN
;

: render-input-buffer ( -- )
    0 locals| x |
    input_buffer foreach
        @ x cursor_y_loc render-char-at
        x FONT_SIZE + TO x
    next    
;

: render ( -- )
    renderer 0 SDL_SetRenderTarget THROW
    renderer 0 0 0 0 SDL_SetRenderDrawColor THROW
    renderer SDL_RenderClear DROP

    \ copy the whole console buffer
    renderer console_tex 0 0 SDL_RenderCopy THROW

    \ render the input buffer and cursor over the top 
    render-input-buffer 
    render-cursor


    renderer SDL_RenderPresent
;

: HandleOnFrame 
     update
     render
; 

' HandleOnFrame IS OnFrame 
DEFER KeyHandler

: try-append-char ( char -- )
    \ appends the char to the current input buffer     
    cursor_x @ 255 < IF
        1 cursor_x +!
        0 cursor_flash_frame !
        1 cursor_vis !
        input_buffer ra-append-val
    THEN
;

: try-remove-char (  -- )    
    cursor_x @ 0 > IF
        -1 cursor_x +!
        0 cursor_flash_frame !
        1 cursor_vis !
        -1 input_buffer ra.length +!
    THEN
;


:noname 
    DUP .
    DUP
    CASE
        8 OF DROP try-remove-char ENDOF \ backspace
        13 OF DROP                      \ enter
            input_buffer push-buffer    \ copy input buffer into next slot
            push-text-tex               \ render the new text, and move the rest up one (losing the top line)
            advance-head                \ move circular buffer pointer
            clear-input-buffer 
        ENDOF    
        try-append-char
    ENDCASE
    
    ; IS KeyHandler

\ HandleOnFrame IS OnFrame

hex
23E8 TASK SDL_PUMP
decimal
CREATE event 128 /allot
variable last_frame
30 CONSTANT FPS
1000 30 / CONSTANT ms_per_frame

: start-pump 
    SDL_PUMP ACTIVATE
    BEGIN 
        PAUSE        
        GetTickCount
        BEGIN 
            event SDL_PollEvent  
        WHILE  \ event != 0
            event SDL_CommonEvent.type @
            CASE
                SDL_QUIT_EVENT OF ." DONE " SDL_QUIT EXIT ENDOF
                SDL_KEYDOWN OF                 
                    event 
                        SDL_KeyboardEvent->SDL_Keysym 
                        SDL_Keysym.Keycode @ KeyHandler
                ENDOF
            ENDCASE
        REPEAT        
        OnFrame
        \ lock to 30fps
        GetTickCount SWAP -
        DUP ms_per_frame SWAP > IF             
            ms_per_frame SWAP - SDL_Delay
        THEN
    AGAIN  ;
