// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.3


// Transaction to mint the multiple tokens

import DisruptArt from 0x1592be4ab7835516


transaction(content:String, description:String, name:String, edition:UInt) {
    let minter: &DisruptArt.Collection
    let receiverAddrss : Address
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

        // borrow a reference to the NFTMinter resource in storage
        self.minter = acct.borrow<&DisruptArt.Collection>(from: /storage/DisruptArtNFTCollection)
            ?? panic("Could not borrow a reference to the NFT minter")

        self.receiverAddrss = acct.address
        
    }
    execute {
            // Borrow the recipient's public NFT collection reference
            let receiver = getAccount(self.receiverAddrss)
                .getCapability(/public/DisruptArtNFTPublicCollection)
                .borrow<&{DisruptArt.NFTPublicCollection}>()
                ?? panic("Could not get receivers reference to the NFT Collection")

            // Mint the NFTs and deposit it to the recipient's collection
            self.minter.GroupMint(recipient: receiver, content:content,description:description, name:name,edition:edition)
    }
}

