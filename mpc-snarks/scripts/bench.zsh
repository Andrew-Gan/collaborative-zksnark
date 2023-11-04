#!/usr/bin/env zsh
trap "exit" INT TERM
trap "kill 0" EXIT

pkill proof || true

proof=$1
infra=$2
size=$3
n_parties=$4
if [[ -z $BIN ]]
then
    BIN=./target/release/proof
fi
if [[ -z $NETWORK_CONFIG ]]
then
    NETWORK_CONFIG=./data/$n_parties
fi
LABEL="timed section"


function usage {
  echo "Usage: $0 {groth16,marlin,plonk} {hbc,spdz,gsz,local,ark-local} N_SQUARINGS N_PARTIES" >&2
  exit 1
}

if [ "$#" -ne 4 ] ; then
    usage
fi

case $proof in
    groth16|marlin|plonk)
        ;;
    *)
        usage
esac

case $infra in
    hbc|spdz|gsz|local|ark-local)
        ;;
    *)
        usage
esac

sleep 1

case $infra in
    hbc|spdz|gsz)
        PROCS=()
        for i in $(seq 0 $(($n_parties - 1)))
        do
          #$BIN $i ./data/4 &
          mkdir -p ./output
          if [ $i -eq 0 ]
          then
            $BIN -p $proof -c squaring --computation-size $size mpc --hosts $NETWORK_CONFIG --party $i --alg $infra > output/delegator_full.out &
            cat output/delegator_full.out | rg "^··End:" > output/delegator_filtered.out
            pid=$!
          else
            $BIN -p $proof -c squaring --computation-size $size mpc --hosts $NETWORK_CONFIG --party $i --alg $infra > output/party${i}_full.out &
            cat output/party${i}_full.out | rg "^··End:" > output/party${i}_filtered.out
            pid=$!
          fi
          PROCS+=($pid)
        done

        for pid in ${PROCS}
        do
          wait $pid
        done
    ;;
    local)
        $BIN -p $proof -c squaring --computation-size $size local | rg "End: *$LABEL" | rg -o '[0-9][0-9.]*.s'
    ;;
    ark-local)
        $BIN -p $proof -c squaring --computation-size $size ark-local | rg "End: *$LABEL" | rg -o '[0-9][0-9.]*.s'
    ;;
    *)
        usage
    ;;
esac

trap - INT TERM EXIT
