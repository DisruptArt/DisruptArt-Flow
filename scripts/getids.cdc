// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.4


import DisruptArt from "../contracts/DisruptArt.cdc"

// Returns tokenids of provided address
pub fun main(owner:Address): [UInt64] {
    let collectionRef = getAccount(owner)
                        .getCapability(DisruptArt.disruptArtPublicPath)
                        .borrow<&{DisruptArt.DisruptArtCollectionPublic}>()
                        ?? panic("Could not borrow capability from public collection")

    return collectionRef.getIDs()
}

