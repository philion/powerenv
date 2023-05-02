package cmd

import "strings"

// getStdlib returns the stdlib.sh, with references to powerenv replaced.
func getStdlib(config *Config) string {
	return strings.Replace(stdlib, "$(command -v powerenv)", config.SelfPath, 1)
}
