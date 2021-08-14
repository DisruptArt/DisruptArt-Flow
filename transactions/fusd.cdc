// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.3


// FUSD Setup

import FungibleToken from 0x9a0766d93b6608b7
import FUSD from 0xe223d8a629e49c68

transaction {
  prepare(acct: AuthAccount) {

    let existingVault = acct.borrow<&FUSD.Vault>(from: /storage/fusdVault)

    if (existingVault == nil) {
          acct.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
          acct.link<&FUSD.Vault{FungibleToken.Receiver}>(
                    /public/fusdReceiver,
                    target: /storage/fusdVault
          )

          acct.link<&FUSD.Vault{FungibleToken.Balance}>(
                    /public/fusdBalance,
                    target: /storage/fusdVault
          )
    }
  }                                  
}

