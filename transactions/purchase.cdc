// DisruptArt.io Marketplace Contract
// Owner  : DisruptionNowMedia (www.disruptionnow.com)
// Author : www.BLAZE.ws
// Version: 0.0.4


import FungibleToken from 0x9a0766d93b6608b7
import DisruptArt from "../contracts/DisruptArt.cdc"
import DisruptArtMarketplace from "../contracts/DisruptArtMarketplace.cdc"
import FUSD from 0xe223d8a629e49c68

// This transaction uses the signers Vault tokens to purchase an NFT
// from the Sale collection of account 0x01.
transaction(tokens:[UInt64], price: UFix64, seller: Address) {
 

    // reference to the buyer's NFT collection where they
    // will store the bought NFT
    let collectionRef: &{DisruptArt.DisruptArtCollectionPublic}

    // Vault that will hold the tokens that will be used to
    // but the NFT
    let temporaryVault: @FungibleToken.Vault

    prepare(acct: AuthAccount) {

        // Return early if the account already has a collection
        if acct.borrow<&DisruptArt.Collection>(from: DisruptArt.disruptArtStoragePath) == nil {

                // Create a new empty collection
                let collection <- DisruptArt.createEmptyCollection()

                // save it to the account
                acct.save(<-collection, to: DisruptArt.disruptArtStoragePath)

                // create a public capability for the collection
                acct.link<&{DisruptArt.DisruptArtCollectionPublic}>(
                                DisruptArt.disruptArtPublicPath,
                                target: DisruptArt.disruptArtStoragePath
                            )
        }


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



        // get the references to the buyer's fungible token Vault and NFT Collection Receiver
        self.collectionRef = acct.borrow<&{DisruptArt.DisruptArtCollectionPublic}>(from: DisruptArt.disruptArtStoragePath)!
        let vaultRef = acct.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            ?? panic("Could not borrow owner's vault reference")

        // withdraw tokens from the buyers Vault
        self.temporaryVault <- vaultRef.withdraw(amount: price)
    }

    execute {
        // get the read-only account storage of the seller
        let seller = getAccount(seller)

        // get the reference to the seller's sale
        let saleRef = seller.getCapability<&AnyResource{DisruptArtMarketplace.SalePublic}>(DisruptArtMarketplace.marketPublicPath)
            .borrow()
            ?? panic("Could not borrow seller's sale reference")

        // purchase the NFTs the seller is selling, giving them the reference
        // to your NFT collection and giving them the tokens to buy it
        saleRef.purchaseGroup(tokens: tokens, recipient: self.collectionRef, payment: <-self.temporaryVault)
    }
}


