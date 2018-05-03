#!/usr/local/bin/python3

import sys

# execute me with
# find . -type f -exec ./replace.py <old_str> <new_str> {} +

def get_lines(file_name):
    fd = open(file_name, 'r')
    return [line for line in fd]

def save_file(file_name, lines):
    # print(file_name)
    # for line in lines:
        # print(line, end='')
    fd = open(file_name, 'w')
    for line in lines:
        fd.write(line)

def file_name_filter(file_names, filters):
    def is_ok(fn):
        for filter in filters:
            if filter in fn:
                return True
        return False
    return [fn for fn in file_names if is_ok(fn)]

def replace(lines, old_str, new_str):
    new_lines = []
    for l in lines:
        if old_str in l:
            new_lines.append(l.replace(old_str, new_str))
        else:
            new_lines.append(l)
    return new_lines

def main(old_str, new_str, *file_names):
    for f in file_name_filter(file_names, [".hpp", ".cpp"]):
        save_file(f, replace(get_lines(f), old_str, new_str))

if __name__ == "__main__":
    main(*sys.argv[1:])
