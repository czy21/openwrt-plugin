#!/bin/sh

# auth-user-pass-verify "/etc/openvpn/auth.sh <auth_method> <auth_file>" via-env
# auth-user-pass-verify "/etc/openvpn/auth.sh plain <auth_file>" via-env
# auth-user-pass-verify "/etc/openvpn/auth.sh radius <radius_server> <radius_secret>" via-env

auth_method="$1"
LOG_TAG="openvpn-auth.${auth_method}"

if [ -z "${username}" ] || [ -z "${password}" ]; then
  logger -t $LOG_TAG "FAIL: empty username or password (username='${username}')"
  exit 1
fi

if [ "${auth_method}" = "plain" ]; then

  PASSFILE="$2"

  if [ ! -r "${PASSFILE}" ]; then
    logger -t $LOG_TAG "FAIL: Cannot read PASSFILE: ${PASSFILE}"
    exit 1
  fi

  CORRECT_PASSWORD=$(awk -v user="$username" '!/^;/&&!/^#/&&$1==user{print $2;exit}' "$PASSFILE")

  if [ -z "${CORRECT_PASSWORD}" ]; then
    logger -t $LOG_TAG "FAIL: ${username} not exists"
    exit 1
  fi

  if [ "${password}" = "${CORRECT_PASSWORD}" ]; then
    exit 0
  else
    logger -t $LOG_TAG "FAIL: ${username} password incorrect"
    exit 1
  fi
fi

if [ "${auth_method}" = "radius" ]; then

  radius_server="$2"
  radius_secret="$3"

  ret=$(echo "User-Name=${username},User-Password=${password}" | radclient -x ${radius_server} auth ${radius_secret})

  if echo "$ret" | grep -q "Access-Accept"; then
    exit 0
  else
    logger -t $LOG_TAG "FAIL: ${username}"
    exit 1
  fi
fi

exit 1