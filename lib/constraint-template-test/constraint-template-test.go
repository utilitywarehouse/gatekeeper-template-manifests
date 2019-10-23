package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path"
	"path/filepath"

	"github.com/kylelemons/godebug/diff"
	"gopkg.in/yaml.v2"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type constraintTemplate struct {
	metav1.TypeMeta   `yaml:",inline"`
	metav1.ObjectMeta `yaml:"metadata,omitempty"`
	Spec              struct {
		Targets []struct {
			Rego string `yaml:"rego"`
		} `yaml:"targets"`
	} `yaml:"spec"`
}

// newConstraintTemplate unmarshals a ConstraintTemplate from a file
func newConstraintTemplate(file string) (constraintTemplate, error) {
	var c constraintTemplate

	f, err := ioutil.ReadFile(file)
	if err != nil {
		return c, err
	}
	err = yaml.Unmarshal(f, &c)
	if err != nil {
		return c, err
	}
	return c, nil
}

type test struct {
	dir string
	err error
}

func main() {
	var failedTests []test

	flag.Usage = func() {
		fmt.Fprintf(flag.CommandLine.Output(), "Usage of %s:\n  %s FILE [FILE...]\n", os.Args[0], path.Base(os.Args[0]))
	}
	flag.Parse()

	// Iterate over the dirs given as arguments
	for _, dir := range flag.Args() {
		// Unmarshal template from file
		c, err := newConstraintTemplate(filepath.Join(dir, "template.yaml"))
		if err != nil {
			failedTests = append(failedTests, test{
				dir: dir,
				err: err,
			})
			continue
		}

		// Extract rego from src file
		regoSrc, err := ioutil.ReadFile(filepath.Join(dir, "src.rego"))
		if err != nil {
			failedTests = append(failedTests, test{
				dir: dir,
				err: err,
			})
			continue
		}

		// Make sure the object in the template.yaml is a ConstraintTemplate
		if c.TypeMeta.Kind == "ConstraintTemplate" {
			// Check that there's only one target
			if len(c.Spec.Targets) != 1 {
				failedTests = append(failedTests, test{
					dir: dir,
					err: fmt.Errorf("%s: ConstraintTemplates must only have one target defined", c.ObjectMeta.Name),
				})
				continue
			}

			// Check that the target rego is the same as the source file
			if c.Spec.Targets[0].Rego != string(regoSrc) {
				failedTests = append(failedTests, test{
					dir: dir,
					err: fmt.Errorf("%s: the rego target doesn't match the content of src.rego:\n%s", c.ObjectMeta.Name, diff.Diff(string(regoSrc), c.Spec.Targets[0].Rego)),
				})
				continue
			}
		} else {
			failedTests = append(failedTests, test{
				dir: dir,
				err: fmt.Errorf("%s should be a ConstraintTemplate not %s", c.ObjectMeta.Name, c.TypeMeta.Kind),
			})
			continue
		}
	}

	if len(failedTests) > 0 {
		for _, test := range failedTests {
			if test.err != nil {
				log.Printf("FAIL: %s:\n%v", test.dir, test.err)
			}
		}
		log.Fatalf("failures found for %d templates", len(failedTests))
	}
}
