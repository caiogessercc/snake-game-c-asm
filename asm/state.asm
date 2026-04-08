; Este arquivo é responsável por armazenar e fornecer acesso ao estado global do jogo.
;
; - Toda a lógica do jogo (snake, comida, estado, score) fica em um bloco de memória contínuo
; - Esse bloco é compartilhado entre C e Assembly

; Definição do layout da memória
;
; Isso é basicamente um mapa da memória.
; Cada campo tem um offset fixo.
;
; position_t:
; - x (int16) -> 2 bytes
; - y (int16) -> 2 bytes
; Total = 4 bytes
;
; snake_body:
; - cada segmento ocupa 4 bytes
; - total de células = 32 * 24
; - então: 32 * 24 * 4 = 3072 bytes

%define SNAKE_BODY_SIZE        (32 * 24 * 4) ; 3072 bytes para o corpo da snake

; Começa logo após o snake_body
; Como o snake_body ocupa 3072 bytes, o próximo campo começa em 3072
%define OFFSET_SNAKE_LENGTH    (SNAKE_BODY_SIZE) ; 3072

; Cada campo abaixo ocupa 4 bytes (uint32)
; Por isso está tendo uma soma de +4

%define OFFSET_CUR_DIRECTION   (OFFSET_SNAKE_LENGTH + 4) ; 3076
%define OFFSET_NEXT_DIRECTION  (OFFSET_CUR_DIRECTION + 4) ; 3080
%define OFFSET_FOOD_POSITION   (OFFSET_NEXT_DIRECTION + 4) ; 3084
%define OFFSET_GAME_STATE      (OFFSET_FOOD_POSITION + 4) ; 3088
%define OFFSET_SCORE           (OFFSET_GAME_STATE + 4) ; 3092


; section .bss
;
; O que é .bss
; - É a área de memória para variáveis não inicializadas
; - Não ocupa espaço no arquivo final (executável)
; - Só reserva espaço na memória em tempo de execução-

section .bss

    global game_state_data

    ; align 8: garante que o endereço começa alinhado em múltiplos de 8 bytes
    align 8

    game_state_data:

        ; snake_body:
        ; resb = "reserve bytes"
        ;
        ; reserva um bloco contínuo de memória
        ; aqui: 3072 bytes
        ;
        ; cada segmento ocupa 4 bytes (int16 + int16)
        resb SNAKE_BODY_SIZE

        ; snake_length:
        ; resd = "reserve double word" (4 bytes)
        ;
        ; uint32_t em C corresponde a 4 bytes
        resd 1

        ; current_direction (também 4 bytes)
        resd 1

        ; next_direction
        resd 1

        ; food_position:
        ; resw = "reserve word" (2 bytes)
        ;
        ; é necessário 2 valores (x e y)
        ; então é usado 2 * 2 bytes = 4 bytes
        resw 2

        ; padding:
        ; espaço extra para manter alinhamento correto
        ;
        ; ajuda a garantir que os próximos dados fiquem alinhados em 4 bytes
        resw 1

        ; game_state
        resd 1

        ; score
        resd 1


; section .text
;
; O que é .text
; - Área onde ficam as instruções (código executável)
; - Tudo que é função fica aqui

section .text

    global game_get_state
    global game_get_game_state
    global game_is_over
    global game_get_score

; const game_state_data_t* game_get_state(void)
;
; Retorna o endereço da estrutura global
game_get_state:

    ; lea = Load Effective Address
    ; Não lê valor da memória, apenas pega o endereço
    ;
    ; rax = registrador de retorno (padrão em x86-64)
    ;
    ; [rel game_state_data]:
    ; - rel = endereço relativo ao código (usado em executáveis modernos)
    ; - [] indica acesso a endereço
    ;
    ; Resultado: rax recebe o endereço da estrutura inteira
    lea rax, [rel game_state_data]

    ; ret = retorna da função
    ret

; game_state_t game_get_game_state(void)
game_get_game_state:

    ; mov = move/copia valor
    ;
    ; eax = registrador de 32 bits
    ;
    ; [rel game_state_data + OFFSET_GAME_STATE]:
    ; - pega o endereço base
    ; - soma o offset (posição do campo)
    ; - lê o valor armazenado ali
    ;
    ; Ou seja, está acessando game_state dentro da struct
    mov eax, [rel game_state_data + OFFSET_GAME_STATE]

    ret

; bool game_is_over(void)
game_is_over:

    ; call = chama função
    ; resultado vem em eax
    call game_get_game_state

    ; cmp = compara dois valores
    ;
    ; aqui compara estado com 2 (GAME_OVER)
    cmp eax, 2

    ; sete = "set if equal"
    ;
    ; se comparação for igual:
    ;   al = 1
    ; senão:
    ;   al = 0
    sete al

    ; movzx = move com zero extend
    ;
    ; converte al (8 bits) para eax (32 bits) preenchendo com zeros
    movzx eax, al

    ret


; uint32_t game_get_score(void)
game_get_score:

    ; mesma lógica de acesso direto à memória
    ; pega valor no offset do score
    mov eax, [rel game_state_data + OFFSET_SCORE]

    ret