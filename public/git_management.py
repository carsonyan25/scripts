#!/usr/bin/python
#code:utf8

import commands
import sys

def git_pull():
        path=sys.argv[1]
        result=commands.getoutput(" cd {directory} && git pull " .format(directory=path))
        print result


git_pull()

