// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.4


import DisruptArtMarketplace from "../contracts/DisruptArtMarketplace.cdc"

pub fun main(owner:Address):[UInt64] {
      // Get the public account object for account 0x01
      let account1 = getAccount(owner)

      // Find the public Sale reference to their Collection
      let acct1saleRef = account1.getCapability<&AnyResource{DisruptArtMarketplace.SalePublic}>(DisruptArtMarketplace.marketPublicPath)
                         .borrow()
                         ?? panic("Could not borrow acct2 nft sale reference")

      // Los the NFTs that are for sale
      log("Account 1 NFTs for sale")
      return acct1saleRef.getIDs()
}

