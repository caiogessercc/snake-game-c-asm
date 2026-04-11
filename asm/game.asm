extern game_state_data
extern snake_update
extern collision_check
extern food_spawn
extern food_check

section .text

    global game_init
    global game_update
    global game_set_input

; void game_init(void)
;
; Inicializa completamente o estado do jogo na memória.
game_init:

    ; carrega o endereço da struct game_state_data em rsi
    lea rsi, [rel game_state_data]

    ; snake_length = 1
    ;
    ; offset 3072 = snake_length
    mov dword [rsi + 3072], 1

    ; posição inicial da cabeça
    ;
    ; offset 0 = x
    ; offset 2 = y
    mov word [rsi + 0], 16
    mov word [rsi + 2], 12

    ; direção inicial
    ;
    ; 3 = RIGHT
    ;
    ; offsets:
    ; 3076 = current_direction
    ; 3080 = next_direction
    mov dword [rsi + 3076], 3
    mov dword [rsi + 3080], 3

    ; score = 0
    ;
    ; offset 3100 = score
    mov dword [rsi + 3100], 0

    ; game_state = RUNNING (0)
    ;
    ; offset 3096 = game_state
    mov dword [rsi + 3096], 0

    ; gerar primeira comida
    call food_spawn

    ret

; void game_set_input(direction_t dir)
;
; Recebe nova direção e valida:
; - se está no intervalo válido
; - se não é reversão direta
;
; edi contém o argumento (dir)
game_set_input:

    ; carregar endereço do estado global
    lea rsi, [rel game_state_data]

    ; validar intervalo permitido (0 a 3)
    ;
    ; jl = jump if less (menor)
    ; jg = jump if greater (maior)
    cmp edi, 0
    jl .end

    cmp edi, 3
    jg .end

    ; carregar direção atual
    ;
    ; eax recebe current_direction
    mov eax, [rsi + 3076]

    ; impedir reversão direta
    ;
    ; não pode ir para direção oposta imediatamente
    ;
    ; UP (0) <-> DOWN (1)
    ; LEFT (2) <-> RIGHT (3)

    ; se atual = UP (0)
    cmp eax, 0
    jne .check_down

    ; se novo = DOWN (1) -> inválido
    cmp edi, 1
    je .end

.check_down:

    ; se atual = DOWN (1)
    cmp eax, 1
    jne .check_left

    ; se novo = UP (0) -> inválido
    cmp edi, 0
    je .end

.check_left:

    ; se atual = LEFT (2)
    cmp eax, 2
    jne .check_right

    ; se novo = RIGHT (3) -> inválido
    cmp edi, 3
    je .end

.check_right:

    ; se atual = RIGHT (3)
    cmp eax, 3
    jne .set_input

    ; se novo = LEFT (2) -> inválido
    cmp edi, 2
    je .end

.set_input:

    ; salvar nova direção em next_direction
    mov [rsi + 3080], edi

.end:
    ret

; void game_update(void)
;
; Executa um frame do jogo
;
; Ordem:
; 1. Movimento
; 2. Comida
; 3. Colisão
game_update:

    ; carregar base do estado global
    lea rsi, [rel game_state_data]

    ; verificar se o jogo já terminou
    ;
    ; 2 = GAME_OVER
    ;
    ; cmp compara estado com 2
    ; je pula se for igual
    mov eax, [rsi + 3096]

    cmp eax, 2
    je .end

    ; FLUXO DO FRAME
    call snake_update
    call food_check
    call collision_check

.end:
    ret