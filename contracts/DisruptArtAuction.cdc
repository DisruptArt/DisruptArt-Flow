// DisruptArt.io NFT Auction Token Contract
// Owner  : DisruptionNowMedia (www.disruptionnow.com)
// Author : www.BLAZE.ws
// Version: 0.0.1
//

import FungibleToken from 0x9a0766d93b6608b7
import DisruptArt from "./DisruptArt.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"
import DisruptArtMarketplace from "./DisruptArtMarketplace.cdc"

pub contract DisruptArtAuction {

    // The total amount of AuctionItems that have been created
    pub var totalAuctions: UInt64

    // Events
    pub event TokenAddedToAuctionItems(auctionID: UInt64, startPrice: UFix64, minimumBidIncrement: UFix64, auctionStartBlock: UInt64, tokenID: UInt64, endTime:Fix64)
    pub event NewBid(auctionID: UInt64, bidPrice: UFix64, bidder: Address?)
    pub event AuctionSettled(auctionID: UInt64, price: UFix64)
    pub event Canceled(auctionID: UInt64)

    // AuctionItem contains the Resources and metadata for a single auction
    pub resource AuctionItem {
        
        // Resources
        pub(set) var NFT: @NonFungibleToken.NFT?
        pub let bidVault: @FungibleToken.Vault

        // Metadata
        pub(set) var meta: ItemMeta

        init(
            NFT: @NonFungibleToken.NFT,
            bidVault: @FungibleToken.Vault,
            meta: ItemMeta
        ) {
            self.NFT <- NFT
            self.bidVault <- bidVault
            self.meta = meta

            DisruptArtAuction.totalAuctions = DisruptArtAuction.totalAuctions + UInt64(1)
        }

        // depositBidTokens deposits the bidder's tokens into the AuctionItem's Vault
        pub fun depositBidTokens(vault: @FungibleToken.Vault) {
            self.bidVault.deposit(from: <-vault)
        }

        // withdrawNFT removes the NFT from the AuctionItem and returns it to the caller
        pub fun withdrawNFT(): @NonFungibleToken.NFT {
            let NFT <- self.NFT <- nil
            return <- NFT!
        }
        
        // sendNFT sends the NFT to the Collection belonging to the provided Capability
        access(contract) fun sendNFT(_ capability: Capability<&{DisruptArt.DisruptArtCollectionPublic}>) {
            // borrow a reference to the owner's NFT receiver
            if let collectionRef = capability.borrow() {
                let NFT <- self.withdrawNFT()
                // deposit the token into the owner's collection
                collectionRef.deposit(token: <-NFT)
            } else {
                panic("sendNFT(): unable to borrow collection ref")
            }
        }

        // sendBidTokens sends the bid tokens to the Vault Receiver belonging to the provided Capability
        access(contract) fun sendBidTokens(_ capability: Capability<&{FungibleToken.Receiver}>, sale: Bool) {
            // borrow a reference to the owner's NFT receiver
            if let vaultRef = capability.borrow() {
                let bidVaultRef = &self.bidVault as &FungibleToken.Vault
                var balance = 0.0
                if(sale){
                    let marketShare = (bidVaultRef.balance / 100.0 ) * DisruptArtMarketplace.marketFee
                    let royalityShare = (bidVaultRef.balance / 100.0 ) * DisruptArtMarketplace.royality
                    balance = bidVaultRef.balance - (marketShare + royalityShare)
                      
                    let marketCut <- bidVaultRef.withdraw(amount: marketShare)
                    let royalityCut <- bidVaultRef.withdraw(amount: royalityShare)

                    let disruptartvaultRef =  getAccount(DisruptArtMarketplace.marketAddress)
                                  .getCapability(/public/fusdReceiver)
                                .borrow<&{FungibleToken.Receiver}>()
                                ?? panic("failed to borrow reference to Marketplace vault")

                    // let itemRef = &self.auctionItems[id] as? &AuctionItem

                    let creatorvaultRef =  getAccount(self.meta.creator!!)
                                 .getCapability(/public/fusdReceiver)
                                .borrow<&{FungibleToken.Receiver}>()
                                ?? panic("failed to borrow reference to owner vault")

                    disruptartvaultRef.deposit(from: <-marketCut)

                    if(self.meta.resale) {
                       creatorvaultRef.deposit(from: <-royalityCut) 
                    } else {
                       disruptartvaultRef.deposit(from: <-royalityCut)
                    }

                } else {
                    balance = bidVaultRef.balance
                }              

                vaultRef.deposit(from: <-bidVaultRef.withdraw(amount:balance))
            } else {
                panic("couldn't get vault ref")
            }
        }

        destroy() {
            // send the NFT back to auction owner
            self.sendNFT(self.meta.ownerCollectionCap)
            
            // if there's a bidder...
            if let vaultCap = self.meta.recipientVaultCap {
                // ...send the bid tokens back to the bidder
                self.sendBidTokens(vaultCap, sale:false)
            }

            destroy self.NFT
            destroy self.bidVault
        }
    }

    // ItemMeta contains the metadata for an AuctionItem
    pub struct ItemMeta {

        // Auction Settings
        pub let auctionID: UInt64
        pub let minimumBidIncrement: UFix64

        // Auction State
        pub(set) var startPrice: UFix64
        pub(set) var currentPrice: UFix64
        pub(set) var auctionStartBlock: UInt64
        pub(set) var auctionCompleted: Bool

        pub let endTime : Fix64
        pub let startTime : Fix64
        pub let owner: Address?
        pub let leader: Address?

        pub let resale: Bool
        pub let creator: Address?

        // Recipient's Receiver Capabilities
        pub(set) var recipientCollectionCap: Capability<&{DisruptArt.DisruptArtCollectionPublic}>
        pub(set) var recipientVaultCap: Capability<&{FungibleToken.Receiver}>?

        // Owner's Receiver Capabilities
        pub let ownerCollectionCap: Capability<&{DisruptArt.DisruptArtCollectionPublic}>
        pub let ownerVaultCap: Capability<&{FungibleToken.Receiver}>

        init(
            minimumBidIncrement: UFix64,
            startPrice: UFix64,
            startTime : Fix64,
            endTime : Fix64, 
            owner : Address?,
            auctionStartBlock: UInt64,
            ownerCollectionCap: Capability<&{DisruptArt.DisruptArtCollectionPublic}>,
            ownerVaultCap: Capability<&{FungibleToken.Receiver}>,
            resale : Bool,
            creator: Address? 
        ) {
            self.auctionID = DisruptArtAuction.totalAuctions + UInt64(1)
            self.minimumBidIncrement = minimumBidIncrement
            self.startPrice = startPrice
            self.currentPrice = startPrice
            self.auctionStartBlock = auctionStartBlock
            self.auctionCompleted = false
            self.recipientCollectionCap = ownerCollectionCap
            self.recipientVaultCap = ownerVaultCap
            self.ownerCollectionCap = ownerCollectionCap
            self.ownerVaultCap = ownerVaultCap
            self.startTime = startTime
            self.endTime = endTime
            self.owner = owner
            self.leader = owner
            self.resale = resale
            self.creator = creator
        }
    }

    // AuctionPublic is a resource interface that restricts users to
    // retreiving the auction price list and placing bids
    pub resource interface AuctionPublic {
        pub fun getAuctionPrices(): {UInt64: UFix64}
        pub fun getAuctionKeys() : [UInt64]

        pub fun getAuctionStatuses(): {UInt64: Bool}
        pub fun getAuctionStatus(_ id:UInt64): Bool

        pub fun placeBid(
            id: UInt64, 
            bidTokens: @FungibleToken.Vault, 
            vaultCap: Capability<&{FungibleToken.Receiver}>, 
            collectionCap: Capability<&{DisruptArt.DisruptArtCollectionPublic}>
        )

        pub fun settleAuction(_ id: UInt64)
    }

    // AuctionCollection contains a dictionary of AuctionItems and provides
    // methods for manipulating the AuctionItems
    pub resource AuctionCollection: AuctionPublic {

        // Auction Items
        pub var auctionItems: @{UInt64: AuctionItem}
        
        init() {
            self.auctionItems <- {}
        }

        // addTokenToauctionItems adds an NFT to the auction items and sets the meta data
        // for the auction item
        pub fun addTokenToAuctionItems(token: @NonFungibleToken.NFT, minimumBidIncrement: UFix64, startPrice: UFix64, bidVault: @FungibleToken.Vault, collectionCap: Capability<&{DisruptArt.DisruptArtCollectionPublic}>, vaultCap: Capability<&{FungibleToken.Receiver}>, endTime : Fix64) {
            
            pre {
                Fix64(getCurrentBlock().timestamp) < endTime : "endtime should greater than current time"
            }

            let bidtoken <-token as! @DisruptArt.NFT

            // create a new auction meta resource
            let meta = ItemMeta(
                minimumBidIncrement: minimumBidIncrement,
                startPrice: startPrice,
                startTime : Fix64(getCurrentBlock().timestamp),
                endTime : endTime,
                owner : self.owner?.address,
                auctionStartBlock: getCurrentBlock().height,
                ownerCollectionCap: collectionCap,
                ownerVaultCap: vaultCap,
                resale: (bidtoken.creator == bidtoken.owner?.address) ? false : true,
                creator: bidtoken.creator
            )
            
            let tokenID = bidtoken.id

            let itemToken <- bidtoken as! @NonFungibleToken.NFT

            // create a new auction items resource container
            let item <- create AuctionItem(
                NFT: <-itemToken,
                bidVault: <-bidVault,
                meta: meta
            )

            let id = item.meta.auctionID

            // update the auction items dictionary with the new resources
            let oldItem <- self.auctionItems[id] <- item
            destroy oldItem

            emit TokenAddedToAuctionItems(auctionID: id, startPrice: startPrice, minimumBidIncrement: minimumBidIncrement, auctionStartBlock: meta.auctionStartBlock, tokenID:tokenID, endTime:endTime)
        }

        // getAuctionPrices returns a dictionary of available NFT IDs with their current price
        pub fun getAuctionPrices(): {UInt64: UFix64} {
            pre {
                self.auctionItems.keys.length > 0: "There are no auction items"
            }

            let priceList: {UInt64: UFix64} = {}

            for id in self.auctionItems.keys {
                let itemRef = &self.auctionItems[id] as? &AuctionItem
                if itemRef.meta.auctionCompleted == false {
                    priceList[id] = itemRef.meta.currentPrice
                }
            }
            
            return priceList
        }

        pub fun getAuctionStatuses(): {UInt64: Bool} {
            pre {
                self.auctionItems.keys.length > 0: "There are no auction items"
            }

            let auctionList: {UInt64: Bool} = {}

            for id in self.auctionItems.keys {
                let itemRef = &self.auctionItems[id] as? &AuctionItem
                auctionList[id] = self.getAuctionStatus(id)
            }

            return auctionList

        }

        pub fun getAuctionStatus(_ id:UInt64): Bool {
            pre {
                self.auctionItems[id] != nil:
                    "NFT doesn't exist"
            }

            // Get the auction item resources
            let itemRef = &self.auctionItems[id] as &AuctionItem
            if itemRef.meta.auctionCompleted == false {
               return false
            } else {
               return true
            }

        }

        pub fun getAuctionKeys() : [UInt64] {

            pre {
                self.auctionItems.keys.length > 0: "There are no auction items"
            }

            return self.auctionItems.keys

        }

        // settleAuction sends the auction item to the highest bidder
        // and deposits the FungibleTokens into the auction owner's account
        pub fun settleAuction(_ id: UInt64) {
           
            pre {
                self.auctionItems.keys.length > 0: "There are no auction items"
                self.auctionItems.keys.contains(id): "Auction not found"
            }
           

            let itemRef = &self.auctionItems[id] as &AuctionItem
            let itemMeta = itemRef.meta

            if itemMeta.auctionCompleted {
                panic("This auction is already settled")
            }

            if itemRef.NFT == nil {
                panic("Auction doesn't exist")
            } 

            // check if the auction has expired
            if self.isAuctionExpired(id) == false {
                panic("Auction has not completed yet")
            }
                
            // return if there are no bids to settle
            if itemMeta.currentPrice == itemMeta.startPrice {
                self.returnAuctionItemToOwner(id)
            } else {            
                self.exchangeTokens(id)
            }

            itemMeta.auctionCompleted = true
            
            emit AuctionSettled(auctionID: id, price: itemMeta.currentPrice)
            
            if let item <- self.auctionItems.remove(key: id) {
                item.meta = itemMeta
                self.auctionItems[id] <-! item
            }
        }

        // isAuctionExpired returns true if the auction has exceeded it's length in blocks,
        // otherwise it returns false
        pub fun isAuctionExpired(_ id: UInt64): Bool {
            
            let itemRef = &self.auctionItems[id] as &AuctionItem
            let itemMeta = itemRef.meta
   
            let currentTime = getCurrentBlock().timestamp
            let endTime = itemMeta.endTime 
            
            if Fix64(endTime) < Fix64(currentTime) {
                return true
            } else {
                return false
            }
        }

        // exchangeTokens sends the purchased NFT to the buyer and the bidTokens to the seller
        pub fun exchangeTokens(_ id: UInt64) {
         
            let itemRef = &self.auctionItems[id] as &AuctionItem    
            
            if itemRef.NFT == nil {
                panic("auction doesn't exist")
            }
            
            let itemMeta = itemRef.meta

            itemRef.sendNFT(itemMeta.recipientCollectionCap)
            itemRef.sendBidTokens(itemMeta.ownerVaultCap, sale:true)
        }


        pub fun cancelAuction(_ id: UInt64) {
            pre {
                self.auctionItems[id] != nil:
                    "Auction does not exist"
            }

            if self.isAuctionExpired(id) {
                panic("Auciton expired, can't cancel")
            }

            let itemRef = &self.auctionItems[id] as &AuctionItem
            self.returnAuctionItemToOwner(id)
          
            let itemMeta = itemRef.meta
            itemMeta.auctionCompleted = true
            
            emit Canceled(auctionID: id)
          
            if let item <- self.auctionItems.remove(key: id) {
                item.meta = itemMeta
                self.auctionItems[id] <-! item
            }
        }

        // placeBid sends the bidder's tokens to the bid vault and updates the
        // currentPrice of the current auction item
        pub fun placeBid(id: UInt64, bidTokens: @FungibleToken.Vault, vaultCap: Capability<&{FungibleToken.Receiver}>, collectionCap: Capability<&{DisruptArt.DisruptArtCollectionPublic}>)  {
           
            pre {
                self.auctionItems[id] != nil:
                    "NFT doesn't exist"
            }

            // Get the auction item resources
            let itemRef = &self.auctionItems[id] as &AuctionItem
            let itemMeta = itemRef.meta

            if itemMeta.auctionCompleted {
                panic("auction has already completed")
            }

            if self.isAuctionExpired(id) {
                panic("Auciton expired, can't place a bid")
            }


            if bidTokens.balance < (itemMeta.currentPrice + itemMeta.minimumBidIncrement) {
                panic("bid amount be larger than minimum bid increment")
            }
            
            if itemRef.bidVault.balance != UFix64(0) {
                if let vaultCapy = itemMeta.recipientVaultCap {
                    itemRef.sendBidTokens(vaultCapy, sale:false)
                } else {
                    panic("unable to get recipient Vault capability")
                }
            }

            // Update the auction item
            itemRef.depositBidTokens(vault: <-bidTokens)

            // Update the current price of the token
            itemMeta.currentPrice = itemRef.bidVault.balance

            // Add the bidder's Vault and NFT receiver references
            itemMeta.recipientCollectionCap = collectionCap
            itemMeta.recipientVaultCap = vaultCap

            itemRef.meta = itemMeta

            emit NewBid(auctionID: id, bidPrice: itemMeta.currentPrice, bidder: vaultCap.address)
        }

        // releasePreviousBid returns the outbid user's tokens to
        // their vault receiver
        pub fun releasePreviousBid(_ id: UInt64) {
            // get a reference to the auction items resources
            let itemRef = &self.auctionItems[id] as &AuctionItem
            let itemMeta = itemRef.meta
            // release the bidTokens from the vault back to the bidder
            if let vaultCap = itemMeta.recipientVaultCap {
                itemRef.sendBidTokens(itemMeta.recipientVaultCap!, sale:false)
            } else {
                panic("unable to get vault capability")
            }
        }

        // TODO: I don't think we need this... this should already happen
        // when the resource gets destroyed
        //
        // returnAuctionItemToOwner releases any bids and returns the NFT
        // to the owner's Collection
        pub fun returnAuctionItemToOwner(_ id: UInt64) {
            let itemRef = &self.auctionItems[id] as &AuctionItem
            
            if itemRef.NFT == nil {
                panic("auction doesn't exist")
            }

            let itemMeta = itemRef.meta
            
            // release the bidder's tokens
            self.releasePreviousBid(id)
            
            // deposit the NFT into the owner's collection
            itemRef.sendNFT(itemMeta.ownerCollectionCap)
        }

        destroy() {
            for id in self.auctionItems.keys {
                self.returnAuctionItemToOwner(id)
            }
            // destroy the empty resources
            destroy self.auctionItems
        }
    }

    // createAuctionCollection returns a new AuctionCollection resource to the caller
    pub fun createAuctionCollection(): @AuctionCollection {
        let auctionCollection <- create AuctionCollection()
        return <- auctionCollection
    }

    init() {
        self.totalAuctions = UInt64(0)
    }   
}
 
