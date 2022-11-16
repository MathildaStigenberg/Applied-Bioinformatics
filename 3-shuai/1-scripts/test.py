#!/usr/bin/env python3
from subprocess import Popen

Popen("module load bioinfo-tools", shell = True)
Popen("module list", shell = True)
