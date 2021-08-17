// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.4

import DisruptArt from "../contracts/DisruptArt.cdc"

transaction(content:String, description:String, name:String) {

    // local variable for storing the minter reference
    let minter: &DisruptArt.Collection
    let receiverAddrss : Address

    prepare(signer: AuthAccount) {

        if signer.borrow<&DisruptArt.Collection>(from: DisruptArt.disruptArtStoragePath) == nil {

            // Create a new empty collection
            let collection <- DisruptArt.createEmptyCollection()

            // save it to the account
            signer.save(<-collection, to: DisruptArt.disruptArtStoragePath)

            // create a public capability for the collection
            signer.link<&{DisruptArt.DisruptArtCollectionPublic}>(
                    DisruptArt.disruptArtPublicPath,
                    target: DisruptArt.disruptArtStoragePath
                    )
        } 

        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&DisruptArt.Collection>(from: DisruptArt.disruptArtStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")

       self.receiverAddrss = signer.address
    }

    execute {
        // Borrow the recipient's public NFT collection reference
        let receiver = getAccount(self.receiverAddrss)
            .getCapability(DisruptArt.disruptArtPublicPath)
            .borrow<&{DisruptArt.DisruptArtCollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        // Mint the NFT and deposit it to the recipient's collection
        self.minter.Mint(recipient: receiver, content:content, name:name, description:description)
    }
}


