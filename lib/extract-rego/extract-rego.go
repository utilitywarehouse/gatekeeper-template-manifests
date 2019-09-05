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

func main() {
	flag.Usage = func() {
		fmt.Fprintf(flag.CommandLine.Output(), "Usage of %s:\n  %s FILE [FILE...]\n", os.Args[0], path.Base(os.Args[0]))
	}

	flag.Parse()

	i := 0

	for _, manifest := range flag.Args() {

		document := make(map[interface{}]interface{})

		file, err := os.Open(manifest)
		if err != nil {
			log.Fatalf("error: %v", err)
		}

		d := yaml.NewDecoder(file)
		for {
			// Stop looping when every yaml document in the file has been decoded
			if err = d.Decode(document); err != nil {
				break
			}
			// Only operate on ConstraintTemplates with spec.targets[].rego fields
			if kind, ok := document["kind"]; ok && kind == "ConstraintTemplate" {
				if targets, ok := document["spec"].(map[interface{}]interface{})["targets"].([]interface{}); ok {
					for _, target := range targets {
						if rego, ok := target.(map[interface{}]interface{})["rego"].(string); ok {
							// Write the rego policy to a unique (enough) file called ${i}.${manifest_basename}.rego
							err := ioutil.WriteFile(
								strconv.Itoa(i)+"."+path.Base(manifest)+".rego",
								[]byte(rego),
								os.ModePerm,
							)
							if err != nil {
								log.Fatalf("error: %v", err)
							}

							i++
						}
					}
				}
			}

		}
	}
}
