//
//  Reactive+UITableView.swift
//  OfflineWallet
//
//  Created by Archie on 2019/2/21.
//  Copyright © 2019 GIB. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UITableView {
    var tableFooterView: Binder<UIView?> {
        return Binder(base) { tableView, value in
            tableView.tableFooterView = value
        }
    }
}
