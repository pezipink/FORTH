include sdl


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
\ -- SDL_Pump kill
\ empty