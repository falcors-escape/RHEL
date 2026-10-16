#!/bin/bash

source ./rh_account.env

sudo subscription-manager register --org="$RH_ORG_ID" --activationkey="$RH_ACTIVATION_KEY"
