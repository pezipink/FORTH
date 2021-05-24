CELL 2 / CONSTANT HCELL
: /allot  here over allot swap erase ;
\ struct creation
: sfield  ( struct bytes - <name> )  ( adr - adr+n )
    create over @ ,  swap +!  does> @ + ;
: svar cell sfield ;
: struct variable ;
: *struct  here swap @ /allot ;
: sembed  @ sfield ;
: sizeof  @  ;

