package cmd

import (
	"testing"
)

func TestPrompt(t *testing.T) {

	// note to self: what's expected?

	env := Env{"FOO": "bar"}

	out := env.Serialize()

	env2, err := LoadEnv(out)
	if err != nil {
		t.Error("parse error", err)
	}

	if env2["FOO"] != "bar" {
		t.Error("FOO != bar", env2["FOO"])
	}

	if len(env2) != 1 {
		t.Error("len != 1", len(env2))
	}
}
