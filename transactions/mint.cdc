// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.3

import DisruptArt from 0x1592be4ab7835516

transaction(content:String, description:String, name:String) {

    // local variable for storing the minter reference
    let minter: &DisruptArt.Collection
    let receiverAddrss : Address

    prepare(signer: AuthAccount) {

        if signer.borrow<&DisruptArt.Collection>(from: /storage/DisruptArtNFTCollection) == nil {

            // Create a new empty collection
            let collection <- DisruptArt.createEmptyCollection()

            // save it to the account
            signer.save(<-collection, to: /storage/DisruptArtNFTCollection)

            // create a public capability for the collection
            signer.link<&{DisruptArt.NFTPublicCollection}>(
                    /public/DisruptArtNFTPublicCollection,
                    target: /storage/DisruptArtNFTCollection
                    )
        } 

        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&DisruptArt.Collection>(from: /storage/DisruptArtNFTCollection)
            ?? panic("Could not borrow a reference to the NFT minter")

       self.receiverAddrss = signer.address
    }

    execute {
        // Borrow the recipient's public NFT collection reference
        let receiver = getAccount(self.receiverAddrss)
            .getCapability(/public/DisruptArtNFTPublicCollection)
            .borrow<&{DisruptArt.NFTPublicCollection}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        // Mint the NFT and deposit it to the recipient's collection
        self.minter.Mint(recipient: receiver, content:content, name:name, description:description)
    }
}


