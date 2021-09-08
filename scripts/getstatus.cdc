// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.1

import DisruptArtAuction from "../contracts/DisruptArtAuction.cdc"

pub fun main(account:Address): {UInt64:Bool} {
    // get the public account object for account 1
    let account1 = getAccount(account)

    // find the public Sale Collection capability
    let auctionCap = account1.getCapability(DisruptArtAuction.auctionPublicPath)

    let auctionRef = auctionCap.borrow<&{DisruptArtAuction.AuctionPublic}>()??
        panic("unable to borrow a reference to the Auction collection for account 1")

    return auctionRef.getAuctionStatuses()
}



