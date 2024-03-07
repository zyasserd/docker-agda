#!/usr/bin/env python3

"""
SCRIPT DESCRIPTION:

    This Python script is a command-line tool designed to selectively comment or
    uncomment lines in a specified text file based on user-defined conditions.

    It uses special comments in the format `#!! if 'flag' => actions` to determine which lines to modify.

    The actions part consists of space-separated elements, each representing a relative line number modification.

    If an action is prefixed with `#``, it comments the specified line; otherwise, it uncomments it. 

    It's important to note that the script supports only Python-style commenting.

"""


import sys
import re



# prevent the printing of traceback on Error
sys.tracebacklimit = 0

def comment(s : str):
    return '# ' + s

def uncomment(s : str):
    re_results = re.search(r"^\s*#\s?(.*\n?)", s)
    if not re_results:
        return None
    return re_results.groups()[0]



if len(sys.argv) < 2:
    print("USAGE: commentor.py file [flags...]")
    exit(1)

file = sys.argv[1]
flags = sys.argv[2:]

with open(file, 'r') as fin:
    lines = fin.readlines()

comment_set = set()
uncomment_set = set()

pattern = r"^#!!\s+if\s+'(.+?)'\s*=>((?:\s+#?\d+)*)\s*$"


for line_i, line in enumerate(lines):
    if line.startswith("#!!"):
        re_results = re.search(pattern, line)
        if not re_results:
            raise SyntaxError(f"Invalid syntax at line {line_i+1}")
        
        flag, actions = re_results.groups()
        if flag in flags:
            for action in actions.split():
                if action.startswith('#'):
                    comment_set.add(line_i + int(action[1:]))
                else:
                    uncomment_set.add(line_i + int(action))
            lines[line_i] = lines[line_i][:-1] + " ✅\n"
        else:
            lines[line_i] = lines[line_i][:-1] + " ❌\n"



# intersection between `comment_set` and `uncomment_set` should be empty
assert len(comment_set.intersection(uncomment_set)) == 0 , "There is an overlap in the lines to be comments and uncommented"

# comment
for line_i in comment_set:
    lines[line_i] = comment(lines[line_i])

# uncomment
for line_i in uncomment_set:
    uncomment_result = uncomment(lines[line_i])
    if uncomment_result == None:
        raise ValueError(f"Line {line_i + 1} is not commented!")
    lines[line_i] = uncomment_result

# print in the stdout
sys.stdout.writelines(lines)

