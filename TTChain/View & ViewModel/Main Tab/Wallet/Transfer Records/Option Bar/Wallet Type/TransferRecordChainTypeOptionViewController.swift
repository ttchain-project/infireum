//
//  TransferRecordChainTypeOptionViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/11.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TransferRecordChainTypeOptionViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    struct Config {
        let defaultMainCoin: Coin
    }
    
    typealias Constructor = Config
    typealias ViewModel = TransferRecordChainTypeOptionViewModel
    var viewModel: TransferRecordChainTypeOptionViewModel!
    var bag: DisposeBag = DisposeBag.init()
    func config(constructor: Config) {
        view.layoutIfNeeded()
        setupCollectionView()
        viewModel = ViewModel.init(
            input: TransferRecordChainTypeOptionViewModel.InputSource(
                selectInput: collectionView.rx.itemSelected.asDriver().map { $0.row },
                defaultMainCoin: constructor.defaultMainCoin
            ),
            output: ()
        )
        
        bindViewModel()
        startMonitorThemeIfNeeded()
    }
    
    private func setupCollectionView() {
        collectionView.register(TransferRecordSingleOptionBarCollectionViewCell.nib, forCellWithReuseIdentifier: TransferRecordSingleOptionBarCollectionViewCell.cellIdentifier())
        collectionView.delegate = self
    }
    
    private func bindViewModel() {
        viewModel.mainCoins.bind(to: collectionView.rx.items(cellIdentifier: TransferRecordSingleOptionBarCollectionViewCell.cellIdentifier(), cellType: TransferRecordSingleOptionBarCollectionViewCell.self)) {
                [unowned self]
                row, coin, cell in
                cell.config(
                    withContent: coin.inAppName!,
                    isSelected: self.viewModel.isMainCoinSelected(coin)
                )
            }
            .disposed(by: bag)
        
        viewModel.selectedMainCoin.subscribe(onNext: {
            [unowned self] _ in self.collectionView.reloadData()
        })
        .disposed(by: bag)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        collectionView.backgroundColor = palette.specific(color: .owPaleGrey)
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

extension TransferRecordChainTypeOptionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 42
        let cell = TransferRecordSingleOptionBarCollectionViewCell.xibInstance() as! TransferRecordSingleOptionBarCollectionViewCell
        let mainCoin = viewModel.getMainCoin(ofIdx: indexPath.row)
        cell.config(withContent: mainCoin.inAppName!, isSelected: true)
        let width = cell.systemLayoutSizeFitting(UILayoutFittingCompressedSize).width
        return CGSize.init(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 4, left: 20, bottom: 0, right: 0)
    }
}
