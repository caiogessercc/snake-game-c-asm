/**
 * Arquivo da plataforma do jogo Snake.
 *
 * Responsável por:
 * - Inicialização da janela (SDL2)
 * - Captura de entrada do usuário
 * - Loop principal
 * - Renderização baseada no estado fornecido pelo Assembly
 *
 * Não contém lógica do jogo.
 */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <SDL2/SDL.h>

#include "constants.h"
#include "snake.h"

/**
 * Dimensões da janela em pixels.
 *
 * Cada célula do grid será escalada para TILE_SIZE pixels.
 */
#define TILE_SIZE 20
#define WINDOW_WIDTH (GRID_WIDTH * TILE_SIZE)
#define WINDOW_HEIGHT (GRID_HEIGHT * TILE_SIZE)

/**
 * @brief Estrutura de contexto da aplicação.
 *
 * Encapsula recursos do SDL para evitar variáveis globais.
 */
typedef struct {
  SDL_Window *window;
  SDL_Renderer *renderer;
  bool running;
} application_context;

/**
 * @brief Inicializa SDL e cria janela e renderer.
 *
 * @param app Ponteiro para estrutura de aplicação
 * @return true em caso de sucesso
 */
static bool app_init(application_context *app) {
  if (SDL_Init(SDL_INIT_VIDEO) != 0) {
    fprintf(stderr, "SDL_Init failed: %s\n", SDL_GetError());
    return false;
  }

  app->window = SDL_CreateWindow(
      "Snake ASM + C",
      SDL_WINDOWPOS_CENTERED,
      SDL_WINDOWPOS_CENTERED,
      WINDOW_WIDTH,
      WINDOW_HEIGHT, SDL_WINDOW_SHOWN
  );

  if (!app->window) {
    fprintf(stderr, "SDL_CreateWindow failed: %s\n", SDL_GetError());
    return false;
  }

  app->renderer = SDL_CreateRenderer(app->window, -1, SDL_RENDERER_ACCELERATED);

  if (!app->renderer) {
    fprintf(stderr, "SDL_CreateRenderer failed: %s\n", SDL_GetError());
    return false;
  }

  app->running = true;
  return true;
}

/**
 * @brief Libera recursos do SDL.
 */
static void app_destroy(application_context *app) {
  if (app->renderer)
    SDL_DestroyRenderer(app->renderer);
  if (app->window)
    SDL_DestroyWindow(app->window);
  SDL_Quit();
}

/**
 * @brief Processa eventos de entrada.
 *
 * Converte eventos SDL para o modelo interno do jogo (constants.h).
 *
 * @param app Contexto da aplicação
 */
static void handle_input(application_context *app) {
  SDL_Event event;

  while (SDL_PollEvent(&event)) {
    switch (event.type) {
      case SDL_QUIT:
        app->running = false;
        break;

      case SDL_KEYDOWN:
        switch (event.key.keysym.sym) {
          case SDLK_ESCAPE:
            app->running = false;
            break;

          case SDLK_UP:
            game_set_input(DIRECTION_UP);
            break;

          case SDLK_DOWN:
            game_set_input(DIRECTION_DOWN);
            break;

          case SDLK_LEFT:
            game_set_input(DIRECTION_LEFT);
            break;

          case SDLK_RIGHT:
            game_set_input(DIRECTION_RIGHT);
            break;

          case SDLK_p:
            game_set_input(INPUT_PAUSE);
            break;

          default:
            break;
        }
        break;

      default:
        break;
    }
  }
}

/**
 * @brief Renderiza o estado atual do jogo.
 *
 * @param app Contexto da aplicação
 */
static void render(application_context *app) {
  const game_state_data_t *state = game_get_state();

  SDL_SetRenderDrawColor(app->renderer, 0, 0, 0, 255);
  SDL_RenderClear(app->renderer);

  /**
   * Renderizar comida
   */
  SDL_Rect food_rect = {state->food_position.x * TILE_SIZE, state->food_position.y * TILE_SIZE, TILE_SIZE, TILE_SIZE};

  SDL_SetRenderDrawColor(app->renderer, 255, 0, 0, 255);
  SDL_RenderFillRect(app->renderer, &food_rect);

  /**
   * Renderizar snake
   */
  SDL_SetRenderDrawColor(app->renderer, 0, 255, 0, 255);

  for (uint32_t i = 0; i < state->snake_length; i++) {
    SDL_Rect rect = {state->snake_body[i].x * TILE_SIZE, state->snake_body[i].y * TILE_SIZE, TILE_SIZE, TILE_SIZE};

    SDL_RenderFillRect(app->renderer, &rect);
  }

  SDL_RenderPresent(app->renderer);
}

/**
 * @brief Loop principal do jogo.
 *
 * Implementa o padrão:
 * - input
 * - update
 * - render
 */
static void game_loop(application_context *app) {
  uint32_t last_tick = SDL_GetTicks();

  while (app->running) {
    handle_input(app);
    uint32_t current = SDL_GetTicks();

    if (current - last_tick >= GAME_TICK_INTERVAL_MS) {
      if (!game_is_over()) {
        game_update();
      }

      last_tick = current;
    }

    render(app);
    SDL_Delay(1);
  }
}

int main(void) {
  application_context app = {0};

  if (!app_init(&app)) {
    return EXIT_FAILURE;
  }

  /**
   * Inicializa estado do jogo (Assembly)
   */
  game_init();

  /**
   * Executa loop principal
   */
  game_loop(&app);

  /**
   * Cleanup
   */
  app_destroy(&app);

  return EXIT_SUCCESS;
}