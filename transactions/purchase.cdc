// DisruptArt.io Marketplace Contract
// Owner  : DisruptionNowMedia (www.disruptionnow.com)
// Author : www.BLAZE.ws
// Version: 0.0.3


import FungibleToken from 0x9a0766d93b6608b7
import DisruptArt from 0x1592be4ab7835516
import DisruptArtMarketplace from 0x1592be4ab7835516
import FUSD from 0xe223d8a629e49c68

// This transaction uses the signers Vault tokens to purchase an NFT
// from the Sale collection of account 0x01.
transaction(price: UFix64, seller: Address) {

    // reference to the buyer's NFT collection where they
    // will store the bought NFT
    let collectionRef: &{DisruptArt.NFTPublicCollection}

    // Vault that will hold the tokens that will be used to
    // but the NFT
    let temporaryVault: @FungibleToken.Vault

    prepare(acct: AuthAccount) {

        // Return early if the account already has a collection
        if acct.borrow<&DisruptArt.Collection>(from: /storage/DisruptArtNFTCollection) == nil {

                // Create a new empty collection
                let collection <- DisruptArt.createEmptyCollection()

                // save it to the account
                acct.save(<-collection, to: /storage/DisruptArtNFTCollection)

                // create a public capability for the collection
                acct.link<&{DisruptArt.NFTPublicCollection}>(
                                /public/DisruptArtNFTPublicCollection,
                                target: /storage/DisruptArtNFTCollection
                            )
        }


        if acct.borrow<&DisruptArtMarketplace.SaleCollection>(from: /storage/NFTSale) == nil {
            // Borrow a reference to the stored Vault
            let receiver = acct.getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver)

            // Create a new Sale object,
            // initializing it with the reference to the owner's vault
            let sales <- DisruptArtMarketplace.createSaleCollection(ownerVault: receiver)

            // Store the sale object in the account storage 
            acct.save(<-sales, to: /storage/NFTSale)

            // Create a public capability to the sale so that others can call its methods
            acct.link<&DisruptArtMarketplace.SaleCollection{DisruptArtMarketplace.SalePublic}>(/public/NFTSale, target: /storage/NFTSale)
        }



        // get the references to the buyer's fungible token Vault and NFT Collection Receiver
        self.collectionRef = acct.borrow<&{DisruptArt.NFTPublicCollection}>(from: /storage/DisruptArtNFTCollection)!
        let vaultRef = acct.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            ?? panic("Could not borrow owner's vault reference")

        // withdraw tokens from the buyers Vault
        self.temporaryVault <- vaultRef.withdraw(amount: price)
    }

    execute {
        // get the read-only account storage of the seller
        let seller = getAccount(seller)

        // get the reference to the seller's sale
        let saleRef = seller.getCapability<&AnyResource{DisruptArtMarketplace.SalePublic}>(/public/NFTSale)
            .borrow()
            ?? panic("Could not borrow seller's sale reference")

        // purchase the NFTs the seller is selling, giving them the reference
        // to your NFT collection and giving them the tokens to buy it
        saleRef.purchaseGroup(tokens: [7,1] as [UInt64], recipient: self.collectionRef, payment: <-self.temporaryVault)
    }
}


