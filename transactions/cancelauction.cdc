// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.1

import DisruptArtAuction from "../contracts/DisruptArtAuction.cdc"

transaction(auctionid:UInt64) {
    // reference to the buyer's NFT collection where they
    // will store the bought NFT

    let vaultCap: &DisruptArtAuction.AuctionCollection 

    prepare(account: AuthAccount) {

        self.vaultCap = account.borrow<&DisruptArtAuction.AuctionCollection>(from: DisruptArtAuction.auctionStoragePath)
            ?? panic("Could not borrow owner's auction collection")
    }

    execute {       
        self.vaultCap.cancelAuction(auctionid)
    }
}
