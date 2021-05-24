cd c:\repos\forth\ 

include zmq
include struct
include ds
include common

CREATE msg_type 64 /ALLOT   
CREATE msg_type_out 64 /ALLOT   
CREATE msg_payload 64 /ALLOT   
CREATE msg_payload_out 64 /ALLOT   
CREATE buffer 64 /ALLOT   
variable ctx 
zmq_ctx_new ctx ! 

VALUE sock 

hex
    23E8 TASK Agent
decimal


CREATE identity ," JUAN"
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
    ." GOT HB " CR
;


: server-say 
    ." GOT SAY " CR
    msg_payload zmq_msg_data COUNT TYPE
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
            ." GOT MSG SIZE " , 
            CR        
            read-message
            msg_type zmq_msg_init THROW 
        THEN
        PAUSE
    AGAIN
;

\ sock @ test-msg test-msg count nip 1 + 0 zmq_send

