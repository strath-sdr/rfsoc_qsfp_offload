#!/bin/bash

#############################################################
# This script is only compatible with Mellanox QSFP Network #
# Interface Cards and mstflint. For other NICs and software #
# please refer to the relevant documentation.               #
#############################################################

DEVICE=$(lspci | grep Mellanox | head -n 1 | grep -o '^[^ ]*')
MAX_DATA_RATE=100G
PORT_STATE=TG

mstconfig -d $DEVICE q

mstlink -d $DEVICE --link_mode_force --speeds $MAX_DATA_RATE
mstlink -d $DEVICE -k RS --fec_speed $MAX_DATA_RATE
mstlink -d $DEVICE --port_state $PORT_STATE
mstlink -d $DEVICE -m
