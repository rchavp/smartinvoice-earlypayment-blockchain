# frontiers-smartinvoice-blockchain

#BUILD IMAGE
docker build -t smart-contract .

#RUN IMAGE
docker run --volume $(pwd):/mount/smart-invoice --interactive --tty --rm --name smart-contract-dev smart-contract

# WORKING WITH THE CONTRACTS
Initialize folder with: truffle init
Compile contracts with: truffle compile
Deploy contracts  with: truffle deploy  (use --reset to redeploy from scratch)
