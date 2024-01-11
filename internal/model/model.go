package model

type Battery struct {
	Path         string `json:"path"`
	Command      string `json:"command"`
	ExtraCommand string `json:"extraCommand"`
}

type BatteryConfig struct {
	BatPaths []Battery `json:"batPaths"`
}
