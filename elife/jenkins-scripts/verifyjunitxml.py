#!/usr/bin/env python3
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
        for child in root:
            if 'errors' in child.attrib:
                errors += int(child.attrib['errors'])
            if 'failures' in child.attrib:
                failures += int(child.attrib['failures'])
    if logger:
        logger("Errors: %d. Failures: %d\n" % (errors, failures))
    warning_test_cases = tree.findall('.//testcase[@name="Warning"]')
    if warning_test_cases is None:
        warnings = 0
    else:
        warnings = len(warning_test_cases)
    return errors + failures + warnings

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: %s junit.xml" % (sys.argv[0], ))
        exit(1)
    exit(verify(sys.argv[1], lambda text: sys.stdout.write(text)))

