extern game_state_data

section .text

    global snake_update

; void snake_update(void)
;
; Essa função é usada para:
; 1. Atualizar direção atual
; 2. Mover o corpo da snake
; 3. Calcular nova posição da cabeça
snake_update:

    ; rsi aponta para o início da struct game_state_data
    lea rsi, [rel game_state_data]

    ; Atualiza direção atual
    ;
    ; current_direction recebe o valor de next_direction
    ;
    ; offsets:
    ; 3080 = next_direction
    ; 3076 = current_direction

    ; eax recebe next_direction
    mov eax, [rsi + 3080]

    ; escreve em current_direction
    mov [rsi + 3076], eax

    ; Carrega tamanho da snake
    ;
    ; offset 3072 = snake_length
    mov ecx, [rsi + 3072]

    ; cmp compara ecx com 1
    cmp ecx, 1

    ; jle = jump if less or equal
    ; se tamanho <= 1, não existe corpo para mover
    jle .skip_shift

    ; Shift do corpo da snake
    ;
    ; A ideia é mover cada segmento para a posição do anterior
    ;
    ; Exemplo:
    ; [head, s1, s2] -> [new_head, head, s1]

    ; rdi aponta para snake_body[0]
    lea rdi, [rsi]

    ; ecx = length - 1 -> começa do último índice
    ; "eax = i"
    dec ecx

.shift_loop:

    ; i = ecx
    mov eax, ecx

    ; (i - 1)
    mov edx, eax
    dec edx

    ; offset_i = i * 4
    ; cada elemento ocupa 4 bytes
    lea r8, [rax*4]

    ; offset_prev = (i - 1) * 4
    lea r9, [rdx*4]

    ; body[i] = body[i-1]
    mov ebx, [rdi + r9] ; lê segmento anterior
    mov [rdi + r8], ebx ; escreve no segmento atual

    ; i--
    dec ecx

    cmp ecx, 0
    ; enquanto i > 0 continua
    jg .shift_loop

.skip_shift:

    ; Atualizar posição da cabeça
    ;
    ; offset 0 = head.x (int16)
    ; offset 2 = head.y (int16)
    ;
    ; int16 ocupa 2 bytes → por isso 0 e 2

    mov ax, [rsi + 0] ; head.x
    mov bx, [rsi + 2] ; head.y

    ; carregar direção atual
    mov ecx, [rsi + 3076]

    ; Decidir movimento com base na direção
    ;
    ; - cmp compara ecx com um valor
    ; - je pula se forem iguais
    ;
    ; Basicamente, "se direção == X então vá para tal bloco"

    cmp ecx, 0
    je .move_up

    cmp ecx, 1
    je .move_down

    cmp ecx, 2
    je .move_left

    cmp ecx, 3
    je .move_right

    jmp .done

.move_up:
    ; mover para cima
    ; diminuir Y (eixo vertical)
    ;
    ; dec = subtrai 1
    dec bx
    jmp .store_head

.move_down:
    ; mover para baixo
    ; aumentar Y
    ;
    ; inc = soma 1
    inc bx
    jmp .store_head

.move_left:
    ; mover para esquerda
    ; diminuir X
    dec ax
    jmp .store_head

.move_right:
    ; mover para direita
    ; aumentar X
    inc ax
    jmp .store_head

.store_head:
    ; salva nova posição da cabeça
    mov [rsi + 0], ax
    mov [rsi + 2], bx

.done:
    ret