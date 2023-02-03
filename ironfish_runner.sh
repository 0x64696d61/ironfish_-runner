
#!/bin/bash

IRONFISH_NODENAME=$(ironfish config:get blockGraffiti | sed 's/\"//g')

if [ -z $IRONFISH_NODENAME ]; then
	echo 'IRONFISH_NODENAME not set';
	return 1;
else
	echo $IRONFISH_NODENAME
fi


function set_fee {
        FEE=$(printf "0.%08d\n" $(shuf -i 1-190 -n 1))
}


function wait_pending_trannsactions {
	while(true); do
	if [ $(ironfish wallet:transactions | grep -E "pending|unconfirmed" | wc -l) -eq 0 ]; then
   		echo "have NO pending or unconfirmed transactions";
	else
   		echo 'waiting .... 1m'
   		sleep 1m
	fi
	done
}

function mint_token {
        RAND_MINT=$(shuf -i 300-500000 -n 1)
	RAND=$(shuf -i 1-200 -n 1)
	set_fee

	ironfish wallet:mint -n "$IRONFISH_NODENAME" -m "$IRONFISH_NODENAME" -a $RAND_MINT   --confirm -o $FEE
}

function send_token {
	asset_addr=$(ironfish wallet:balances | grep -v 'Account:'  | grep "$IRONFISH_NODENAME" | awk '{print $2}')
	echo $asset_addr
	set_fee

	ironfish wallet:send  -a $RAND --to dfc2679369551e64e3950e06a88e68466e813c63b100283520045925adbe59ca -i $asset_addr -o $FEE --confirm
}

function burn_token {
	asset_addr=$(ironfish wallet:balances | grep -v 'Account:'  | grep "$IRONFISH_NODENAME" | awk '{print $2}')
	echo $asset_addr
	set_fee

	ironfish wallet:burn --assetId $asset_addr --amount $RAND  -o $FEE --confirm
}


mint_token
wait_pending_trannsactions
send_token
wait_pending_trannsactions
burn_token
