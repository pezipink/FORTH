cd c:\repos\forth\ 

include zmq
include struct
include ds
include common

struct ClientData
    ClientData svar ClientData.ID           \ char *
    ClientData svar ClientData.heartbeat    \ from gettickcount


variable clients                            \ connected clients
ClientData sizeof 8 ra-new clients !            


CREATE msg_id 64 /ALLOT   
CREATE msg_payload 64 /ALLOT   
CREATE msg_type 64 /ALLOT   
CREATE msg_id_out 64 /ALLOT   
CREATE msg_payload_out 64 /ALLOT   
CREATE msg_type_out 64 /ALLOT   


variable ctx 
zmq_ctx_new ctx ! 

VALUE sock 

\ SERVER 

ctx @ ZMQ_ROUTER zmq_socket TO sock 
sock Z" tcp://*:5561" zmq_bind THROW

hex
    23E8 TASK Server
decimal

CREATE client-temp 0 , 0 ,

: cstr-full-size ( cstr* -- n+1 ) C@ 1 + ;

: cstr-new ( size -- cstr* ) 
    DUP 1 +      \ extra byte to hold size
    GALLOC       \ return address
    SWAP OVER !  \ set size
    \ return address
;

: cstr-concat ( cstr1* cstr2* -- cstr3* )
    SWAP 2DUP COUNT NIP SWAP COUNT NIP +  \ full amount of chars, not including size itself
    cstr-new >R        \ c2 c2 
    COUNT R@ 1 + SWAP  \ c2 c1d mem u ( skip past first len byte)
    2DUP + >R          \ store new pointer + len
    MOVE               \ c2
    COUNT R> SWAP      \ c2d mem u 
    MOVE
    R>                 \ original cstr ptr
;

: set-msg-type-out ( msg-type -- )
    msg_type_out CELL zmq_msg_init_size THROW
    msg_type_out zmq_msg_data !
;

: set-msg-cstr-out ( msg* cstr* -- )
    2DUP cstr-full-size >R
    R@ zmq_msg_init_size THROW
    SWAP zmq_msg_data R> MOVE
;

: set-msg-id-out ( cstr-id* -- )
    msg_id_out SWAP set-msg-cstr-out    
;

: set-msg-payload-out ( cstr-pl* -- )
    msg_payload_out SWAP set-msg-cstr-out
;

: send-payload ( -- )
    msg_id_out sock ZMQ_SNDMORE zmq_msg_send DROP  \ todo: -1 throw 
    msg_type_out sock ZMQ_SNDMORE zmq_msg_send DROP
    msg_payload_out sock 0 zmq_msg_send DROP
;

: find-client ( id* -- client*|0 )        \ TODO: generalise this into ds.f ra words ?
    clients @ RA.Data @ 
    clients @ RA.Length @ 0 ?DO  
        2DUP       
        @ COUNT ROT COUNT COMPARE 0= IF
            NIP UNLOOP EXIT
        THEN        
        clients @ RA.ItemSize @ + 
    LOOP
    2DROP 0    
;

: send-all-clients ( cstr-pl* -- )
    clients @ RA.Data @ 
    clients @ RA.Length @ 0 ?DO  
        \ payload* current*
        2DUP
        @ set-msg-id-out \ current* is client id         
        set-msg-payload-out
        MSG-SAY set-msg-type-out
        send-payload
        clients @ RA.ItemSize @ +
    LOOP
    2DROP
 ;

: announce-welcome 
     <!
        msg_id zmq_msg_data C"  has entered the chat " cstr-concat
        send-all-clients
    !>
;

: client-connect 
    msg_id zmq_msg_data DUP find-client DUP 0= IF DROP
        msg_id zmq_msg_size
        DUP ALLOCATE DROP DUP client-temp ! \ set client id
        SWAP MOVE    
        GetTickCount client-temp CELL+ !    \ hb
        client-temp clients @ ra-append* DROP
        client-temp @ COUNT TYPE ."  connected" CR
        announce-welcome
    ELSE
        \ update heartbeat
        ClientData.heartbeat GetTickCount SWAP !
        client-temp @ COUNT TYPE ."  reconnected" CR
        DROP
    THEN
;

: client-heartbeat
    \ copy the id and hb messages and send them back to the client
    msg_id zmq_msg_data find-client DUP IF 
        ClientData.heartbeat GetTickCount SWAP !
        \ init messages
        msg_id_out zmq_msg_init THROW
        msg_type_out zmq_msg_init THROW
        \ copy messages
        msg_id_out msg_id zmq_msg_copy THROW
        msg_type_out msg_type zmq_msg_copy THROW
        \ send 
        msg_id_out sock ZMQ_SNDMORE zmq_msg_send DROP  \ todo: -1 throw 
        msg_type_out sock 0 zmq_msg_send DROP
    ELSE DROP
        ." hb from unknown client "
    THEN

;

: client-say 
    msg_id zmq_msg_data find-client IF 
        <!
            msg_id zmq_msg_data C" : " cstr-concat
            msg_payload zmq_msg_data cstr-concat
            send-all-clients
        !>
    ELSE 
        ." say from unknown client "
    THEN
;

: dispatch-message 
    msg_type zmq_msg_size 4 = IF
        msg_type zmq_msg_data @
        CASE
            MSG-CONNECT OF client-connect ENDOF
            MSG-HEARTBEAT OF client-heartbeat ENDOF
            MSG-SAY OF client-say ENDOF
            ." received unknown msg_type "
        ENDCASE 
    ELSE
        ." received malformed or unknown msg_type "
    THEN ;

: read-message
    \ we have the id message already populated, now we can read further messages.
    \ we expect at least one more message (type) then maybe another (payload).  
    \ otherwise, eat messages until no more - bad data
    msg_type zmq_msg_init THROW
    msg_payload zmq_msg_init THROW
    msg_id zmq_msg_more IF
        msg_type sock 0 zmq_msg_recv DROP
    THEN
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

    msg_id zmq_msg_close THROW
    msg_type zmq_msg_close THROW
    msg_payload zmq_msg_close THROW
;

: start-server 
    Server ACTIVATE
    msg_id zmq_msg_init THROW     \ TODO work out exactly what cases we need to close this?
BEGIN
    \ we expect the first mesage to be the socket id    
    msg_id sock ZMQ_DONTWAIT zmq_msg_recv -1 <> IF        
        \ ." GOT MSG SIZE " . msg_id COUNT TYPE \ DROP \ id size - we should have this as a forth string in the msg buffer anyway
        \ CR        
        read-message
        msg_id zmq_msg_init THROW 
    THEN
    PAUSE
AGAIN

;


 \ msg_id zmq_msg_init THROW msg_id sock @ 0 zmq_msg_recv