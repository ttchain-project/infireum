//
//  OWMnemonicViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/20.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class OWMnemonicViewController: UIViewController, KLVMVC {
    typealias ViewModel = OWMnemonicViewModel
    typealias Constructor = Setup
    struct Setup {
        let targetMnemonic: String
        let sourceMnemonic: String
        let delete: (String) -> Void
        let match: ((Bool?) -> Void)?
        let requiredHeight: (CGFloat) -> Void
        let empty: ((Bool) -> Void)?
    }
    
    var bag: DisposeBag = DisposeBag.init()
    var viewModel: OWMnemonicViewModel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func config(constructor: OWMnemonicViewController.Setup) {
        view.layoutIfNeeded()
        view.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.collectionViewLayout = KLTagFlowLayout(inset: .init(top: 20, left: 20, bottom: 20, right: 20))
        collectionView.backgroundColor = .clear
        
        collectionView.register(
            OWMnemonicWordCollectionViewCell.nib,
            forCellWithReuseIdentifier: OWMnemonicWordCollectionViewCell.cellIdentifier()
        )
        
        
        viewModel = ViewModel.init(
            input:
            OWMnemonicViewModel.InputSource(
                targetMnemonic: constructor.targetMnemonic,
                beginMnemonic: constructor.sourceMnemonic,
                itemRowSelected: collectionView.rx.itemSelected.asDriver().map { $0.row }
            ),
            output:
            OWMnemonicViewModel.OutputSource(
                wordSelectHandler: constructor.delete,
                sourcesUpdate: { [unowned self] (_) in
                    self.collectionView.reloadData()
                },
                matchingHandler: constructor.match
            )
        )
        
        bindCollectionView(constructor: constructor)
    }
    
    private func bindCollectionView(constructor: OWMnemonicViewController.Setup) {
        collectionView.rx.contentSize.subscribe(onNext: {
            size in
            let minHeight: CGFloat = 60
            let height = max(minHeight, size.height)
            constructor.requiredHeight(height)
        })
        .disposed(by: bag)
        
        viewModel.sources.bind(to:
            collectionView.rx.items(
                cellIdentifier: OWMnemonicWordCollectionViewCell.cellIdentifier(),
                cellType: OWMnemonicWordCollectionViewCell.self
            )
        ) {
            row, source, cell in
            cell.config(word: source)
        }
        .disposed(by: bag)
        
        viewModel.sources.map { $0.count == 0 }.subscribe(onNext: {
            isEmpty in
            constructor.empty?(isEmpty)
        })
        .disposed(by: bag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OWMnemonicViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = OWMnemonicWordCollectionViewCell.xibInstance() as! OWMnemonicWordCollectionViewCell
        let source = viewModel.sources.value[indexPath.row]
        let size = cell.sizeNeeded(ofWord: source)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)
    }
}

extension OWMnemonicViewController {
    func insert(word: String) {
        viewModel.insert(word: word)
    }
}
