# Snake Game - C + Assembly

Snake Game desenvolvido utilizando C e Assembly. A interface, entrada e loop são feitos em C, enquanto a lógica do jogo (movimento, colisões, geração de comida e estado) é implementada em Assembly. Esse projeto foi desenvolvido com objetivo de aprender mais sobre programação de baixo nível, controle de memória e integração entre C e Assembly.

---

O projeto separa as responsabilidades entre:

* **Assembly (NASM x86-64)**: lógica do jogo
* **C (SDL2)**: janela, input e loop principal

A lógica do jogo não depende da camada de renderização. O C apenas:

* envia input
* chama o update
* lê o estado para renderizar

---

## Estrutura do Projeto

```text
snake-game-c-asm
├── asm/
│   ├── state.asm        # estado global
│   ├── snake.asm        # movimento da snake
│   ├── food.asm         # geração e consumo de comida
│   ├── collision.asm    # detecção de colisões
│   └── game.asm         # orquestração do sistema
├── include/
│   ├── constants.h      # contrato de dados
│   └── snake.h          # interface pública
├── src/
│   └── main.c           # SDL + loop principal
├── Makefile
└── README.md
```

---

## Integração C <-> Assembly

A comunicação entre as camadas é feita por:

* headers compartilhados (`constants.h`, `snake.h`)
* acesso direto ao mesmo bloco de memória

Regras adotadas:

* não existe duplicação de estado
* Assembly é responsável pela lógica
* C apenas consome e exibe o estado

---

## Sobre o uso de C no projeto

Parte do projeto foi implementada em C por limitação prática durante o desenvolvimento.

* ainda estou no processo de aprendizado de Assembly
* tudo o que foi feito em C, fazer em Assembly puro, seria significativamente mais complexo pra mim no momento, então escolhi usar C

Decisão temporária:

* Assembly -> lógica do jogo
* C -> camada de suporte (janela, input e render)

---

## Regras do sistema

* posições devem estar dentro do grid
* snake não pode atravessar paredes
* snake não pode colidir com o próprio corpo
* comida não pode nascer sobre a snake
* direção não pode ser invertida diretamente

---

## Como testar o jogo

### Requisitos

* GCC
* NASM
* SDL2

### Build

```bash
make
```

### Execução

```bash
make run
```

---

## Possíveis melhorias futuras

* remover dependência de C (engine 100% Assembly)
* adicionar game over na tela com opção de reiniciar / restart automático
* suporte a diferentes tamanhos de grid
* otimizar detecção de colisão
