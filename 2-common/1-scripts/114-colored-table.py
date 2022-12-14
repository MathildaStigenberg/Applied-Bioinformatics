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
                    #ref = re.search("(<td> )([A-Z])([A-Z]*)(->)([A-Z]* <\/td>)",contents)
                    #nt = re.search("(<td> [A-Z]{4})([A-Z])([A-Z]{4} <\/td> <\/tr>)",contents)
                    nt = re.search("(<td> [A-Z]{8})([A-Z])([[.]*[]]*[A-Z]* <\/td> <\/tr>)", contents)
                    color_nt = re.sub("(<td> [A-Z]{8})([A-Z])([[.]*[]]*[A-Z]* <\/td> <\/tr>)",f"{nt.group(1)}<font color='Blue'><strong>{nt.group(2)}</strong></font>{nt.group(3)}",contents)
                    color_table.write(color_nt)
        color_table.write("<style>")
        color_table.write("table, th, td {text-align: center; border-collapse: collapse; font-family: Courier New; table-layout: fixed; padding: 5px}")
        color_table.write("td {border: 0;}")
        color_table.write("th {border: thin}")
        color_table.write("tr:nth-child(even) {background-color: rgb(240, 239, 239);}")
        color_table.write("</style>")

