// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.4

import FungibleToken from 0x9a0766d93b6608b7
import DisruptArt from "../contracts/DisruptArt.cdc"
import DisruptArtMarketplace from "../contracts/DisruptArtMarketplace.cdc"

transaction(tokens:[UInt64], price:UFix64) {

   
    prepare(acct: AuthAccount) {

        if acct.borrow<&DisruptArtMarketplace.SaleCollection>(from: DisruptArtMarketplace.marketStoragePath) == nil {
            // Borrow a reference to the stored Vault
            let receiver = acct.getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver)

            // Create a new Sale object,
            // initializing it with the reference to the owner's vault
            let sales <- DisruptArtMarketplace.createSaleCollection(ownerVault: receiver)

            // Store the sale object in the account storage 
            acct.save(<-sales, to: DisruptArtMarketplace.marketStoragePath)

            // Create a public capability to the sale so that others can call its methods
            acct.link<&DisruptArtMarketplace.SaleCollection{DisruptArtMarketplace.SalePublic}>(DisruptArtMarketplace.marketPublicPath, target: DisruptArtMarketplace.marketStoragePath)
        }

        let sale = acct.borrow<&DisruptArtMarketplace.SaleCollection>(from: DisruptArtMarketplace.marketStoragePath)
                    ?? panic("Could not borrow acct nft sale reference")

        // borrow a reference to the NFTCollection in storage
        let collectionRef = acct.borrow<&DisruptArt.Collection>(from: DisruptArt.disruptArtStoragePath)
            ?? panic("Could not borrow owner's nft collection reference")
 
        // List the tokens for sale by moving it into the sale object
        sale.listForSaleGroup(sellerRef: collectionRef, tokens: tokens, price: price)

    }
}

