#!/usr/bin/python3

import sys
import re

def main(args):
    if len(args) != 2:
        print(f"Usage: python3 {args[0]} <tex file>")
        exit(-1)

    file_path = args[1]
    f = open(file_path)
    content = f.read()
    data = re.search(r'\\newcommand\{\\documentversionlongcount\}\{(.*)\\xspace\}', content)
    if data is None:
        print(f"No \documentversionlongcount tag found in {file_path}")
        exit(-1)

    print(data.groups()[0])

if __name__ == '__main__':
    main(sys.argv)
