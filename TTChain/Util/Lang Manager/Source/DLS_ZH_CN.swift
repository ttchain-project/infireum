import Foundation

struct DLS_ZH_CN: DLS {
    var g_ok = "确定"
    var g_cancel = "取消"
    var g_loading = "载入中，请稍等"
    var g_close = "关闭"
    var g_done = "完成"
    var g_success = "成功"
    var g_confirm = "确认"
    var g_update = "更新"
    var g_copy = "复制"
    var g_edit = "编辑"
    var g_next = "下一步"
    var g_error_exit = "是否确认要离开？"
    var g_error_networkIssue = "网路发生问题，请再试一次"
    var g_error_networkTimeout = "连线已逾时，请重新尝试"
    var g_error_emptyform = "请输入"
    var g_error_networkUnreachable = "当前没有网路"
    var g_error_tokenInvalid = "检查到无效的 Token"
    var g_error_apiReject = "伺服器忙碌中，请稍后再试"
    var g_error_tokenExpired = "登入 Token 已过时"
    var g_error_appDisabled = "维护中"
    var g_error_appDisabled_detail = "App 目前正在维护"
    var g_error_invalidVersion = "版本过时"
    var g_error_emptyData = "查无资料"
    var g_error_broadcastFail = "广播失败"
    var g_error_encryptFail_mnemonic = "无法加密助记词"
    var g_error_encryptFail_privateKey = "无法加密私钥"
    var g_error_decryptFail_mnemonic = "无法解密助记词"
    var g_error_decryptFail_privateKey = "无法解密私钥"
    var g_camera_permission_requestion = "如要开启条码扫描功能，请允许开启相机权限"
    var g_error_mnemonic_wrong = "助记词错误。请删除多余空白或输入正确单字"
    var g_toast_addr_copied = "地址已复制"
    var lang_zh_cn = "简体中文"
    var lang_zh_tw = "繁体中文"
    var lang_en_us = "英文"
    func strValidate_error_common_spacePrefixOrSuffix(_ args: String...) -> String { return String.init(format: "%@首尾不得空白", arguments: args) }
    func strValidate_error_common_lengthInvalid(_ args: String...) -> String { return String.init(format: "%@长度需为 %@-%@ 字元", arguments: args) }
    func strValidate_error_common_allowAlphanumericOnly(_ args: String...) -> String { return String.init(format: "%@只允许使用英数字", arguments: args) }
    var strValidate_error_mnemonic_12WordsAtLeast = "助记词格式错误，必须包含 12 个以上单词"
    func strValidate_error_mnemonic_containUppercase(_ args: String...) -> String { return String.init(format: "助记词格式错误，侦测到含有非小写的单词 %@", arguments: args) }
    func strValidate_error_mnemonic_invalidCharacter(_ args: String...) -> String { return String.init(format: "助记词格式错误，侦测到非英文字元的单词 %@，请确认是否正确输入，并且使用一个半形空白分开各个单词", arguments: args) }
    var strValidate_error_confirmPwd_diffWithPwd = "两次密码输入不同"
    var strValidate_field_identityName = "名称"
    var strValidate_field_mnemonic = "助记词"
    var strValidate_field_pwd = "密码"
    var strValidate_field_confirmPwd = "确认密码"
    var strValidate_field_walletName = "钱包名称"
    var strValidate_field_pwdHint = "密码提示讯息"
    var strValidate_field_pwdHintSame = "密码与密码提示不能相同"
    var strValidate_field_addressInvalid = "请确认收款地址格式是否正确"
    var fee_cic_per_byte = "cic/b"
    var fee_eth_gas_price = "gas price"
    var fee_sat_per_byte = "sat/b"
    var fee_eth_gwei = "gwei"
    var fee_ether = "ether"
    var intro_title_page_one = "Welcome !\n欢迎来到HopeSeed"
    var intro_title_page_two = "多币种交易"
    var intro_title_page_three = "创新快速安全"
    var qrCodeImport_alert_error_wrong_pwd_title = "密码错误"
    func qrCodeImport_info_g_alert_error_title_error_field(_ args: String...) -> String { return String.init(format: "%@ 格式错误", arguments: args) }
    var qrCodeImport_info_g_alert_error_field_pwd = "密码"
    var qrCodeImport_info_g_alert_error_field_idName = "用户名称"
    var qrCodeImport_info_g_alert_error_field_hint = "密码提示讯息"
    var qrCodeImport_alert_error_wrong_pwd_content = "QRCODE 密码错误"
    var qrCodeImport_alert_input_pwd = "输入密码"
    var qrCodeImport_alert_content = "请输入 QRCODE 密码以解锁内容"
    func qrCodeImport_alert_placeholder_pwd(_ args: String...) -> String { return String.init(format: "密码提示: %@", arguments: args) }
    var qrCodeImport_list_user_system_wallets = "用户内的系统钱包"
    var qrCodeImport_list_imported_wallets = "外部导入的钱包"
    var qrCodeImport_list_title = "身份 QRCODE 内容"
    var qrCodeImport_list_label_will_not_import_existed_wallets = "已经存在的钱包地址将不会进行导入。"
    var qrCodeImport_info_title = "身份 QRCODE 内容"
    var qrCodeImport_info_label_intro = "是否要恢复此QRCODE内容？\n导入后所有钱包将使用您新设定的支付密码与提示"
    var qrCodeImport_info_placeholder_idName = "请输入用户名"
    var qrCodeImport_info_placeholder_pwd = "设定用户密码"
    var qrCodeImport_info_placeholder_hint = "设定密码提示"
    var qrCodeImport_info_btn_startImport = "开始导入"
    var qrCodeExport_alert_backup_title = "是否进行 QRCODE 备份？"
    var qrCodeExport_alert_note_content = "您输入的密码与提示会使用于 QR Code 的安全加密防护与引导，请使用易于记得的密码与适当的提示讯息。"
    var qrCodeExport_alert_placeholder_pwd = "密码 (8个以上英数字, 首尾不得空白)"
    var qrCodeExport_alert_placeholder_hint = "密码提示 (首尾不得空白)"
    var qrCodeExport_title = "备份 QRCODE"
    var qrCodeExport_btn_save_qrcode = "储存 QRCODE"
    var qrCodeExport_btn_qrcode_saved = "QRCODE 已储存"
    var qrCodeExport_btn_backup_qrcode = "備份QRCODE"
    var qrCodeExport_label_desc = "储存身份 QRCODE 后，您可以使用该 QRCODE 进行身份恢复以及钱包导入功能。请务必记得设定的 QRCODE 密码，在使用时系统需要您输入该密码以验证身份。"
    var qrCodeExport_label_user_system_wallets = "用户当前身份内的钱包"
    var qrCodeExport_label_imported_wallets = "外部导入的钱包"
    var qrcodeExport_toast_qrcode_saved_to_album = "QRCODE 已储存至相簿"
    var qrcodeExport_alert_title_did_not_backup_qrcode = "您尚未备份 QRCODE"
    var qrcodeExport_alert_content_did_not_backup_qrcode = "QRCODE 尚未储存至相簿，请问是否要进行备份？"
    var qrcodeExport_alert_btn_backup = "备份"
    var qrcodeExport_alert_btn_skip = "略过"
    var qrcodeProcess_alert_title_cannot_find_qrcode_in_img = "无法解析图片"
    var qrcodeProcess_alert_content_cannot_find_qrcode_in_img = "请确认图片是否含有 QRCode 内容"
    var qrcodeProcess_alert_title_cannot_decode_qrcode_in_img = "无法解析 QRCODE 内容"
    var qrcodeProcess_alert_content_cannot_decode_qrcode_in_img = "请确认 QRCODE 是否包含对应的资讯"
    var qrcodeProcess_alert_title_album_permission_denied = "尚未开启权限"
    var qrcodeProcess_alert_content_album_permission_denied = "您尚未开启使用相簿权限，请至「设定」开启权限以存取 QR Code"
    var qrcodeProcess_alert_content_camera_permission_denied = "您尚未开启使用相机权限，请至“设定”开启以存取 QR Code"
    var qrcodeProcess_hud_decoding = "解析中"
    var tab_wallet = "钱包"
    var tab_trade = "交易"
    var tab_me = "我的"
    var tab_chat = ""
    var tab_alert_newSystemWallet_title = "Hope Seed 支援了新的钱包！"
    var tab_alert_newSystemWallet_content = "若要新增钱包，请输入身份(钱包)密码"
    var tab_alert_placeholder_identityPwd = "身份(钱包)密码"
    var tab_alert_error_mnemonic_decrypt_failed = "密码输入错误"
    var tab_alert_error_wallet_sync_failed = "系统暂时无法新增钱包，请稍后再试"
    var agreement_title = "用户协议"
    var agreement_dont_display_again_today = "今天内不要再显示"
    var qrcode_title = "扫码"
    var qrcode_label_intro = "请将镜头对准二维码进行扫描"
    var qrcode_btn_withdrawal = "转帐"
    var qrcode_btn_importWallet = "导入钱包"
    var qrcode_btn_contact = "连络人"
    var qrcode_actionSheet_pickChainTypeToImport_title = "请选择导入钱包种类"
    var qrcode_actionSheet_pickChainTypeToImport_content = "请选择与原本扫描内容相同的钱包种类，以避免还原导入的资产"
    func qrcode_actionSheet_btn_mainCoinType(_ args: String...) -> String { return String.init(format: "%@ 钱包", arguments: args) }
    var login_label_title = "创建您的第一个数字身份\n轻松管理多链钱包"
    var login_btn_create = "创建身份"
    var login_label_desc = "创建身份将自动创建多链钱包"
    var login_btn_restore = "恢复身份"
    var login_label_or = "或"
    var login_actionsheet_restore_mnemonic = "助记词恢复"
    var login_actionsheet_restore_qrcode = "QRCODE 恢复"
    var login_alert_title_camera_permission_denied = "尚未开启权限"
    var login_alert_content_camera_permission_denied = "您尚未开启使用相簿权限，请至“设定”开启以存取 QR Code"
    var login_alert_title_import_qrcode_failed = "导入钱包失败"
    var login_alert_content_import_qrcode_failed = "系统无法导入您的身份钱包，请尝试使用其他的 QRCODE"
    var createID_title = "创建身份"
    var createID_hud_creating = "创建中..."
    var createID_btn_create = "创建"
    var createID_placeholder_name = "用戶名"
    var createID_placeholder_password = "密码"
    var createID_placeholder_confirmPassword = "重复输入密码"
    var createID_placeholder_passwordNote = "密码提示讯息"
    var createID_error_pwd_title = "密码错误"
    var createID_error_confirmPwd_title = "确认密码错误"
    var createID_error_identityName_title = "用戶名错误"
    var createID_error_pwdHint_title = "密码提示错误"
    var backupWallet_title = "备份钱包"
    var backupWallet_label_mainNote = "没有妥善备份就无法保障资产安全。删除程序或钱包后，你需要备份文件来恢复钱包。"
    var backupWallet_label_subNote = "请在四周无人、确保没有摄像头的安全环境进行备份。"
    var backupWallet_btn_backupMnemonic = "备份助记词"
    var backupMnemonic_title = "备份助记词"
    var backupMnemonic_desc = "请仔细抄写下方助记词，我们将在下一步验证。"
    var sortMnemonic_title = "排序助记词"
    var sortMnemonic_desc = "请按顺序点击助记词，以确认您正确备份。"
    var sortMnemonic_error_mnemonic_wrong_order = "助记词顺序错误"
    var sortMnemonic_error_create_user_fail = "创建使用者失败"
    var sortMnemonic_error_create_wallet_fail = "创建钱包失败"
    var restoreIdentity_label_settingPwd = "设置密码"
    var restoreIdentity_placeholder_walletPwd = "钱包密码"
    var restoreIdentity_placeholder_walletConfirmPwd = "重复输入密码"
    var restoreIdentity_placeholder_mnemonic = "输入助记词，用空格分隔"
    var restoreIdentity_placeholder_pwdHint = "密码提示信息"
    var restoreIdentity_btn_import = "开始导入"
    var restoreIdentity_title = "恢复身份"
    var restoreIdentity_label_able_to_change_pwd_note = "使用助记词导入的同时可以修改钱包密码。"
    var restoreIdentity_hud_restoring = "恢复中..."
    var restoreIdentity_hud_restoreSuccess = "导入成功"
    var restoreIdentity_error_create_user_fail = "创建使用者失败"
    var restoreIdentity_error_create_wallet_fail = "创建钱包失败"
    var restoreIdentity_error_pwd_title = "密码错误"
    var restoreIdentity_error_confirmPwd_title = "确认密码错误"
    var restoreIdentity_error_mnemonic_title = "助记词错误"
    var restoreIdentity_error_pwdHint_title = "密码提示错误"
    var localAuth_btn_tapToStartVerify = "点击唤醒验证"
    var localAuth_alert_verifyToBrowse_title = "请先验证身份以浏览钱包"
    var localAuth_alert_inputIdentiyPwd_title = "请输入身份密码"
    var walletOverview_refresher_status_pulling = "持续下拉以刷新"
    var walletOverview_refresher_status_overpulled = "放开以刷新"
    var walletOverview_refresher_status_loading = "读取中"
    var walletOverview_refresher_status_finished = "完成"
    var walletOverview_btn_deposit = "收款"
    var walletOverview_btn_manageAsset = "新增币种"
    var walletOverview_btn_txRecord = "转账记录"
    var walletOverview_btn_switchWallet = "切换钱包"
    func walletOverview_alert_withdrawal_noAsset_title(_ args: String...) -> String { return String.init(format: "尚无 %@ 资产", arguments: args) }
    func walletOverview_alert_withdrawal_noAsset_content(_ args: String...) -> String { return String.init(format: "您可以在管理资产页面开启/搜寻加入 %@ 来进行转帐", arguments: args) }
    func deposit_label_depositAddress(_ args: String...) -> String { return String.init(format: "%@ 收款地址", arguments: args) }
    var deposit_btn_changeAsset = "更换资产"
    var changeAsset_label_remainAmt = "余额:"
    var changeAsset_title = "选择资产类型"
    var manageAsset_searchBar_search_token_and_contract = "输入Token名称或合约地址"
    var manageAsset_btn_manage = "管理"
    var manageAsset_label_myAsset = "我的资产"
    var manageAsset_actoinSheet_hideEmptyAsset = "隐藏无余额资产"
    var manageAsset_actoinSheet_sortAlphabatically = "按字母排序"
    var manageAsset_actoinSheet_sortAlphabatically_cancel = "取消按字母排序"
    var manageAsset_actoinSheet_sortByAssetAmt = "按余额排序"
    var manageAsset_actoinSheet_sortByAssetAmt_cancel = "取消按余额排序"
    var manageAsset_actoinSheet_removeAsset = "移除资产"
    var searchAsset_label_myAsset = "我的资产"
    var searchAsset_label_resultNotFound = "未找到结果，您可以换个词重新搜寻看看"
    var changeWallet_label_wallets_current_identity = "当前身份下的钱包"
    var changeWallet_label_wallets_imported = "导入外部钱包"
    var changeWallet_label_offline = "离线"
    var changeWallet_alert_import_fail = "导入失败，已达外部钱包数量上限"
    var walletManage_title = "管理"
    var walletManage_label_pwdHint = "密码提示讯息"
    var walletManage_label_exportPKey = "导出私钥"
    var walletManage_error_pwd = "密码错误"
    var walletManage_alert_exportPKey_title = "导出私钥"
    var walletManage_alert_exportPKey_content = "请输入密码"
    var walletManage_alert_placeholder_exportPKey_pwd = "密码"
    var walletManage_alert_changeWalletName_title = "更换钱包名"
    var walletManage_alert_changeWalletName_content = "请输入要更换的钱包名字"
    var walletManage_error_walletName_invalidFormat_title = "钱包名称格式错误"
    var walletManage_alert_placeholder_walletName_char_range = "1-30 字元, 首尾请勿留空"
    var walletManage_btn_delete_wallet = "删除钱包"
    var walletManage_alert_title_delete_wallet = "删除钱包"
    var pwdHint_title = "密码提示讯息"
    var pwdHint_hud_updating = "更新中"
    var pwdHint_hud_updated = "已更新"
    var exportPKey_title = "导出私钥"
    var exportPKey_tab_privateKey = "私钥"
    var exportPKey_tab_qrcode = "二维码"
    var exportPKey_label_offline_save = "离线保存"
    var exportPKey_label_offline_save_message = "切勿保存至邮箱、记事本、网盘、聊天工具等，非常危险"
    var exportPKey_label_dont_trans_by_internet = "请勿使用网络传输"
    var exportPKey_label_dont_trans_by_internet_message = "请勿通过网络工具传输，一旦被黑客获取将造成不可挽回的资产损失。建议离线设备通过扫二维码方式传输"
    var exportPKey_label_pwd_manage_tool_save = "密码管理工具保存"
    var exportPKey_label_pwd_manage_tool_save_message = "建议使用密码管理工具管理"
    var exportPKey_label_provide_scan_directly_only = "仅供直接扫描"
    var exportPKey_label_provide_scan_directly_only_message = "二维码禁止保存、截图、以及拍照。仅供用户在安全环境下直接扫描来方便的导入钱包"
    var exportPKey_label_use_in_save_environment = "在安全环境下使用"
    var exportPKey_label_use_in_save_environment_message = "请在确保四周无人及无摄像头的情况下使用。二维码一旦被他人获取将造成不可挽回的资产损失"
    var exportPKey_btn_copy_private_key = "复制私钥"
    var importWallet_sourceChoose_label_title = "选择导入方式"
    var importWallet_sourceChoose_label_use_identity_qrcode = "使用身份 QRCODE"
    var importWallet_sourceChoose_label_identity_qrcode_desc = "选择使用身份 QRCODE 导入钱包，将可以快速导入所有该 QRCODE 内含有的钱包内容至当前身份，导入时将会要求您输入当初备份时设定的 QRCODE 密码。"
    var importWallet_sourceChoose_label_use_pKey = "使用钱包私钥"
    var importWallet_sourceChoose_label_user_pKey_desc = "选择使用钱包私钥导入，您需要选择特定导入的钱包型态 (BTC / ETH ... )，系统将会为您导入该私钥对应钱包型态的内容至身份内。"
    var importWallet_typeChoose_title = "选择钱包类型"
    var importWallet_typeChoose_btn_ethWallet = "以太坊钱包"
    var importWallet_typeChoose_btn_btcWallet = "比特币钱包"
    var importWallet_typeChoose_btn_cicWallet = "CIC 钱包"
    func importWallet_typeChoose_btn_generalWallet(_ args: String...) -> String { return String.init(format: "%@ 钱包", arguments: args) }
    var importWallet_privateKey_import_etherum_wallet = "导入ETHERUM钱包"
    var importWallet_privateKey_import_bitcoin_wallet = "导入BITCOIN钱包"
    var importWallet_privateKey_import_cic_wallet = "导入CIC钱包"
    var importWallet_privateKey_import_guc_wallet = "导入GUC钱包"
    func importWallet_privateKey_import_general_wallet(_ args: String...) -> String { return String.init(format: "导入%@钱包", arguments: args) }
    var importWallet_privateKey_error_import = "导入失败"
    var importWallet_privateKey_label_desc_private_key = "复制粘贴 PrivateKey 文件内容至输入框。或通过扫描 Private Key 内容生成的二维码录入。"
    var importWallet_privateKey_placeholder_hint_fill_in_private_key = "输入明文私钥"
    var importWallet_privateKey_hud_importing = "导入中..."
    var importWallet_privateKey_hud_imported = "导入成功"
    var importWallet_privateKey_label_setPwd = "设置密码"
    var importWallet_privateKey_placeholder_walletPwd = "钱包密码"
    var importWallet_privateKey_placeholder_confirmPwd = "重复输入密码"
    var importWallet_privateKey_placeholder_pwdHint = "密码提示信息"
    var importWallet_privateKey_btn_startImport = "开始导入"
    var importWallet_privateKey_error_pwd_invalid_format = "密码格式错误"
    var importWallet_privateKey_error_pwd_invalid_format_content = "至少包含 8 个字元"
    var importWallet_privateKey_error_confirmPwd_diff_with_pwd = "两次密码不同"
    var importWallet_privateKey_error_confirmPwd_diff_with_pwd_content = "请确认两次密码是否输入相同"
    var importWallet_privateKey_error_wallet_exist_already = "此钱包已存在"
    var assetDetail_btn_deposit = "收款"
    var assetDetail_btn_withdrawal = "转帐"
    var assetDetail_tab_total = "全部"
    var assetDetail_tab_withdrawal = "转出"
    var assetDetail_tab_deposit = "转入"
    var assetDetail_tab_fail = "失败"
    var assetDetail_label_tx_failed = "失败"
    var assetDetail_label_tx_go_check = "前往查看"
    func withdrawal_title(_ args: String...) -> String { return String.init(format: "%@转帐", arguments: args) }
    var withdrawal_btn_nextstep = "下一步"
    var withdrawal_error_same_address_content = "收款地址不得与付款地址相同"
    func withdrawal_error_asset_insuffient_content(_ args: String...) -> String { return String.init(format: "余额不足:\n您的资产 %@ %@\n转帐金额 %@ %@", arguments: args) }
    func withdrawal_error_asset_insuffient_for_same_asset_fee_content(_ args: String...) -> String { return String.init(format: "余额不足: 无法支付手续费\n您的资产: %@ %@\n转帐花费: (转移)%@ + (手续费)%@ ", arguments: args) }
    func withdrawal_error_fee_insufficient(_ args: String...) -> String { return String.init(format: "余额不足: 无法支付%@手续费\n手续费:%@ %@\n持有额度:%@ %@", arguments: args) }
    func withdrawal_error_fee_rate_too_low(_ args: String...) -> String { return String.init(format: "%@过低，建议高于 %@ %@", arguments: args) }
    func withdrawal_error_unknown(_ args: String...) -> String { return String.init(format: "发生未知的验证错误\n系统讯息: %@", arguments: args) }
    func withdrawal_label_assetAmt(_ args: String...) -> String { return String.init(format: "余额: %@ %@", arguments: args) }
    var withdrawal_placeholder_withdrawalAmt = "输入金额"
    var withdrawal_label_toAddr = "收款地址"
    var withdrawal_btn_common_used_addr = "常用地址"
    var withdrawal_placeholder_toAddr = "请输入地址"
    var withdrawal_label_fromAddr = "付款地址"
    var withdrawal_label_minerFee = "矿工费用"
    var withdrawal_placeholder_custom_btc_feeRate = "自定义手续费 (sat/b)"
    var withdrawal_placeholder_btc_feeRate_normal = "普通:"
    var withdrawal_placeholder_btc_feeRate_priority = "优先:"
    var withdrawal_label_advanced_mode = "高级模式"
    var withdrawal_label_slow = "慢"
    var withdrawal_label_fast = "快"
    var withdrawal_placeholder_eth_custom_gasPrice = "自定义 Gas Price"
    var withdrawal_placeholder_eth_custom_gas = "自定义 Gas"
    func withdrawal_label_eth_fee_content(_ args: String...) -> String { return String.init(format: "Gas(%@) * Gas Price (%@ gwei)", arguments: args) }
    var withdrawalConfirm_title = "支付详情"
    var withdrawalConfirm_label_payment_detail = "支付信息"
    var withdrawalConfirm_label_receipt_address = "收款地址"
    var withdrawalConfirm_label_payment_address = "付款地址"
    var withdrawalConfirm_label_miner_fee = "矿工费用"
    func withdrawalConfirm_label_payment_detail_content(_ args: String...) -> String { return String.init(format: "%@转帐", arguments: args) }
    var withdrawalConfirm_changeFee_title = "矿工费用设置"
    func withdrawalConfirm_changeWallet_label_assetAmt(_ args: String...) -> String { return String.init(format: "金额: %@ %@", arguments: args) }
    var withdrawalConfirm_changeWallet_title = "切换钱包"
    var withdrawalConfirm_pwdVerify_title = "请输入密码"
    var withdrawalConfirm_pwdVerify_label_input_wallet_pwd = "输入钱包密码"
    var withdrawalConfirm_pwdVerify_placeholder_wallet_pwd = "请输入钱包密码"
    var withdrawalConfirm_pwdVerify_error_pwd_is_wrong = "密码错误"
    var withdrawalConfirm_pwdVerify_hud_signing = "签章中"
    var withdrawalConfirm_pwdVerify_hud_broadcasting = "广播中"
    var withdrawalConfirm_pwdVerify_error_btc_insufficient_fee_title = "余额不足"
    func withdrawalConfirm_pwdVerify_error_btc_insufficient_fee_content(_ args: String...) -> String { return String.init(format: "您的 BTC 余额不足，交易转帐会收取额外的矿工费 %@ BTC, 请确认您的余额是否足够支付矿工费。", arguments: args) }
    var withdrawalConfirm_pwdVerify_error_tx_save_fail = "储存失败"
    var txRecord_title = "转账记录"
    var txRecord_btn_deposit = "转入"
    var txRecord_btn_withdrawal = "转出"
    var txRecord_btn_fail = "失败"
    var txRecord_empty_tx = "暂无转帐记录"
    var lightningTx_title = "闪电转帐"
    var lightningTx_label_rate = "汇率"
    var lightningTx_btn_exchange = "快速兑换"
    var lightningTx_placeholder_out_amt = "转出数量"
    var lightningTx_placeholder_in_amt = "收到数量"
    var lightningTx_label_txRecord = "本地兑换纪录"
    var lightningTx_label_empty_tx = "暂无本地兑换纪录"
    func lightningTx_label_txRecord_miner_fee(_ args: String...) -> String { return String.init(format: "矿工费用：%@ %@", arguments: args) }
    var lightningTx_label_txRecord_failed = "失败"
    var lightningTx_label_txRecord_go_check = "前往查看"
    func lightningTx_error_insufficient_asset_amt(_ args: String...) -> String { return String.init(format: "%@ 余额不足", arguments: args) }
    var lightningTx_error_empty_transRate_title = "无法取得转换汇率"
    var lightningTx_error_empty_transRate_content = "请检察网路是否正常, 点击确认将尝试更新汇率。"
    func lightningTx_error_no_asset_title(_ args: String...) -> String { return String.init(format: "該錢包尚無%@資產", arguments: args) }
    func lightningTx_error_no_asset_content(_ args: String...) -> String { return String.init(format: "請先至「新增與管理資產」加入 %@ 資產後再交易", arguments: args) }
    var lightningTx_label_custom = "自订"
    func lightningTx_label_remain_amt(_ args: String...) -> String { return String.init(format: "余额 %@", arguments: args) }
    var ltTx_title = "支付详情"
    var ltTx_label_pay_info = "支付信息"
    var ltTx_label_changeTo = "换取"
    var ltTx_label_exchangeRate = "转换汇率"
    var ltTx_label_toAddr = "收款地址"
    var ltTx_label_toAddr_empty_tap_to_set = "点击设定收款地址"
    var ltTx_label_fromAddr = "付款地址"
    var ltTx_label_minerFee = "矿工费用"
    var ltTx_minerFee_title = "矿工费用设置"
    var ltTx_changeToAddress_title = "选择收款地址"
    var ltTx_changeToAddress_label_toAddress = "收款地址"
    var ltTx_changeToAddress_btn_common_used_addr = "常用地址"
    func ltTx_changeToAddress_placeholder_input_valid_addr(_ args: String...) -> String { return String.init(format: "输入有效的 %@ 地址", arguments: args) }
    var ltTx_changeToAddress_label_toWallet = "收款钱包"
    var ltTx_pwdVerify_title = "请输入密码"
    var ltTx_pwdVerify_label_input_wallet_pwd = "输入钱包密码"
    var ltTx_pwdVerify_placeholder_input_wallet_pwd = "请输入钱包密码"
    var ltTx_pwdVerify_error_pwd_is_wrong = "密码错误"
    var ltTx_pwdVerify_hud_signing = "签章中"
    var ltTx_pwdVerify_hud_broadcasting = "广播中"
    var ltTx_pwdVerify_error_btc_insufficient_fee_title = "余额不足"
    func ltTx_pwdVerify_error_btc_insufficient_fee_content(_ args: String...) -> String { return String.init(format: "您的 BTC 余额不足，交易转帐会收取额外的矿工费 %@ BTC, 请确认您的余额是否足够支付矿工费。", arguments: args) }
    var ltTx_pwdVerify_error_tx_save_fail = "储存失败"
    var ltTx_pwdVerify_error_miner_fee_setting = "矿工费用设置"
    var ltTx_pwdVerify_error_miner_fee_input_p = "请输入矿工费"
    var ltTx_pwdVerify_error_payment_detail = "支付详情"
    var me_btn_edit = "编辑"
    var me_label_common_used_addr = "常用地址"
    var me_label_settings = "使用设置"
    var me_label_qa = "常见问题"
    var me_label_agreement = "用户协议"
    var me_label_check_update = "检查版本更新"
    var me_hud_checking = "检查中"
    var me_alert_already_latest_version_title = "目前已是最新版本"
    func me_alert_version_content(_ args: String...) -> String { return String.init(format: "当前版本: %@\n最新版本: %@", arguments: args) }
    var me_alert_able_to_update_version_title = "已有新版本，请立即更新以享有完整功能"
    var me_btn_update = "更新"
    var myIdentity_title = "我的身份"
    var myIdentity_label_name = "名字"
    var myIdentity_label_identityID = "身份 ID"
    var myIdentity_btn_backup_identity = "备份身份"
    var myIdentity_btn_exit_current_identity = "退出当前身份"
    var myIdentity_alert_changeName_title = "更换用戶名"
    var myIdentity_alert_changeName_content = "请输入要更换的昵称"
    var myIdentity_placeholder_changeName = "1-30 字元, 首尾不得留空"
    var myIdentity_error_name_invalid_format = "用戶名称格式错误"
    var myIdentity_error_unable_to_decrypt_mnemonic = "无法解密助记词，请确认密码是否正确"
    var myIdentity_error_pwd_is_wrong = "密码验证失败，请重新输入"
    var myIdentity_alert_backup_identity_title = "备份身份"
    var myIdentity_alert_input_pwd_content = "请输入密码"
    var myIdentity_alert_clearIdentity_title = "退出当前身份"
    var myIdentity_alert_clearIdentity_ensure_wallet_backup_content = "即将移除身份及所有已导入的钱包，请确保所有钱包已备份"
    var myIdentity_alert_clearIdentity_verify_pwd_title = "请输入密码"
    var myIdentity_alert_clearIdentity_verify_pwd_content = "警告:若无妥善备份，删除钱包后将无法找回钱包，请慎重处理该操作"
    var myIdentity_placeholder_pwd = "密码"
    var myIdentity_hud_exiting = "退出中"
    var myIdentity_hud_exited = "已退出"
    var backupWallet_sourceChoose_label_title = "选择备份方式"
    var backupWallet_sourceChoose_label_use_identity_qrcode = "备份身份 QRCODE"
    var backupWallet_sourceChoose_label_identity_qrcode_desc = "选择使用身份 QRCODE 备份，将可以备份当前身份下所有的钱包 (系统钱包+外部钱包)，系统会提供一个您的专属身份 QRCODE，日后在恢复身份或者导入钱包时，使用该 QRCODE 即可快速恢复所有钱包。"
    var backupWallet_sourceChoose_label_use_mnemonic = "备份身份助记词"
    var backupWallet_sourceChoose_label_user_mnemonic_desc = "选择备份身份助记词，系统将协助您导出「原身份」底下的钱包助记词。请特别留意该助记词并不会包含您外部导入的钱包资讯，日后若以该助记词恢复身份，将不会还原外部导入的钱包内容。"
    var settings_title = "使用设置"
    var settings_label_localAuth = "Touch ID / Face ID 验证"
    var settings_label_privateMode = "隐私模式"
    var settings_label_privateMode_note = "开启隐私模式后钱包的资产和金额将会隐藏"
    var settings_label_language = "语言"
    var settings_label_currencyUnit = "货币单位"
    var settings_alert_verify_to_turn_off_functionality = "验证以关闭功能"
    
    var account_setting_title = "帐户设定"
    var basic_setting_title = "基本设置"
    var follow_us_title = "关注我们"
    var others_title = "其他"
    
    var changePrefFiat_title = "货币单位"
    var changePrefFiat_btn_save = "保存"
    var addressbook_title = "常用地址"
    var addressbook_label_empty_addressbook = "暂无纪录"
    var abInfo_title = "联络人资讯"
    func abInfo_label_address_type(_ args: String...) -> String { return String.init(format: "%@地址", arguments: args) }
    var abInfo_btn_edit = "编辑"
    var abInfo_label_name = "名称"
    var abInfo_label_note = "备注"
    var ab_update_title_create = "新增联络人"
    var ab_update_title_edit = "编辑联络人"
    var ab_update_hud_saving = "储存中..."
    var ab_update_placeholder_name = "名称"
    var ab_update_placeholder_note = "备注(选填)"
    var ab_update_btn_save = "保存"
    var ab_update_error_unable_update_title = "无法更新"
    var ab_update_error_unable_create_title = "无法新增"
    var ab_update_error_already_has_same_unit_content = "已有相同的纪录"
    func ab_update_actionsheet_createAddress_general(_ args: String...) -> String { return String.init(format: "添加%@地址", arguments: args) }
    var ab_update_actionsheet_createAddress_btc = "添加比特币地址"
    var ab_update_actionsheet_createAddress_eth = "添加以太币地址"
    var ab_update_actionsheet_createAddress_cic = "添加 CIC 地址"
    var ab_update_label_createAddress = "添加地址"
    var ab_update_placeholder_input_valid_address = "请输入有效地址"
    var ab_update_alert_confirm_delete_address_title = "确定删除地址?"
    var ab_update_btn_delete_addressbook = "删除联络人"
    var ab_update_alert_confirm_delete_addressbook_title = "确定删除联络人？"
    var ab_update_alert_test_string = "測試文字"
    var chat_list_alert_recover_message_history_title = "取回通讯纪录"
    var chat_list_alert_recover_message_history_message = "小贴士：请先于原手机通讯>个人信息中设定"
    var chat_list_placeholder_recover_message_history = "请输入移转密码"
    var chat_list_alert_recover_message_history_create = "重新创建"
    var chat_list_alert_recover_message_history_recover = "开始移转"
    var chat_list_title = "通讯"
    var chat_extend_item_sweep_qrcode = "我的二维码"
    var chat_extend_item_add_channel = "创建群组"
    var chat_extend_item_add_friends = "添加好友"
    var chat_extend_item_search_group = "搜寻公开群"
    var chat_extend_item_social_envelope = "红包地址"
    var chat_extend_item_user_information = "个人信息"
    var user_profile_title = "个人信息"
    var user_profile_button_add_friend = "添加好友"
    var user_profile_block_user = "封锁用户"
    var user_profile_transfer_account = "移转帐号"
    var user_profile_alert_transfer_account_title = "设定移转密码"
    var user_profile_alert_transfer_account_message = "设定移转密码后即可将帐号移动至其他智慧手机"
    var user_profile_placeholder_transfer_account = "请输入移转密码"
    var add_friend_title = "添加朋友"
    var add_friend_alert_title = "验证信息"
    var add_friend_alert_message = "请输入好友验证信息"
    var add_friend_placeholder_message = ""
    var add_friend_alert_success = "已送出交友邀请"
    var add_friend_placeholder_friend_id = "扫描好友QR Code"
    
    var friend_request_title = "交友邀请"
    var group_request_title = "群组邀请"
    var friend = "好友"
    var group = "群组"
    
    var trend = "行情"
    var hot_group = "热门群组"
    var media =  "媒体"
    
    var blockchain_explorer = "区块链浏览器"
    var select_from_camera = "相機"
    var select_from_gallery = "從照片相簿選取"
    var create_group = "建立群組"

    var chat_secret_setting = "密聊设定"
    var decentralize = "去中心化"
    var time_limit = "时间限制"
    var chat_secret_single = "单次对话"
    var chat_secret_keep_5 = "保留5分钟"
    var chat_secret_keep_10 = "保留10分钟"
    var chat_secret_keep_20 = "保留20分钟"
    
    var tab_explorer = "发现"
    var tab_social = "社群"
    var tab_setting = "设定"
    
    var contact_title = "通讯录"
    var contact_individual = "个人"
    var contact_group = "群组"


    var stable_coin = "稳定币"
    var sto_coin = "上市区"
    var delete = "删除"
    var forward = "转传"
    var message_action =  "消息动作"
    
    var select_wallet_address = "请选择钱包地址"
    var backupChat_alert_password_mismatch = "钱包账号与移转备份密码不符"
    
    var copy_file_url = "复制档案网址"

    var confirm_cancel_editing = "确认取消编辑?"
    var exit_group = "退出群组"
    var manage_group = "管理群组"
    var confirm_exit = "确认退出群组"
    var confirm_delete_group = "确认解散删除群组?"
    var delete_group = "删除群组"
    var group_member = "群组成员"
    var manage_currency = "管理币种"

    var create_new_wallet = "新增钱包"
    var create_new_wallet_desc = "选择新增钱包，将使用助记词产生新的钱包地址。"
    var create_new_btc_wallet = "新增BTC钱包"
    var create_new_eth_wallet = "新增ETH钱包"
    
    var myQRCode = "我的QR Code"
    var chat_room_has_blocked = "这个聊天室被封锁了"
    
    var chat_room_receipt = "收款"
    var chat_room_image = "图片"
    var chat_room_camera = "相机"

    var copied_successfully = "复制成功"
    
    var secret_chat_on = "秘密聊天是开放的"
    
    var accept_request = "接受"
    var reject_request = "拒绝"

    var trans_success = "转帐成功"
    var trans_failed = "转帐失败"

}
