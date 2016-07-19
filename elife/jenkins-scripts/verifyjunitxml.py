#!/usr/bin/env python
import xml.etree.ElementTree as ET
import sys

def verify(filename, logger=None):
    tree = ET.parse(filename)
    root = tree.getroot()
    if 'errors' in root.attrib:
        errors = int(root.attrib['errors'])
        failures = int(root.attrib['failures'])
    else:
        errors = 0
        failures = 0
        for i in root.getchildren():
            if 'errors' in i.attrib:
                errors += int(i.attrib['errors'])
            if 'failures' in i.attrib:
                failures += int(i.attrib['failures'])
    if logger:
        logger("Errors: %d. Failures: %d\n" % (errors, failures))
    return errors + failures

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: %s junit.xml" % (sys.argv[0], ))
        exit(1)
    exit(verify(sys.argv[1], lambda text: sys.stdout.write(text)))

