#ifndef SNAKE_H
#define SNAKE_H

/**
 * @file snake.h
 * @brief Interface entre o código em C e o núcleo do jogo escrito em Assembly (NASM).
 *
 * Esse arquivo funciona como uma ponte entre duas linguagens:
 * - C        -> responsável por janela, input e renderização (SDL)
 * - Assembly -> responsável por toda a lógica do jogo
 */

#include <stdint.h>
#include <stdbool.h>

#include "constants.h"

/**
 * Inicializa todo o estado do jogo.
 *
 * - Define o tamanho inicial da snake (geralmente 1)
 * - Define posição inicial (centro do grid)
 * - Define direção inicial (ex: direita)
 * - Zera o score
 * - Define estado como RUNNING
 * - Gera a primeira comida
 */
void game_init(void);

/**
 * Atualiza o jogo.
 * 
 * 1. Atualiza direção (current = next)
 * 2. Move a snake (shift do corpo)
 * 3. Verifica se comeu comida
 * 4. Verifica colisão (parede ou corpo)
 */
void game_update(void);

/**
 * Define a próxima direção da snake.
 *
 * Essa função não move a snake imediatamente.
 * Ela apenas armazena a intenção de movimento.
 *
 * @param direction valor inteiro definido em constants.h
 */
void game_set_input(direction_t direction);

/**
 * Retorna ponteiro para o estado global do jogo.
 *
 * No Assembly isso é feito com instrução lea (load effective address)
 *
 * Exemplo:
 * lea rax, [rel game_state_data]
 *
 * Explicando:
 * - lea -> carrega endereço
 * - rel -> endereço relativo
 *
 * @return ponteiro para estrutura global
 */
const game_state_data_t* game_get_state(void);

/**
 * Retorna o estado atual do jogo.
 *
 * Em vez de acessar diretamente a struct, é usado essa função.
 *
 * No Assembly:
 * - Um valor é lido diretamente da memória
 * - Exemplo:
 *   mov eax, [rel game_state_data + OFFSET_GAME_STATE]
 *
 * Explicando:
 * - mov -> copia valor da memória
 * - OFFSET -> posição dentro da struct
 *
 * @return estado atual (RUNNING, PAUSED ou GAME_OVER)
 */
game_state_t game_get_game_state(void);

/**
 * Verifica se o jogo terminou.
 *
 * @return true se terminou
 */
bool game_is_over(void);

/**
 * Retorna o score atual.
 */
uint32_t game_get_score(void);

/**
 * Reseta o jogo completamente.
 */
void game_reset(void);

/**
 * Gera uma nova comida.
 *
 * - gerar x aleatório
 * - gerar y aleatório
 * - verificar colisão com corpo
 * - repetir se inválido
 */
void game_spawn_food(void);

/**
 * Executa verificação de colisões manualmente.
 */
void game_check_collisions(void);

/**
 * Retorna o tamanho atual da snake.
 * - Valor armazenado em memória como uint32.
 *
 * uint32_t:
 * - inteiro sem sinal
 * - 32 bits
 * - nunca negativo
 *
 * @return quantidade de segmentos da snake
 */
uint32_t game_get_snake_length(void);

/**
 * Retorna o array do corpo da snake.
 *
 * Cada elemento:
 * - 2 bytes para x (int16)
 * - 2 bytes para y (int16)
 *
 * Total por elemento = 4 bytes
 *
 * @return ponteiro para início do array
 */
const position_t* game_get_snake_body(void);

#endif