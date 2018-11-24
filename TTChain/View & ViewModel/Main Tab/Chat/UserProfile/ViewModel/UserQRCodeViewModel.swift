//
//  UserQRCodeViewModel.swift
//  OfflineWallet
//
//  Created by Archie on 2018/11/13.
//  Copyright © 2018 gib. All rights reserved.
//

import RxSwift
import RxCocoa

final class UserQRCodeViewModel: KLRxViewModel {
    var bag: DisposeBag = DisposeBag()
    typealias InputSource = Input
    typealias OutputSource = Output

    struct Input {
        let uID = BehaviorRelay<String?>(value: nil)
        
        init(imUser: FriendModel) {
            uID.accept(imUser.uid)
        }
    }
    struct Output {
        let image = BehaviorRelay<UIImage?>(value: nil)
    }

    var input: UserQRCodeViewModel.Input
    var output: UserQRCodeViewModel.Output
    

    init(input: UserQRCodeViewModel.Input, output: UserQRCodeViewModel.Output) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
        input.uID.map({ text -> UIImage? in
            guard let text = text else { return nil }
            return UIImage.init(ciImage: QRCodeGenerator.generateQRCode(from: text)!)
        }).bind(to: output.image).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
}
