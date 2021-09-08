// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.1


import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import DisruptArtAuction from "../contracts/DisruptArtAuction.cdc"
import FUSD from 0xe223d8a629e49c68
import DisruptArt from "../contracts/DisruptArt.cdc"

transaction(startprice:UFix64,minimumincrement:UFix64,endtime:Fix64,tokenid:UInt64) {

    prepare(account: AuthAccount) {

        if account.borrow<&DisruptArtAuction.AuctionCollection>(from: DisruptArtAuction.auctionStoragePath) == nil {
            // create a new sale object     
            // initializing it with the reference to the owner's Vault
            let auction <- DisruptArtAuction.createAuctionCollection()

            // store the sale resource in the account for storage
            account.save(<-auction, to: DisruptArtAuction.auctionStoragePath)

           // create a public capability to the sale so that others
           // can call it's methods
           account.link<&{DisruptArtAuction.AuctionPublic}>(
              DisruptArtAuction.auctionPublicPath,
              target: DisruptArtAuction.auctionStoragePath
           )

           log("Auction Collection and public capability created.")

       }

       let accountCollectionRef = account.borrow<&NonFungibleToken.Collection>(from: DisruptArt.disruptArtStoragePath)!

       // get the public Capability for the signer's NFT collection (for the auction)
       let publicCollectionCap = account.getCapability<&{DisruptArt.DisruptArtCollectionPublic}>(DisruptArt.disruptArtPublicPath)

       let vaultCap = account.getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver) 

       // borrow a reference to the Auction Collection in account storage
       let auctionCollectionRef = account.borrow<&DisruptArtAuction.AuctionCollection>(from: DisruptArtAuction.auctionStoragePath)!

       // Create an empty bid Vault for the auction
       let bidVault <- FUSD.createEmptyVault()

       // withdraw the NFT from the collection that you want to sell
       // and move it into the transaction's context
       let NFT <- accountCollectionRef.withdraw(withdrawID: tokenid)

       // list the token for sale by moving it into the sale resource
       auctionCollectionRef.addTokenToAuctionItems(
                token: <-NFT,
                minimumBidIncrement: minimumincrement,
                startPrice: startprice,
                bidVault: <-bidVault,
                collectionCap: publicCollectionCap,
                vaultCap: vaultCap,
                endTime : endtime
       )
     

    }
}
