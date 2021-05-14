\ some ideas for a game / sim type thing

: /allot  here over allot swap erase ;
\ struct creation
: sfield  ( struct bytes - <name> )  ( adr - adr+n )
    create over @ ,  swap +!  does> @ + ;
: svar cell sfield ;
: struct variable ;
: *struct  here swap @ /allot ;


\ GC

CREATE GC_MARKERS 0 , 512 /ALLOT 
CREATE GC_STACK 0 , 1024 /ALLOT
: GC_PUSH ( addr -- ) 
	GC_STACK DUP @ CELLS + CELL+ !
	1 GC_STACK +! ;
: GC_MARK ( -- ) \ add a new gc stack marker
	\ increase the marker count by one
	\ and save the current gc_stack count in the new slot
	GC_STACK @ 
	GC_MARKERS DUP @ CELLS + CELL+ !
	1 GC_MARKERS +!  ;
: GC_FREE ( -- )
	\ free everything from the current marker point upwards	
	GC_MARKERS DUP @ CELLS + @ \ current mark level count
	DUP 
	GC_STACK @ SWAP - \ amount to remove
	SWAP
	GC_STACK CELL+ \ base address
	SWAP CELLS +   \ start address	
	\ free everything here upwards
	OVER
	0 ?DO DUP .S @ FREE THROW CELL+ LOOP DROP
	\ now subtract the gc stack count by that amount
	GC_STACK @ SWAP - GC_STACK ! ;
: GALLOC ( n -- addr )
	ALLOCATE THROW
	GC_MARKERS @ 0<> IF DUP GC_PUSH THEN ;
: <! GC_MARK  ;
: !> GC_FREE
	 -1 GC_MARKERS +!  
	 GC_MARKERS @ 0< ABORT" GC_MARKER stack is negative!"
	 ;


\ ResizeArray.  Directly uses head alloc and works with GC
\   since the data is behind an indirect pointer. it can be updated
\   if realloc is called.
struct %RA
	%RA svar RA.Capacity
	%RA svar RA.Length
	%RA svar RA.ItemSize  ( in bytes )
	%RA svar RA.Data      ( pointer to data )

: ra-new ( item-size initial-capacity -- ra-addr )
	2DUP * -ROT
	%RA *struct
	TUCK RA.Capacity !
	TUCK RA.ItemSize !
	DUP ROT GALLOC 
	SWAP RA.Data !
	;

: ra[]* ( ra-addr n -- item-addr )
	locals| n addr |
	addr RA.Length @ n <= IF n . ABORT" index out of range!" THEN
	addr RA.ItemSize @
	n *
	addr RA.Data @ + ;

: ra[] ( ra-addr n )
	ra[]* @ ;

: ra-ensure-capacity ( ra-addr -- ra-addr ) 
	>R 
	R@ RA.Length @ R@ RA.Capacity @ = IF 
		R@ RA.Capacity @ DUP DUP 2 * DUP \ cap cap newcap newcap
		R@ RA.Capacity ! 				 \ cap cap newcap
		R> SWAP RESIZE THROW		     \ cap cap addr
		>R R@ + SWAP ERASE               \ zero latter half of (new) memory
	THEN
	R>
	;

: ra-next* ( ra-addr )
	\ get ptr to next avaialable item.  use ensure-capacity first.
	DUP DUP 
	RA.ItemSize @ SWAP RA.Length @ * 
	SWAP RA.Data @ + ;

: ra-append-val ( data ra-addr -- )
	\ only for literals / pointers of CELL size RAs	
	ra-ensure-capacity	
	>R R@	
	ra-next* !	
	R> RA.Length 1 SWAP +! ;

	
: ra-append* ( item* ra-addr - new-addr )
	\ copes ItemSize byets from item* into new location
	\ return pointer to new item (don't hold this since it might move)	
	ra-ensure-capacity     
	>R R@
	ra-next* TUCK           \ n-addr item* n-addr 
	R@ RA.ItemSize @        \ n-addr item* n-addr size
	MOVE                    \ n-addr
	R> RA.Length 1 SWAP +!  \ n-addr
	;


\ Loading files

struct %FI
   %FI svar FI.FID
   %FI svar FI.Size
   %FI svar FI.Data

: file->bytes create
  R/O OPEN-FILE THROW
  %FI *struct 
  locals| base fid |
  fid base !  
  base @ 
  file-size throw throw dup dup
  base FI.Size !
  allocate throw dup
  base FI.Data !
  \ read file is addr - n - fid
  swap fid
  READ-FILE THROW DROP 
  fid CLOSE-FILE THROW
   ;


cd c:\libtcod  
LIBRARY libtcod 
FUNCTION: TCOD_console_init_root ( w h title fullscreen renderer -- )
FUNCTION: TCOD_console_set_window_title ( title -- )
FUNCTION: TCOD_console_set_default_background ( con r g b -- )
FUNCTION: TCOD_console_set_default_foreground ( con r g b -- )
FUNCTION: TCOD_console_clear ( con -- )
FUNCTION: TCOD_console_flush ( -- )
FUNCTION: TCOD_console_set_char_background ( con x y r g b flag -- )
FUNCTION: TCOD_console_set_char_foreground ( con x y r g b -- )
FUNCTION: TCOD_console_set_char ( con x y c -- )

110 110 Z" TEST" 0 1 TCOD_console_init_root
z" HELLO WORLD" TCOD_console_set_window_title
0 64 10 0 TCOD_console_set_default_background
0 0 2 255 TCOD_console_set_default_foreground
0 TCOD_console_clear
TCOD_console_flush

: rgb ( r g b -- colour )
	16 LSHIFT
	SWAP 8 LSHIFT OR
	OR ;

: set-def-background ( colour -- )
	0 SWAP 0 0 TCOD_console_set_default_background ;

: set-def-foreground ( colour -- )
	0 SWAP 0 0 TCOD_console_set_default_foreground ;

: flush TCOD_console_flush ;
: clear 0 TCOD_console_clear ;
: clearf 0 TCOD_console_clear flush ;

186	CONSTANT	W_VWALL
185	CONSTANT	W_-|
187	CONSTANT	W_TR
188	CONSTANT	W_BR
200	CONSTANT	W_BL
201	CONSTANT	W_TL
202	CONSTANT	W__|_
203	CONSTANT	W_T
204	CONSTANT	W_|-
205	CONSTANT	W_HWALL
206	CONSTANT	W_+

struct %RECT
	%RECT svar RECT.X
	%RECT svar RECT.Y
	%RECT svar RECT.W
	%RECT svar RECT.H


\ return !(r1.Left > r2.Left + r2.Width) &&
 \      !(r1.Left + r1.Width < r2.Left) &&
 \      !(r1.Top > r2.Top + r2.Height) &&
 \      !(r1.Top + r1.Height < r2.Top);
\ : rect-intersect ( rect1* rect2* -- flag )
	\ todo: write this in assembler?
	\ todo: work out how to short circuit nicely
\	locals| rect1* rect2* |
\	rect1* RECT.X @ rect2* RECT.X @ rect2* RECT.W @ + >	
\ ;


: set ( x y c -- )
	locals| c y x |
	0 x y c TCOD_console_set_char
	;

: setf ( x y c -- )	set	flush ;



: draw-room ( x y w h -- )
	locals| h w y x |
	x y W_TL set
	x y h + W_BL set
	x w + y W_TR set
	x w + y h + W_BR set

	w 1 - 0 
	DO 
		x 1 + I + y W_HWALL set 
		x I 1 + + y h + W_HWALL set 
	LOOP

	h 1 - 0 
	DO 
		x y 1 I + + W_VWALL set 
		x w + y 1 I + +  W_VWALL set 
	LOOP
	;

\ 10 10 10 10 draw-room flush

VARIABLE (RND)
GetTickCount (rnd) ! \ seed

: rnd ( -- n )
(rnd) @ dup 13 lshift xor
dup 17 rshift xor
dup DUP 5 lshift xor (rnd) ! ;

\ lets try and gen a simple maze
\ we'll use a binary representation to store the walls that are linked
\ 0 0 0 0 N S E W  these bits are set to indicate the cells are linked
\ (as in, there's no wall) 
\ so we'll start off with 10 x 10 CELL sized ra
50 CONSTANT WIDTH
50 CONSTANT HEIGHT

\ link bits
HEX
1 CONSTANT WEST
2 CONSTANT EAST
4 CONSTANT SOUTH
8 CONSTANT NORTH
DECIMAL

: LINKED? ( dir val -- flag ) AND ;
: LINK ( dir val -- val ) OR ;

CELL WIDTH HEIGHT * ra-new CONSTANT map
: map-init ( -- )
	WIDTH HEIGHT * 0 DO 
		0 map ra-append-val
	LOOP
	;
: map[]* ( x y -- data )
	HEIGHT * + 
	map SWAP ra[]*
;
: map[] ( x y -- data )
	HEIGHT * + 
	map SWAP ra[]
;

: map[]! ( data x y -- )
	HEIGHT * + 
	map SWAP ra[]* !
;

: map[]!| ( data x y -- )
	HEIGHT * + 
	map SWAP ra[]* DUP -ROT @ OR SWAP !
;
	

: map-loop ( xt -- )
	locals| xt |
	HEIGHT 0 DO 
		WIDTH 0 DO
			I J xt EXECUTE
		LOOP
	LOOP
;

: map-loop-fast ( xt -- )
	locals| xt |
	map RA.Data @ CELL-
	HEIGHT 0 DO 
		WIDTH 0 DO
			CELL+ DUP I J xt EXECUTE
		LOOP		
	LOOP
	DROP

;


: loop-test ( x y ) 
 	. . ;

\ :noname . . ; map-loop

: :=> :noname ;

\  ' loop-test map-loop
\ :=> . . ;map-loop


: map-clear  ( -- )	
	HEIGHT 0 DO 
		WIDTH 0 DO
			0 I J map[]!
		LOOP
	LOOP
;

: map-clear-fast  ( -- )
	map RA.Data @
	WIDTH HEIGHT * 1 - 0 DO
		CELL+ DUP 0 SWAP !
	LOOP DROP
;

: calc-neighbours ( x y -- bitflag )
	locals| y x |
	\ 3S and 3E we can get from this location
	x y map[]
	\ south is 3rd bit
	DUP  2 RSHIFT  1 AND
	SWAP
	\ east is 2nd bit
	1 RSHIFT 1 AND  1 LSHIFT  OR
	\ to get 4 S we need to go +1 x and get its south bit
	x 1 + y map[]
	2 RSHIFT  1 AND  2 LSHIFT  OR
	\ to get 5 E we need to go +1 y and get its west bit
	x y 1 + map[]
	1 RSHIFT 1 AND  3 LSHIFT  OR
;

: bounds-check ( x y ) \ returns 10 if x is max, 01 if y is max or both
	HEIGHT 1 - = 1 AND SWAP
	WIDTH 1 -  = 1 AND 1 LSHIFT OR ;

: draw-map
	\ draw one row of walls
	HEIGHT 0  DO
		WIDTH 0 DO
			I J map[] EAST LINKED? 0= IF 
			 	I 2 * 2 +  J 2 * 1 +  W_VWALL set
			THEN
			I J map[] SOUTH LINKED? 0= IF 
			 	I 2 * 1 +  J 2 * 2 +  W_HWALL set
			THEN
					
			I 2 * 2 +  J 2 * 2 +						
			I J bounds-check
			0= IF			
				I J calc-neighbours
				CASE
					1 OF W_|-     ENDOF
					2 OF W_T      ENDOF
					3 OF W_TL     ENDOF
					4 OF W_-|     ENDOF
					5 OF W_VWALL  ENDOF
					6 OF W_TR 	  ENDOF
					8 OF W__|_ 	  ENDOF
					9 OF W_BL 	  ENDOF					
					10 OF W_HWALL ENDOF
					12 OF W_BR 	  ENDOF
					[CHAR] # SWAP
				ENDCASE				
			ELSE
				[CHAR] #  
			THEN
			SET
		LOOP
	LOOP
	0 0 WIDTH 2 * HEIGHT 2 * draw-room
	flush
;

: link-south ( x y )
	2DUP SOUTH -ROT map[]!|
	1 + NORTH -ROT map[]!| ;

: link-east ( x y )
	2DUP EAST -ROT map[]!|
	SWAP 1 + SWAP WEST -ROT map[]!| ;

: bounds-check ( x y ) \ returns 10 if x is max, 01 if y is max or both
	HEIGHT 1 - = 1 AND SWAP
	WIDTH 1 -  = 1 AND 1 LSHIFT OR ;

: binary-tree ( x y -- )
	locals| y x |
	x y bounds-check

	CASE
		0 OF 
			rnd 1 AND IF 
				x y link-east
			ELSE
				x y link-south
			THEN
		ENDOF 
		1 OF 
			\ max y 			
			x y link-east
		ENDOF
		2 OF 
			\ max x, link south
			x y link-south
		ENDOF			
		3 OF 
		ENDOF

	ENDCASE
;

: link-south-fast ( addr - )	
	DUP DUP @ SOUTH OR SWAP !
	HEIGHT CELLS + DUP @ NORTH OR SWAP ! ;

: link-east-fast ( addr )
	DUP DUP @ EAST OR SWAP !
	CELL+ DUP @ WEST OR SWAP ! ;


: binary-tree-fast ( addr x y -- )

	locals| y x addr |
	x y bounds-check

	CASE
		0 OF 
			rnd 1 AND IF 
				addr link-east-fast
			ELSE
				addr link-south-fast
			THEN
		ENDOF 
		1 OF 
			\ max y 			
			addr link-east-fast
		ENDOF
		2 OF 
			\ max x, link south
			addr link-south-fast
		ENDOF			
		3 OF 
		ENDOF

	ENDCASE
;


: tlf
	map-clear ['] binary-tree-fast map-loop-fast clearf draw-map ;

: tloop 
	GetTickCount
	5000 0 DO map-clear ['] binary-tree map-loop  LOOP 
	GetTickCount - . draw-map ;

: tloopb
	GetTickCount
	5000 0 DO map-clear-fast ['] binary-tree map-loop  LOOP 
	GetTickCount - . draw-map ;

: tloop-fast
	GetTickCount
	5000 0 DO map-clear-fast ['] binary-tree-fast map-loop-fast  LOOP 
	GetTickCount - . draw-map ;

: tloop2 
	GetTickCount
	5000 0 DO ['] binary-tree map-loop  LOOP 
	GetTickCount - . draw-map ;

: tloop3 
	GetTickCount
	5000 0 DO map-clear   LOOP 
	GetTickCount - . draw-map ;

: tloop3b 
	GetTickCount
	5000 0 DO map-clear-fast   LOOP 
	GetTickCount - . draw-map ;

\ draw-map-grid

 : draw-alpha 
 	255 0 DO 0 I 16 MOD I 16 / I TCOD_console_set_char  LOOP ;

\ 10 10 10 10 char @ draw-rect TCOD_console_flush
\ 10 10 10 10 char # draw-rect2 TCOD_console_flush

\ 0 10 10 CHAR % TCOD_console_set_char TCOD_console_flush

\  