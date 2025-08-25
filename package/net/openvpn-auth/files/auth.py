#! /usr/bin/python3
import os
import pathlib
import sys


def main():
    username = os.environ['username']
    password = os.environ['password']
    passfile = sys.argv[1]
    passfile = pathlib.Path(passfile)
    passfile_str: str = passfile.read_text(encoding="utf-8")
    passfile_users = {}
    for t in passfile_str.split('\n'):
        t_arr = t.split(" ")
        if t_arr.__len__() == 2:
            passfile_users[t_arr[0]] = t_arr[1]
    passfile_password = passfile_users.get(username)
    if not passfile_password:
        os.system("logger -t {} \"User does not exist: username=\"{}\", password=\"{}\"\"".format(passfile.as_posix(), username, password))
        sys.exit(1)
    elif password != passfile_password:
        os.system("logger -t {} \"Incorrect password: username=\"{}\", password=\"{}\"\"".format(passfile.as_posix(), username, password))
        sys.exit(1)
    sys.exit(0)


if __name__ == '__main__':
    main()
