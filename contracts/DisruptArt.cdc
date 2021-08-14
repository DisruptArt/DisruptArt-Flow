// DisruptArt NFT Smart Contract
// NFT Marketplace : www.DisruptArt.io
// Owner           : Disrupt Art, INC.
// Developer       : www.blaze.ws
// Version         : 0.0.3
// Blockchain      : Flow www.onFlow.org

import NonFungibleToken from 0x1592be4ab7835516


pub contract DisruptArt: NonFungibleToken {
   
    // Total number of token supply
    pub var totalSupply: UInt64
    // Total number of token groups
    pub var tokenGroup: UInt64
    // NFT No of Editions(Multiple copies) limit
    pub var editionLimit: UInt
    
    // Contract Events
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Mint(id: UInt64, content:String, owner: Address?, name:String)
    pub event GroupMint(id: UInt64, content:String, owner: Address?, name:String, tokenGroup: UInt64 )


    // TOKEN RESOURCE
    pub resource NFT: NonFungibleToken.INFT {

        // Unique identifier for NFT Token
        pub let id :UInt64

        // Meta data to store token data (use dict for data)
        pub let metaData: {String : String}

        // NFT token name
        pub let name:String

        // NFT token creator address
        pub let creator:Address?

        // In current store static dict in meta data
        init( id : UInt64, content : String, name:String, description:String , creator:Address?) {
            self.id = id
            self.metaData = {"content" : content, "description": description}
            self.creator = creator
            self.name = name
        }
    }

    // Account's public collection
    pub resource interface NFTPublicCollection {

        pub fun deposit(token:@NonFungibleToken.NFT)

        pub fun getIDs(): [UInt64]

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT

    } 

    // NFT Collection resource
    pub resource Collection : NFTPublicCollection, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        
        // Contains caller's list of NFTs
        pub var ownedNFTs: @{UInt64 : NonFungibleToken.NFT}

        init() {
            self.ownedNFTs <- {}
        }

        pub fun deposit(token: @NonFungibleToken.NFT) {

            let token <- token as! @DisruptArt.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // function returns token keys of owner
        pub fun getIDs():[UInt64] {
            return self.ownedNFTs.keys
        }

        // function returns token data of token id
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // function to check wether the owner have token or not
        pub fun tokenExists(id:UInt64) : Bool {
            return self.ownedNFTs[id] != nil
        }

        pub fun withdraw(withdrawID:UInt64) : @NonFungibleToken.NFT {
            
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token    

        }

        // Function to mint group of tokens
        pub fun GroupMint(recipient: &{NFTPublicCollection},content:String, description:String, name:String, edition:UInt) {
            pre {
                DisruptArt.editionLimit >= edition : "Edition count exceeds the limit"
                edition >=2 : "Edition count should be greater than or equal to 2"
            }
            var count = 0 as UInt
            while count < edition {
                let token <- create NFT(id: DisruptArt.totalSupply, content:content, name:name, description:description, creator: recipient.owner?.address)
                emit GroupMint(id:DisruptArt.totalSupply,content:content,owner: recipient.owner?.address, name:name, tokenGroup:DisruptArt.tokenGroup)
                recipient.deposit(token: <- token)
                DisruptArt.totalSupply = DisruptArt.totalSupply + 1 as UInt64
                count = count + 1
            }
            DisruptArt.tokenGroup = DisruptArt.tokenGroup + 1 as UInt64
        }

        pub fun Mint(recipient: &{NFTPublicCollection},content:String, name:String, description:String) {
            let token <- create NFT(id: DisruptArt.totalSupply, content:content, name:name, description:description, creator: recipient.owner?.address)
            emit Mint(id:DisruptArt.totalSupply,content:content,owner: recipient.owner?.address, name:name)
            recipient.deposit(token: <- token)
            DisruptArt.totalSupply = DisruptArt.totalSupply + 1 as UInt64
        } 

        destroy(){
            destroy self.ownedNFTs
        }

    }

    // This is used to create the empty collection. without this address cannot access our NFT token
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create DisruptArt.Collection()
    }
    // Admin can change the maximum supported group minting count limit for the platform. Currently it is 50
    pub resource Admin {
        pub fun changeLimit(limit:UInt) {
            DisruptArt.editionLimit = limit
        }
    }

    // Contract init
    init() {

        // total supply is zero at the time of contract deployment
        self.totalSupply = 0

        self.tokenGroup = 1

        self.editionLimit = 50

        self.account.save(<-self.createEmptyCollection(), to: /storage/DisruptArtNFTCollection)

        self.account.link<&{NFTPublicCollection}>(/public/DisruptArtNFTPublicCollection, target:/storage/DisruptArtNFTCollection)

        self.account.save(<-create self.Admin(), to: /storage/DirsuptArtAdmin)

        emit ContractInitialized()

    }

}
