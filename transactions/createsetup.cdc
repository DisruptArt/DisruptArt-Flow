// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.4


// Transaction to mint the multiple tokens

import DisruptArt from "../contracts/DisruptArt.cdc"


transaction() {
    
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

   }


}
