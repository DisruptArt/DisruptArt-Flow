// DisruptArt Rates Smart Contract
// NFT Marketplace : www.Disrupt.Art
// Owner           : Disrupt Art, INC.
// Developer       : www.blaze.ws
// Version         : 0.0.1
// Blockchain      : Flow www.onFlow.org

pub contract DisruptArtRates {

  // Market operator Address 
  pub var disruptArtMarketAddress : Address
  // Market fee percentage 
  pub var disruptArtMarketplaceFees : UFix64
  // creator royality
  pub var disruptArtCreatorRoyalty : UFix64

  /// Path where the `Configs` is stored
  pub let DisruptArtStoragePath: StoragePath

  pub resource Admin {
    pub fun changeRated(newOperator: Address, marketCommission: UFix64, royality: UFix64 ) {
        DisruptArtRates.disruptArtMarketAddress = newOperator
        DisruptArtRates.disruptArtMarketplaceFees = marketCommission
        DisruptArtRates.disruptArtCreatorRoyalty = royality
    } 
  }

  init() {
    self.disruptArtMarketAddress = 0x4e96267cf76199ef
    // 5% DisruptArt Fee
    self.disruptArtMarketplaceFees = 0.05
    // 10% Royalty reward for original creater / minter for every re-sale
    self.disruptArtCreatorRoyalty = 0.1

    self.DisruptArtStoragePath = /storage/DisruptArtRates

    self.account.save(<- create Admin(), to:self.DisruptArtStoragePath)
  } 

}

