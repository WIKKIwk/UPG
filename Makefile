.PHONY: run build clean test deps help fmt lint install prepare ensure-env ensure-data

# Default target
.DEFAULT_GOAL := run

# Variables
BINARY_NAME=bot
MAIN_PATH=cmd/bot/main.go
ENV_FILE=.env
ENV_EXAMPLE=.env.example
DATA_DIR=data

## help: Ko'rsatish barcha mavjud komandalar
help:
	@echo "Mavjud komandalar:"
	@echo "  make          - (default) deps + env check + botni ishga tushirish"
	@echo "  make run      - Botni ishga tushirish (prepare bilan)"
	@echo "  make build    - Botni build qilish"
	@echo "  make clean    - Build fayllarni o'chirish"
	@echo "  make deps     - Dependencies ni o'rnatish"
	@echo "  make test     - Testlarni ishga tushirish"
	@echo "  make fmt      - Kodni formatlash"
	@echo "  make lint     - Kodni tekshirish"
	@echo "  make prepare  - Env, data va deps ni tayyorlash"

## run: Botni ishga tushirish
run: prepare
	@echo "Bot ishga tushmoqda..."
	@go run $(MAIN_PATH)

## prepare: Env, data va deps tayyorgarligi
prepare: ensure-env ensure-data deps
	@echo "OK: Muhit tayyor, bot ishga tushirilmoqda..."

## ensure-env: .env faylini tekshirish
ensure-env:
	@if [ ! -f $(ENV_FILE) ]; then \
		cp $(ENV_EXAMPLE) $(ENV_FILE); \
		echo "WARNING: $(ENV_FILE) fayli yaratildi. TELEGRAM_BOT_TOKEN va GEMINI_API_KEY ni to'ldiring, so'ngra 'make' ni qayta ishga tushiring."; \
		exit 1; \
	fi
	@. $(ENV_FILE); \
	if [ -z "$${TELEGRAM_BOT_TOKEN}" ] || [ "$${TELEGRAM_BOT_TOKEN}" = "your_telegram_bot_token_here" ]; then \
		echo "ERROR: TELEGRAM_BOT_TOKEN to'ldirilmagan. $(ENV_FILE) ni tahrirlang."; \
		exit 1; \
	fi; \
	if [ -z "$${GEMINI_API_KEY}" ] || [ "$${GEMINI_API_KEY}" = "your_gemini_api_key_here" ]; then \
		echo "ERROR: GEMINI_API_KEY to'ldirilmagan. $(ENV_FILE) ni tahrirlang."; \
		exit 1; \
	fi
	@echo "Environment sozlamalari topildi"

## ensure-data: Kerakli papkalarni yaratish
ensure-data:
	@mkdir -p $(DATA_DIR)
	@echo "OK: $(DATA_DIR) papkasi tayyor"

## build: Botni build qilish
build:
	@echo "Build qilinyapti..."
	@go build -o $(BINARY_NAME) $(MAIN_PATH)
	@echo "Build tayyor: ./$(BINARY_NAME)"

## clean: Build fayllarni o'chirish
clean:
	@echo "Tozalanyapti..."
	@rm -f $(BINARY_NAME)
	@go clean
	@echo "Tozalandi!"

## deps: Dependencies ni o'rnatish
deps:
	@echo "Dependencies o'rnatilmoqda..."
	@go mod download
	@go mod tidy
	@echo "Dependencies tayyor!"

## test: Testlarni ishga tushirish
test:
	@echo "Testlar ishga tushmoqda..."
	@go test -v ./...

## fmt: Kodni formatlash
fmt:
	@echo "Kod formatlanmoqda..."
	@go fmt ./...
	@echo "Format tayyor!"

## lint: Kodni tekshirish (golangci-lint kerak)
lint:
	@echo "Kod tekshirilmoqda..."
	@golangci-lint run ./...

## install: Binary ni install qilish
install: build
	@echo "Installing..."
	@go install $(MAIN_PATH)
