package cmd

import (
	"fmt"
)

// CmdStatus is `powerenv status`
var CmdPrompt = &Cmd{
	Name: "prompt",
	Desc: "generate a powerline prompt",
	Action: actionWithConfig(func(env Env, args []string, config *Config) error {
		fmt.Println("powerenv exec path", config.SelfPath)
		fmt.Println("powerenv_CONFIG", config.ConfDir)

		fmt.Println("bash_path", config.BashPath)
		fmt.Println("disable_stdin", config.DisableStdin)
		fmt.Println("warn_timeout", config.WarnTimeout)
		fmt.Println("whitelist.prefix", config.WhitelistPrefix)
		fmt.Println("whitelist.exact", config.WhitelistExact)

		loadedRC := config.LoadedRC()
		foundRC, err := config.FindRC()
		if err != nil {
			return err
		}

		if loadedRC != nil {
			formatRC("Loaded", loadedRC)
		} else {
			fmt.Println("No .envrc or .env loaded")
		}

		if foundRC != nil {
			formatRC("Found", foundRC)
		} else {
			fmt.Println("No .envrc or .env found")
		}

		return nil
	}),
}
