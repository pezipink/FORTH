
    \ sdl 

    cd c:\repos\forth\ 

    include "ds.f"
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

    \ blend modes 
    00000000 CONSTANT SDL_BLENDMODE_NONE \     /**< no blending
                                        \        dstRGBA = srcRGBA */
    00000001 CONSTANT SDL_BLENDMODE_BLEND \    /**< alpha blending
                                        \       dstRGB = (srcRGB * srcA) + (dstRGB * (1-srcA))
                                        \      dstA = srcA + (dstA * (1-srcA)) */
    00000002 CONSTANT SDL_BLENDMODE_ADD \      /**< additive blending
                                            \     dstRGB = (srcRGB * srcA) + dstRGB
                                            \    dstA = dstA */
    00000004 CONSTANT SDL_BLENDMODE_MOD \      /**< color modulate
                                            \   dstRGB = srcRGB * dstRGB
                                            \  dstA = dstA */
    00000008 CONSTANT SDL_BLENDMODE_MUL \      /**< color multiply
                                            \   dstRGB = (srcRGB * dstRGB) + (dstRGB * (1-srcA))
                                            \  dstA = (srcA * dstA) + (dstA * (1-srcA)) */
    7FFFFFFF CONSTANT SDL_BLENDMODE_INVALID \

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
    FUNCTION: SDL_SetTextureBlendMode ( tex* blendMode -- err )
    FUNCTION: SDL_SetRenderDrawBlendMode ( renderer* blendMode -- err )

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


    800 CONSTANT WINDOW_WIDTH
    800 CONSTANT WINDOW_HEIGHT

    variable window
    z" test" 100 100 WINDOW_WIDTH WINDOW_HEIGHT SDL_WINDOW_RESIZABLE SDL_CreateWindow window !
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

    renderer @ SDL_PIXELFORMAT_RGBA8888 SDL_TEXTUREACCESS_TARGET WINDOW_WIDTH WINDOW_HEIGHT SDL_CreateTexture console-tex !

    renderer @ SDL_PIXELFORMAT_RGBA8888 SDL_TEXTUREACCESS_TARGET WINDOW_WIDTH WINDOW_HEIGHT SDL_CreateTexture fx-tex !




    : create-rect ( h w y x ) create , , , , ;

    12 12 8 0  create-rect char-rect
    12 12 20 20  create-rect targ-rect

    50 WIDTH 12 * 0 0 create-rect h-bar-rect
    HEIGHT 12 * 50 0 0 create-rect v-bar-rect

    100 100 100 100  create-rect fx-rect
    12 12 0 10  create-rect matrix-rect
    100 100 150 150  create-rect fx-rect2


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
                DUP         0 SWAP !   \ srcrect->x = 0
                CELL+ DUP   0 SWAP !   \ srcrect->y = 0
                CELL+ DUP   C SWAP !   \ srcrect->w = 12
                CELL+ DUP   C SWAP !   \ srcrect->h = 12
                
                CELL+ DUP   I C * SWAP !   \ dstrect->x = x * 12
                CELL+ DUP   J C * SWAP !   \ dstrect->y = y << 4  ( * 16 )
                CELL+ DUP   C SWAP !   \ dstrect->w = 12
                CELL+ DUP   C SWAP !   \ dstrect->h = 12
                
                CELL+ DUP   0 SWAP !  \ foreground r = 24
                CELL+ DUP   f0 SWAP !  \ foreground g = 24
                CELL+ DUP   0 SWAP !  \ foreground b = 24
                CELL+ DUP   1  SWAP !  \ unused alpha (temp: dtermines if needs rendering)

                CELL+ DUP   0 SWAP !  \ background r = 0
                CELL+ DUP   10 SWAP !  \ background g = 224
                CELL+ DUP   0 SWAP !  \ background  b = 0
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
        \ renderer @ SDL_RenderPresent 
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

    : set-char-c ( x y c ) 
        locals| c y x |

        x %ConsoleBufferCell @ * 
        y %ConsoleBufferCell @ * WIDTH * + 
        ConsoleBuffer +
        DUP %ConsoleBufferCell->ForegroundA 1 SWAP !
        %ConsoleBufferCell->SourceRect DUP 
        c 16 MOD 12 * SWAP !
        c 16 / 12 * SWAP CELL+ !

        
    ;


    \ fx test

    variable blend 
    variable blend-step 
    variable blend-dir
    0 blend-step !
    0 blend-dir !
    0 blend !
    : blend-frame
        blend-step @ 64 = IF
            0 blend-step !
            blend @ 128 = blend @ 0= OR IF 
                blend-dir @ 1 = IF
                    -1 blend-dir !
                ELSE 
                    1 blend-dir !
                THEN                                   
            THEN
            blend-dir @ blend +!
            \ blend @ .
        THEN
        renderer @  SDL_BLENDMODE_BLEND SDL_SetRenderDrawBlendMode THROW
        fx-tex @ SDL_BLENDMODE_BLEND SDL_SetTextureBlendMode
        renderer @ fx-tex @ SDL_SetRenderTarget THROW
        renderer @ 0 0 0 blend @ SDL_SetRenderDrawColor THROW
        renderer @ SDL_RenderClear THROW

        blend-dir fx-rect  CELL+ CELL+ +!

        renderer @ 128 100 32 blend @ SDL_SetRenderDrawColor THROW
        renderer @ fx-rect SDL_RenderFillRect THROW

        renderer @ 32 100 128 blend @ SDL_SetRenderDrawColor THROW
        renderer @ fx-rect2 SDL_RenderFillRect THROW
        
        renderer @ 0 SDL_SetRenderTarget THROW
        renderer @ fx-tex @ fx-rect fx-rect SDL_RenderCopy THROW
        renderer @ fx-tex @ fx-rect2 fx-rect2 SDL_RenderCopy THROW
        1 blend-step +!
        \ renderer @ SDL_RenderPresent
    ;

    \ let's build a Matrix style animation where we will have a list 
    \ of "head" points that travel down the console.  
    \ they will have the affect of alpha blending themselves and then 
    \ a trail behind them in diminshing intensity.  the head will move
    \ down the screen at a pace determined randomly at creation time.
    \ based on the current stength each cell also has a chance to change
    \ the character at the location. 

    \ start with the most basic implementation which is a single char with
    \ no trail moving down the screen every x frames. 

    struct MatrixTrail 
        MatrixTrail svar MatrixTrail.X  \ character x pos
        MatrixTrail svar MatrixTrail.Y  \ character y pos
        MatrixTrail svar MatrixTrail.Counter  \ animation tracker
        MatrixTrail svar MatrixTrail.Speed    \ frames between movement (higher is slower)

    CREATE matrix-test 10 , 0 , 0 , 200 ,

    variable matrix-ra 
    MatrixTrail @ 25 ra-new matrix-ra !


    : in-console-bounds-y ( y -- flag ) 
        DUP 0 >= SWAP HEIGHT < AND ;

    : in-console-bounds-x ( x -- flag ) 
        DUP 0 >= SWAP WIDTH < AND ;

    : in-console-bounds ( x y -- flag ) 
        in-console-bounds-y SWAP
        in-console-bounds-x AND ;



    variable v-bar-x
    20 v-bar-x !
    variable v-bar-count
    0 v-bar-count !
    variable v-bar-speed
    2 v-bar-speed !
    variable v-bar-dir
    -1 v-bar-dir !


    : draw-v-bar 
        \ assume renderer setup already
        \ draw one larger dimmer rect across whole console
        \ and a thinner, more opaque one inside it
        \ fx-tex @ SDL_BLENDMODE_ADD SDL_SetTextureBlendMode THROW
        
        v-bar-x @ v-bar-rect !  \ set rect x
        50 v-bar-rect 2 CELLS + !      \ set width
        
        renderer @  200 200 200 128 SDL_SetRenderDrawColor THROW
        renderer @  v-bar-rect SDL_RenderFillRect THROW
        
        v-bar-x @ 10 + v-bar-rect !  \ set rect y
        30 v-bar-rect 2 CELLS + !      \ set width
        
        renderer @  200 200 200 150 SDL_SetRenderDrawColor THROW
        renderer @  v-bar-rect SDL_RenderFillRect THROW
        
        v-bar-x @ 20 + v-bar-rect !  \ set rect y
        10 v-bar-rect 2 CELLS + !      \ set width
        
        renderer @  200 200 200 255 SDL_SetRenderDrawColor THROW
        renderer @  v-bar-rect SDL_RenderFillRect THROW
        
        
    ;

    : flip-v-bar-dir 
        [ HEX ] 
        v-bar-dir @ FFFFFFFF XOR 1 + 
        v-bar-dir ! 
        [ DECIMAL ] ;

    : move-v-bar 
        v-bar-x @ v-bar-dir @ + 
        DUP 12 / in-console-bounds-x IF
            v-bar-x !
        ELSE        
            flip-v-bar-dir
        THEN ;

    : update-v-bar 
        1 v-bar-count +!
        v-bar-count @ v-bar-speed @ = IF
            0 v-bar-count !
            move-v-bar 
        THEN
    ;


    variable h-bar-y
    20 h-bar-y !
    variable h-bar-count
    0 h-bar-count !
    variable h-bar-speed
    5 h-bar-speed !
    variable h-bar-dir
    -1 h-bar-dir !


    : draw-h-bar 
        \ assume renderer setup already
        \ draw one larger dimmer rect across whole console
        \ and a thinner, more opaque one inside it
        fx-tex @ SDL_BLENDMODE_MOD SDL_SetTextureBlendMode THROW
        
        h-bar-y @ h-bar-rect CELL+ !  \ set rect y
        50 h-bar-rect 3 CELLS + !      \ set height
        
        renderer @  200 200 200 100 SDL_SetRenderDrawColor THROW
        renderer @  h-bar-rect SDL_RenderFillRect THROW
        
        h-bar-y @ 10 + h-bar-rect CELL+ !  \ set rect y
        30 h-bar-rect 3 CELLS + !      \ set height
        
        renderer @  200 200 200 150 SDL_SetRenderDrawColor THROW
        renderer @  h-bar-rect SDL_RenderFillRect THROW
        
        h-bar-y @ 20 + h-bar-rect CELL+ !  \ set rect y
        10 h-bar-rect 3 CELLS + !      \ set height
        
        renderer @  200 200 200 255 SDL_SetRenderDrawColor THROW
        renderer @  h-bar-rect SDL_RenderFillRect THROW
        
        
    ;

    : flip-h-bar-dir 
        [ HEX ] 
        h-bar-dir @ FFFFFFFF XOR 1 + 
        h-bar-dir ! 
        [ DECIMAL ] ;

    : move-h-bar 
        h-bar-y @ h-bar-dir @ + 
        DUP 12 / in-console-bounds-y IF
            h-bar-y !
        ELSE        
            flip-h-bar-dir
        THEN ;

    : update-h-bar 
        1 h-bar-count +!
        h-bar-count @ h-bar-speed @ = IF
            0 h-bar-count !
            move-h-bar 
        THEN
    ;

    : init-matrix 
        45 0 DO  
            WIDTH RND matrix-test MatrixTrail.X !
            255 RND matrix-test MatrixTrail.Speed !
            matrix-test matrix-ra @ ra-append* DROP
        LOOP
    ;
    : matrix-draw-single ( x y intensity -- ) 
        >R
        12 * matrix-rect SDL_RECT.Y !
        12 * matrix-rect SDL_RECT.X !
        renderer @  0 128 20 R> SDL_SetRenderDrawColor THROW
        renderer @  matrix-rect SDL_RenderFillRect THROW
    ;

    : matrix-draw ( matrix* -- ) 
        \ render target and blend already set.
        \ draw rect with full intensity
        DUP DUP MatrixTrail.X @ SWAP MatrixTrail.Y @ 255 matrix-draw-single
        10 0 DO
            DUP DUP MatrixTrail.X @ SWAP MatrixTrail.Y @ 1 I + - 255 I 10 * - matrix-draw-single
        LOOP
        DROP
    ;    

    : matrix-draw-all ( -- )    
        renderer @ SDL_BLENDMODE_BLEND SDL_SetRenderDrawBlendMode THROW
        fx-tex @ SDL_BLENDMODE_ADD SDL_SetTextureBlendMode THROW
        renderer @ fx-tex @ SDL_SetRenderTarget THROW
        renderer @ 0 0 0 0 SDL_SetRenderDrawColor THROW
        renderer @ SDL_RenderClear THROW

        matrix-ra @ ra.data @
        matrix-ra @ ra.Length @ 0 DO
            DUP matrix-draw  
            MatrixTrail @ + 
        LOOP
        DROP

        
        draw-v-bar
        
        draw-h-bar 

        renderer @ 0 SDL_SetRenderTarget THROW
        renderer @ fx-tex @ 0 0 SDL_RenderCopy THROW
    ;

    : matrix-update-counter ( matrix* -- )
        DUP DUP MatrixTrail.Counter @ SWAP
        MatrixTrail.Speed @ >= IF 
            DUP MatrixTrail.Counter 0 SWAP ! 
            MatrixTrail.Y 1 SWAP +! 
        ELSE        
            MatrixTrail.Counter 1 SWAP +!
        THEN
    ;

    : matrix-update ( matrix* -- ) 
        DUP DUP MatrixTrail.X @ SWAP
        MatrixTrail.Y @ in-console-bounds IF
            1000 RND 980 > IF             
                DUP DUP MatrixTrail.X @ SWAP MatrixTrail.Y @ 128 RND set-char-c
            THEN
            matrix-update-counter        
        ELSE \ remove from ra? not yet supported ;)
            DUP MatrixTrail.Y 0 SWAP !
            MatrixTrail.X WIDTH RND SWAP !
        THEN
    ;    


    : matrix-update-all ( -- )    
        matrix-ra @ ra.data @
        matrix-ra @ ra.Length @ 0 DO
            DUP matrix-update
            MatrixTrail @ + 
        LOOP
        DROP
    ;



    : flush renderer @ SDL_RenderPresent ;


    \ \ fx-tex @ SDL_BLENDMODE_BLEND SDL_SetTextureBlendMode
    \ fx-tex @ SDL_BLENDMODE_ADD SDL_SetTextureBlendMode

    \ renderer @ fx-tex @ SDL_SetRenderTarget THROW
    \ renderer @ 128 64 128 247 SDL_SetRenderDrawColor THROW
    \ renderer @ fx-rect SDL_RenderFillRect THROW
    \ renderer @ 0 SDL_SetRenderTarget THROW

    \ \ renderer @ 0 0 0 0 SDL_SetRenderDrawColor THROW
    \ \ renderer @ SDL_RenderClear DROP
    \ renderer @ fx-tex @ fx-rect fx-rect SDL_RenderCopy THROW

    \ renderer @ SDL_RenderPresent 


    \ \ console tex test 
    \ renderer @ console-tex @ SDL_SetRenderTarget 

    \ renderer @ 255 0 0 0 SDL_SetRenderDrawColor THROW
    \ renderer @ SDL_RenderClear DROP
    \ renderer @ SDL_RenderPresent 
    \ renderer @ console-tex @ 0 0 SDL_RenderCopy
    \ renderer @ 0 SDL_SetRenderTarget 
    \ renderer @ SDL_RenderPresent 


    \ 255 255 255  255 255 255  0 0 1 set-char2 render-console 

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


    : FPS_Calc 
        1 fps_frames +!

        fps_lasttime @ SDL_GetTicks 1000 - < IF
            SDL_GetTicks fps_lasttime !
            fps_frames @ fps_current !
            0 fps_frames !
            fps_current @ .        
        THEN

        \ 10 SDL_Delay

        \ 50 0 DO
        \     256 RND 256 RND 256 RND
        \     256 RND 256 RND 256 RND
        \     WIDTH RND HEIGHT RND 128 RND set-char2
        \ LOOP

        render-console
        \ blend-frame
        \ matrix-test matrix-update
        matrix-update-all
        update-h-bar
        update-v-bar
        matrix-draw-all
        renderer @ SDL_RenderPresent
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


    console-init
    init-matrix
    start-pump  
-- SDL_Pump kill
-- empty