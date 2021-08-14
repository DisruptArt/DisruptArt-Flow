// DisruptArt.io Marketplace Contract
// Owner  : DisruptionNowMedia (www.disruptionnow.com)
// Author : www.BLAZE.ws
// Version: 0.0.3

import DisruptArtMarketplace from 0x1592be4ab7835516

transaction() {

       prepare(acct: AuthAccount) {

           let salewithdrawn = acct.borrow<&DisruptArtMarketplace.SaleCollection>(from: /storage/NFTSale)
                  ?? panic("Could not borrow acct nft sale reference")
           
           let tokens:[UInt64] = [14] // tokens to be withdraw                                  
  
           salewithdrawn.saleWithdrawn(tokens: tokens)

       }
}

