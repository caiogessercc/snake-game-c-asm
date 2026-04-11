; Tipos de colisão:
; - Colisão com parede (fora do grid)
; - Colisão com o próprio corpo da snake
;
; Se alguma colisão ocorrer:
; - o estado do jogo é alterado para GAME_OVER

extern game_state_data

section .text

    global collision_check

; void collision_check(void)
;
; 1. Lê posição da cabeça
; 2. Verifica colisão com paredes
; 3. Verifica colisão com o próprio corpo
; 4. Se houver colisão -> GAME_OVER
collision_check:

    ; carrega o endereço da struct game_state_data em rsi
    lea rsi, [rel game_state_data]

    ; Offsets importantes da estrutura:
    ;
    ; snake_body começa no offset 0
    ; snake_length está em 3072
    ; game_state está em 3096
    ;
    ; Esses valores vêm do layout definido no state.asm

    ; Carregar posição da cabeça
    ;
    ; Cada posição usa int16:
    ; - 2 bytes para x
    ; - 2 bytes para y
    ;
    ; movsx:
    ; move com extensão de sinal
    ; converte 16 bits -> 32 bits mantendo sinal

    ; head.x (offset 0)
    movsx eax, word [rsi + 0]

    ; head.y (offset 2)
    movsx edx, word [rsi + 2]

    ; Colisão com paredes
    ;
    ; Verificado:
    ; - se x é menor que 0
    ; - se x é maior ou igual a largura
    ; - se y é menor que 0
    ; - se y é maior ou igual a altura
    ;
    ; test:
    ; faz uma operação AND com ele mesmo
    ; No contexto atual, é usado para verificar se o valor é negativo

    ; verifica se x < 0
    test eax, eax
    ; jl = jump if less (menor que zero)
    jl .game_over

    ; verifica se x >= 32 (largura do grid)
    cmp eax, 32
    ; jge = jump if greater or equal
    jge .game_over

    ; verifica se y < 0
    test edx, edx
    jl .game_over

    ; verifica se y >= 24 (altura do grid)
    cmp edx, 24
    jge .game_over

    ; Colisão com o próprio corpo
    ;
    ; Percorre todos os segmentos da snake
    ; comparando com a cabeça

    ; carregar tamanho da snake (uint32)
    mov ecx, [rsi + 3072]

    ; se tamanho <= 1, não há corpo para colidir
    cmp ecx, 1
    jle .no_collision


    ; rdi aponta para snake_body
    lea rdi, [rsi]

    ; r8d será usado como índice (i = 1)
    ;
    ; começa do 1 porque o índice 0 é a cabeça
    ; não faz sentido comparar com ela mesma
    mov r8d, 1

.self_collision_loop:

    ; calcular offset do segmento atual
    ;
    ; cada segmento ocupa 4 bytes (int16 x + int16 y)
    lea r9, [r8*4]

    ; carregar x do segmento
    movsx r10d, word [rdi + r9]

    ; carregar y do segmento
    movsx r11d, word [rdi + r9 + 2]

    ; comparar x com head.x
    cmp r10d, eax
    jne .next

    ; comparar y com head.y
    cmp r11d, edx
    jne .next

    ; se x e y forem iguais -> colisão é detectada
    jmp .game_over

.next:

    ; i++
    inc r8d

    ; cmp compara índice com tamanho
    cmp r8d, ecx

    ; jl = jump if less
    ; continua enquanto i < length
    jl .self_collision_loop

.no_collision:
    ret

; Define o estado do jogo como GAME_OVER
;
; No constants.h está como GAME_STATE_GAME_OVER = 2
.game_over:

    ; mov dword:
    ; escreve 4 bytes (uint32)
    ;
    ; offset 3096 = game_state
    mov dword [rsi + 3096], 2

    ret