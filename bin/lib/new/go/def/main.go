package main

import (
	"os"

	"github.com/pkg/errors"

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
	if err := sub(); err != nil {
		log.Errorf("==> Error occured: %v", err)
		panic(err)
	}
}
