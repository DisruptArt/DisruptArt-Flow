# DisruptArt.io NFT Marketplace Smart Contracts
    NFT Token and Marketplace smart contracts of DisruptArt.io

    Owner : Disruption Now Media LLC - www.disruptionnow.com
    NFT Marketplace : www.DisruptArt.io 
    Developer : www.BLAZE.ws


# Testnet
   Address : 0x1592be4ab7835516

   Deployed Contracts : https://flow-view-source.com/testnet/account/0x1592be4ab7835516/

# Transactions

## transactions/fusd.cdc - FUSD setup in a account
flow transactions send transactions/fusd.cdc -n=testnet --signer="testnet-account"

## transactions/multiplemint.cdc - Mint multiple copies of NFT tokens
flow transactions send transactions/multiplemint.cdc --arg String:"Art" --arg String:"art description" --arg String:"Art title" --arg UInt:2 --network=testnet --signer="testnet-account"

## transactions/singlemint.cdc - Mint a NFT token
flow transactions send transactions/mint.cdc --arg String:"Art" --arg String:"art description" --arg String:"Art title" --network=testnet --signer="testnet-account"

## transactions/changeprice.cdc - Change price of the listed tokens
flow transactions send transactions/changeprice.cdc --arg UFix64:11.0 --network="testnet" --signer="testnet-account"

Note: add tokenids inside the file transactions/listforsale.cdc

## transactions/listforsale.cdc - List NFT tokens in market
flow transactions send transactions/listforsale.cdc  --arg UFix64:11.0 --network="testnet" --signer="testnet-account"

Note: add tokenids inside the file transactions/listforsale.cdc

## transactions/purchase.cdc - Purchase group of NFT tokens
flow transactions send transactions/purchase.cdc --arg UFix64:11.0 --arg Address:0x1592be4ab7835516 --network="testnet" --signer="testnet2-account"

Note: add tokenids inside the file transactions/listforsale.cdc

## transactions/withdraw.cdc - Withdraw a tokens from market
flow transactions send transactions/withdraw.cdc --network="testnet"  --signer="testnet-account"

Note: add tokenids inside the file transactions/listforsale.cdc

# Scripts

## scripts/getids - Returns NFT token ids of the owner
flow scripts execute scripts/getids.cdc --arg Address:"0x1592be4ab7835516" --network="testnet"

## scripts/getmarketids.cdc - Returns nft ids listed in market by owner
flow scripts execute scripts/getmarketids.cdc --arg Address:"0x1592be4ab7835516" --network="testnet"

## scripts/gettokenprice.cdc - Returns price of the listed token 
flow scripts execute scripts/gettokenprice.cdc --arg Address:"0x1592be4ab7835516" --arg UInt64:2 --network="testnet"

## scripts/gettoken.cdc - Returns a token
flow scripts execute scripts/gettoken.cdc --arg Address:"0x1592be4ab7835516" --arg UInt64:1 --network="testnet"
