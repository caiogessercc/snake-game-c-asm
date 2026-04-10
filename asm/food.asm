extern game_state_data

section .data

    ; rng_seed:
    ; valor inicial do gerador aleatório
    ;
    ; dd = define double word (4 bytes)
    ;
    ; esse valor será atualizado a cada chamada do RNG
    rng_seed dd 123456789

section .text

    global food_spawn
    global food_check

; uint32_t lcg_random(void)
;
; Implementa um gerador aleatório simples
;
; próximo_valor = valor_atual * constante + constante
;
; Não é algo realmente aleatório, mas o suficiente para esse jogo
lcg_random:

    ; carrega seed atual
    mov eax, [rel rng_seed]

    ; imul: Multiplicação de inteiros
    ;
    ; eax = eax * 1103515245
    imul eax, eax, 1103515245

    ; soma constante
    add eax, 12345

    ; salva novo valor como seed
    mov [rel rng_seed], eax

    ; retorna valor em eax
    ret

; void food_spawn(void)
;
; O objetivo é gerar uma posição válida para a comida
;
; Regras:
; - deve estar dentro do grid
; - não pode coincidir com nenhum segmento da snake
;
; Estratégia:
; - gerar posição aleatória
; - verificar colisão
; - repetir até encontrar posição válida
food_spawn:

    ; rsi aponta para o estado global
    lea rsi, [rel game_state_data]

.retry:
; ponto de retorno caso posição gerada seja inválida

    ; Gerar X dentro do grid (0 até 31)
    call lcg_random ; resultado vem em eax

    ; zera edx
    ;
    ; é necessário porque a instrução div usa edx:eax como valor de entrada
    xor edx, edx

    ; tamanho do grid em X
    mov ecx, 32

    ; divide (edx:eax) por ecx
    ;
    ; resultado:
    ; eax = quociente
    ; edx = resto
    div ecx

    ; usa o resto como valor dentro do intervalo
    ; agora r8d = valor entre 0 e 31
    mov r8d, edx

    ; Gerar Y dentro do grid (0 até 23)
    call lcg_random

    xor edx, edx
    mov ecx, 24

    div ecx

    ; r9d = valor entre 0 e 23
    mov r9d, edx

    ; div usa dois registradores juntos:
    ; edx:eax
    ;
    ; se edx não for zerado:
    ; o valor vira muito grande (como se fosse 64 bits)
    ; e pode causar erro de divisão

    ; Verificar se posição colide com a snake
    mov ecx, [rsi + 3072] ; snake_length (uint32)

    ; rdi aponta para snake_body[0]
    lea rdi, [rsi]

    ; r10d será usado como índice (i = 0)
    xor r10d, r10d

.check_loop:

    ; compara índice com tamanho da snake
    cmp r10d, ecx

    ; jge = jump if greater or equal
    ;
    ; se i >= length -> terminou de verificar todos os segmentos
    jge .valid_position

    ; calcular offset do segmento atual
    ; cada segmento ocupa 4 bytes
    lea r11, [r10*4]

    ; movsx:
    ; move com extensão de sinal
    ;
    ; lê 2 bytes (int16) e converte para 32 bits
    movsx eax, word [rdi + r11]       ; x do segmento
    movsx ebx, word [rdi + r11 + 2]   ; y do segmento

    ; comparar com posição gerada
    cmp eax, r8d
    jne .next

    cmp ebx, r9d
    jne .next

    ; se chegou aqui:
    ; posição é igual a algum segmento da snake
    ; então é inválida

    jmp .retry

.next:

    inc r10d
    ; i++

    jmp .check_loop

.valid_position:

    ; Salvar posição da comida
    ;
    ; offsets:
    ; 3084 = food.x
    ; 3086 = food.y
    ;
    ; cada valor ocupa 2 bytes (int16)
    mov word [rsi + 3084], r8w
    mov word [rsi + 3086], r9w

    ret

; void food_check(void)
;
; verifica se a cabeça da snake encostou na comida
;
; Se encostar:
; - aumenta o tamanho da snake
; - gera nova comida
food_check:

    lea rsi, [rel game_state_data]

    ; Carregar posição da cabeça
    ;
    ; offset 0 = x
    ; offset 2 = y
    movsx eax, word [rsi + 0]
    movsx ebx, word [rsi + 2]

    ; Carregar posição da comida
    ;
    ; offset 3084 = x
    ; offset 3086 = y
    movsx ecx, word [rsi + 3084]
    movsx edx, word [rsi + 3086]

    ; Comparar posições
    ;
    ; cmp + jne:
    ; - cmp compara valores
    ; - jne pula se forem diferentes
    ;
    ; se x for diferente -> não colidiu
    ; se y for diferente -> não colidiu

    cmp eax, ecx
    jne .end

    cmp ebx, edx
    jne .end

    ; Se chegou aqui -> houve colisão (comeu comida)

    ; tamanho atual da snake
    mov r8d, [rsi + 3072]

    ; limite máximo:
    ; 3072 bytes / 4 bytes por segmento = 768
    cmp r8d, 768

    ; se atingiu limite, não cresce mais
    jge .end

    ; aumenta tamanho
    inc r8d

    mov [rsi + 3072], r8d

    ; gerar nova comida
    call food_spawn

.end:
    ret