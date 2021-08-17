// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.4


import DisruptArt from "../contracts/DisruptArt.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"

//[UInt64] &DisruptNow.NFT
pub fun main(owner:Address, tokenid:UInt64): &NonFungibleToken.NFT {

    let collectionRef = getAccount(owner)
        .getCapability(DisruptArt.disruptArtPublicPath)
        .borrow<&{DisruptArt.DisruptArtCollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")

    let nft = collectionRef.borrowNFT(id:tokenid)

    return nft

}

