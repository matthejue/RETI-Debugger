#!/usr/bin/env python

# function that creates a named pipe in the /tmp folder and writes to it
def create_pipe():
    import os
    import time
    import sys
    # create a named pipe
    pipe_name = '/tmp/pipe'
    if not os.path.exists(pipe_name):
        os.mkfifo(pipe_name)
    # open the pipe
    pipe = open(pipe_name, 'w')
    # write to the pipe
    pipe.write('Hello from the pipe!\n')
    # close the pipe
    pipe.close()
    # wait for a bit
    time.sleep(5)
    # delete the pipe
    os.unlink(pipe_name)

if __name__ == '__main__':
    create_pipe()
