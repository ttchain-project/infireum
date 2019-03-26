//
//  UIImageView+ProfileImage.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/26.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation

extension UIImageView {
    func setProfileImage(image : String?, tempName:String?) {
        guard let url = URL.init(string:image ?? String()) else {
            guard let tempName = tempName, tempName.count > 0 else {
                self.image = #imageLiteral(resourceName: "no_image")
                return
            }
            self.image = ImageUntil.drawAvatar(text: tempName)
            return
        }
        self.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "no_image"))
    }
}
