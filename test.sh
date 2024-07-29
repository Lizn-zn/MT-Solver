#!/bin/bash

start=$(date +%s)

mtsolve --fpath ./test/cases/52.smt --mplrc "--timeout 500000"

end=$(date +%s)
take=$(( end - start ))
echo Time taken to execute commands is ${take} seconds.
