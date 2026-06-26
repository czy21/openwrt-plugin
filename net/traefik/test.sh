#!/bin/sh

traefik version | grep -F "$PKG_VERSION"
