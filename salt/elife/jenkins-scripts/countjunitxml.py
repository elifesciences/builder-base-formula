#!/usr/bin/env python3
import sys
import xml.etree.ElementTree as ET

if len(sys.argv) < 3:
    print("Checks a JUnit XML report contains a minimum number of tests")
    print("Usage: %s PATH_TO_REPORT MINIMUM_NUMBER" % sys.argv[0])
    print("Example: %s build/jest-junit/unit-tests.xml 400" % sys.argv[0])
    sys.exit(1)

path_to_report = sys.argv[1]
minimum_number = int(sys.argv[2])

test_count = int(ET.parse(path_to_report).getroot().attrib['tests']);
print('%s tests have been run' % test_count)
assert test_count > minimum_number, 'Are you sure enough tests have been run?'
