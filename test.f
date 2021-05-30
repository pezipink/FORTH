cd c:\repos\forth
include ds.f

4 10 ra-new VALUE array

10 array ra-append-val
20 array ra-append-val
30 array ra-append-val

: print-vals 
    array RA.Data @ 
    array RA.Length @ 0 ?DO  
        DUP @ .
        array RA.ItemSize @ +
    LOOP
    DROP
;

: fet ( ra-addr -- )
    DUP RA.ItemSize @ SWAP
    DUP RA.Data @ SWAP
    RA.Length @ 0  ?DO
        DUP @ .
        OVER + 
    LOOP
;




: foreach-preamble 
    DUP RA.ItemSize @ SWAP
    DUP RA.Data @ SWAP
    RA.Length  @   0  ;


: foreach ( ra-addr -- ) 
       POSTPONE foreach-preamble
       POSTPONE ?DO
       POSTPONE DUP
;  IMMEDIATE

: next ( -- )
    POSTPONE OVER POSTPONE +
    POSTPONE LOOP    
    POSTPONE 2DROP 
;  IMMEDIATE

: test 
    array foreach
        @ .
    next
;


: DO2 ( -- flag addr)
   POSTPONE (DO) 0  (BEGIN) ;  IMMEDIATE

: LOOP2 ( flag addr | addr1 flag addr2 -- )
   POSTPONE (LOOP)  DUP <RESOLVE POSTPONE UNLOOP >LEAVES
   IF  POSTPONE THEN  THEN ;  IMMEDIATE

: xx 10 0 DO2 LOOP2 ;

