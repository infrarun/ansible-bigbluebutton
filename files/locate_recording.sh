#!/usr/bin/env -S bash -eo pipefail


# ---  V A R I A B L E S  --- #

SCRIPT_NAME=$(basename "$0")



# ---  S U B R O U T I N E S  --- #

print_help_message_and_exit() {
    cat << EOM
usage: $SCRIPT_NAME [-h]
       $SCRIPT_NAME [-t <min>] <frontend> <start time>

Locates a recording matching the specified frontend and start time.

options:
  -h        show this help message
  -t <min>  start time tolerance in minutes (default: 15)

positional arguments:
  frontend  frontend name
  start     start time (mind UTC offset!)

examples:
  # Find recordings started at 2024-06-11 13:37 UTC +/- 15 minutes
  $SCRIPT_NAME greenlight-local.bastelgenosse.de '2024-06-11 13:37'

  # Find recordings started at 2024-06-11 13:37 CEST +/- 30 minutes
  $SCRIPT_NAME -t 30 greenlight-local.bastelgenosse.de '2024-06-11 13:37 +0200'
EOM
    exit
}



# ---  M A I N   S C R I P T  --- #

tolerance=15
while getopts "ht:" option; do
    case $option in
        t) tolerance=$OPTARG ;;
        *) print_help_message_and_exit
    esac
done
shift $((OPTIND - 1))

if [ -z "$1" ]; then
    print_help_message_and_exit
fi

FRONTEND_NAME=$1
START_TIME=$(date +%s --date="$2")
tolerance=$((60 * tolerance))
FROM=$((START_TIME - tolerance))
TILL=$((START_TIME + tolerance))

shopt -s globstar nullglob
for candidate in /var/bigbluebutton/**/metadata.xml; do
    if ! grep -q ">$FRONTEND_NAME<" "$candidate"; then
        continue
    fi
    ts=${candidate##*-}
    ts=${ts%%/*}
    ts=$((ts / 1000))
    if [ "$ts" -gt "$FROM" ] && [ "$ts" -lt "$TILL" ]; then
        echo "$candidate"
    fi
done
