# filters out noise in logrotate in Ubuntu 18.04
# https://github.com/logrotate/logrotate/issues/169
# if this can be done with an elaborate grep or sed or awk or
# whatever, feel free to replace it.
import fileinput
buffer=[]
for line in fileinput.input():
    if line.lower().startswith('error:'):
        buffer.append(line)
        continue
    if buffer \
       and (line.startswith('switching euid to') or line.startswith('switching uid to')) \
       and buffer[-1].startswith('error: Compressing program wrote following message to stderr'):
        buffer.pop() # remove last entry
# if errors remain after filtering the noise out, exit successfully
# this mimics current grep behaviour on matching on an error
if buffer:
    exit(0)
# no errors, die. the 'logger' won't be called, errors won't be reported
exit(1)
