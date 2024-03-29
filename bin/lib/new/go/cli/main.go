package main

import (
	"os"

	log "github.com/sirupsen/logrus"
	"github.com/urfave/cli"
)

func main() {
	var (
		suffix string
	)

	app := cli.NewApp()
	app.Name = "Hello xxxx"
	app.Usage = "Make `Hello xxx` for arbitrary text"
	app.Version = "0.1.0"
	app.Action = func(c *cli.Context) error {
		log.Infof("main called")
		return nil
	}

	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:        "suffix, s",
			Value:       "!!!",
			Usage:       "text after speaking something",
			Destination: &suffix,
			EnvVar:      "SUFFIX",
		},
	}

	app.Commands = []cli.Command{
		{
			Name:  "hello",
			Usage: "if use set -t or --text",
			Flags: []cli.Flag{
				cli.StringFlag{
					Name:  "text, t",
					Value: "world",
					Usage: "hello xxx text",
				},
			},
			Action: func(c *cli.Context) error {
				// fmt.Printf("Hello %s %s\n", c.String("text"), suffix)
				log.Infof("Hello %s %s\n", c.String("text"), suffix)
				return nil
			},
		},
	}

	if err := app.Run(os.Args); err != nil {
		// fmt.Fprintln(os.Stderr, err)
		log.Error("==> Error occured: %w", err)
		os.Exit(1)
	}
}
