#ifndef SNAKE_CONSTANTS_H
#define SNAKE_CONSTANTS_H

/**
 * @file constants.h
 * @brief Arquivo central de definições compartilhadas entre C e Assembly (NASM).
 */

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#define GRID_WIDTH  32
#define GRID_HEIGHT 24

/**
 * Número máximo de segmentos da snake.
 *
 * SNAKE_MAX_LENGTH = GRID_WIDTH * GRID_HEIGHT
 *
 * - O pior caso é a snake ocupar TODAS as células do grid
 * - Isso evita overflow de memória (não cresce além do limite)
 */
#define SNAKE_MAX_LENGTH (GRID_WIDTH * GRID_HEIGHT)

/**
 * Representação de posição no grid.
 *
 * Cada posição tem:
 * - x -> coluna
 * - y -> linha
 *
 * Tipo utilizado: int16_t
 *
 * int16_t:
 * - Inteiro com sinal de 16 bits (2 bytes)
 * - Intervalo: [-32768, 32767]
 *
 * Por que int16_t:
 * - O grid é pequeno (32x24), então não é necessário int32
 * - Cada posição ocupa apenas 4 bytes (2 + 2)
 */
typedef struct {
    int16_t x;
    int16_t y;
} position_t;

/**
 * Direções possíveis da snake.
 * - Cada direção é representada por um número inteiro.
 *
 * Isso é bom porque:
 * - Em Assembly é usado cmp (uma comparação direta com números)
 */
typedef enum {
    DIRECTION_UP    = 0,
    DIRECTION_DOWN  = 1,
    DIRECTION_LEFT  = 2,
    DIRECTION_RIGHT = 3
} direction_t;

/**
 * Estados globais do jogo.
 *
 * Estados
 * 0 = RUNNING   -> jogo ativo
 * 1 = PAUSED    -> jogo pausado
 * 2 = GAME_OVER -> perdeu
 */
typedef enum {
    GAME_STATE_RUNNING   = 0,
    GAME_STATE_PAUSED    = 1,
    GAME_STATE_GAME_OVER = 2
} game_state_t;

typedef struct {

    /**
     * Corpo da snake.
     *
     * Cada elemento ocupa:
     * 4 bytes (int16 x + int16 y)
     *
     * SNAKE_MAX_LENGTH * 4 bytes
     */
    position_t snake_body[SNAKE_MAX_LENGTH];

    /**
     * Tamanho atual da snake.
     *
     * Tipo: uint32_t
     * - Inteiro sem sinal (unsigned)
     * - 32 bits (4 bytes)
     * - Intervalo: [0, ~4 bilhões]
     *
     * Por que unsigned: Tamanho nunca é negativo
     */
    uint32_t   snake_length;

    /**
     * Direção atual da snake.
     */
    direction_t current_direction;

    /**
     * Próxima direção (input do usuário).
     */
    direction_t next_direction;

    /**
     * Posição da comida.
     */
    position_t food_position;

    /**
     * Estado atual do jogo.
     */
    game_state_t game_state;

    /**
     * Pontuação do jogador.
     */
    uint32_t score;

} game_state_data_t;

/**
 * Intervalo de atualização do jogo.
 * - Define a velocidade do jogo.
 *
 * Exemplo:
 * 100 ms = 10 updates por segundo
 *
 * - Se diminuir -> jogo mais rápido
 */
#define GAME_TICK_INTERVAL_MS 100

/**
 * Códigos de entrada.
 * - Representam ações do usuário de forma abstrata.
 *
 * SDL      -> converte tecla       -> código
 * Assembly -> interpreta código
 */
#define INPUT_NONE  0
#define INPUT_UP    1
#define INPUT_DOWN  2
#define INPUT_LEFT  3
#define INPUT_RIGHT 4
#define INPUT_PAUSE 5

/**
 * Basicamente um valor especial que indica "estado inválido"
 *
 * O -1 é usado porque:
 * - Está fora do grid válido (0 até GRID-1)
 */
#define INVALID_POSITION -1

/**
 * Validar posição dentro do grid.
 * Isso evita repetir lógica em vários lugares.
 *
 * x no intervalo [0, WIDTH-1]
 * y no intervalo [0, HEIGHT-1]
 */
#define IS_POSITION_VALID(x, y) \
    ((x) >= 0 && (x) < GRID_WIDTH && (y) >= 0 && (y) < GRID_HEIGHT)

#endif