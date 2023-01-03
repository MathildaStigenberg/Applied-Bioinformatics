#!/usr/bin/env bash

sed -i "s/>MtDNA/>$(basename ${1%%.*})/" ${1}
