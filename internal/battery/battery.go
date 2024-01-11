package battery

import (
	"os"
	"strings"
	"time"

	"gomon/internal/exec"
	"gomon/internal/logger"
	"gomon/internal/model"
)

// battery monitor service
func Monitor(bat model.Battery, profiles ...string) error {
	// wait a while if needed
	startupWait := os.Getenv("STARTUP_WAIT")
	if startupWait != "" {
		duration, err := time.ParseDuration(startupWait)
		if err != nil {
			logger.Error("Invalid STARTUP_WAIT duration")
			return nil
		}
		time.Sleep(duration)
	}

	// start the monitor loop
	var prevProfile string
	for {
		// read the current state
		batteryStatus, err := os.ReadFile(bat.Path + "/status")
		if err != nil {
			logger.Error("Failed to read battery status")
			return nil
		}
		currentProfile := "performance"
		if strings.TrimSpace(string(batteryStatus)) == "Discharging" {
			currentProfile = "balanced"
		}

		// set the new profile
		if currentProfile != prevProfile {
			logger.Info("Setting power profile to %s for battery %s", currentProfile, bat.Path)
			var commandArgs []string
			if bat.Command != "" {
				commandArgs = strings.Split(bat.Command, " ")
			} else {
				commandArgs = []string{"powerprofilesctl", "set", currentProfile}
			}
			err = exec.ExecCommand(commandArgs[0], commandArgs[1:]...)
			if err != nil {
				logger.Error("Failed to execute command")
				return nil
			}

			// execute the extra command
            // if any
			if bat.ExtraCommand != "" {
				extraCommandArgs := strings.Split(bat.ExtraCommand, " ")
				err = exec.ExecCommand(extraCommandArgs[0], extraCommandArgs[1:]...)
				if err != nil {
					logger.Error("Failed to execute extra command")
					return nil
				}
			}
		}
		prevProfile = currentProfile

		// wait for the next power change event
		time.Sleep(1 * time.Second)
	}
}
