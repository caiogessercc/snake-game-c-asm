BUILD_DIR = build
EXECUTABLE = $(BUILD_DIR)/snake

C_SOURCE = main.c

ASM_SOURCES = asm/collision.asm asm/food.asm asm/game.asm asm/snake.asm asm/state.asm

ASM_OBJECTS = $(ASM_SOURCES:asm/%.asm=$(BUILD_DIR)/%.o)
C_OBJECT = $(BUILD_DIR)/main.o

C_FLAGS = -std=c11 -O2 -Iinclude
SDL_FLAGS = $(shell sdl2-config --cflags)
SDL_LIBS = $(shell sdl2-config --libs)

ASM_FLAGS = -f elf64

all: $(EXECUTABLE)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: asm/%.asm | $(BUILD_DIR)
	nasm $(ASM_FLAGS) $< -o $@

$(BUILD_DIR)/main.o: $(C_SOURCE) | $(BUILD_DIR)
	gcc $(C_FLAGS) $(SDL_FLAGS) -c $< -o $@

$(EXECUTABLE): $(ASM_OBJECTS) $(C_OBJECT)
	gcc $^ -o $@ $(SDL_LIBS)

run: all
	./$(EXECUTABLE)

clean:
	rm -rf $(BUILD_DIR)

run:
	./build/snake