package config

import (
	"fmt"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

// Config ilovaning konfiguratsiyasi
type Config struct {
	TelegramToken  string
	GeminiAPIKey   string
	MaxContextSize int
	Group1ChatID   int64
	Group2ChatID   int64
	ChatDBPath     string
}

// Load konfiguratsiyani yuklash
func Load() (*Config, error) {
	// .env faylini yuklash (mavjud bo'lsa)
	_ = godotenv.Load()

	config := &Config{
		TelegramToken:  os.Getenv("TELEGRAM_BOT_TOKEN"),
		GeminiAPIKey:   os.Getenv("GEMINI_API_KEY"),
		MaxContextSize: 20, // Default qiymat
		ChatDBPath:     "data/chat.db",
	}

	if dbPath := os.Getenv("CHAT_DB_PATH"); dbPath != "" {
		config.ChatDBPath = dbPath
	}

	if rawGroupID := os.Getenv("GROUP_1_CHAT_ID"); rawGroupID != "" {
		if parsed, err := strconv.ParseInt(rawGroupID, 10, 64); err == nil {
			config.Group1ChatID = parsed
		} else {
			return nil, fmt.Errorf("GROUP_1_CHAT_ID noto'g'ri formatda: %v", err)
		}
	}

	if rawGroupID := os.Getenv("GROUP_2_CHAT_ID"); rawGroupID != "" {
		if parsed, err := strconv.ParseInt(rawGroupID, 10, 64); err == nil {
			config.Group2ChatID = parsed
		} else {
			return nil, fmt.Errorf("GROUP_2_CHAT_ID noto'g'ri formatda: %v", err)
		}
	}

	// Validatsiya
	if config.TelegramToken == "" {
		return nil, fmt.Errorf("TELEGRAM_BOT_TOKEN environment variable bo'sh")
	}
	if config.GeminiAPIKey == "" {
		return nil, fmt.Errorf("GEMINI_API_KEY environment variable bo'sh")
	}

	return config, nil
}
