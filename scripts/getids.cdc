// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.3


import DisruptArt from 0x1592be4ab7835516

// Returns tokenids of provided address
pub fun main(owner:Address): [UInt64] {
    let collectionRef = getAccount(owner)
                        .getCapability(/public/DisruptArtNFTPublicCollection)
                        .borrow<&{DisruptArt.NFTPublicCollection}>()
                        ?? panic("Could not borrow capability from public collection")

    return collectionRef.getIDs()
}

