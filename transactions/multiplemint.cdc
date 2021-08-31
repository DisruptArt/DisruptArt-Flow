// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.4


// Transaction to mint the multiple tokens

import DisruptArt from "../contracts/DisruptArt.cdc"


transaction(content:String, description:String, name:String, edition:UInt, receiver:Address) {
    let minter: &DisruptArt.NFTMinter
    let receiverAddrss : Address
    prepare(acct: AuthAccount) {

        self.minter = acct.borrow<&DisruptArt.NFTMinter>(from: DisruptArt.disruptArtMinterPath)
            ?? panic("could not borrow minter reference")

        self.receiverAddrss = receiver
        
    }
    execute {
            // Borrow the recipient's public NFT collection reference
            let receiver = getAccount(self.receiverAddrss)
                .getCapability(DisruptArt.disruptArtPublicPath)
                .borrow<&{DisruptArt.DisruptArtCollectionPublic}>()
                ?? panic("Could not get receivers reference to the NFT Collection")

            // Mint the NFTs and deposit it to the recipient's collection
            self.minter.GroupMint(recipient: receiver, content:content,description:description, name:name,edition:edition)
    }
}

