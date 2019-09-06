#!/usr/bin/env bash

printUsage() {
    cat <<EOUSAGE
Usage:
    destroy.sh
      -g <Resource Group Name to destroy>

EOUSAGE
    echo "Example: destroy.sh -g sathya-px-rg"
}

while getopts "h?:g:" opt; do
    case "$opt" in
    h|\?)
        printUsage
        exit 0
        ;;
    g)  RG_NAME=$OPTARG
        ;;
    :)
        echo "[ERROR] Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    default)
       printUsage
       exit 1
    esac
done

# Validate Input Args
if [[ (-z ${RG_NAME}) ]]; then
    echo "[ERROR]: Required arguments missing"
    printUsage
    exit 1
fi

az login
az group delete --name ${RG_NAME} --yes --no-wait
