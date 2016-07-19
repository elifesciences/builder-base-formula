import unittest
import subprocess
from verifyjunitxml import verify

class TestVerifyJunitXml(unittest.TestCase):
    def test_failed_test_case_with_no_top_level_errors_and_failures_count(self):
        self.assertEqual(17, verify("tests/failed-test-suite.junit.xml"))

    def test_running_script_passing_in_filename_returns_number_of_errors_and_failures_as_exit_code(self):
        self.assertEqual(
            17,
            subprocess.call(
                [
                    "python",
                    "verifyjunitxml.py",
                    "tests/failed-test-suite.junit.xml"
                ]
            )
        )
