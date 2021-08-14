// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.3

import DisruptArtMarketplace from 0x1592be4ab7835516

pub fun main(owner:Address,tokenid:UInt64):UFix64? {
     // Get the public account object for account 0x01
     let account1 = getAccount(owner)

     // Find the public Sale reference to their Collection
     let acct1saleRef = account1.getCapability<&AnyResource{DisruptArtMarketplace.SalePublic}>(/public/NFTSale)
                        .borrow()
                        ?? panic("Could not borrow acct2 nft sale reference")

     return acct1saleRef.idPrice(id:tokenid)
}

