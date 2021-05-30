 
: /allot  here over allot swap erase ;
\ struct creation
: sfield  ( struct bytes - <name> )  ( adr - adr+n )
    create over @ ,  swap +!  does> @ + ;
: svar cell sfield ;
: struct variable ;
: *struct  here swap @ /allot ;
: sizeof @ ;


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
	0 ?DO DUP @ FREE THROW CELL+ LOOP DROP
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


: foreach-preamble 
    DUP RA.ItemSize @ SWAP
    DUP RA.Data @ SWAP
    RA.Length @ 0 ;

\ foreach ... next , over an RA, leaves the current pointer on the stack
: foreach ( ra-addr -- ) POSTPONE foreach-preamble POSTPONE ?DO POSTPONE DUP ; IMMEDIATE
: next ( -- ) POSTPONE OVER POSTPONE + POSTPONE LOOP POSTPONE 2DROP ;  IMMEDIATE

