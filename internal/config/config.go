package config

import (
	"encoding/json"
	"os"

	"batmon/internal/logger"
	"batmon/internal/model"
)

// Load loads the battery configuration from a file.
func Load(filename string) (model.BatteryConfig, error) {
	file, err := os.Open(filename)
	if err != nil {
		logger.Error("Failed to open file")
		return model.BatteryConfig{}, err
	}
	defer file.Close()

	var config model.BatteryConfig
	decoder := json.NewDecoder(file)
	err = decoder.Decode(&config)
	if err != nil {
		logger.Error("Failed to decode JSON")
		return model.BatteryConfig{}, err
	}

	return config, nil
}
