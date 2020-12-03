#!/usr/bin/env bash
set -ex

usage () {

cat <<EOT
Usage:
  "$0" [-u url] [-o builOrder] [-b buildName] [-B buildUrl] [-r reportName] [-R reportUrl]
Description:
  Generate allure's executor.json having executor's information.
  Support for GitHub Actions, CircleCI.
Output:
  executor.json
EOT

exit 1
}

while getopts u:o:b:B:r:R:h option
do
  case $option in
    u)
      readonly URL="$OPTARG"
      ;;
    o)
      readonly BUILD_ORDER="$OPTARG"
      ;;
    b)
      readonly BUILD_NAME="$OPTARG"
      ;;
    B)
      readonly BUILD_URL="$OPTARG"
      ;;
    r)
      readonly REPORT_NAME="$OPTARG"
      ;;
    R)
      readonly REPORT_URL="$OPTARG"
      ;;
    h)
      usage
      ;;
    \?)
      usage
      ;;
  esac
done

readonly JSON_FMT='{"name": "%s", "type": "%s", "url": "%s", "buildOrder": %d, "buildName": "%s", "buildUrl": "%s", "reportName": "%s", "reportUrl": "%s" }\n'

function err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

function verify_circleci() {
  if [ -z "${REPORT_URL}" ]; then
    err "reportUrl with -r option must be passed."
    usage
  fi
}

function circleci() {
  if [ -z "${CIRCLE_JOB}"  ]; then
    return 0
  fi

  verify_circleci

  name="CircleCI"
  type="" # CircleCI icon is not provided
  url="$URL"
  buildOrder="${BUILD_ORDER:-$CIRCLE_BUILD_NUM}"
  buildName="${BUILD_NAME:-$CIRCLE_JOB}"
  buildUrl="${BUILD_URL:-$CIRCLE_BUILD_URL}"
  reportName="${REPORT_NAME:-$CIRCLE_JOB report}"
  reportUrl="${REPORT_URL}"
}

function verify_github_actions() {
  if [ -z "${REPORT_URL}" ]; then
    err "reportUrl with -r option must be passed."
    usage
  fi
}

function github_actions() {
  if [ -z "${GITHUB_ACTION}"  ]; then
    return 0
  fi

  verify_github_actions

  name="GitHub Actions"
  type="github"
  url="$URL"
  buildOrder="${BUILD_ORDER:-$GITHUB_RUN_NUMBER}"
  buildName="${BUILD_NAME:-$GITHUB_WORKFLOW}"
  buildUrl="${BUILD_URL:-https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID}"
  reportName="${REPORT_NAME:-$GITHUB_WORKFLOW report}"
  reportUrl="${REPORT_URL}"
}

circleci
github_actions
printf "$JSON_FMT" "$name" "$type" "$url" "$buildOrder" "$buildName" "$buildUrl" "$reportName" "$reportUrl" > executor.json
