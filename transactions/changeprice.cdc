import DisruptArtMarketplace from "../contracts/DisruptArtMarketplace.cdc"
 transaction(tokens:[UInt64], price:UFix64) {


       prepare(acct: AuthAccount) {

       let collectionRef = acct.borrow<&DisruptArtMarketplace.SaleCollection>(from: DisruptArtMarketplace.marketStoragePath)
                            ?? panic("Could not borrow acct nft sale reference")

       // List the token for sale by moving it into the sale object
       collectionRef.changePrice(tokens:tokens,newPrice:price)

       }
} 

