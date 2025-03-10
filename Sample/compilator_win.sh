#!/bin/bash

# @pawn-lang compiler 3.10.7^ - ("https://github.com/pawn-lang/compiler")

# Usage:   pawncc <filename> [filename...] [options]
# Options:
#        -A<num>  alignment in bytes of the data segment and the stack
#        -a       output assembler code
#        -C[+/-]  compact encoding for output file (default=+)
#        -c<name> codepage name or number; e.g. 1252 for Windows Latin-1
#        -Dpath   active directory path
#        -d<num>  debugging level (default=-d1)
#            0    no symbolic information, no run-time checks
#            1    run-time checks, no symbolic information
#            2    full debug information and dynamic checking
#            3    same as -d2, but implies -O0
#        -e<name> set name of error file (quiet compile)
#        -H<hwnd> window handle to send a notification message on finish
#        -i<name> path for include files
#        -l       create list file (preprocess only)
#        -o<name> set base name of (P-code) output file
#        -O<num>  optimization level (default=-O1)
#            0    no optimization
#            1    JIT-compatible optimizations only
#            2    full optimizations
#        -p<name> set name of "prefix" file
#        -R[+/-]  add detailed recursion report with call chains (default=-)
#        -r[name] write cross reference report to console or to specified file
#        -S<num>  stack/heap size in cells (default=4096)
#        -s<num>  skip lines from the input file
#        -t<num>  TAB indent size (in character positions, default=8)
#        -v<num>  verbosity level; 0=quiet, 1=normal, 2=verbose (default=1)
#        -w<num>  disable a specific warning by its number
#        -X<num>  abstract machine size limit in bytes
#        -XD<num> abstract machine data/stack size limit in bytes
#        -Z[+/-]  run in compatibility mode (default=-)
#        -E[+/-]  turn warnings in to errors
#        -\       use '\' for escape characters
#        -^       use '^' for escape characters
#        -;[+/-]  require a semicolon to end each statement (default=-)
#        -([+/-]  require parantheses for function invocation (default=-)
#        sym=val  define constant "sym" with value "val"
#        sym=     define constant "sym" with value 0

COMPILERS() {
  BASHDIR=$(dirname "$0")
  BASHPAWNCC=""

  while IFS= read -r -d '' file; do
    if [[ -f "$file" ]]; then
      BASHPAWNCC="$file"
      break
    fi
  done < <(find "$BASHDIR" -type f -name "pawncc.exe" -print0)

  if [[ -z "$BASHPAWNCC" ]]; then
    echo
    echo "# [$(date +%T)] pawncc not found in any subdirectories."
    echo
    read -r -p "Press any key to continue..."
    exit 1
  fi

  while IFS= read -r -d '' file; do
    if [[ -f "$file" ]]; then
      AMX="${file%.io*}.amx"
      "$BASHPAWNCC" "$file" -o"$AMX" -O0 -d2
    fi
  done < <(find "$BASHDIR" -type f -name "*.io*" -print0)

  read -r -p "Press any key to continue..."
  COMPILERS
}

COMPILERS
