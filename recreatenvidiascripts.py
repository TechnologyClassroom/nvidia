#!/bin/python3

# python3 recreatenvidiascripts.py oldversion newversion
# Michael McMahon
# Example: python3 recreatenvidiascripts 39025 39042

from argparse import ArgumentParser  # Add switch arguments for python 2.7&3.2+
# from re import
import fileinput
from shutil import copy2  # Copy files

# argparse
# This section adds switch -h and argument to the script.
parser = ArgumentParser(
    description='Plot CSV visualizes csv data using matplotlib.')
parser.add_argument('versions', nargs='+', type=str,
                    help='a csv spreadsheet to be graphed')
args = parser.parse_args()

# Variables
OLD = args.versions[0]
NEW = args.versions[1]
OLDV = OLD[0:3] + "." + OLD[3:]
NEWV = NEW[0:3] + "." + NEW[3:]
OLDF1 = "nvidia" + OLD + "gpu.sh"
OLDF2 = "nvidia" + OLD + "gpulan.sh"
OLDF3 = "nvidia" + OLD + "mb.sh"
OLDF4 = "nvidia" + OLD + "mblan.sh"
NEWF1 = "nvidia" + NEW + "gpu.sh"
NEWF2 = "nvidia" + NEW + "gpulan.sh"
NEWF3 = "nvidia" + NEW + "mb.sh"
NEWF4 = "nvidia" + NEW + "mblan.sh"

print("Old version is " + OLD)
print("New version is " + NEW)

# Copy Files
# Synatx: copy2(src, dst)
copy2(OLDF1, NEWF1)
copy2(OLDF2, NEWF2)
copy2(OLDF3, NEWF3)
copy2(OLDF4, NEWF4)

# Syntax replace("OldString", "NewString", "Filename")
#pysed.replace(OLDV, NEWV, NEWF1)
#pysed.replace(OLDV, NEWV, NEWF2)
#pysed.replace(OLDV, NEWV, NEWF3)
#pysed.replace(OLDV, NEWV, NEWF4)
#pysed.replace(OLD, NEW, NEWF1)
#pysed.replace(OLD, NEW, NEWF2)
#pysed.replace(OLD, NEW, NEWF3)
#pysed.replace(OLD, NEW, NEWF4)

with fileinput.input(files=(NEWF1, NEWF2, NEWF3, NEWF4), inplace=True) as files:
    for line in files:
        print(line.replace(OLD, NEW), end='')

with fileinput.input(files=(NEWF1, NEWF2, NEWF3, NEWF4), inplace=True) as files:
    for line in files:
        print(line.replace(OLDV, NEWV), end='')
