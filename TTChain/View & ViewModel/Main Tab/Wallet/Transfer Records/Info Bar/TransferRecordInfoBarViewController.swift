//
//  TransferRecordInfoBarViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/10.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TransferRecordInfoBarViewController: KLModuleViewController, KLVMVC {
    
    static var prefererHeight: CGFloat {
        //1 for th esepline
        return 50 + 1
    }
    
    struct Config {
        let wallet: Wallet
    }
    
    typealias Constructor = Config
    typealias ViewModel = TransferRecordInfoBarViewModel
    var viewModel: TransferRecordInfoBarViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    func config(constructor: TransferRecordInfoBarViewController.Config) {
        view.layoutIfNeeded()
        setupCollectionView()
        viewModel = ViewModel.init(
            input:
                TransferRecordInfoBarViewModel.InputSource(
                    wallet: constructor.wallet,
                    switchToOptionBarsInput: expandListBtn.rx.tap.asDriver()
                ),
                output: ()
        )
        
        bindViewModel()
        startMonitorThemeIfNeeded()
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var expandListBtn: UIButton!
    @IBOutlet weak var sepline: UIView!
    
    public var onSwitchingToOptionBar: Driver<Void> {
        return viewModel.onSwitchToOptionBars
    }
    
    private func setupCollectionView() {
        collectionView.register(TransferRecordInfoBarCollectionViewCell.nib, forCellWithReuseIdentifier: TransferRecordInfoBarCollectionViewCell.cellIdentifier())
        collectionView.delegate = self
    }
    
    private func bindViewModel() {
        viewModel.options.bind(to: collectionView.rx.items(cellIdentifier: TransferRecordInfoBarCollectionViewCell.cellIdentifier(), cellType: TransferRecordInfoBarCollectionViewCell.self)) {
            row, option, cell in
            cell.config(contentName: option)
        }
        .disposed(by: bag)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        collectionView.backgroundColor = palette.specific(color: .owPaleGrey)
        expandListBtn.backgroundColor = palette.specific(color: .owPaleGrey)
        sepline.backgroundColor = palette.sepline
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

extension TransferRecordInfoBarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 40
        let cell = TransferRecordInfoBarCollectionViewCell.xibInstance() as! TransferRecordInfoBarCollectionViewCell
        let option = viewModel.getOptions()[indexPath.row]
        cell.config(contentName: option)
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
