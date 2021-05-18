
\ sdl 

cd c:\repos\forth\ 

include "struct.f"

LIBRARY SDL2

HEX

struct SDL_RECT
    SDL_RECT svar SDL_RECT.X
    SDL_RECT svar SDL_RECT.Y
    SDL_RECT svar SDL_RECT.W
    SDL_RECT svar SDL_RECT.H
    
struct SDL_POINT
    SDL_POINT svar SDL_POINT.X
    SDL_POINT svar SDL_POINT.Y
    
struct SDL_CommonEvent
    SDL_CommonEvent svar SDL_CommonEvent.type
    SDL_CommonEvent svar SDL_CommonEvent.timestamp

struct SDL_Keysym
    SDL_Keysym svar SDL_Keysym.Scancode
    SDL_Keysym svar SDL_Keysym.Keycode
    SDL_Keysym HCELL sfield SDL_Keysym.mod
    SDL_Keysym svar SDL_Keysym.unused

struct SDL_KeyboardEvent
    SDL_KeyboardEvent SDL_CommonEvent sembed SDL_KeyboardEvent>SDL_CommonEvent
    SDL_KeyboardEvent svar SDL_KeyboardEvent.windowId
    SDL_KeyboardEvent 1 sfield SDL_KeyboardEvent.state
    SDL_KeyboardEvent 1 sfield SDL_KeyboardEvent.repeat
    SDL_KeyboardEvent 1 sfield SDL_KeyboardEvent.padding2
    SDL_KeyboardEvent 1 sfield SDL_KeyboardEvent.padding3
    SDL_KeyboardEvent SDL_Keysym sembed SDL_KeyboardEvent->SDL_Keysym 


\ init subsystem flags
0001 CONSTANT SDL_INIT_TIMER
0010 CONSTANT SDL_INIT_AUDIO
0100 CONSTANT SDL_INIT_VIDEO
1000 CONSTANT SDL_INIT_CDROM
FFFF CONSTANT SDL_INIT_EVERYTHING

\ sdl event types
0 CONSTANT SDL_RELEASED
1 CONSTANT SDL_PRESSED

100 CONSTANT SDL_QUIT_EVENT

300 CONSTANT SDL_KEYDOWN
301 CONSTANT SDL_KEYUP

400 SDL_MOUSEMOTION     \ mouse moved
401 SDL_MOUSEBUTTONDOWN 
402 SDL_MOUSEBUTTONUP
403 SDL_MOUSEWHEEL      

\ window create flags 
00000001 CONSTANT SDL_WINDOW_FULLSCREEN         \ fullscreen window */
00000002 CONSTANT SDL_WINDOW_OPENGL             \ window usable with OpenGL context */
00000004 CONSTANT SDL_WINDOW_SHOWN              \ window is visible */
00000008 CONSTANT SDL_WINDOW_HIDDEN             \ window is not visible */
00000010 CONSTANT SDL_WINDOW_BORDERLESS         \ no window decoration */
00000020 CONSTANT SDL_WINDOW_RESIZABLE          \ window can be resized */
00000040 CONSTANT SDL_WINDOW_MINIMIZED          \ window is minimized */
00000080 CONSTANT SDL_WINDOW_MAXIMIZED          \ window is maximized */
00000100 CONSTANT SDL_WINDOW_MOUSE_GRABBED      \ window has grabbed mouse input */
00000200 CONSTANT SDL_WINDOW_INPUT_FOCUS        \ window has input focus */
00000400 CONSTANT SDL_WINDOW_MOUSE_FOCUS        \ window has mouse focus */
00000800 CONSTANT SDL_WINDOW_FOREIGN            \ window not created by SDL */
00002000 CONSTANT SDL_WINDOW_ALLOW_HIGHDPI      \ window should be created in high-DPI mode if supported.
00004000 CONSTANT SDL_WINDOW_MOUSE_CAPTURE      \ window has mouse captured (unrelated to MOUSE_GRABBED) */
00008000 CONSTANT SDL_WINDOW_ALWAYS_ON_TOP      \ window should always be above others */
00010000 CONSTANT SDL_WINDOW_SKIP_TASKBAR       \ window should not be added to the taskbar */
00020000 CONSTANT SDL_WINDOW_UTILITY            \ window should be treated as a utility window 
00040000 CONSTANT SDL_WINDOW_TOOLTIP            \ window should be treated as a tooltip */
00080000 CONSTANT SDL_WINDOW_POPUP_MENU         \ window should be treated as a popup menu */
00100000 CONSTANT SDL_WINDOW_KEYBOARD_GRABBED   \ window has grabbed keyboard input */
10000000 CONSTANT SDL_WINDOW_VULKAN             \ window usable for Vulkan surface */
20000000 CONSTANT SDL_WINDOW_METAL              \ window usable for Metal view */

\ CreateRenderer flags
00000001 CONSTANT SDL_RENDERER_SOFTWARE   \         /**< The renderer is a software fallback */
00000002 CONSTANT SDL_RENDERER_ACCELERATED   \      /**< The renderer uses hardware
00000004 CONSTANT SDL_RENDERER_PRESENTVSYNC   \     /**< Present is synchronized
00000008 CONSTANT SDL_RENDERER_TARGETTEXTURE   \    /**< The renderer supports rendering to texture */
    
\ texture access enum
000000000 CONSTANT SDL_TEXTUREACCESS_STATIC    \ /**< Changes rarely, not lockable */
000000001 CONSTANT SDL_TEXTUREACCESS_STREAMING \ /**< Changes frequently, lockable */
000000002 CONSTANT SDL_TEXTUREACCESS_TARGET    \ /**< Texture can be used as a render target */

DECIMAL

6 CONSTANT SDL_PIXELTYPE_PACKED32
4 CONSTANT SDL_PACKEDORDER_RGBA
6 CONSTANT SDL_PACKEDLAYOUT_8888

1 28 LSHIFT
SDL_PIXELTYPE_PACKED32 24 LSHIFT OR
SDL_PACKEDORDER_RGBA 20 LSHIFT OR
SDL_PACKEDLAYOUT_8888 16 LSHIFT OR
32 8 LSHIFT OR
4 OR CONSTANT SDL_PIXELFORMAT_RGBA8888

 \ SDL_PIXELFORMAT_RGBA8888 =
\        SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBA,
\                               SDL_PACKEDLAYOUT_8888, 32, 4),           

\ #define SDL_DEFINE_PIXELFORMAT(type, order, layout, bits, bytes) \
\     ((1 << 28) | (type << 24) | ((order) << 20) | ((layout) << 16) | \
\      ((bits) << 8) | ((bytes) << 0))                                          


FUNCTION: SDL_Init ( flags -- res )
FUNCTION: SDL_GetError ( -- char* )
FUNCTION: SDL_Quit ( -- )
FUNCTION: SDL_GetVersion ( -- *ver )

FUNCTION: SDL_CreateWindow ( *title x y w h flags -- window* )
FUNCTION: SDL_DestroyWindow ( window* -- )
FUNCTION: SDL_ShowSimpleMessageBox ( flags *title *message *window -- err )

FUNCTION: SDL_GetRenderer ( *window -- renderer* )
FUNCTION: SDL_CreateRenderer ( *window index flags -- renderer* )
FUNCTION: SDL_SetRenderTarget ( renderer* texture* -- err )
FUNCTION: SDL_RenderClear ( renderer* -- err )
FUNCTION: SDL_RenderPresent ( renderer* -- )
FUNCTION: SDL_RenderCopy ( ren* tex* srcrect* destrect* -- err )
FUNCTION: SDL_RenderDrawRect ( renderer* rect* -- err )
FUNCTION: SDL_RenderFillRect ( renderer* rect* -- err )
FUNCTION: SDL_SetRenderDrawColor ( renderer* r g b a -- err )
FUNCTION: SDL_SetTextureColorMod ( tex* r g b -- err )

FUNCTION: SDL_CreateTexture ( ren* piexelFormatEnum access w h -- tex* )
FUNCTION: SDL_CreateTextureFromSurface ( ren* surf* -- tex* )
FUNCTION: SDL_QueryTexture ( tex* &format &access &w &h -- err )
FUNCTION: SDL_FreeSurface ( surface* -- )
FUNCTION: SDL_DestroyTexture ( tex* -- )
FUNCTION: SDL_DestroyRenderer ( ren* -- )

FUNCTION: SDL_PollEvent ( event* -- res ) \ 1 if pending event
FUNCTION: SDL_GetTicks ( -- ticks )
FUNCTION: SDL_Delay ( ms -- )

FUNCTION: SDL_MapRGB ( pixformat* r g b -- res )
FUNCTION: SDL_SetColorKey ( surf* flag key -- err )

LIBRARY SDL2_Image
FUNCTION: IMG_Load ( file* -- surface* )



HEX
: rgba ( r g b a ) 
    18 LSHIFT SWAP
    10 LSHIFT OR SWAP
    8 LSHIFT OR OR 
;

DECIMAL
variable window
z" test" 100 100 1200 1200 0 SDL_CreateWindow window !
variable renderer 
\ window @ -1 SDL_RENDERER_ACCELERATED SDL_CreateRenderer renderer !
 \ window @ -1 SDL_RENDERER_SOFTWARE SDL_CreateRenderer renderer !
 window @ -1 SDL_RENDERER_ACCELERATED SDL_RENDERER_TARGETTEXTURE OR SDL_CreateRenderer renderer !
\ window @ -1 SDL_RENDERER_SOFTWARE SDL_RENDERER_TARGETTEXTURE OR SDL_CreateRenderer renderer ! 
CREATE event 128 /allot
DEFER KeyHandler
:noname . ; IS KeyHandler

CREATE my-rect 10 , 10 , 100 , 100 ,


: test
    renderer @ 255 0 0 255 SDL_SetRenderDrawColor
    renderer @ SDL_RenderClear    
    renderer @ 0 0 255 255 SDL_SetRenderDrawColor
    renderer @ my-rect SDL_RenderDrawRect
    renderer @ SDL_RenderPresent

;


80 CONSTANT HEIGHT
80 CONSTANT WIDTH

variable surf
variable font-tex
variable console-tex
variable fx-tex

\ z" font.bmp" IMG_Load surf !
z" font.png" IMG_Load surf !

surf @ 1
    surf @ CELL+ @ 0 0 0 SDL_MapRGB SDL_SetColorKey THROW

renderer @ surf @ SDL_CreateTextureFromSurface font-tex !

surf @ SDL_FreeSurface

renderer @ SDL_PIXELFORMAT_RGBA8888 SDL_TEXTUREACCESS_TARGET 1200 1200 SDL_CreateTexture console-tex !

renderer @ SDL_PIXELFORMAT_RGBA8888 SDL_TEXTUREACCESS_TARGET 1200 1200 SDL_CreateTexture fx-tex !




: create-rect create , , , , ;

12 12 8 0  create-rect char-rect
12 12 20 20  create-rect targ-rect

100 100 100 100  create-rect fx-rect


decimal

c0 c0 0 0 create-rec font-rect 
\ font-tex @ tex-data tex-data CELL+ tex-data CELL+ CELL+ tex-data CELL+ CELL+ CELL+ SDL_QueryTexture

\ font-tex @ 255 0 0 SDL_SetTextureColorMod

renderer @ SDL_RenderClear
\ renderer @ font-tex @ char-rect char-rect SDL_RenderCopy
\ renderer @ font-tex @ font-rect font-rect SDL_RenderCopy
renderer @ SDL_RenderPresent


DEFER KeyHandler
:noname . ; IS KeyHandler
' set-char is KeyHandler


struct %ConsoleBufferCell
    %ConsoleBufferCell SDL_RECT sembed %ConsoleBufferCell->SourceRect
    %ConsoleBufferCell SDL_RECT sembed %ConsoleBufferCell->DestRect
    %ConsoleBufferCell svar %ConsoleBufferCell->ForegroundR
    %ConsoleBufferCell svar %ConsoleBufferCell->ForegroundG
    %ConsoleBufferCell svar %ConsoleBufferCell->ForegroundB
    %ConsoleBufferCell svar %ConsoleBufferCell->ForegroundA
    %ConsoleBufferCell svar %ConsoleBufferCell->BackgroundR
    %ConsoleBufferCell svar %ConsoleBufferCell->BackgroundG
    %ConsoleBufferCell svar %ConsoleBufferCell->BackgroundB
    %ConsoleBufferCell svar %ConsoleBufferCell->BackgroundA


CREATE ConsoleBuffer HEIGHT WIDTH * %ConsoleBufferCell @ * /ALLOT ;

HEX
: console-init ( -- ) 
    ConsoleBuffer 
    HEIGHT 0 DO
        WIDTH  0 DO
            DUP         C SWAP !   \ srcrect->x = 0
            CELL+ DUP   0 SWAP !   \ srcrect->y = 0
            CELL+ DUP   C SWAP !   \ srcrect->w = 12
            CELL+ DUP   C SWAP !   \ srcrect->h = 12
            
            CELL+ DUP   I C * SWAP !   \ dstrect->x = x * 12
            CELL+ DUP   J C * SWAP !   \ dstrect->y = y << 4  ( * 16 )
            CELL+ DUP   C SWAP !   \ dstrect->w = 12
            CELL+ DUP   C SWAP !   \ dstrect->h = 12
            
            CELL+ DUP   FF SWAP !  \ foreground r = 24
            CELL+ DUP   18 SWAP !  \ foreground g = 24
            CELL+ DUP   18 SWAP !  \ foreground b = 24
            CELL+ DUP   1  SWAP !  \ unused alpha (temp: dtermines if needs rendering)

            CELL+ DUP   1  SWAP !  \ background r = 0
            CELL+ DUP  E0 SWAP !  \ background g = 224
            CELL+ DUP   3  SWAP !  \ background  b = 0
            CELL+ DUP   0  SWAP !  \ unused alpha
            CELL+
        LOOP
    LOOP
    DROP

;
DECIMAL


: render-console 
    renderer @ 0 0 0 0 SDL_SetRenderDrawColor THROW
    renderer @ SDL_RenderClear DROP

    renderer @ console-tex @ SDL_SetRenderTarget THROW
    ConsoleBuffer
    WIDTH HEIGHT * 0 DO 
        \ set background and draw filled rect 
        \ dup .
        
        \ only render if this bit is set, in which case clear it
        DUP %ConsoleBufferCell->ForegroundA DUP @ 1 = IF
            0 SWAP !

            DUP                         
            renderer @ SWAP DUP DUP 
                %ConsoleBufferCell->BackgroundR @ SWAP
                %ConsoleBufferCell->BackgroundG @ ROT
                %ConsoleBufferCell->BackgroundB @ 255 SDL_SetRenderDrawColor THROW

            DUP 
            renderer @ SWAP %ConsoleBufferCell->DestRect SDL_RenderFillRect THROW

            \ set foreground colour mod
            DUP                 
            font-tex @ SWAP DUP DUP 
                %ConsoleBufferCell->ForegroundR @ SWAP
                %ConsoleBufferCell->ForegroundG @ ROT
                %ConsoleBufferCell->ForegroundB @ SDL_SetTextureColorMod THROW

            \ blit
            DUP 
            renderer @ SWAP 
            font-tex @ SWAP 
            DUP %ConsoleBufferCell->SourceRect SWAP
            %ConsoleBufferCell->DestRect SDL_RenderCopy THROW
        ELSE DROP
        THEN
        %ConsoleBufferCell @ +
    LOOP
    DROP

    renderer @ 0 SDL_SetRenderTarget THROW
    renderer @ console-tex @ 0 0 SDL_RenderCopy THROW
    renderer @ SDL_RenderPresent 
;

: set-char2 ( rf gf bf rb gb bb x y c ) 
    locals| c y x bb gb rb bf gf rf |

    x %ConsoleBufferCell @ * 
    y %ConsoleBufferCell @ * WIDTH * + 
    ConsoleBuffer +

    DUP %ConsoleBufferCell->ForegroundR rf SWAP !
    DUP %ConsoleBufferCell->ForegroundG gf SWAP !
    DUP %ConsoleBufferCell->ForegroundB bf SWAP !
    DUP %ConsoleBufferCell->ForegroundA 1 SWAP !
    DUP %ConsoleBufferCell->BackgroundR rb SWAP !
    DUP %ConsoleBufferCell->BackgroundG gb SWAP !
    DUP %ConsoleBufferCell->BackgroundB bb SWAP !

    %ConsoleBufferCell->SourceRect DUP 
    c 16 MOD 12 * SWAP !
    c 16 / 12 * SWAP CELL+ !

    
;


\ fx test

renderer @ fx-tex @ SDL_SetRenderTarget 
renderer @ 128 128 128 128 SDL_SetRenderDrawColor THROW
renderer @ fx-rect SDL_RenderFillRect THROW
renderer @ 0 SDL_SetRenderTarget 

renderer @ 0 0 0 0 SDL_SetRenderDrawColor THROW
renderer @ SDL_RenderClear DROP
renderer @ fx-tex @ fx-rect fx-rect SDL_RenderCopy

renderer @ SDL_RenderPresent 


\ console tex test 
renderer @ console-tex @ SDL_SetRenderTarget 

renderer @ 255 0 0 0 SDL_SetRenderDrawColor THROW
renderer @ SDL_RenderClear DROP
renderer @ SDL_RenderPresent 
renderer @ console-tex @ 0 0 SDL_RenderCopy
renderer @ 0 SDL_SetRenderTarget 
renderer @ SDL_RenderPresent 


255 255 255  255 255 255  0 0 1 set-char2 render-console 

hex
23E8 TASK SDL_PUMP
decimal

variable fps_frames
variable fps_current
variable fps_lasttime
0 fps_frames !
0 fps_current !
0 fps_lasttime !

DEFER OnFrame


     16807 CONSTANT A
2147483647 CONSTANT M
    127773 CONSTANT Q   \ m a /
      2836 CONSTANT R   \ m a mod

CREATE SEED  123475689 ,

\ Returns a full cycle random number

: RANDS ( 'seed -- rand )
   DUP >R
   @ Q /MOD ( lo high)
   R * SWAP A * 2DUP > IF  - ELSE  - M +  THEN  DUP R> ! ;

: RAND ( -- rand )  \ 0 <= rand < ((4,294,967,296/2)-1)
   SEED RANDS ;

\ Returns single random number less than n

: RND ( n -- rnd )  \ 0 <= rnd < n
   RAND SWAP MOD ;

: RNDS ( n 'seed -- rnd )
   RANDS SWAP MOD ;


: FPS_Calc 
    1 fps_frames +!

    fps_lasttime @ SDL_GetTicks 1000 - < IF
        SDL_GetTicks fps_lasttime !
        fps_frames @ fps_current !
        0 fps_frames !
        fps_current @ .        
    THEN

    50 0 DO
        256 RND 256 RND 256 RND
        256 RND 256 RND 256 RND
        WIDTH RND HEIGHT RND 128 RND set-char2
    LOOP

    render-console
;

' FPS_Calc IS OnFrame

: start-pump 
    SDL_PUMP ACTIVATE
  BEGIN 
    PAUSE
    
  
    OnFrame

    event SDL_PollEvent 
    1 = IF
        event SDL_CommonEvent.type @
            CASE
                SDL_QUIT_EVENT OF ." DONE " SDL_QUIT EXIT ENDOF
                SDL_KEYUP OF                 
                event 
                    SDL_KeyboardEvent->SDL_Keysym 
                    SDL_Keysym.Keycode @ KeyHandler
                ENDOF
            ENDCASE
            2
    ELSE 1

    THEN
    
  WHILE
  REPEAT  ;


