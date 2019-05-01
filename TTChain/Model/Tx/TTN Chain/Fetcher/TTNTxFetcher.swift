
import UIKit
import RxSwift
import RxCocoa
import RxOptional
import SwiftMoment

class TTNTxFetcher: TxFetcher {
    
    typealias Tx = TTNTx

    var mainCoin: Coin
    init(mainCoin: Coin) {
        self.mainCoin = mainCoin
    }
    
    func getTxs(address: String, page: Int = 0, offset: Int = 0) -> RxAPIResponse<TxFetcherElement<TTNTx>> {
        return Server.instance.getTTNTxRecords(ofAddress: address, mainCoin: mainCoin)
            .map {
                result in
                switch result {
                case .failed(error: let err):
                    return RxAPIResponse.ElementType.failed(error: err)
                case .success(let model):
                    let element = TxFetcherElement(txs: model.txs,
                                                   reachEnd: true)
                    return RxAPIResponse.ElementType.success(
                        element
                    )
                }
        }
    }
}
