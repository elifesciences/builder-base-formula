#!/usr/bin/env python3
import argparse
import json
import os
import re
from datetime import datetime

def create_event(pipeline, type, number=None, commit=None):
    microseconds_format = "%Y-%m-%dT%H:%M:%S.%fZ"
    event = {
        "pipeline": str(pipeline),
        "type": str(type),
        "datetime": datetime.utcnow().strftime(microseconds_format)
    }
    if number:
        event["number"] = int(number)
    if commit:
        event["commit"] = str(commit)
    return event

def store_event(event, directory):
    filename = "%s.json" % event['pipeline']
    absolute_path = os.path.join(directory, filename)
    with open(absolute_path, 'a') as f:
        f.write(json.dumps(event) + "\n")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('--directory', required=True, help='Directory to store the event in')
    parser.add_argument('--pipeline', required=True, help='Name of the pipeline being run')
    parser.add_argument('--type', required=True, help='Directory to store the event in')
    parser.add_argument('--number', type=int, help='Directory to store the event in')
    parser.add_argument('--commit', help='Directory to store the event in')

    args = vars(parser.parse_args())
    event_fields = dict(args)
    del event_fields['directory']
    store_event(create_event(**event_fields), args['directory'])



