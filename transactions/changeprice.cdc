import DisruptArtMarketplace from 0x1592be4ab7835516
transaction(price:UFix64) {

       prepare(acct: AuthAccount) {

       let collectionRef = acct.borrow<&DisruptArtMarketplace.SaleCollection>(from: /storage/NFTSale)
                            ?? panic("Could not borrow acct nft sale reference")

       let tokens:[UInt64] = [1,2,11] // change price of the following tokens
       // List the token for sale by moving it into the sale object
       collectionRef.changePrice(tokens:tokens,newPrice:price)

       }
} 

