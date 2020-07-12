package main

import (
	"fmt"
	"os"
	"syscall"
)

func main() {
	var buff syscall.Utsname
	if err := syscall.Uname(&buff); err != nil {
		fmt.Println("Unknown")
		os.Exit(1)
	}
	fmt.Println("CPU     =", toString(buff.Machine[:]))
	fmt.Println("OS      =", toString(buff.Sysname[:]))
	fmt.Println("RELEASE =", toString(buff.Release[:]))
	fmt.Println("VERSION =", toString(buff.Version[:]))
	os.Exit(0)
}

func toString(c []int8) string {
	s := make([]byte, len(c))
	var xs int
	for ; xs < len(c); xs++ {
		if c[xs] == 0 {
			break
		}
		s[xs] = uint8(c[xs])
	}
	return string(s[0:xs])
}
