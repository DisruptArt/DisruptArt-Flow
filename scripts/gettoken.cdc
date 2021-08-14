// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.3


import DisruptArt from 0x1592be4ab7835516
import NonFungibleToken from 0x1592be4ab7835516

//[UInt64] &DisruptNow.NFT
pub fun main(owner:Address, tokenid:UInt64): &NonFungibleToken.NFT {

    let collectionRef = getAccount(owner)
        .getCapability(/public/DisruptArtNFTPublicCollection)
        .borrow<&{DisruptArt.NFTPublicCollection}>()
        ?? panic("Could not borrow capability from public collection")

    let nft = collectionRef.borrowNFT(id:tokenid)

    return nft

}

