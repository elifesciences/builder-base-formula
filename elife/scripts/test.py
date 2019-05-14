import syslog
import os
import sys
import time

pid = os.getpid()
aid = sys.argv[1:2]

iteration=0
while True:
    iteration += 1
    message = "aid: %s, pid: %s, iteration: %s" % (aid, pid, iteration)
    syslog.syslog(message)
    time.sleep(5)
