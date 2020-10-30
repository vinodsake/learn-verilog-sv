#!bin/bash

for dir in *; do [ -d "$dir" ] && yes|cp -rf Makefile "$dir" ; done
