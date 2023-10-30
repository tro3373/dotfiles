package main

import (
	"errors"
	"os"

	log "github.com/sirupsen/logrus"
)

func sub() error {
	return errors.Errorf("Error: %s", "sample error")
}

func main() {
	// initConfigInner
	level, err := log.ParseLevel(os.Getenv("LOG_LEVEL"))
	if err == nil {
		log.SetLevel(level)
	}
	log.Infof("==> Start")
	if err := sub; err != nil {
		log.Error("==> Error occured: %w", err)
		panic(err)
	}
}
