// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.3

import FungibleToken from 0x9a0766d93b6608b7
import DisruptArt from 0x1592be4ab7835516
import DisruptArtMarketplace from 0x1592be4ab7835516

transaction(price:UFix64) {


    prepare(acct: AuthAccount) {

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

        let sale = acct.borrow<&DisruptArtMarketplace.SaleCollection>(from: /storage/NFTSale)
                    ?? panic("Could not borrow acct nft sale reference")

        // borrow a reference to the NFTCollection in storage
        let collectionRef = acct.borrow<&DisruptArt.Collection>(from: /storage/DisruptArtNFTCollection)
            ?? panic("Could not borrow owner's nft collection reference")

        let val:[UInt64] = [14,15] // move tokens to sale object
        // List the tokens for sale by moving it into the sale object
        sale.listForSaleGroup(sellerRef: collectionRef, tokens: val, price: price)

    }
}

