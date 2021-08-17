// DisruptArt.io Marketplace Contract
// Owner  : DisruptionNowMedia (www.disruptionnow.com)
// Author : www.BLAZE.ws
// Version: 0.0.4

import DisruptArtMarketplace from "../contracts/DisruptArtMarketplace.cdc"

transaction(tokens:[UInt64]) {

       prepare(acct: AuthAccount) {

           let salewithdrawn = acct.borrow<&DisruptArtMarketplace.SaleCollection>(from: DisruptArtMarketplace.marketStoragePath)
                  ?? panic("Could not borrow acct nft sale reference")
           
           salewithdrawn.saleWithdrawn(tokens: tokens)

       }
}

