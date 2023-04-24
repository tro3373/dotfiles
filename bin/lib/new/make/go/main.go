package main

import (
	"errors"

	log "github.com/sirupsen/logrus"
)

func sub() error {
	return errors.Errorf("Error: %s", "sample error")
}

func main() {
	if err := sub; err != nil {
		log.Error("==> Error occured: %w", err)
		panic(err)
	}
}
