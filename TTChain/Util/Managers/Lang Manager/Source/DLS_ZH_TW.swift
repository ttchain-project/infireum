import Foundation

struct DLS_ZH_TW: DLS {
    var g_alert_title: String = "請確認是否正確"
    var strValidate_error_mnemonic_with_space: String = "不正常的恢復短語"
    
    var g_ok = "確定"
    var g_cancel = "取消"
    var g_loading = "載入中，請稍等"
    var g_close = "關閉"
    var g_done = "完成"
    var g_success = "成功"
    var g_confirm = "確認"
    var g_update = "更新"
    var g_copy = "複製"
    var g_edit = "編輯"
    var g_next = "下一步"
    var g_error_exit = "是否確認要離開？"
    var g_something_went_wrong = "有些不對勁。 請再試一次。"
    var g_error_networkIssue = "網路發生問題，請再試一次"
    var g_error_networkTimeout = "連線已逾時，請重新嘗試"
    var g_error_emptyform = "請輸入"
    var g_error_networkUnreachable = "當前沒有網路"
    var g_error_tokenInvalid = "檢查到無效的 Token"
    var g_error_apiReject = "伺服器忙碌中，請稍後再試"
    var g_error_tokenExpired = "登入 Token 已過時"
    var g_error_appDisabled = "維護中"
    var g_error_appDisabled_detail = "App 目前正在維護"
    var g_error_invalidVersion = "版本過時"
    var g_error_emptyData = "查無資料"
    var g_error_broadcastFail = "廣播失敗"
    var g_error_encryptFail_mnemonic = "無法加密助記詞"
    var g_error_encryptFail_privateKey = "無法加密私鑰"
    var g_error_decryptFail_mnemonic = "無法解密助記詞"
    var g_error_decryptFail_privateKey = "無法解密私鑰"
    var g_camera_permission_requestion = "如要開啟條碼掃描功能，請允許開啟相機權限"
    var g_error_mnemonic_wrong = "助記詞錯誤。請刪除多餘空白或輸入正確單字"
    var g_toast_addr_copied = "地址已復制"
    var lang_zh_cn = "簡體中文"
    var lang_zh_tw = "繁體中文"
    var lang_en_us = "English"
    func strValidate_error_common_spacePrefixOrSuffix(_ args: String...) -> String { return String.init(format: "%@首尾不得空白", arguments: args) }
    func strValidate_error_common_lengthInvalid(_ args: String...) -> String { return String.init(format: "%@長度需為 %@-%@ 字元", arguments: args) }
    func strValidate_error_common_allowAlphanumericOnly(_ args: String...) -> String { return String.init(format: "%@只允許使用英數字", arguments: args) }
    var strValidate_error_mnemonic_12WordsAtLeast = "助記詞格式錯誤，必須包含 12 個以上單詞"
    func strValidate_error_mnemonic_containUppercase(_ args: String...) -> String { return String.init(format: "助記詞格式錯誤，偵測到含有非小寫的單詞 %@", arguments: args) }
    func strValidate_error_mnemonic_invalidCharacter(_ args: String...) -> String { return String.init(format: "助記詞格式錯誤，偵測到非英文字元的單詞 %@，請確認是否正確輸入，並且使用一個半形空白分開各個單詞", arguments: args) }
    var strValidate_error_confirmPwd_diffWithPwd = "兩次密碼輸入不同"
    var strValidate_field_identityName = "名稱"
    var strValidate_field_mnemonic = "助記詞"
    var strValidate_field_pwd = "密碼"
    var strValidate_field_confirmPwd = "確認密碼"
    var strValidate_field_walletName = "錢包名稱"
    var strValidate_field_pwdHint = "密碼提示訊息"
    var strValidate_field_pwdHintSame = "密碼與密碼提示不能相同"
    var strValidate_field_addressInvalid = "請確認收款地址格式是否正確"
    var fee_cic_per_byte = "cic/b"
    var fee_eth_gas_price = "gas price"
    var fee_sat_per_byte = "sat/b"
    var fee_eth_gwei = "gwei"
    var fee_ether = "ether"
    var intro_title_page_one = "Welcome !\n歡迎來到Infireum"
    var intro_title_page_two = "多幣種交易"
    var intro_title_page_three = "創新快速安全"
    var qrCodeImport_alert_error_wrong_pwd_title = "密碼錯誤"
    func qrCodeImport_info_g_alert_error_title_error_field(_ args: String...) -> String { return String.init(format: "%@ 格式錯誤", arguments: args) }
    var qrCodeImport_info_g_alert_error_field_pwd = "密碼"
    var qrCodeImport_info_g_alert_error_field_idName = "用戶名稱"
    var qrCodeImport_info_g_alert_error_field_hint = "密碼提示訊息"
    var qrCodeImport_alert_error_wrong_pwd_content = "QRCODE 密碼錯誤"
    var qrCodeImport_alert_input_pwd = "輸入密碼"
    var qrCodeImport_alert_content = "請輸入 QRCODE 密碼以解鎖內容"
    func qrCodeImport_alert_placeholder_pwd(_ args: String...) -> String { return String.init(format: "密碼提示: %@", arguments: args) }
    var qrCodeImport_list_user_system_wallets = "用戶內的系統錢包"
    var qrCodeImport_list_imported_wallets = "外部導入的錢包"
    var qrCodeImport_list_title = "身份 QRCODE 內容"
    var qrCodeImport_list_label_will_not_import_existed_wallets = "已經存在的錢包地址將不會進行導入。"
    var qrCodeImport_info_title = "身份 QRCODE 內容"
    var qrCodeImport_info_label_intro = "是否要恢復此QRCODE內容？ \n導入後所有錢包將使用您新設定的支付密碼與提示"
    var qrCodeImport_info_placeholder_idName = "請輸入用戶名"
    var qrCodeImport_info_placeholder_pwd = "設定用戶密碼"
    var qrCodeImport_info_placeholder_hint = "設定密碼提示"
    var qrCodeImport_info_btn_startImport = "開始導入"
    var qrCodeExport_alert_backup_title = "是否進行 QRCODE 備份？"
    var qrCodeExport_alert_note_content = "您輸入的密碼與提示會使用於 QR Code 的安全加密防護與引導，請使用易於記得的密碼與適當的提示訊息。"
    var qrCodeExport_alert_placeholder_pwd = "密碼 (8個以上英數字, 首尾不得空白)"
    var qrCodeExport_alert_placeholder_hint = "密碼提示 (首尾不得空白)"
    var qrCodeExport_title = "備份 QRCODE"
    var qrCodeExport_btn_save_qrcode = "儲存 QRCODE"
    var qrCodeExport_btn_qrcode_saved = "QRCODE 已儲存"
    var qrCodeExport_btn_backup_qrcode = "備份QRCODE"
    var qrCodeExport_label_desc = "儲存身份 QRCODE 後，您可以使用該 QRCODE 進行身份恢復以及錢包導入功能。請務必記得設定的 QRCODE 密碼，在使用時系統需要您輸入該密碼以驗證身份。"
    var qrCodeExport_label_user_system_wallets = "用戶當前身份內的錢包"
    var qrCodeExport_label_imported_wallets = "外部導入的錢包"
    var qrcodeExport_toast_qrcode_saved_to_album = "QRCODE 已儲存至相簿"
    var qrcodeExport_alert_title_did_not_backup_qrcode = "您尚未備份 QRCODE"
    var qrcodeExport_alert_content_did_not_backup_qrcode = "QRCODE 尚未儲存至相簿，請問是否要進行備份？"
    var qrcodeExport_alert_btn_backup = "備份"
    var qrcodeExport_alert_btn_skip = "略過"
    var qrcodeProcess_alert_title_cannot_find_qrcode_in_img = "無法解析圖片"
    var qrcodeProcess_alert_content_cannot_find_qrcode_in_img = "請確認圖片是否含有 QRCode 內容"
    var qrcodeProcess_alert_title_cannot_decode_qrcode_in_img = "無法解析 QRCODE 內容"
    var qrcodeProcess_alert_content_cannot_decode_qrcode_in_img = "請確認 QRCODE 是否包含對應的資訊"
    var qrcodeProcess_alert_title_album_permission_denied = "尚未開啟權限"
    var qrcodeProcess_alert_content_album_permission_denied = "您尚未開啟使用相簿權限，請至「設定」開啟權限以存取 QR Code"
    var qrcodeProcess_alert_content_camera_permission_denied = "您尚未開啟使用相機權限，請至“設定”開啟以存取 QR Code"
    var qrcodeProcess_hud_decoding = "解析中"
    var tab_wallet = "錢包"
    var tab_trade = "交易"
    var tab_me = "我的"
    var tab_chat = "聊天"
    var tab_alert_newSystemWallet_title = "Infireum 支援了新的錢包！"
    var tab_alert_newSystemWallet_content = "若要新增錢包，請輸入身份(錢包)密碼"
    var tab_alert_placeholder_identityPwd = "身份(錢包)密碼"
    var tab_alert_error_mnemonic_decrypt_failed = "密碼輸入錯誤"
    var tab_alert_error_wallet_sync_failed = "系統暫時無法新增錢包，請稍後再試"
    var agreement_title = "用戶協議"
    var agreement_dont_display_again_today = "今天內不要再顯示"
    var qrcode_title = "掃碼"
    var qrcode_label_intro = "請將鏡頭對準二維碼進行掃描"
    var qrcode_btn_withdrawal = "轉帳"
    var qrcode_btn_select_photo = "選擇相片"
    var qrcode_btn_importWallet = "導入錢包"
    var qrcode_btn_contact = "連絡人"
    var qrcode_actionSheet_pickChainTypeToImport_title = "請選擇導入錢包種類"
    var qrcode_actionSheet_pickChainTypeToImport_content = "請選擇與原本掃描內容相同的錢包種類，以避免還原導入的資產"
    func qrcode_actionSheet_btn_mainCoinType(_ args: String...) -> String { return String.init(format: "%@ 錢包", arguments: args) }
    var login_label_title = "創建您的第一個數字身份\n輕鬆管理多鏈錢包"
    var login_btn_create = "創建身份"
    var login_label_desc = "創建身份將自動創建多鏈錢包"
    var login_btn_restore = "恢復身份"
    var login_label_or = "或"
    var login_actionsheet_restore_mnemonic = "助記詞恢復"
    var login_actionsheet_restore_qrcode = "QRCODE 恢復"
    var login_alert_title_camera_permission_denied = "尚未開啟權限"
    var login_alert_content_camera_permission_denied = "您尚未開啟使用相簿權限，請至“設定”開啟以存取 QR Code"
    var login_alert_title_import_qrcode_failed = "導入錢包失敗"
    var login_alert_content_import_qrcode_failed = "系統無法導入您的身份錢包，請嘗試使用其他的 QRCODE"
    var createID_title = "創建身份"
    var createID_hud_creating = "創建中..."
    var createID_btn_create = "創建"
    var createID_placeholder_name = "用戶名"
    var createID_placeholder_password = "密碼"
    var createID_placeholder_confirmPassword = "重複輸入密碼"
    var createID_placeholder_passwordNote = "密碼提示訊息"
    var createID_error_pwd_title = "密碼錯誤"
    var createID_error_confirmPwd_title = "確認密碼錯誤"
    var createID_error_identityName_title = "用戶名错误"
    var createID_error_pwdHint_title = "密碼提示錯誤"
    var backupWallet_title = "備份錢包"
    var backupWallet_label_mainNote = "沒有妥善備份就無法保障資產安全。刪除程序或錢包後，你需要備份文件來恢復錢包。"
    var backupWallet_label_subNote = "請在四周無人、確保沒有攝像頭的安全環境進行備份。"
    var backupWallet_btn_backupMnemonic = "備份助記詞"
    var backupMnemonic_title = "備份助記詞"
    var backupMnemonic_desc = "請仔細抄寫下方助記詞，我們將在下一步驗證。"
    var sortMnemonic_title = "排序助記詞"
    var sortMnemonic_desc = "請按順序點擊助記詞，以確認您正確備份。"
    var sortMnemonic_error_mnemonic_wrong_order = "助記詞順序錯誤"
    var sortMnemonic_error_create_user_fail = "創建使用者失敗"
    var sortMnemonic_error_create_wallet_fail = "創建錢包失敗"
    var restoreIdentity_label_settingPwd = "設置密碼"
    var restoreIdentity_placeholder_walletPwd = "錢包密碼"
    var restoreIdentity_placeholder_walletConfirmPwd = "重複輸入密碼"
    var restoreIdentity_placeholder_mnemonic = "輸入助記詞，用空格分隔"
    var restoreIdentity_placeholder_pwdHint = "密碼提示信息"
    var restoreIdentity_btn_import = "開始導入"
    var restoreIdentity_title = "恢復身份"
    var restoreIdentity_label_able_to_change_pwd_note = "使用助記詞導入的同時可以修改錢包密碼。"
    var restoreIdentity_hud_restoring = "恢復中..."
    var restoreIdentity_hud_restoreSuccess = "導入成功"
    var restoreIdentity_error_create_user_fail = "創建使用者失敗"
    var restoreIdentity_error_create_wallet_fail = "創建錢包失敗"
    var restoreIdentity_error_pwd_title = "密碼錯誤"
    var restoreIdentity_error_confirmPwd_title = "確認密碼錯誤"
    var restoreIdentity_error_mnemonic_title = "助記詞錯誤"
    var restoreIdentity_error_pwdHint_title = "密碼提示錯誤"
    var localAuth_btn_tapToStartVerify = "點擊喚醒驗證"
    var localAuth_alert_verifyToBrowse_title = "請先驗證身份以瀏覽錢包"
    var localAuth_alert_inputIdentiyPwd_title = "請輸入身份密碼"
    var walletOverview_refresher_status_pulling = "持續下拉以刷新"
    var walletOverview_refresher_status_overpulled = "放開以刷新"
    var walletOverview_refresher_status_loading = "讀取中"
    var walletOverview_refresher_status_finished = "完成"
    var walletOverview_btn_deposit = "收款"
    var walletOverview_btn_manageAsset = "新增幣種"
    var walletOverview_btn_txRecord = "轉賬記錄"
    var walletOverview_btn_switchWallet = "切換錢包"
    func walletOverview_alert_withdrawal_noAsset_title(_ args: String...) -> String { return String.init(format: "尚無 %@ 資產", arguments: args) }
    func walletOverview_alert_withdrawal_noAsset_content(_ args: String...) -> String { return String.init(format: "您可以在管理資產頁面開啟/搜尋加入 %@ 來進行轉帳", arguments: args) }
    func deposit_label_depositAddress(_ args: String...) -> String { return String.init(format: "%@ 收款地址", arguments: args) }
    var deposit_btn_changeAsset = "更換資產"
    var changeAsset_label_remainAmt = "餘額:"
    var changeAsset_title = "選擇資產類型"
    var manageAsset_searchBar_search_token_and_contract = "輸入Token名稱或合約地址"
    var manageAsset_btn_manage = "管理"
    var manageAsset_label_myAsset = "我的資產"
    var manageAsset_actoinSheet_hideEmptyAsset = "隱藏無餘額資產"
    var manageAsset_actoinSheet_sortAlphabatically = "按字母排序"
    var manageAsset_actoinSheet_sortAlphabatically_cancel = "取消按字母排序"
    var manageAsset_actoinSheet_sortByAssetAmt = "按餘額排序"
    var manageAsset_actoinSheet_sortByAssetAmt_cancel = "取消按餘額排序"
    var manageAsset_actoinSheet_removeAsset = "移除資產"
    var searchAsset_label_myAsset = "我的資產"
    var searchAsset_label_resultNotFound = "未找到結果，您可以換個詞重新搜尋看看"
    var changeWallet_label_wallets_current_identity = "當前身份下的錢包"
    var changeWallet_label_wallets_imported = "導入外部錢包"
    var changeWallet_label_offline = "離線"
    var changeWallet_alert_import_fail = "導入失敗，已達外部錢包數量上限"
    var walletManage_title = "管理"
    var walletManage_label_pwdHint = "密碼提示訊息"
    var walletManage_label_exportPKey = "導出私鑰"
    var walletManage_error_pwd = "密碼錯誤"
    var walletManage_alert_exportPKey_title = "導出私鑰"
    var walletManage_alert_exportPKey_content = "請輸入密碼"
    var walletManage_alert_placeholder_exportPKey_pwd = "密碼"
    var walletManage_alert_changeWalletName_title = "更換錢包名"
    var walletManage_alert_changeWalletName_content = "請輸入要更換的錢包名字"
    var walletManage_error_walletName_invalidFormat_title = "錢包名稱格式錯誤"
    var walletManage_alert_wallet_name_changed_title = "已更改錢包名稱"
    var walletManage_alert_wallet_name_changed_message = "錢包名稱將變更為新名稱"
    var walletManage_alert_placeholder_walletName_char_range = "1-30 字元, 首尾請勿留空"
    var walletManage_btn_delete_wallet = "刪除錢包"
    var walletManage_alert_title_delete_wallet = "刪除錢包"
    var pwdHint_title = "密碼提示訊息"
    var pwdHint_hud_updating = "更新中"
    var pwdHint_hud_updated = "已更新"
    var exportPKey_title = "導出私鑰"
    var exportPKey_tab_privateKey = "私鑰"
    var exportPKey_tab_qrcode = "二維碼"
    var exportPKey_label_offline_save = "離線保存"
    var exportPKey_label_offline_save_message = "切勿保存至郵箱、記事本、網盤、聊天工具等，非常危險"
    var exportPKey_label_dont_trans_by_internet = "請勿使用網絡傳輸"
    var exportPKey_label_dont_trans_by_internet_message = "請勿通過網絡工具傳輸，一旦被黑客獲取將造成不可挽回的資產損失。建議離線設備通過掃二維碼方式傳輸"
    var exportPKey_label_pwd_manage_tool_save = "密碼管理工具保存"
    var exportPKey_label_pwd_manage_tool_save_message = "建議使用密碼管理工具管理"
    var exportPKey_label_provide_scan_directly_only = "僅供直接掃描"
    var exportPKey_label_provide_scan_directly_only_message = "二維碼禁止保存、截圖、以及拍照。僅供用戶在安全環境下直接掃描來方便的導入錢包"
    var exportPKey_label_use_in_save_environment = "在安全環境下使用"
    var exportPKey_label_use_in_save_environment_message = "請在確保四周無人及無攝像頭的情況下使用。二維碼一旦被他人獲取將造成不可挽回的資產損失"
    var exportPKey_btn_copy_private_key = "複製私鑰"
    var importWallet_sourceChoose_label_title = "選擇導入方式"
    var importWallet_sourceChoose_label_use_identity_qrcode = "使用身份 QRCODE"
    var importWallet_sourceChoose_label_identity_qrcode_desc = "選擇使用身份 QRCODE 導入錢包，將可以快速導入所有該 QRCODE 內含有的錢包內容至當前身份，導入時將會要求您輸入當初備份時設定的 QRCODE 密碼。"
    var importWallet_sourceChoose_label_use_pKey = "使用錢包私鑰"
    var importWallet_sourceChoose_label_user_pKey_desc = "選擇使用錢包私鑰導入，您需要選擇特定導入的錢包型態 (BTC / ETH ... )，系統將會為您導入該私鑰對應錢包型態的內容至身份內。"
    var importWallet_typeChoose_title = "選擇錢包類型"
    var importWallet_typeChoose_btn_ethWallet = "以太坊錢包"
    var importWallet_typeChoose_btn_btcWallet = "比特幣錢包"
    var importWallet_typeChoose_btn_cicWallet = "CIC 錢包"
    func importWallet_typeChoose_btn_generalWallet(_ args: String...) -> String { return String.init(format: "%@ 錢包", arguments: args) }
    var importWallet_privateKey_import_etherum_wallet = "導入ETHERUM錢包"
    var importWallet_privateKey_import_bitcoin_wallet = "導入BITCOIN錢包"
    var importWallet_privateKey_import_cic_wallet = "導入CIC錢包"
    var importWallet_privateKey_import_guc_wallet = "導入GUC錢包"
    func importWallet_privateKey_import_general_wallet(_ args: String...) -> String { return String.init(format: "導入%@錢包", arguments: args) }
    var importWallet_privateKey_error_import = "導入失敗"
    var importWallet_privateKey_label_desc_private_key = "請輸入私鑰 或 使用行動條碼掃描"
    var importWallet_privateKey_placeholder_hint_fill_in_private_key = "輸入私鑰"
    var importWallet_privateKey_hud_importing = "導入中..."
    var importWallet_privateKey_hud_imported = "導入成功"
    var importWallet_privateKey_label_setPwd = "設置密碼"
    var importWallet_privateKey_placeholder_walletPwd = "錢包密碼"
    var importWallet_privateKey_placeholder_confirmPwd = "重複輸入密碼"
    var importWallet_privateKey_placeholder_pwdHint = "密碼提示信息"
    var importWallet_privateKey_btn_startImport = "開始導入"
    var importWallet_privateKey_error_pwd_invalid_format = "密碼格式錯誤"
    var importWallet_privateKey_error_pwd_invalid_format_content = "至少包含 8 個字元"
    var importWallet_privateKey_error_confirmPwd_diff_with_pwd = "兩次密碼不同"
    var importWallet_privateKey_error_confirmPwd_diff_with_pwd_content = "請確認兩次密碼是否輸入相同"
    var importWallet_privateKey_error_wallet_exist_already = "此錢包已存在"
    var assetDetail_btn_deposit = "收款"
    var assetDetail_btn_withdrawal = "轉帳"
    var assetDetail_tab_total = "全部"
    var assetDetail_tab_withdrawal = "轉出"
    var assetDetail_tab_deposit = "轉入"
    var assetDetail_tab_fail = "失敗"
    var assetDetail_label_tx_failed = "失敗"
    var assetDetail_label_tx_go_check = "前往查看TXID"
    func withdrawal_title(_ args: String...) -> String { return String.init(format: "%@轉帳", arguments: args) }
    var withdrawal_btn_nextstep = "下一步"
    var withdrawal_error_same_address_content = "收款地址不得與付款地址相同"
    func withdrawal_error_asset_insuffient_content(_ args: String...) -> String { return String.init(format: "餘額不足:\n您的資產 %@ %@\n轉帳金額 %@ %@", arguments: args) }
    func withdrawal_error_asset_insuffient_for_same_asset_fee_content(_ args: String...) -> String { return String.init(format: "餘額不足: 無法支付手續費\n您的資產: %@ %@\n轉帳花費: (轉移)%@ + (手續費)%@ ", arguments: args) }
    func withdrawal_error_fee_insufficient(_ args: String...) -> String { return String.init(format: "餘額不足: 無法支付%@手續費\n手續費:%@ %@\n持有額度:%@ %@", arguments: args) }
    func withdrawal_error_fee_rate_too_low(_ args: String...) -> String { return String.init(format: "%@過低，建議高於 %@ %@", arguments: args) }
    func withdrawal_error_unknown(_ args: String...) -> String { return String.init(format: "發生未知的驗證錯誤\n系統訊息: %@", arguments: args) }
    func withdrawal_label_assetAmt(_ args: String...) -> String { return String.init(format: "餘額: %@ %@", arguments: args) }
    var withdrawal_placeholder_withdrawalAmt = "輸入金額"
    var withdrawal_label_toAddr = "收款地址"
    var withdrawal_btn_common_used_addr = "常用地址"
    var withdrawal_placeholder_toAddr = "請輸入地址"
    var withdrawal_label_fromAddr = "付款地址"
    var withdrawal_label_minerFee = "礦工費用"
    var withdrawal_placeholder_custom_btc_feeRate = "自定義手續費 (btc)"
    var withdrawal_placeholder_btc_feeRate_normal = "普通:"
    var withdrawal_placeholder_btc_feeRate_priority = "優先:"
    var withdrawal_label_advanced_mode = "高級模式"
    var withdrawal_label_slow = "慢"
    var withdrawal_label_fast = "快"
    var withdrawal_placeholder_eth_custom_gasPrice = "自定義 Gas Price"
    var withdrawal_placeholder_eth_custom_gas = "自定義 Gas"
    func withdrawal_label_eth_fee_content(_ args: String...) -> String { return String.init(format: "Gas(%@) * Gas Price (%@ gwei)", arguments: args) }
    var withdrawalConfirm_title = "支付詳情"
    var withdrawalConfirm_label_payment_detail = "支付信息"
    var withdrawalConfirm_label_receipt_address = "收款地址"
    var withdrawalConfirm_label_payment_address = "付款地址"
    var withdrawalConfirm_label_miner_fee = "礦工費用"
    func withdrawalConfirm_label_payment_detail_content(_ args: String...) -> String { return String.init(format: "%@轉帳", arguments: args) }
    var withdrawalConfirm_changeFee_title = "礦工費用設置"
    func withdrawalConfirm_changeWallet_label_assetAmt(_ args: String...) -> String { return String.init(format: "金額: %@ %@", arguments: args) }
    var withdrawalConfirm_changeWallet_title = "切換錢包"
    var withdrawalConfirm_pwdVerify_title = "請輸入密碼"
    var withdrawalConfirm_pwdVerify_label_input_wallet_pwd = "輸入錢包密碼"
    var withdrawalConfirm_pwdVerify_placeholder_wallet_pwd = "請輸入錢包密碼"
    var withdrawalConfirm_pwdVerify_error_pwd_is_wrong = "密碼錯誤"
    var withdrawalConfirm_pwdVerify_hud_signing = "簽章中"
    var withdrawalConfirm_pwdVerify_hud_broadcasting = "廣播中"
    var withdrawalConfirm_pwdVerify_error_btc_insufficient_fee_title = "餘額不足"
    func withdrawalConfirm_pwdVerify_error_btc_insufficient_fee_content(_ args: String...) -> String { return String.init(format: "您的 BTC 餘額不足，交易轉帳會收取額外的礦工費 %@ BTC, 請確認您的餘額是否足夠支付礦工費。", arguments: args) }
    var withdrawalConfirm_pwdVerify_error_tx_save_fail = "儲存失敗"
    var txRecord_title = "轉賬記錄"
    var txRecord_btn_deposit = "轉入"
    var txRecord_btn_withdrawal = "轉出"
    var txRecord_btn_fail = "失敗"
    var txRecord_empty_tx = "暫無轉帳記錄"
    var lightningTx_title = "閃電轉帳"
    var lightningTx_label_rate = "匯率"
    var lightningTx_btn_exchange = "快速兌換"
    var lightningTx_placeholder_out_amt = "轉出數量"
    var lightningTx_placeholder_in_amt = "收到數量"
    var lightningTx_label_txRecord = "本地兌換紀錄"
    var lightningTx_label_empty_tx = "暫無本地兌換紀錄"
    func lightningTx_label_txRecord_miner_fee(_ args: String...) -> String { return String.init(format: "礦工費用：%@ %@", arguments: args) }
    var lightningTx_label_txRecord_failed = "失敗"
    var lightningTx_label_txRecord_go_check = "前往查看"
    func lightningTx_error_insufficient_asset_amt(_ args: String...) -> String { return String.init(format: "%@ 餘額不足", arguments: args) }
    var lightningTx_error_empty_transRate_title = "無法取得轉換匯率"
    var lightningTx_error_empty_transRate_content = "請檢察網路是否正常, 點擊確認將嘗試更新匯率。"
    func lightningTx_error_no_asset_title(_ args: String...) -> String { return String.init(format: "該錢包尚無%@資產", arguments: args) }
    func lightningTx_error_no_asset_content(_ args: String...) -> String { return String.init(format: "請先至「新增與管理資產」加入 %@ 資產後再交易", arguments: args) }
    var lightningTx_label_custom = "自訂"
    func lightningTx_label_remain_amt(_ args: String...) -> String { return String.init(format: "餘額 %@", arguments: args) }
    var ltTx_title = "支付詳情"
    var ltTx_label_pay_info = "支付信息"
    var ltTx_label_changeTo = "換取"
    var ltTx_label_exchangeRate = "轉換匯率"
    var ltTx_label_toAddr = "收款地址"
    var ltTx_label_toAddr_empty_tap_to_set = "點擊設定收款地址"
    var ltTx_label_fromAddr = "付款地址"
    var ltTx_label_minerFee = "礦工費用"
    var ltTx_minerFee_title = "礦工費用設置"
    var ltTx_changeToAddress_title = "選擇收款地址"
    var ltTx_changeToAddress_label_toAddress = "收款地址"
    var ltTx_changeToAddress_btn_common_used_addr = "常用地址"
    func ltTx_changeToAddress_placeholder_input_valid_addr(_ args: String...) -> String { return String.init(format: "輸入有效的 %@ 地址", arguments: args) }
    var ltTx_changeToAddress_label_toWallet = "收款錢包"
    var ltTx_pwdVerify_title = "請輸入密碼"
    var ltTx_pwdVerify_label_input_wallet_pwd = "輸入錢包密碼"
    var ltTx_pwdVerify_placeholder_input_wallet_pwd = "請輸入錢包密碼"
    var ltTx_pwdVerify_error_pwd_is_wrong = "密碼錯誤"
    var ltTx_pwdVerify_hud_signing = "簽章中"
    var ltTx_pwdVerify_hud_broadcasting = "廣播中"
    var ltTx_pwdVerify_error_btc_insufficient_fee_title = "餘額不足"
    func ltTx_pwdVerify_error_btc_insufficient_fee_content(_ args: String...) -> String { return String.init(format: "您的 BTC 餘額不足，交易轉帳會收取額外的礦工費 %@ BTC, 請確認您的餘額是否足夠支付礦工費。", arguments: args) }
    var ltTx_pwdVerify_error_tx_save_fail = "儲存失敗"
    var ltTx_pwdVerify_error_miner_fee_setting = "礦工費用設置"
    var ltTx_pwdVerify_error_miner_fee_input_p = "請輸入礦工費"
    var ltTx_pwdVerify_error_payment_detail = "支付詳情"
    var me_btn_edit = "編輯"
    var me_label_common_used_addr = "常用地址"
    var me_label_settings = "使用設置"
    var me_label_qa = "常見問題"
    var me_label_agreement = "用戶協議"
    var me_label_check_update = "檢查版本更新"
    var me_hud_checking = "檢查中"
    var me_alert_already_latest_version_title = "目前已是最新版本"
    func me_alert_version_content(_ args: String...) -> String { return String.init(format: "當前版本: %@\n最新版本: %@", arguments: args) }
    var me_alert_able_to_update_version_title = "已有新版本，請立即更新以享有完整功能"
    var me_btn_update = "更新"
    var myIdentity_title = "我的身份"
    var myIdentity_label_name = "名字"
    var myIdentity_label_identityID = "身份 ID"
    var myIdentity_btn_backup_identity = "備份身份"
    var myIdentity_btn_exit_current_identity = "退出當前身份"
    var myIdentity_alert_changeName_title = "更换用戶名"
    var myIdentity_alert_changeName_content = "請輸入要更換的暱稱"
    var myIdentity_placeholder_changeName = "1-30 字元, 首尾不得留空"
    var myIdentity_error_name_invalid_format = "用戶名称格式错误"
    var myIdentity_error_unable_to_decrypt_mnemonic = "無法解密助記詞，請確認密碼是否正確"
    var myIdentity_error_pwd_is_wrong = "密碼驗證失敗，請重新輸入"
    var myIdentity_alert_backup_identity_title = "備份身份"
    var myIdentity_alert_input_pwd_content = "請輸入密碼"
    var myIdentity_alert_clearIdentity_title = "退出當前身份"
    var myIdentity_alert_clearIdentity_ensure_wallet_backup_content = "即將移除身份及所有已導入的錢包，請確保所有錢包已備份"
    var myIdentity_alert_clearIdentity_verify_pwd_title = "請輸入密碼"
    var myIdentity_alert_clearIdentity_verify_pwd_content = "警告:若無妥善備份，刪除錢包後將無法找回錢包，請慎重處理該操作"
    var myIdentity_placeholder_pwd = "密碼"
    var myIdentity_hud_exiting = "退出中"
    var myIdentity_hud_exited = "已退出"
    var backupWallet_sourceChoose_label_title = "選擇備份方式"
    var backupWallet_sourceChoose_label_use_identity_qrcode = "備份身份 QRCODE"
    var backupWallet_sourceChoose_label_identity_qrcode_desc = "選擇使用身份QRCODE 備份，將可以備份當前身份下所有的錢包(系統錢包+外部錢包)，系統會提供一個您的專屬身份QRCODE，日後在恢復身份或者導入錢包時，使用該QRCODE 即可快速恢復所有錢包。"
    var backupWallet_sourceChoose_label_use_mnemonic = "備份身份助記詞"
    var backupWallet_sourceChoose_label_user_mnemonic_desc = "選擇備份身份助記詞，系統將協助您導出「原身份」底下的錢包助記詞。請特別留意該助記詞並不會包含您外部導入的錢包資訊，日後若以該助記詞恢復身份，將不會還原外部導入的錢包內容。"
    var settings_title = "使用設置"
    var settings_label_localAuth = "Touch ID / Face ID 驗證"
    var settings_label_privateMode = "隱私模式"
    var settings_label_privateMode_note = "開啟隱私模式後錢包的資產和金額將會隱藏"
    var settings_label_language = "語言"
    var settings_label_currencyUnit = "貨幣單位"
    var settings_alert_verify_to_turn_off_functionality = "驗證以關閉功能"
    var changePrefFiat_title = "貨幣單位"
    var changePrefFiat_btn_save = "存儲"
    
    var settings_notification_title:String = "訊息通知"
    var setting_export_key_title:String = "導出"
    var setting_export_btc_wallet_title:String  = "比特币（Bitcoin）钱包"
    var setting_export_eth_wallet_title:String = "以太幣(Ethereum) 錢包"
    var setting_delete_account_title:String = "刪除帳號"

    var account_setting_title = "帳戶設定"
    var basic_setting_title = "基本設置"
    var follow_us_title = "關注我們"
    var others_title = "其他"
    var system_settings_title:String = "系統設定"
    var wallet_settings_title:String = "錢包設定"
    var account_safety_settings_title:String = "帳號安全"
    
    var addressbook_title = "常用地址"
    var addressbook_label_empty_addressbook = "暫無紀錄"
    var abInfo_title = "聯絡人資訊"
    func abInfo_label_address_type(_ args: String...) -> String { return String.init(format: "%@地址", arguments: args) }
    var abInfo_btn_edit = "編輯"
    var abInfo_label_name = "名稱"
    var abInfo_label_note = "備註"
    var ab_update_title_create = "新增聯絡人"
    var ab_update_title_edit = "編輯聯絡人"
    var ab_update_hud_saving = "儲存中..."
    var ab_update_placeholder_name = "名稱"
    var ab_update_placeholder_note = "備註(選填)"
    var ab_update_btn_save = "存儲"
    var ab_update_error_unable_update_title = "無法更新"
    var ab_update_error_unable_create_title = "無法新增"
    var ab_update_error_already_has_same_unit_content = "已有相同的紀錄"
    func ab_update_actionsheet_createAddress_general(_ args: String...) -> String { return String.init(format: "添加%@地址", arguments: args) }
    var ab_update_actionsheet_createAddress_btc = "添加比特幣地址"
    var ab_update_actionsheet_createAddress_eth = "添加以太幣地址"
    var ab_update_actionsheet_createAddress_cic = "添加 CIC 地址"
    var ab_update_label_createAddress = "添加地址"
    var ab_update_placeholder_input_valid_address = "請輸入有效地址"
    var ab_update_alert_confirm_delete_address_title = "確定刪除地址?"
    var ab_update_btn_delete_addressbook = "刪除聯絡人"
    var ab_update_alert_confirm_delete_addressbook_title = "確定刪除聯絡人？"
    var ab_update_alert_test_string = "測試文字"
    var chat_list_alert_recover_message_history_title = "取回通訊紀錄"
    var chat_list_alert_recover_message_history_message = "小貼士：請先於原手機通訊>個人信息中設定"
    var chat_list_placeholder_recover_message_history = "請輸入移轉密碼"
    var chat_list_alert_recover_message_history_create = "重新創建"
    var chat_list_alert_recover_message_history_recover = "開始移轉"
    var chat_list_title = "通訊"
    var chat_extend_item_sweep_qrcode = "我的二維碼"
    var chat_extend_item_add_channel = "創建群組"
    var chat_extend_item_add_friends = "添加好友"
    var chat_extend_item_search_group = "搜尋公開群"
    var chat_extend_item_social_envelope = "紅包地址"
    var chat_extend_item_user_information = "個人信息"
    var user_profile_title = "個人信息"
    var user_profile_button_add_friend = "添加好友"
    var user_profile_block_user = "封鎖用戶"
    var user_profile_transfer_account = "移轉帳號"
    var user_profile_alert_transfer_account_title = "設定移轉密碼"
    var user_profile_alert_transfer_account_message = "設定移轉密碼後即可將帳號移動至其他智慧手機"
    var user_profile_placeholder_transfer_account = "請輸入移轉密碼"
    var add_friend_title = "添加朋友"
    var add_friend_alert_title = "驗證信息"
    var add_friend_alert_message = "請輸入好友驗證信息"
    var add_friend_placeholder_message = ""
    var add_friend_alert_success = "已送出交友邀請"
    var add_friend_placeholder_friend_id = "扫描好友QR Code"
    var switch_on_notification_setting = "開啟訊息通知"
    var switch_off_notification_setting = "關閉訊息通知"
    var friend_request_title = "交友邀請"
    var group_request_title = "群组邀請"
    var friend = "好友"
    var group = "群组"
    
    

    var trend = "行情"
    
    var hot_group = "熱門群組"
    var hot_group_sub = "最火社群等您來參與"
    
    var media =  "幣圈財經媒體"
    var media_sub = "幣圈新知都在這"
    
    var dapp = "DApp"
    var dapp_sub = "遊戲一把抓"
    
    var blockchain_explorer = "區塊鏈瀏覽器"
    var blockchain_explorer_sub = "快速查詢您的交易資訊"
    
    var select_from_camera = "相机"
    var select_from_gallery = "从照片相簿选取"
    
    var create_group = "建立群組"
    
    var chat_secret_setting = "密聊設定"
    var decentralize = "去中心化"
    var time_limit = "時間限制"
    var chat_secret_single = "單次對話"
    var chat_secret_keep_5 = "保留5分鐘"
    var chat_secret_keep_10 = "保留10分鐘"
    var chat_secret_keep_20 = "保留20分鐘"
    

    
    var tab_explorer = "發現"
    var tab_social = "社群"
    var tab_setting = "設定"
    
    var contact_title = "通訊錄"
    var contact_individual = "個人"
    var contact_group = "群組"
    
    var stable_coin = "穩定幣"
    var sto_coin = "上市區"
    
    var delete = "刪除"
    var forward = "轉傳"
    var message_action = "消息動作"
    
    var select_wallet_address = "請選擇錢包地址"
    var backupChat_alert_password_mismatch = "錢包賬號與移轉備份密碼不符"
    
    var copy_file_url = "複製檔案網址"
    var send_file_title = "檔案"
    var confirm_cancel_editing = "確認取消編輯?"
    var exit_group = "退出群組"
    var manage_group = "管理群組"
    var confirm_exit = "確認退出群組?"
    var confirm_delete_group = "確認解散刪除群組?"
    var delete_group = "刪除群組"
    var group_member = "群組成員"
    
    var manage_currency = "管理幣種"
    
    var create_new_wallet = "創建新錢包"
    var create_new_wallet_desc = "選擇新增錢包，將使用助記詞產生新的錢包地址。"
    var create_new_btc_wallet = "新增BTC錢包"
    var create_new_eth_wallet = "新增ETH錢包"

    var myQRCode = "我的QR Code"
    var chat_room_has_blocked = "這個聊天室被封鎖了"

    var chat_room_receipt = "收款"
    var chat_room_image = "圖片"
    var chat_room_camera = "相機"
    var chat_room_audio_call = "音頻通話"
    var chat_room_video_call = "視頻電話"
    var chat_room_red_env = "紅包"
    
    var copied_successfully = "複製成功"
    
    var secret_chat_on = "秘密聊天是開放的"
    
    var accept_request = "接受"
    var reject_request = "拒絕"

    var trans_success = "轉帳成功"
    var trans_failed = "轉帳失敗"
    
    var group_qr_code = "群組二維碼"
    var account = "帳號"
    
    var assetDetail_receive = "接收"
    var join_group = "加入群組"
    var alert_cant_join_pvt_group = "無法加入此群組，因為這是一個私人群組"
    var group_join_success = "群組成功加入"
    
    var group_name = "群組名稱"
    var group_type = "群組類型"
    
    var public_group = "公開群"
    var private_group = "私密群"
    var post_message = "張貼訊息"
    
    var admin_only = "僅管理員"
    var all_members = "所有成員"
    var group_description = "描述"
    var show_qr_code =  "顯示二維碼"
    var display_pvt_key_btn_title = "點選此處顯示私鑰"
    var precaution_before_exporting_msg = "導出前請先閱讀注意事項"

    var group_member_new = "新增"
    var group_member_invited = "正在邀請"
    
    func group_text_too_long(_ args: String...) -> String { return String.init(format: "字数过长 (%@)/%@", arguments: args) }

    var members_invitation_successfull = "成員邀請成功"
    
    var transfer_all_amount = "轉出總額"

    var invalid_mnemonic_phrase = "助記詞不正確"
    
    var image_saved_success = "圖像保存到相冊"
    var exists = "已存在"
    
    var access_denied_mic = "您已拒絕訪問麥克風。 轉到“設置”並提供對麥克風的訪問以執行此功能。"
    var recording_failed = "錄音失敗"
    
    var record_audio_start_button = "按可錄製音頻"
    var record_audio_stop_to_send_button = "釋放按鈕發送音頻"

    var red_env_send_balance: String = "餘額"
    
    var red_env_send_total_amount: String = "總金額"
    
    var red_env_send_enter_amount: String = "請輸入發送紅包的總金額"
    
    var red_env_send_number_title = "數量 "
    func red_env_send_number_of_members(_ args: String...) -> String { return String.init(format: "數量 (該社群成員人數 %@)", arguments: args) }
    
    var red_env_send_number_of_red_env: String  = "請輸入發送紅包的數量"
    
    var red_env_send_dist_rule: String = "領取規則"
    
    var red_env_send_divide: String = "均分"
    
    var red_env_send_random: String = "隨機"
    
    var red_env_send_comment: String = "留言"
    var red_env_comment_placeholder: String = "在紅包上寫些吉祥話吧！"
    
    var red_env_send_notice_one: String = "請留意所有交易皆須扣除的礦工費用"
    
    var red_env_send_notice_two: String = "紅包發送後，如超過時限仍未被領取，將會自動退回金額"
    
    var red_env_send_currency: String = "發送幣種"
    var red_env_send_time_limit:String = "領取時限"
    var red_env_send_reservationTime:String = "預約發送"

    var red_env_send_day = "天"
    var red_env_send_hour = "小時"
    var red_env_send_minute = "分鐘"
    var red_env_send_infinite = "無窮"
    
    var red_env_send_please_select = "請選擇"

    var red_env_money_sent:String = "塞錢完成"
    var red_env_waiting_to_send:String = "等待塞錢進紅包"
    func red_env_amount_received(_ args:String ...) -> String {return String.init(format: "%@/%@ 已領取",arguments: args) }
    func red_env_transfer_alert_message(_ args :String ...) -> String {return String.init(format: "您將塞錢入紅包，請輸入錢包密碼 (另外收取單筆礦工費 %@%@)", arguments: args)}
    var red_env_send_sent_successfully = "恭喜,紅包錢入賬了"
    func red_env_status_waiting_for_money(_ args:String ...) -> String {return String.init(format: "等待 %@ 塞錢進紅包", arguments: args)}
    var red_evn_send_by_me = "我發送的紅包"
    func red_env_sent_by_sender(_ args:String ...) -> String {return String.init(format: "%@的紅包", arguments: args)}
    var red_env_expired = "可領取時間到期了"
    func red_env_money_sent_already_message(_ args:String ...) -> String {return String.init(format: "塞錢給%@已完成，是否繼續塞錢？", arguments: args)}
    func red_env_money_sent_to_user_message(_ args:String ...) -> String {return String.init(format: "塞錢給%@已完成", arguments: args)}
    
    var view_red_envelope:String = "查看紅包"
    var red_env_view_record:String = "查看紅包記錄"
    var red_env_view_record_substring:String = "查看"

    var red_env_receive_expired_message:String = "手慢了，紅包過期了"
    var red_env_receive_no_remaining_envelopes:String = "手慢了，紅包被搶光了"
    var red_env_receive_status_not_yet_received:String  = "未領取"
    var red_env_receive_status_received:String  = "已領取"
    var red_env_send_confirm_transfer:String = "確認塞錢進紅包"
    var red_env_send_records:String = "紅包發送紀錄"

    var red_env_history_receive:String = "領取記錄"
    var red_env_history_sent:String = "發送記錄"
    var red_evn_history_title:String = "紅包記錄"
    
    var red_env_history_waiting_for_collection:String = "等待領取"
    var red_env_history_waiting_for_money:String  = "等待塞錢"
    var red_env_history_money_transfered:String  = "塞錢成功"

    
    var receipt_receiving_currency:String = "收款币别"
    var receiving_amount:String = "收款金額"
    var receive_red_env_no_wallet_found = "找不到支持這枚硬幣的錢包"
    
    var profile_edit_empty_name_error = "請輸入有效的名字"
    var red_env_history_from_title:String = "從"
    var red_env_history_create_time_title:String = "送出紅包時間"
    var red_env_history_receive_time_title:String = "接收紅包時間"
    var red_env_history_deposit_time_title:String = "紅包撥款時間"

    var chat_keyboard_placeholder:String = "在這裡寫點東西"
    var chat_recovery_password_successful:String = "密碼設置成功"
    
    var chat_history_delete_chat_title:String = "刪除聊天"
    var chat_history_delete_chat_message:String = "您確定要刪除此聊天中的所有訊息嗎？"

    var receipt_request_error_string:String = "請選擇一個硬幣並輸入金額"
    
    var use_edited_image_title:String = "使用編輯過的圖像"
    var use_original_image_title:String = "使用原始圖像"
    var create_red_env_title:String = "創建一個紅包"

    var voice_message_string:String = "語音"
    var image_message_string:String = "圖片"
    var call_message_string:String = "通話"
    var receipt_message_string:String = "已發送收款訊息"
    
    var download_file_title:String = "下載檔案"
    var file_download_successful_message:String = "檔案下載成功"

    var lightning_receipt_btn_title:String = "閃電收款"
    var transaction_details_btn_title:String = "交易明細"
    
    var lightning_payment_title:String = "閃電轉帳"
    
    var light_withdraw_btn_title:String = "提出"
    var light_deposit_btn_title:String = "存入"
    
    var insufficient_unspend_error_msg:String = "可轉帳餘額不足。若為USDT轉帳，請檢查BTC錢包餘額是否足夠支付礦工費"
    
    var transfer_amount_title:String = "轉帳金額"
    
    var transfer_note_placeholder:String = "請輸入20字以內的描述"
    
    var payment_wallet:String = "付款錢包"
    
    var transfer_all_coin_ttn_address:String = "轉出所有金額"

    var forward_message_title_string :String = "选择消息"
    
    var light_withdrawal_placeholder_toAddr : String  = "請輸入TTN閃電支付的收款地址 或 掃描行動條碼"

    var alert_post_message_restriction = "只有管理員才能在此組中發布消息"

    var total_assets_title = "總資產"

    var asset_management_btn_title :String = "資產管理"
    var wallet_type_btn_main_chain:String  = "主鏈幣"
    
    var total_amount_transfer_info_alert_title:String = "什麼是轉出總額？"
    var total_amount_transfer_info_alert_message:String  = "點選此選項後，系統會自動將錢包內的該幣全部轉出，不用再另外計算輸入。 而系統也會將總額自動扣除所選擇的礦工費用。"
    
    var transfer_success_check_record_message = "您的轉帳請求已經成功。您可以到轉帳紀錄查看此筆交易狀態。"

    var check_record_btn_title = "查看轉帳紀錄"
    var tx_number_title = "交易序號"
    var tx_block_number_title = "區塊編號"
    
    func tx_record_detail_title(_ args: String...) -> String {
        return String.init(format: "%@ 轉帳紀錄", arguments: args)
    }

    var chat_msg_tab_title:String = "訊息"
    var loading_please_wait_label:String  = "系統更新中，請稍後"
    
    var register_new_account_btn_title = "註冊新帳號"
    
    var register_account_msg_label_login = "註冊帳號將自動新增多鏈錢包"
    
    var original_account_login = "原有帳號登入"
    
    var transfer_back_button_title :String = "修改"

    var import_key_string = "導入"
    
    var add_wallet_password_warning_one = "Infireum團隊不會保存您的錢包密碼，也無法在您遺失錢包密碼時協助尋回，請謹慎設立密碼與密碼提示。"
    
    var add_wallet_password_warning_two = "如遺忘密碼將一併遺失錢包內的資產，請特別注意。"

    var new_wallet_name = "請為新錢包命名"
    var chat_nick_name = "聊天暱稱"
    var personal_information = "個人資訊"
    
    var receipt_request_warning_label = "发送收款请求时，矿工费用将由付款方支出。"
    var receipt_request_coin_address_placeholder = "請先選擇收款幣種，系統將自動偵測"

    var group_info_label_title_string:String = "社群公告"
    
    var group_setting_title:String = "社群設定"
    var group_member_mgmgt_title:String  = "成員管理"
    
    var group_invite_member_title:String = "邀請成員"
    var group_info_title:String = "社群資訊"
    
    var backup_qrcode_message_label = "此行動條碼為甜甜圈錢包為您貼心設計，供您日後可方便快速恢復您在甜甜圈錢上的所有錢包帳號。 請妥善備份您的帳號資訊，並且不要上傳至雲端硬碟或在任何公用網路上存取。這與您日後要維護資產安全、恢復帳號等動作至關重要。"
    
    var back_up_skip_warning_msg =  "備份帳號行動碼與您日後要維護資產安全、恢復帳號等動作相當重要。 如在無備份帳號的情況下遺失手機或各種意外導致帳號遺失，將永遠無法尋回。"
    
    var backup_skip_msg_title = "您確定要略過嗎？"
    
    var create_identity_username_placeholder = "帳號建立僅限英文字母與數字組合，至少8個字元"
    
    var create_identity_password_placeholder = "建議使用英文字母大小寫與數字組合"
    
    var create_identity_reenter_password_placeholder = "請再次輸入密碼"
    
    var create_identity_password_reminder_placeholder = "提示內容請勿與密碼一樣，以免被輕易盜取"
    var create_identity_privacy_policy_btn_title = "我同意《InfiniteChain隱私政策》"
    
    var agree_bnt_title: String  = "同意"

    var sign_in_using_mnemonic_title = "使用《助記詞》登入帳號"
    
    var sign_in_mnemonic_subtitle = "輸入助記詞，共 12 個字"
    var new_wallet_created_msg = "已創建新錢包"
    var wallet_import_success_subtitle_msg = "您可以開始使用此錢包功能"
    var new_wallet_imported_msg = "已成功導入錢包"
    
    var chat_notifications_turn_off_title = "關閉提醒"
    
    var chat_community_mgmt_label = "社群管理"
    
    var only_admin_post_title = "只有管理員以上階級可以張貼訊息"
    var imported_wallets = "已導入的錢包"
    var login_success = "您已成功登入"
    var welcome_back = "歡迎回來"
}


