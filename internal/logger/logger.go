package logger

import (
	"github.com/sirupsen/logrus"
)

var Log *logrus.Logger

func init() {
	Log = logrus.New()
	Log.SetFormatter(&logrus.JSONFormatter{})
}

func Info(format string, v ...interface{}) {
	Log.Infof(format, v...)
}

func Error(format string, v ...interface{}) {
	Log.Errorf(format, v...)
}

func Fatal(format string, v ...interface{}) {
	Log.Fatalf(format, v...)
}
