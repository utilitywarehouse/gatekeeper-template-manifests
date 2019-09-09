package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path"
	"strconv"

	"gopkg.in/yaml.v2"
)

type constraintTemplate struct {
	Kind string `yaml:"kind"`
	Spec struct {
		Targets []struct {
			Rego string `yaml:"rego"`
		} `yaml:"targets"`
	} `yaml:"spec"`
}

func main() {
	flag.Usage = func() {
		fmt.Fprintf(flag.CommandLine.Output(), "Usage of %s:\n  %s FILE [FILE...]\n", os.Args[0], path.Base(os.Args[0]))
	}

	flag.Parse()

	i := 0

	for _, manifest := range flag.Args() {
		file, err := os.Open(manifest)
		if err != nil {
			log.Fatalf("error: %v", err)
		}

		d := yaml.NewDecoder(file)
		for {
			var c constraintTemplate

			if err = d.Decode(&c); err != nil {
				// Stop looping when every yaml document in the file has been decoded
				if err.Error() == "EOF" {
					break
				}
				log.Fatalf("error: %v", err)
			}
			if c.Kind == "ConstraintTemplate" {
				for _, t := range c.Spec.Targets {
					if len(t.Rego) > 0 {
						// Write the rego policy to a unique (enough) file called ${i}.${manifest_basename}.rego
						err := ioutil.WriteFile(
							strconv.Itoa(i)+"."+path.Base(manifest)+".rego",
							[]byte(t.Rego),
							os.ModePerm,
						)
						if err != nil {
							log.Fatalf("error: %v", err)
						}
					}
				}
			}
		}
	}
}
