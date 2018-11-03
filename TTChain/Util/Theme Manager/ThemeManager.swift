//
//  ThemeManager.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias ThemeResponder = (Theme) -> Void

enum Theme {
    case `default`
    
    var palette: OfflineWalletThemePalette {
        switch self {
        case .default:
            return OfflineWalletDefaultThemePalette()
        }
    }
}

typealias TM = ThemeManager

class ThemeManager {
    static let instance: ThemeManager = ThemeManager.init()
    static var palette: OfflineWalletThemePalette {
        return instance.theme.value.palette
    }
    
    var theme: BehaviorRelay<Theme> = BehaviorRelay.init(value: .default)
}

protocol OfflineWalletThemePalette {
    var application_main: UIColor { get set }
    var application_alert: UIColor { get set }
    var application_success: UIColor { get set }
    
    var btn_bgFill_enable_bg: UIColor { get set }
    var btn_bgFill_enable_text: UIColor { get set }
    var btn_bgFill_disable_bg: UIColor { get set }
    var btn_bgFill_disable_text: UIColor { get set }
    
    var btn_borderFill_enable_bg: UIColor { get set }
    var btn_borderFill_enable_text: UIColor { get set }
    var btn_borderFill_disable_bg: UIColor { get set }
    var btn_borderFill_diable_text: UIColor { get set }
    var btn_borderFill_border_1st: UIColor { get set }
    var btn_borderFill_border_2nd: UIColor { get set }
    
    var label_main_1: UIColor { get set }
    var label_main_2: UIColor { get set }
    var label_asAppMain: UIColor { get }
    var label_sub: UIColor { get set }
    
    var input_text: UIColor { get set }
    var input_placeholder: UIColor { get set }
    
    var sepline: UIColor { get set }
    
    var bgView_main: UIColor { get set }
    var bgView_sub: UIColor { get set }
    var bgView_mask: UIColor { get set }
    var bgView_border: UIColor { get set }
    
    var wallet_1_gradient_from: UIColor { get set }
    var wallet_1_gradient_to: UIColor { get set }
    var wallet_1_main: UIColor { get set }
    var wallet_2_gradient_from: UIColor { get set }
    var wallet_2_gradient_to: UIColor { get set }
    var wallet_2_main: UIColor { get set }
    var wallet_3_gradient_from: UIColor { get set }
    var wallet_3_gradient_to: UIColor { get set }
    var wallet_3_main: UIColor { get set }
    
    var nav_bg_1: UIColor { get set }
    var nav_bg_2: UIColor { get set }
    var nav_bg_clear: UIColor { get set }
    var nav_item_1: UIColor { get set }
    var nav_item_2: UIColor { get set }
    
    var pager_selected: UIColor { get set }
    var pager_unselected: UIColor { get set }
    
    var tab_selected: UIColor { get set }
    var tab_unselected: UIColor { get set }
    
    var networkView_reachable_bg: UIColor { get set }
    var networkView_reachable_text: UIColor { get set }
    var networkView_unreachable_bg: UIColor { get set }
    var networkView_unreachable_text: UIColor { get set }
    
    var hud_spinner: UIColor { get set }
    var hud_text: UIColor { get set }
    
    var mnemonic_item_border: UIColor { get set }
    var mnemonic_item_text: UIColor { get set }
    var mnemonic_item_bg: UIColor { get set }
    
    var recordStatus_deposit: UIColor { get set }
    var recordStatus_withdrawal: UIColor { get set }
    var recordStatus_failed: UIColor { get set }
    
    func specific(color: UIColor) -> UIColor
}

extension OfflineWalletThemePalette {
    func specific(color: UIColor) -> UIColor { return color }
}


struct OfflineWalletDefaultThemePalette: OfflineWalletThemePalette {
    var application_main: UIColor = .darkPink
    
    var application_alert: UIColor = .owPinkRed
    
    var application_success: UIColor = .owCoolGreen
    
    var btn_bgFill_enable_bg: UIColor = .darkPink
    
    var btn_bgFill_enable_text: UIColor = .owWhite
    
    var btn_bgFill_disable_bg: UIColor = .owSilver
    
    var btn_bgFill_disable_text: UIColor = .owWhite
    
    var btn_borderFill_enable_bg: UIColor = .clear
    
    var btn_borderFill_enable_text: UIColor = .owAzure
    
    var btn_borderFill_disable_bg: UIColor = .clear
    
    var btn_borderFill_diable_text: UIColor = .owSilver
    
    var btn_borderFill_border_1st: UIColor = .owAzure
    
    var btn_borderFill_border_2nd: UIColor = .owWhiteTwo
    
    var label_main_1: UIColor = .darkPink
    
    var label_main_2: UIColor = .owWhite
    
    var label_asAppMain: UIColor { return application_main }
    
    var label_sub: UIColor = .owWarmGrey
    
    var input_text: UIColor = .owSunsetOrange
    
    var input_placeholder: UIColor = .owWewak
    
    var sepline: UIColor = UIColor.cupid
    
    var bgView_main: UIColor = .owWhite
    
    var bgView_sub: UIColor = .lavenderBlush
    
    var bgView_mask: UIColor = .owBlack40
    
    var bgView_border: UIColor = .owWhiteTwo
    
    var wallet_1_gradient_from: UIColor = .owLiliac
    
    var wallet_1_gradient_to: UIColor = .owAzureTwo
    
    var wallet_1_main: UIColor = .owAzureTwo
    
    var wallet_2_gradient_from: UIColor = .owSunflowerYellow
    
    var wallet_2_gradient_to: UIColor = .owPumpkinOrange
    
    var wallet_2_main: UIColor = .owSunflowerYellow
    
    var wallet_3_gradient_from: UIColor = .owSicklyYellow
    
    var wallet_3_gradient_to: UIColor = .owDarkSeaGreen
    
    var wallet_3_main: UIColor = .owDarkSeaGreen
    
    var nav_bg_1: UIColor = .owWhite
    
    var nav_bg_2: UIColor = .owBlack
    
    var nav_bg_clear: UIColor = .clear
    
    var nav_item_1: UIColor = .owBlack
    
    var nav_item_2: UIColor = .owWhite
    
    var pager_selected: UIColor = .owBlack
    
    var pager_unselected: UIColor = .owSilver
    
    var tab_selected: UIColor = .owAzure
    
    var tab_unselected: UIColor = .owWarmGrey
    
    var networkView_reachable_bg: UIColor = .owCoolGreen
    
    var networkView_reachable_text: UIColor = .owWhite
    
    var networkView_unreachable_bg: UIColor = .owPinkRed
    
    var networkView_unreachable_text: UIColor = .owWhite
    
    var hud_spinner: UIColor = .owBlack
    
    var hud_text: UIColor = .owBlack
    
    var mnemonic_item_border: UIColor = .owSilver
    
    var mnemonic_item_text: UIColor = .owBlack
    
    var mnemonic_item_bg: UIColor = .owWhite
    
    var recordStatus_deposit: UIColor = .owCoolGreen
    
    var recordStatus_withdrawal: UIColor = .owAzure
    
    var recordStatus_failed: UIColor = .owPinkRed
}
