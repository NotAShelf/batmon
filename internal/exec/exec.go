package exec

import (
	"os/exec"

	"batmon/internal/logger"
)

// execute a command with args and returns its output
// this will be used primarily for executing external commands if configured
// or executing bash commands verbatim
func ExecCommand(name string, arg ...string) error {
	cmd := exec.Command(name, arg...)
	err := cmd.Run()
	if err != nil {
		logger.Error("Failed to execute command")
		return err
	}

	return nil
}
