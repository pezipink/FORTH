cd c:\repos\forth\ 

include zmq
include struct
include ds
include common
include sdl


CREATE msg_type 64 /ALLOT   
CREATE msg_type_out 64 /ALLOT   
CREATE msg_payload 64 /ALLOT   
CREATE msg_payload_out 64 /ALLOT   
CREATE buffer 64 /ALLOT   
variable ctx 
zmq_ctx_new ctx ! 

0 VALUE sock 

hex
    23E8 TASK Agent
decimal


CREATE identity ," CATBUS"
ctx @ ZMQ_DEALER zmq_socket TO sock
sock ZMQ_ROUTING_ID identity identity count nip 1 + zmq_setsockopt 
sock Z" tcp://127.0.0.1:5561" zmq_connect THROW

CREATE temp-msg  0 , 0 ,

: connect 
    temp-msg MSG-CONNECT SWAP !
    sock temp-msg 4 0 zmq_send DROP
;

: hb
    temp-msg  MSG-HEARTBEAT SWAP !
    sock temp-msg 4 0 zmq_send DROP
;


: say ( cstr* u -- )
    1 + >R
    msg_payload_out R@ zmq_msg_init_size THROW
    1 -   \ include len
    msg_payload_out zmq_msg_data R> CMOVE
    msg_type_out CELL zmq_msg_init_size THROW
    MSG-SAY msg_type_out zmq_msg_data !
    msg_type_out sock ZMQ_SNDMORE zmq_msg_send DROP
    msg_payload_out sock 0 zmq_msg_send DROP
    
;


: server-heartbeat 
   \ ." GOT HB " CR
;

DEFER HandleSay
:noname ; IS HandleSay

: server-say 
  \  ." GOT SAY " CR
    \ msg_payload zmq_msg_data COUNT TYPE
    HandleSay
;

: dispatch-message 
    msg_type zmq_msg_size 4 = IF
        msg_type zmq_msg_data @
        CASE
            MSG-HEARTBEAT OF server-heartbeat ENDOF
            MSG-SAY OF server-say ENDOF
             ." received unknown msg_type "
        ENDCASE 
    ELSE
        ." received malformed or unknown msg_type "
    THEN ;


: read-message
    \ expect maybe one more message (payload).  
    \ otherwise, eat messages until no more - bad data
    msg_payload zmq_msg_init THROW
    msg_type zmq_msg_more IF
        msg_payload sock 0 zmq_msg_recv DROP
    THEN

    \ fail condition - more messages is bad
    msg_payload zmq_msg_more IF
        BEGIN
            msg_payload sock 0 zmq_msg_recv
        WHILE msg_payload zmq_msg_more REPEAT
        ." chomped invalid message frame sequence "
    ELSE
        dispatch-message
    THEN

    msg_type zmq_msg_close THROW
    msg_payload zmq_msg_close THROW
;


: start-agent 
    Agent ACTIVATE
    msg_type zmq_msg_init THROW     \ TODO work out exactly what cases we need to close this?
    BEGIN
        \ we expect the first mesage to be the socket id    
        msg_type sock ZMQ_DONTWAIT zmq_msg_recv -1 <> IF        
            \ ." GOT MSG SIZE " , 
            \ CR        
            read-message
            msg_type zmq_msg_init THROW 
        THEN
        PAUSE
    AGAIN
;

\ sock @ test-msg test-msg count nip 1 + 0 zmq_send

\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ SDL


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
0 VALUE console_tex_back

\ load font surface
z" font.png" IMG_Load TO surf 

\ set black transparency 
surf 1
    surf CELL+ @ 0 0 0 SDL_MapRGB 
    SDL_SetColorKey THROW

\ convert to texture
renderer surf SDL_CreateTextureFromSurface TO font_tex 

surf SDL_FreeSurface

\ create two textures for rendering the console
\ we need a backbuffer to avoid SDL glitches
renderer SDL_PIXELFORMAT_RGBA8888 SDL_TEXTUREACCESS_TARGET WINDOW_WIDTH WINDOW_HEIGHT SDL_CreateTexture TO console_tex 
renderer SDL_PIXELFORMAT_RGBA8888 SDL_TEXTUREACCESS_TARGET WINDOW_WIDTH WINDOW_HEIGHT SDL_CreateTexture TO console_tex_back

\ -------------------------------------------------------------------------------------
\ Cursor and animation state
\ -------------------------------------------------------------------------------------
variable cursor_x
variable cursor_vis
1 cursor_vis !
0 cursor_x !
variable cursor_flash_frame
15 CONSTANT cursor_flash_frames
WINDOW_HEIGHT FONT_SIZE - CONSTANT cursor_y_loc

: update-cursor
    1 cursor_flash_frame +! 
    cursor_flash_frame @ cursor_flash_frames = IF
        0 cursor_flash_frame !
        cursor_vis @ NEGATE cursor_vis !
    THEN
;

\ -------------------------------------------------------------------------------------



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

: push-buffer ( ra-src-addr -- ) \ copy the contents of the buffer into the current head, and advance head
    ra.data @  text_head @ @ ra.data @  256  MOVE    
    text_head @ @ ra.length 255 SWAP !
;

: push-buffer-cstr ( cstr* -- )
    COUNT 0 DO
        DUP I + C@ text_head @ @ ra-append-val 
    LOOP
    DROP
    text_head @ @ ra.length 255 SWAP !
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
    WINDOW_WIDTH                   \ width 
    FONT_SIZE 0 
create-rect text-up-src \ + font_size Y

    WINDOW_HEIGHT FONT_SIZE 2 * - 
    WINDOW_WIDTH 0 0 
create-rect text-up-dest


: switch-clear-buffer ( tex* -- )
    renderer SWAP SDL_SetRenderTarget THROW
    renderer 0 0 0 255 SDL_SetRenderDrawColor THROW
    renderer SDL_RenderClear DROP
;

: move-text-up ( -- )
    \ we must use a back buffer to avoid SDL glitches.
    \ first, clear the back buffer
    console_tex_back switch-clear-buffer
    
    \ now copy from the current buffer the text excluding the top row
    renderer console_tex text-up-src text-up-dest SDL_RenderCopy THROW

    \ switch and clear buffer 
    console_tex switch-clear-buffer
    
    \ copy data back
    renderer console_tex_back 0 0 SDL_RenderCopy THROW
;

: push-text-tex ( -- )
    \ text_head has a newly added buffer entry.  we need to render this out to the bottom of the console
    \ texture, above the input buffer area.  First, we must move all the existing text except the top row
    \ up one row.  We can do this simply by copying a large rect from Y = 1 -> Y = MAX, to Y = 0. Then 
    \ replace Y = Max with a blank rect, then finally copy the buffer text into it.
    move-text-up
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
     update-cursor
     render
; 

' HandleOnFrame IS OnFrame 
DEFER KeyHandler
DEFER TextHandler

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
 \   DUP ." TH " .
    try-append-char    
; IS TextHandler

:noname 
  \  ." IN HANDLE SAY "
    msg_payload zmq_msg_data 
        push-buffer-cstr    \ copy input buffer into next slot
    push-text-tex               \ render the new text, and move the rest up one (losing the top line)
    advance-head                \ move circular buffer pointer
    clear-input-buffer 
; IS HandleSay

CREATE temp_msg 256 /ALLOT 
:noname 
    DUP
    CASE
        8 OF DROP try-remove-char ENDOF \ backspace
        13 OF DROP                      \ enter
            input_buffer RA.Length @ 
            temp_msg !
            temp_msg 1 +  locals| x | 
            input_buffer foreach
          \      DUP C@ .
                C@ x C!
                x 1 + TO x
            next

            temp_msg COUNT say
            clear-input-buffer 
            \ input_buffer push-buffer    \ copy input buffer into next slot

            \ push-text-tex               \ render the new text, and move the rest up one (losing the top line)
            \ advance-head                \ move circular buffer pointer
            \ clear-input-buffer 
        ENDOF    
        DROP
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
    SDL_StartTextInput
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
                SDL_TEXTINPUT OF 
                    event SDL_TextInputEvent.text C@ TextHandler
                ENDOF
                SDL_TEXTEDITING OF
             \       ." TE " CR                    
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
