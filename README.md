# DISRUPT.ART NFT Marketplace Smart Contracts
    
    Owner : Disrupt Art, INC. [https://www.disrupt.art] (https://www.disrupt.art)
    NFT Marketplace : [https://www.disrupt.art/nft] (https://www.disrupt.art/nft)
    Developer : [https://www.BLAZE.ws] (https://www.BLAZE.ws)

Flow blockchain based NFT marketplace with multiple minting, auction, multi format content (Video, Audio, Image) NFT minting with IPFS storage support. Blocto, Dapper & Ledger wallets are integrated for fast and secure payments. Moon Pay payment gateway is also integrated for fast FUSD / Flow purchases as well as NFT purchase with Fiat / Credit Card & additional payment options.

# Testnet
   Address : 0xe1392621e26c3274

   Deployed Contracts : https://flow-view-source.com/testnet/account/0xe1392621e26c3274/

# Transactions

## transactions/fusd.cdc - FUSD setup in a account
flow transactions send transactions/fusd.cdc -n=testnet --signer="testnet-account"

## transactions/multiplemint.cdc - Mint multiple copies of NFT tokens
flow transactions send transactions/multiplemint.cdc --arg String:"Art" --arg String:"art description" --arg String:"Art title" --arg UInt:2 --arg Address:"0x1592be4ab7835516" --network=testnet --signer="testnet-account"

## transactions/singlemint.cdc - Mint a NFT token
flow transactions send transactions/mint.cdc --arg String:"Art" --arg String:"art description" --arg String:"Art title" --arg Address:"0x1592be4ab7835516" --network=testnet --signer="testnet-account"

## transactions/changeprice.cdc - Change price of the listed tokens
flow transactions send transactions/changeprice.cdc --arg UFix64:11.0 --network="testnet" --signer="testnet-account"

## transactions/listforsale.cdc - List NFT tokens in market
flow transactions send transactions/listforsale.cdc  --arg UFix64:11.0 --network="testnet" --signer="testnet-account"

## transactions/purchase.cdc - Purchase group of NFT tokens
flow transactions send transactions/purchase.cdc --arg UFix64:11.0 --arg Address:0x1592be4ab7835516 --network="testnet" --signer="testnet2-account"

## transactions/withdraw.cdc - Withdraw a tokens from market
flow transactions send transactions/withdraw.cdc --network="testnet"  --signer="testnet-account"

## transactions/listauction.cdc - List NFT in auction
flow transactions send transactions/listauction.cdc --arg UFix64:2.0 --arg UFix64:1.0 --arg Fix64:1630567277.0 --arg UInt64:37 --network="testnet" --signer="testnet-account"

## transactions/cancelauction.cdc - Cancel an auction
flow transactions send transactions/cancelauction.cdc --arg UInt64:6 --network="testnet" --signer="testnettest-account"

## transactions/placebid.cdc - Place a bid 
flow transactions send transactions/placebid.cdc --arg UInt64:3 --arg Address:0x9229f7ab4ba8e2b4 --arg UFix64:1.9 --network="testnet" --signer="testnettest-account"

## transactions/settle.cdc - Auction settlement
flow transactions send transactions/settle.cdc --arg UInt64:6 --arg Address:0x764e4e765a52e26b --network="testnet" --signer="testnettest-account"

# Scripts

## scripts/getids - Returns NFT token ids of the owner
flow scripts execute scripts/getids.cdc --arg Address:"0x1592be4ab7835516" --network="testnet"

## scripts/getmarketids.cdc - Returns nft ids listed in market by owner
flow scripts execute scripts/getmarketids.cdc --arg Address:"0x1592be4ab7835516" --network="testnet"

## scripts/gettokenprice.cdc - Returns price of the listed token 
flow scripts execute scripts/gettokenprice.cdc --arg Address:"0x1592be4ab7835516" --arg UInt64:2 --network="testnet"

## scripts/gettoken.cdc - Returns a token
flow scripts execute scripts/gettoken.cdc --arg Address:"0x1592be4ab7835516" --arg UInt64:1 --network="testnet"

## scripts/getstatus.cdc - Returns auction status
flow scripts execute scripts/getstatus.cdc --arg Address:"0x764e4e765a52e26b" --network="testnet"


