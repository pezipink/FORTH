
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

struct SDL_TextEditingEvent 
    SDL_TextEditingEvent SDL_CommonEvent sembed SDL_KeyboardEvent>SDL_CommonEvent
    SDL_TextEditingEvent svar SDL_TextEditingEvent.windowId
    SDL_TextEditingEvent 32 sfield SDL_TextEditingEvent.text
    SDL_TextEditingEvent svar SDL_TextEditingEvent.start
    SDL_TextEditingEvent svar SDL_TextEditingEvent.length

struct SDL_TextInputEvent 
    SDL_TextInputEvent SDL_CommonEvent sembed SDL_KeyboardEvent>SDL_CommonEvent
    SDL_TextInputEvent svar SDL_TextInputEvent.windowId
    SDL_TextInputEvent 32 sfield SDL_TextInputEvent.text

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
302 CONSTANT SDL_TEXTEDITING
303 CONSTANT SDL_TEXTINPUT

400 CONSTANT SDL_MOUSEMOTION     \ mouse moved
401 CONSTANT SDL_MOUSEBUTTONDOWN 
402 CONSTANT SDL_MOUSEBUTTONUP
403 CONSTANT SDL_MOUSEWHEEL      

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

\ KEYMOD patterns

0000 CONSTANT KMOD_NONE
0001 CONSTANT KMOD_LSHIFT
0002 CONSTANT KMOD_RSHIFT
0040 CONSTANT KMOD_LCTRL
0080 CONSTANT KMOD_RCTRL
0100 CONSTANT KMOD_LALT
0200 CONSTANT KMOD_RALT
0400 CONSTANT KMOD_LGUI
0800 CONSTANT KMOD_RGUI
1000 CONSTANT KMOD_NUM
2000 CONSTANT KMOD_CAPS
4000 CONSTANT KMOD_MODE
8000 CONSTANT KMOD_RESERVED

KMOD_LCTRL KMOD_RCTRL OR CONSTANT KMOD_CTRL
KMOD_LSHIFT KMOD_RSHIFT OR CONSTANT KMOD_SHIFT
KMOD_LALT KMOD_RALT OR CONSTANT KMOD_ALT
KMOD_LGUI KMOD_RGUI OR CONSTANT KMOD_GUI

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

FUNCTION: SDL_GetModState ( -- state )

FUNCTION: SDL_StartTextInput ( -- )  \ uses focused sdl window
FUNCTION: SDL_StopTextInput ( -- )

LIBRARY SDL2_Image
FUNCTION: IMG_Load ( file* -- surface* )



HEX
: rgba ( r g b a ) 
    18 LSHIFT SWAP
    10 LSHIFT OR SWAP
    8 LSHIFT OR OR 
;

: create-rect ( h w y x ) create , , , , ;

DECIMAL

