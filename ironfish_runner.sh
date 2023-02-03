#!/bin/bash

IRONFISH_NODE_NAME=$(ironfish config:get blockGraffiti | sed 's/\"//g')

if [ -z "$IRONFISH_NODE_NAME" ]; then
	echo 'IRONFISH_NODE_NAME not set';
	return 1;
else
	echo "$IRONFISH_NODE_NAME"
fi

function set_fee {
        # shellcheck disable=SC2046
        FEE=$(printf "0.%08d\n" $(shuf -i 1-190 -n 1))
}

function wait_pending_trannsactions {
	while(true); do

	# shellcheck disable=SC2046
	if [ $(ironfish wallet:transactions | grep -c -E "pending|unconfirmed") -eq 0 ]; then
   		echo "You have NO pending or unconfirmed transactions";
   		return 0
	else
   		echo 'Waiting for transactions to be confirmed... 1m'
   		sleep 1m
	fi
	done
}

function mint_token {
  RAND_MINT=$(shuf -i 300-500000 -n 1)
  RAND=$(shuf -i 1-200 -n 1)
  set_fee

	ironfish wallet:mint -n "$IRONFISH_NODE_NAME" -m "$IRONFISH_NODE_NAME" -a "$RAND_MINT"   --confirm -o "$FEE"
}

function send_token {
	asset_addr=$(ironfish wallet:balances | grep -v 'Account:'  | grep "$IRONFISH_NODE_NAME" | awk '{print $2}')
	echo "$asset_addr"
	set_fee

	ironfish wallet:send  -a "$RAND" --to dfc2679369551e64e3950e06a88e68466e813c63b100283520045925adbe59ca -i $asset_addr -o $FEE --confirm
}

function burn_token {
	asset_addr=$(ironfish wallet:balances | grep -v 'Account:'  | grep "$IRONFISH_NODE_NAME" | awk '{print $2}')
	echo "$asset_addr"
	set_fee

	ironfish wallet:burn --assetId "$asset_addr" --amount "$RAND"  -o "$FEE" --confirm
}

mint_token
wait_pending_trannsactions
send_token
wait_pending_trannsactions
burn_token
