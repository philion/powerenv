package cmd

import (
	"errors"
)

// CmdCurrent is `powerenv current`
var CmdCurrent = &Cmd{
	Name:    "current",
	Desc:    "Reports whether powerenv's view of a file is current (or stale)",
	Args:    []string{"PATH"},
	Private: true,
	Action:  actionSimple(cmdCurrentAction),
}

func cmdCurrentAction(env Env, args []string) (err error) {
	if len(args) < 2 {
		err = errors.New("missing PATH argument")
		return
	}

	path := args[1]
	watches := NewFileTimes()
	watchString, ok := env[powerenv_WATCHES]
	if ok {
		err = watches.Unmarshal(watchString)
		if err != nil {
			return
		}
	}

	err = watches.CheckOne(path)

	return
}
