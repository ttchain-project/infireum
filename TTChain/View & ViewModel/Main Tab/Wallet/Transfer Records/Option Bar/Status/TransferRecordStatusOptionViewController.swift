//
//  TransferRecordStatusOptionViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/11.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TransferRecordStatusOptionViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    typealias Constructor = Void
    typealias ViewModel = TransferRecordStatusOptionViewModel
    var viewModel: TransferRecordStatusOptionViewModel!
    var bag: DisposeBag = DisposeBag.init()
    func config(constructor: Void) {
        view.layoutIfNeeded()
        setupCollectionView()
        viewModel = ViewModel.init(
            input: TransferRecordStatusOptionViewModel.InputSource(
                selectInput: collectionView.rx.itemSelected.asDriver().map { $0.row }
            ),
            output: ()
        )
        
        bindViewModel()
        startMonitorThemeIfNeeded()
    }
    
    private func setupCollectionView() {
        collectionView.register(TransferRecordCancellableOptionBarCollectionViewCell.nib, forCellWithReuseIdentifier: TransferRecordCancellableOptionBarCollectionViewCell.cellIdentifier())
        collectionView.delegate = self
    }
    
    private func bindViewModel() {
        viewModel.statuses.bind(to: collectionView.rx.items(cellIdentifier: TransferRecordCancellableOptionBarCollectionViewCell.cellIdentifier(), cellType: TransferRecordCancellableOptionBarCollectionViewCell.self)) {
            [unowned self]
            row, status, cell in
            cell.config(withContent: status.name, isSelected: self.viewModel.isStatusSelected(status))
            }
            .disposed(by: bag)
        
        viewModel.selectedStatus.subscribe(onNext: {
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

extension TransferRecordStatusOptionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 40
        let cell = TransferRecordCancellableOptionBarCollectionViewCell.xibInstance() as! TransferRecordCancellableOptionBarCollectionViewCell
        let status = viewModel.getStatus(ofIdx: indexPath.row)
        cell.config(withContent: status.name, isSelected: true)
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

