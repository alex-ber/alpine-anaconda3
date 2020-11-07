#!/usr/bin/python3

import keyring
import getpass


#see https://alexwlchan.net/2016/11/you-should-use-keyring/
#for Windows, see https://stackoverflow.com/questions/14756352/how-is-python-keyring-implemented-on-windows

def main():
    print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
    print(keyring.get_keyring())
    print('ssssssssssssssssssssssssssssssss')
    keyring.set_password("https://upload.pypi.org/legacy", "username",  getpass.getpass())
    print(keyring.get_password("https://upload.pypi.org/legacy", "username"))


if __name__ == "__main__":
    main()
