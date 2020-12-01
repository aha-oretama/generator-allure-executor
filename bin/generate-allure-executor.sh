#!/usr/bin/env bash
set -e

usage () {

cat <<EOT
Usage:
  "$0" [-u url] [-o builOrder] [-b buildName] [-B buildUrl] [-r reportName] [-R reportUrl]
Description:

Environment variables are needed:
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

function circleci() {
  if [ -z "${CIRCLE_JOB}"  ]; then
    return 1
  fi

  name="CircleCI"
  type="" # CircleCI icon is not provided
  url="$URL"
  buildOrder="${BUILD_ORDER:-$CIRCLE_BUILD_NUM}"
  buildName="${BUILD_NAME:-$CIRCLE_JOB}"
  buildUrl="${BUILD_URL:-$CIRCLE_BUILD_URL}"
  reportName="${REPORT_NAME}"
  reportUrl="${REPORT_URL}"
}

circleci
printf "$JSON_FMT" "$name" "$type" "$url" "$buildOrder" "$buildName" "$buildUrl" "$reportName" "$reportUrl" > executor.json
