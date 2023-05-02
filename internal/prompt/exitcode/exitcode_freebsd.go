package exitcode

var Signals = map[int]string{
	0x01: "SIGHUP",
	0x02: "SIGINT",
	0x03: "SIGQUIT",
	0x04: "SIGILL",
	0x05: "SIGTRAP",
	0x06: "SIGABRT",
	0x07: "SIGEMT",
	0x08: "SIGFPE",
	0x09: "SIGKILL",
	0x0a: "SIGBUS",
	0x0b: "SIGSEGV",
	0x0c: "SIGSYS",
	0x0d: "SIGPIPE",
	0x0e: "SIGALRM",
	0x0f: "SIGTERM",
	0x10: "SIGURG",
	0x11: "SIGSTOP",
	0x12: "SIGTSTP",
	0x13: "SIGCONT",
	0x14: "SIGCHLD",
	0x15: "SIGTTIN",
	0x16: "SIGTTOU",
	0x17: "SIGIO",
	0x18: "SIGXCPU",
	0x19: "SIGXFSZ",
	0x1a: "SIGVTALRM",
	0x1b: "SIGPROF",
	0x1c: "SIGWINCH",
	0x1d: "SIGINFO",
	0x1e: "SIGUSR1",
	0x1f: "SIGUSR2",
	0x20: "SIGTHR",
	0x21: "SIGLIBRT",
}
