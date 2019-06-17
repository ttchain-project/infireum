//
//  TTTabManButton.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/17.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import Tabman

class TTTabManButton: TMBarButton {
    
    let bgView =  UIView()
    let titleLabel = UILabel()
    
    override func layout(in view: UIView) {
        super.layout(in: view)
        
        adjustsAlphaOnSelection = false
        
        bgView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgView)
        self.bgView.addSubview(titleLabel)
        self.titleLabel.textColor = .white
        self.titleLabel.font = .owMedium(size:14)
        self.titleLabel.textAlignment = .center
        self.titleLabel.sizeToFit()
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            bgView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            bgView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            
            titleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 5),
            titleLabel.topAnchor.constraint(equalTo: bgView.topAnchor,constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor,constant: -5),
            titleLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor,constant: -5),
            ])
        
    }
    
    override func layoutSubviews() {
        self.bgView.layoutIfNeeded()
        self.titleLabel.layoutIfNeeded()
        self.bgView.cornerRadius = self.bgView.height/2
    }
    
    override func populate(for item: TMBarItemable) {
        super.populate(for: item)
        self.titleLabel.text = item.title
    }
    
    override func update(for selectionState: TMBarButton.SelectionState) {
        switch selectionState {
        case .selected:
            bgView.backgroundColor = UIColor.yellowGreen
         DLogInfo()
        default:
            bgView.backgroundColor = .clear
         DLogInfo()
        }
    }
}
