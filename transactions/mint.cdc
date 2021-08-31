// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.4

import DisruptArt from "../contracts/DisruptArt.cdc"

transaction(content:String, description:String, name:String, receiver:Address) {

    // local variable for storing the minter reference
    let minter: &DisruptArt.NFTMinter
    let receiverAddrss : Address

    prepare(signer: AuthAccount) {

       self.minter = signer.borrow<&DisruptArt.NFTMinter>(from: DisruptArt.disruptArtMinterPath)
            ?? panic("could not borrow minter reference")

       self.receiverAddrss = receiver
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


