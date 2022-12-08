#!/usr/bin/env/python3

import csv
import re
import sys

# The input is the table displaying variants for an istope, a .html file
table = sys.argv[1]

# This is the output table, a colored .html file 
col_table = sys.argv[2]

with open(table,"r") as read_table:
    reader = csv.reader(read_table, delimiter= "<")
    with open(col_table,"w") as color_table:
        for row in reader:
            if len(row) != 0:
                if row[0] != "  " or row[-1] == "/table>":
                    content = "<".join(row)
                    color_table.write(content)
                else:
                    contents = "<".join(row)
                    nt = re.search("(<td> [a-z]{4})([a-z])([a-z]{4} <\/td> <\/tr>)",contents)
                    color_nt = re.sub("(<td> [a-z]{4})([a-z])([a-z]{4} <\/td> <\/tr>)",f"{nt.group(1)}<font color='Blue'><strong>{nt.group(2)}</strong></font>{nt.group(3)}",contents)
                    color_table.write(color_nt)

