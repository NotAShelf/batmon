package main

import (
	"sync"

	"github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"

	"batmon/internal/battery"
	"batmon/internal/config"
	"batmon/internal/model"
)

func main() {
	var rootCmd = &cobra.Command{
		Use:   "batmon",
		Short: "Dead-simple battery monitor for Linux",
		Long:  `TODO`,
		Run: func(cmd *cobra.Command, args []string) {
			// load the battery configuration
			config, err := config.Load(viper.GetString("config"))
			if err != nil {
				logrus.WithFields(logrus.Fields{
					"error": err,
				}).Fatal("Failed to load configuration")
			}

			// create a WaitGroup to wait for all goroutines to finish
			var wg sync.WaitGroup
			wg.Add(len(config.BatPaths))

			// start a goroutine for each battery
			for _, bat := range config.BatPaths {
				go func(bat model.Battery) {
					defer wg.Done()
					err := battery.Monitor(bat)
					if err != nil {
						logrus.WithFields(logrus.Fields{
							"error":   err,
							"battery": bat.Path,
						}).Error("Failed to monitor battery")
					}
				}(bat)
			}

			// wait for all goroutines to finish
			wg.Wait()
		},
	}

	rootCmd.PersistentFlags().StringP("config", "c", "config.json", "Path to the configuration file")
	viper.BindPFlag("config", rootCmd.PersistentFlags().Lookup("config"))

	if err := rootCmd.Execute(); err != nil {
		logrus.WithFields(logrus.Fields{
			"error": err,
		}).Fatal("Failed to execute root command")
	}
}
