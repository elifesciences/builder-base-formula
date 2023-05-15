#!/bin/bash
set -e

# Parses specified YAML for all ERA articles and creates/posts jobs to the specified message queue.
TriggerWorkflows()
{
  REGEX_ERA_ARTICLE_ID="^'([0-9]{5,})':$" # note use of [0-9] to avoid \d which is not suppored in bash
  REGEX_ERA_ARTICLE_PROPERTY="(date|display|download): '?([^']+)"
  SQS_QUEUE_URL="https://sqs.us-east-1.amazonaws.com/512686554592/${WORKFLOW_ENVIRONMENT}-era-incoming-queue";

  while read -r LINE; do
    if [[ "$LINE" =~ $REGEX_ERA_ARTICLE_ID ]]; then
      ARTICLE="{ \"id\": \"${BASH_REMATCH[1]}\""

      while [ ! -z "$LINE" ]; do
        read -r LINE || true # returns non-zero for EOF
        if [[ "$LINE" =~ $REGEX_ERA_ARTICLE_PROPERTY ]]; then
          ARTICLE+=", \"${BASH_REMATCH[1]}\": \"${BASH_REMATCH[2]}\""
        fi
      done;

      ARTICLE+=" }"

      echo "Queuing message for ${ARTICLE}"
      aws sqs send-message --queue-url "${SQS_QUEUE_URL}" --message-body "${ARTICLE}"
    fi
  done < "$PATH_TO_ERA_ARTICLES_YAML"
}

PrintUsage()
{
  echo " "
  echo "$0 [options]"
  echo " "
  echo "Script to trigger bot workflows when an era article is published."
  echo " "
  echo "options:"
  echo "    -i, --input"
  echo "       Path to the yaml file containing a list of published ERA articles"
  echo "       e.g. $0 --input era-articles.yaml"
  echo "    -e, --environment"
  echo "       The environment to trigger the workflows for"
  echo "       e.g. $0 --environment ci"
  echo " "
}

# Parse options
if [ $# -eq 0 ]
then
  PrintUsage
  exit 1
else
  while [ $# -gt 0 ]
  do
    case "$1" in
      --environment|-e)
        WORKFLOW_ENVIRONMENT="$2"
        shift
        shift
        ;;
      --input|-i)
        PATH_TO_ERA_ARTICLES_YAML="$2"
        shift
        shift
        ;;
      *) 
        PrintUsage
        exit 1
        ;;
    esac
  done
fi

# Sanity check that required options are set
if [ -z "$WORKFLOW_ENVIRONMENT" ] || [ -z "$PATH_TO_ERA_ARTICLES_YAML" ]; then
  PrintUsage
  exit 1
fi

TriggerWorkflows
exit 0
