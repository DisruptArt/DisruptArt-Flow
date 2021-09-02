// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.1


import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import DisruptArtAuction from "../contracts/DisruptArtAuction.cdc"
import DisruptArt from "../contracts/DisruptArt.cdc"


transaction(auctionid:UInt64,seller:Address,amount:UFix64) {
    // reference to the buyer's NFT collection where they
    // will store the bought NFT

    let vaultCap: Capability<&{FungibleToken.Receiver}>
    let collectionCap: Capability<&{DisruptArt.DisruptArtCollectionPublic}> 
    // Vault that will hold the tokens that will be used
    // to buy the NFT
    let temporaryVault: @FungibleToken.Vault

    prepare(account: AuthAccount) {

        if account.borrow<&DisruptArtAuction.AuctionCollection>(from: /storage/NFTAuction) == nil {
            // create a new sale object
            // initializing it with the reference to the owner's Vault
            let auction <- DisruptArtAuction.createAuctionCollection()

            // store the sale resource in the account for storage
            account.save(<-auction, to: /storage/NFTAuction)

           // create a public capability to the sale so that others
           // can call it's methods
           account.link<&{DisruptArtAuction.AuctionPublic}>(
              /public/NFTAuction,
              target: /storage/NFTAuction
           )

           log("Auction Collection and public capability created.")

       }

        // get the references to the buyer's Vault and NFT Collection receiver
        self.collectionCap = account.getCapability<&{DisruptArt.DisruptArtCollectionPublic}>(DisruptArt.disruptArtPublicPath) 

        self.vaultCap = account.getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver) 
                    
        let vaultRef = account.borrow<&FungibleToken.Vault>(from: /storage/fusdVault)
            ?? panic("Could not borrow owner's Vault reference")

        // withdraw tokens from the buyer's Vault
        self.temporaryVault <- vaultRef.withdraw(amount: amount)
    }

    execute {
        // get the read-only account storage of the seller
        let seller = getAccount(seller)

        // get the reference to the seller's sale
        let auctionRef = seller.getCapability(/public/NFTAuction)!
                         .borrow<&AnyResource{DisruptArtAuction.AuctionPublic}>()
                         ?? panic("Could not borrow seller's sale reference")

        auctionRef.placeBid(id: UInt64(auctionid), bidTokens: <- self.temporaryVault, vaultCap: self.vaultCap, collectionCap: self.collectionCap)

    }
}
