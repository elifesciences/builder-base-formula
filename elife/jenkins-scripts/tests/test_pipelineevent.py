import unittest
import subprocess
import datetime
import json
import os
from glob import glob
from mock import patch
from pipelineevent import create_event

class TestPipelineEvent(unittest.TestCase):
    def setUp(self):
        for test_file in glob("/tmp/test-journal*"):
            os.remove(test_file)

    @patch('pipelineevent.datetime')
    def test_create_event(self, mock_datetime):
        mock_datetime.utcnow.return_value = datetime.datetime(2017, 1, 1)
        event = create_event(type="pipeline-started", pipeline="test-journal", number=42, commit="20cef59d6af19de64d43ac029514f1977ac91f82")
        self.assertEqual(
            event,
            {
                'pipeline': 'test-journal',
                'type': 'pipeline-started',
                'number': 42,
                'datetime': '2017-01-01T00:00:00.000000Z',
                'commit': '20cef59d6af19de64d43ac029514f1977ac91f82',
            }
        )

    def test_running_script_passing_in_parameters(self):
        parameters = [
            "python",
            "pipelineevent.py",
            "--directory",
            "/tmp",
            "--pipeline",
            "test-journal",
            "--type",
            "pipeline-started",
            "--number",
            "42",
            "--commit",
            "20cef59d6af19de64d43ac029514f1977ac91f82"
        ]
        subprocess.check_output(parameters)
        subprocess.check_output(parameters)
        written_files = glob("/tmp/test-journal.json")
        self.assertEqual(len(written_files), 1)
        with open(written_files[0], 'r') as fp:
            first_line = json.loads(fp.readline())
            second_line = json.loads(fp.readline())
            self.assertEqual(first_line['pipeline'], 'test-journal')
            self.assertEqual(first_line['type'], 'pipeline-started')
            self.assertEqual(first_line['number'], 42)
            self.assertEqual(first_line['commit'], '20cef59d6af19de64d43ac029514f1977ac91f82')
            self.assertGreater(second_line['datetime'], first_line['datetime'])

