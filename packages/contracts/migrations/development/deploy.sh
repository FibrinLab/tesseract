#!/bin/bash

# load env variables
source .env

forge script migrations/development/DeployDiamond.s.sol:Deploy001_Diamond --rpc-url https://cool-responsive-river.avalanche-testnet.quiknode.pro/4ba079563ddbda7c7e4188eb271ce814b8cd1b52/ext/bc/C/rpc/ --broadcast -vvvv