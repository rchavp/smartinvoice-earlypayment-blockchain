#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
trap "echo 'Interrupted. Aborting with error exit status.'; exit 1;" INT
trap "echo \"Error occured in subcommand @ \${BASH_SOURCE[0]}:\$LINENO.\"; exit 1;" ERR


workdir_root="$(dirname "$0")/../.workdirs/"
network_id="3611"


function start_node ()
{ # {{{

  local num="$1"
  grep -qx '[123]' <<< "$num" || return 1

  if [ ! -d "$workdir_root/geth_node_${num}/" ]; then
    echo "No workdir in \"$workdir_root/geth_node_${num}/\". Have you --initialize'ed?" >&2
    exit 1
  fi

  bootnodes=""
  #for ((i=1;i<=3;i++)); do
  #  bootnodes="${bootnodes:-}${bootnodes:+,}enode://$(< "$workdir_root/geth_node_${i}/geth/nodekey")@localhost:$((30302+i))"
  #done

  echo "Starting geth node ${num}, logging to '$workdir_root/geth_node_${num}.stderr'"
  geth  \
    --port "$((30302+num))" \
    --bootnodes "$bootnodes" \
    --unlock '0,1' \
    --password "$workdir_root/geth_node_${num}.password" \
    $([ "2" = "$num" ] && echo '--mine --minerthreads 1' || true ) \
    $([ "2" = "$num" ] && echo '--rpc --rpccorsdomain 'http://localhost:8080' --rpcport 8545' || true ) \
     \
    --networkid "$network_id"  \
    --datadir "$workdir_root/geth_node_${num}/" \
    2>> "$workdir_root/geth_node_${num}.stderr" & pid="$!"

  echo "$pid" > "$workdir_root/geth_node_${num}.pid"
} # }}}

function initialize_node ()
{ # {{{
  local num="$1"
  grep -qx '[123]' <<< "$num" || return 1

  local pidfile="$workdir_root/geth_node_${num}.pid"

  mkdir -p "$workdir_root/geth_node_${num}/"
  if [ -e "$pidfile" ] && ps -p "$(< "$pidfile")" &>/dev/null; then
    kill -9 "$(< "$pidfile")"
  fi
  # https://github.com/ethereum/go-ethereum/wiki/Managing-your-accounts : one pw per line
  [ -e "$workdir_root/geth_node_${num}.password" ] || (for i in 1 2; do openssl rand -hex 32 ; done) > "$workdir_root/geth_node_${num}.password"

  echo "Setting up default account in node ${num}..."
  geth  --datadir "$workdir_root/geth_node_${num}/" --password <(sed -n 1p "$workdir_root/geth_node_${num}.password") account new

  echo "Setting up second account in node ${num}..."
  geth  --datadir "$workdir_root/geth_node_${num}/" --password <(sed -n 2p "$workdir_root/geth_node_${num}.password") account new

  echo "Initializing node ${num} ..."
  geth  --datadir "$workdir_root/geth_node_${num}/" init genesis.json &>/dev/null

  echo "Starting node ${num} in isolation to bootstrap it..."
  geth  --datadir "$workdir_root/geth_node_${num}/" console --exec 'return 0' &>/dev/null || true
  #timeout 10 geth  --datadir "$workdir_root/geth_node_${num}/" || true

} # }}}

function run_command ()
{ # {{{
  local cmd="$1"

  geth  --datadir "$workdir_root/geth_node_3/" --password "$workdir_root/geth_node_3.password" console --exec "$cmd"
} # }}}

function start_console ()
{ # {{{
  geth  \
    --port "30305" \
    --password "$workdir_root/geth_node_3.password" \
    --datadir "$workdir_root/geth_node_3/" \
    --networkid "$network_id"  \
    console
} # }}}

function taillogs ()
{ # {{{

  local -a pids=()
  echo "Tailing logs. Ctrl-C or enter to stop...."
  for ((i=1;i<=2;i++)); do
    tail -Fn0 "$workdir_root/geth_node_${i}.stderr" | sed -u "s/^/node_$i: /" & pids+=( "$!" )
  done
  trap "kill ${pids[*]}" EXIT
  read _
  kill ${pids[*]}
} # }}}


declare start_mode="" initialize_mode="" clean_mode="" command_to_be_run="" start_console="" taillogs_mode=""

while [ "0" != "$#" ]; do
  case "$1" in
    --help) # --help: Outputs this help.
      echo -e "Alas, only a minimal help output is available:\n\n"
      sed -nre 's/^\s*(--[0-9a-z_-]+)\) # --help: (.*)$/\1\t\2/;tp;b;:p p' < "$0"
      exit 0
      ;;
    --start) # --help: Starts up stack.
      start_mode="yes, we're doing this."
      ;;
    --taillogs) # --help: Starts a tail -F on all geth processes' stderr.
      taillogs_mode="uh-huh"
      ;;
    --initialize) # --help: Initializes the stack (any one-off operations).
      initialize_mode="yes, we're doing this."
      ;;
    --clean) # --help: Deletes all traces. The dual to --initialize.
      clean_mode="yes, we're doing this."
      ;;
    --run-command) # --help: Run the command given through the geth console.
      command_to_be_run="$2"
      shift
      ;;
    --console) # --help: Start the geth console interactively
      start_console="mm-hmm."
      ;;
    *)
      echo "Unrecogized option: \"$1\". Aborting."
      exit 1
      ;;
  esac
  shift
done



if [ -n "$clean_mode" ]; then
  for num in 1 2; do
    if [ -e "$workdir_root/geth_node_${num}.pid" ]; then
      echo "Killing geth process $num: $(< "$workdir_root/geth_node_${num}.pid")..." >&2
      kill -9 "$(< "$workdir_root/geth_node_${num}.pid")" || true
    fi
  done
  echo "Removing \"$workdir_root\"..." >&2
  rm -Rf "$workdir_root"
  echo "Done cleaning." >&2
else
  if [ -n "$initialize_mode" ]; then
    initialize_node 1
    initialize_node 2
    initialize_node 3
  fi

  if [ -n "$start_mode" ]; then
    start_node 1
    start_node 2
    # node 3 is for console interactions, doesn't get started initially
  fi
fi


if [ -n "$command_to_be_run" ]; then
  run_command "$command_to_be_run"
fi

if [ -n "$start_console" ]; then
  start_console
elif [ -n "$taillogs_mode" ]; then
  taillogs
fi



# vim: set fml=1 fdm=marker
