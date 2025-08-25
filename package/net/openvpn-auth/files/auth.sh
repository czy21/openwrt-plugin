#!/bin/sh
# auth-user-pass-verify "/etc/openvpn/auth.sh <auth file>" via-env

PASSFILE="$1"
LOG_TAG="$PASSFILE"
if [ ! -r "${PASSFILE}" ]; then
  logger -t $LOG_TAG "Could not open password file \"${PASSFILE}\" for reading."
  exit 1
fi

CORRECT_PASSWORD=`awk '!/^;/&&!/^#/&&$1=="'${username}'"{print $2;exit}' ${PASSFILE}`

if [ "${CORRECT_PASSWORD}" = "" ]; then
  logger -t $LOG_TAG "User does not exist: username=\"${username}\", password=\"${password}\""
  exit 1
fi

if [ "${password}" != "${CORRECT_PASSWORD}" ]; then
  logger -t $LOG_TAG "Incorrect password: username=\"${username}\", password=\"${password}\""
  exit 1
fi

exit 0