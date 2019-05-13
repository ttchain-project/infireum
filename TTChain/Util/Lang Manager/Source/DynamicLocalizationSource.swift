import Foundation

typealias DLS = DynamicLocalizationSource
protocol DynamicLocalizationSource {
    var g_ok: String { get set }
    var g_cancel: String { get set }
    var g_loading: String { get set }
    var g_close: String { get set }
    var g_done: String { get set }
    var g_success: String { get set }
    var g_confirm: String { get set }
    var g_update: String { get set }
    var g_copy: String { get set }
    var g_edit: String { get set }
    var g_next: String { get set }
    var g_error_exit: String { get set }
    var g_something_went_wrong: String { get set }
    var g_error_networkIssue: String { get set }
    var g_error_networkTimeout: String { get set }
    var g_error_emptyform: String { get set }
    var g_error_networkUnreachable: String { get set }
    var g_error_tokenInvalid: String { get set }
    var g_error_apiReject: String { get set }
    var g_error_tokenExpired: String { get set }
    var g_error_appDisabled: String { get set }
    var g_error_appDisabled_detail: String { get set }
    var g_error_invalidVersion: String { get set }
    var g_error_emptyData: String { get set }
    var g_error_broadcastFail: String { get set }
    var g_error_encryptFail_mnemonic: String { get set }
    var g_error_encryptFail_privateKey: String { get set }
    var g_error_decryptFail_mnemonic: String { get set }
    var g_error_decryptFail_privateKey: String { get set }
    var g_camera_permission_requestion: String { get set }
    var g_error_mnemonic_wrong: String { get set }
    var g_toast_addr_copied: String { get set }
    var lang_zh_cn: String { get set }
    var lang_zh_tw: String { get set }
    var lang_en_us: String { get set }
    func strValidate_error_common_spacePrefixOrSuffix(_ args: String...) -> String
    func strValidate_error_common_lengthInvalid(_ args: String...) -> String
    func strValidate_error_common_allowAlphanumericOnly(_ args: String...) -> String
    var strValidate_error_mnemonic_12WordsAtLeast: String { get set }
    func strValidate_error_mnemonic_containUppercase(_ args: String...) -> String
    func strValidate_error_mnemonic_invalidCharacter(_ args: String...) -> String
    var strValidate_error_confirmPwd_diffWithPwd: String { get set }
    var strValidate_field_identityName: String { get set }
    var strValidate_field_mnemonic: String { get set }
    var strValidate_field_pwd: String { get set }
    var strValidate_field_confirmPwd: String { get set }
    var strValidate_field_walletName: String { get set }
    var strValidate_field_pwdHint: String { get set }
    var strValidate_field_pwdHintSame: String { get set }
    var strValidate_field_addressInvalid: String { get set }
    var fee_cic_per_byte: String { get set }
    var fee_eth_gas_price: String { get set }
    var fee_sat_per_byte: String { get set }
    var fee_eth_gwei: String { get set }
    var fee_ether: String { get set }
    var intro_title_page_one: String { get set }
    var intro_title_page_two: String { get set }
    var intro_title_page_three: String { get set }
    var qrCodeImport_alert_error_wrong_pwd_title: String { get set }
    func qrCodeImport_info_g_alert_error_title_error_field(_ args: String...) -> String
    var qrCodeImport_info_g_alert_error_field_pwd: String { get set }
    var qrCodeImport_info_g_alert_error_field_idName: String { get set }
    var qrCodeImport_info_g_alert_error_field_hint: String { get set }
    var qrCodeImport_alert_error_wrong_pwd_content: String { get set }
    var qrCodeImport_alert_input_pwd: String { get set }
    var qrCodeImport_alert_content: String { get set }
    func qrCodeImport_alert_placeholder_pwd(_ args: String...) -> String
    var qrCodeImport_list_user_system_wallets: String { get set }
    var qrCodeImport_list_imported_wallets: String { get set }
    var qrCodeImport_list_title: String { get set }
    var qrCodeImport_list_label_will_not_import_existed_wallets: String { get set }
    var qrCodeImport_info_title: String { get set }
    var qrCodeImport_info_label_intro: String { get set }
    var qrCodeImport_info_placeholder_idName: String { get set }
    var qrCodeImport_info_placeholder_pwd: String { get set }
    var qrCodeImport_info_placeholder_hint: String { get set }
    var qrCodeImport_info_btn_startImport: String { get set }
    var qrCodeExport_alert_backup_title: String { get set }
    var qrCodeExport_alert_note_content: String { get set }
    var qrCodeExport_alert_placeholder_pwd: String { get set }
    var qrCodeExport_alert_placeholder_hint: String { get set }
    var qrCodeExport_title: String { get set }
    var qrCodeExport_btn_save_qrcode: String { get set }
    var qrCodeExport_btn_qrcode_saved: String { get set }
    var qrCodeExport_btn_backup_qrcode: String { get set }
    var qrCodeExport_label_desc: String { get set }
    var qrCodeExport_label_user_system_wallets: String { get set }
    var qrCodeExport_label_imported_wallets: String { get set }
    var qrcodeExport_toast_qrcode_saved_to_album: String { get set }
    var qrcodeExport_alert_title_did_not_backup_qrcode: String { get set }
    var qrcodeExport_alert_content_did_not_backup_qrcode: String { get set }
    var qrcodeExport_alert_btn_backup: String { get set }
    var qrcodeExport_alert_btn_skip: String { get set }
    var qrcodeProcess_alert_title_cannot_find_qrcode_in_img: String { get set }
    var qrcodeProcess_alert_content_cannot_find_qrcode_in_img: String { get set }
    var qrcodeProcess_alert_title_cannot_decode_qrcode_in_img: String { get set }
    var qrcodeProcess_alert_content_cannot_decode_qrcode_in_img: String { get set }
    var qrcodeProcess_alert_title_album_permission_denied: String { get set }
    var qrcodeProcess_alert_content_album_permission_denied: String { get set }
    var qrcodeProcess_alert_content_camera_permission_denied: String { get set }
    var qrcodeProcess_hud_decoding: String { get set }
    var tab_wallet: String { get set }
    var tab_trade: String { get set }
    var tab_me: String { get set }
    var tab_chat: String { get set }
    var tab_alert_newSystemWallet_title: String { get set }
    var tab_alert_newSystemWallet_content: String { get set }
    var tab_alert_placeholder_identityPwd: String { get set }
    var tab_alert_error_mnemonic_decrypt_failed: String { get set }
    var tab_alert_error_wallet_sync_failed: String { get set }
    var agreement_title: String { get set }
    var agreement_dont_display_again_today: String { get set }
    var qrcode_title: String { get set }
    var qrcode_label_intro: String { get set }
    var qrcode_btn_withdrawal: String { get set }
    var qrcode_btn_importWallet: String { get set }
    var qrcode_btn_contact: String { get set }
    var qrcode_actionSheet_pickChainTypeToImport_title: String { get set }
    var qrcode_actionSheet_pickChainTypeToImport_content: String { get set }
    func qrcode_actionSheet_btn_mainCoinType(_ args: String...) -> String
    var login_label_title: String { get set }
    var login_btn_create: String { get set }
    var login_label_desc: String { get set }
    var login_btn_restore: String { get set }
    var login_label_or: String { get set }
    var login_actionsheet_restore_mnemonic: String { get set }
    var login_actionsheet_restore_qrcode: String { get set }
    var login_alert_title_camera_permission_denied: String { get set }
    var login_alert_content_camera_permission_denied: String { get set }
    var login_alert_title_import_qrcode_failed: String { get set }
    var login_alert_content_import_qrcode_failed: String { get set }
    var createID_title: String { get set }
    var createID_hud_creating: String { get set }
    var createID_btn_create: String { get set }
    var createID_placeholder_name: String { get set }
    var createID_placeholder_password: String { get set }
    var createID_placeholder_confirmPassword: String { get set }
    var createID_placeholder_passwordNote: String { get set }
    var createID_error_pwd_title: String { get set }
    var createID_error_confirmPwd_title: String { get set }
    var createID_error_identityName_title: String { get set }
    var createID_error_pwdHint_title: String { get set }
    var backupWallet_title: String { get set }
    var backupWallet_label_mainNote: String { get set }
    var backupWallet_label_subNote: String { get set }
    var backupWallet_btn_backupMnemonic: String { get set }
    var backupMnemonic_title: String { get set }
    var backupMnemonic_desc: String { get set }
    var sortMnemonic_title: String { get set }
    var sortMnemonic_desc: String { get set }
    var sortMnemonic_error_mnemonic_wrong_order: String { get set }
    var sortMnemonic_error_create_user_fail: String { get set }
    var sortMnemonic_error_create_wallet_fail: String { get set }
    var restoreIdentity_label_settingPwd: String { get set }
    var restoreIdentity_placeholder_walletPwd: String { get set }
    var restoreIdentity_placeholder_walletConfirmPwd: String { get set }
    var restoreIdentity_placeholder_mnemonic: String { get set }
    var restoreIdentity_placeholder_pwdHint: String { get set }
    var restoreIdentity_btn_import: String { get set }
    var restoreIdentity_title: String { get set }
    var restoreIdentity_label_able_to_change_pwd_note: String { get set }
    var restoreIdentity_hud_restoring: String { get set }
    var restoreIdentity_hud_restoreSuccess: String { get set }
    var restoreIdentity_error_create_user_fail: String { get set }
    var restoreIdentity_error_create_wallet_fail: String { get set }
    var restoreIdentity_error_pwd_title: String { get set }
    var restoreIdentity_error_confirmPwd_title: String { get set }
    var restoreIdentity_error_mnemonic_title: String { get set }
    var restoreIdentity_error_pwdHint_title: String { get set }
    var localAuth_btn_tapToStartVerify: String { get set }
    var localAuth_alert_verifyToBrowse_title: String { get set }
    var localAuth_alert_inputIdentiyPwd_title: String { get set }
    var walletOverview_refresher_status_pulling: String { get set }
    var walletOverview_refresher_status_overpulled: String { get set }
    var walletOverview_refresher_status_loading: String { get set }
    var walletOverview_refresher_status_finished: String { get set }
    var walletOverview_btn_deposit: String { get set }
    var walletOverview_btn_manageAsset: String { get set }
    var walletOverview_btn_txRecord: String { get set }
    var walletOverview_btn_switchWallet: String { get set }
    func walletOverview_alert_withdrawal_noAsset_title(_ args: String...) -> String
    func walletOverview_alert_withdrawal_noAsset_content(_ args: String...) -> String
    func deposit_label_depositAddress(_ args: String...) -> String
    var deposit_btn_changeAsset: String { get set }
    var changeAsset_label_remainAmt: String { get set }
    var changeAsset_title: String { get set }
    var manageAsset_searchBar_search_token_and_contract: String { get set }
    var manageAsset_btn_manage: String { get set }
    var manageAsset_label_myAsset: String { get set }
    var manageAsset_actoinSheet_hideEmptyAsset: String { get set }
    var manageAsset_actoinSheet_sortAlphabatically: String { get set }
    var manageAsset_actoinSheet_sortAlphabatically_cancel: String { get set }
    var manageAsset_actoinSheet_sortByAssetAmt: String { get set }
    var manageAsset_actoinSheet_sortByAssetAmt_cancel: String { get set }
    var manageAsset_actoinSheet_removeAsset: String { get set }
    var searchAsset_label_myAsset: String { get set }
    var searchAsset_label_resultNotFound: String { get set }
    var changeWallet_label_wallets_current_identity: String { get set }
    var changeWallet_label_wallets_imported: String { get set }
    var changeWallet_label_offline: String { get set }
    var changeWallet_alert_import_fail: String { get set }
    var walletManage_title: String { get set }
    var walletManage_label_pwdHint: String { get set }
    var walletManage_label_exportPKey: String { get set }
    var walletManage_error_pwd: String { get set }
    var walletManage_alert_exportPKey_title: String { get set }
    var walletManage_alert_exportPKey_content: String { get set }
    var walletManage_alert_placeholder_exportPKey_pwd: String { get set }
    var walletManage_alert_changeWalletName_title: String { get set }
    var walletManage_alert_changeWalletName_content: String { get set }
    var walletManage_error_walletName_invalidFormat_title: String { get set }
    var walletManage_alert_placeholder_walletName_char_range: String { get set }
    var walletManage_btn_delete_wallet: String { get set }
    var walletManage_alert_title_delete_wallet: String { get set }
    var pwdHint_title: String { get set }
    var pwdHint_hud_updating: String { get set }
    var pwdHint_hud_updated: String { get set }
    var exportPKey_title: String { get set }
    var exportPKey_tab_privateKey: String { get set }
    var exportPKey_tab_qrcode: String { get set }
    var exportPKey_label_offline_save: String { get set }
    var exportPKey_label_offline_save_message: String { get set }
    var exportPKey_label_dont_trans_by_internet: String { get set }
    var exportPKey_label_dont_trans_by_internet_message: String { get set }
    var exportPKey_label_pwd_manage_tool_save: String { get set }
    var exportPKey_label_pwd_manage_tool_save_message: String { get set }
    var exportPKey_label_provide_scan_directly_only: String { get set }
    var exportPKey_label_provide_scan_directly_only_message: String { get set }
    var exportPKey_label_use_in_save_environment: String { get set }
    var exportPKey_label_use_in_save_environment_message: String { get set }
    var exportPKey_btn_copy_private_key: String { get set }
    var importWallet_sourceChoose_label_title: String { get set }
    var importWallet_sourceChoose_label_use_identity_qrcode: String { get set }
    var importWallet_sourceChoose_label_identity_qrcode_desc: String { get set }
    var importWallet_sourceChoose_label_use_pKey: String { get set }
    var importWallet_sourceChoose_label_user_pKey_desc: String { get set }
    var importWallet_typeChoose_title: String { get set }
    var importWallet_typeChoose_btn_ethWallet: String { get set }
    var importWallet_typeChoose_btn_btcWallet: String { get set }
    var importWallet_typeChoose_btn_cicWallet: String { get set }
    func importWallet_typeChoose_btn_generalWallet(_ args: String...) -> String
    var importWallet_privateKey_import_etherum_wallet: String { get set }
    var importWallet_privateKey_import_bitcoin_wallet: String { get set }
    var importWallet_privateKey_import_cic_wallet: String { get set }
    var importWallet_privateKey_import_guc_wallet: String { get set }
    func importWallet_privateKey_import_general_wallet(_ args: String...) -> String
    var importWallet_privateKey_error_import: String { get set }
    var importWallet_privateKey_label_desc_private_key: String { get set }
    var importWallet_privateKey_placeholder_hint_fill_in_private_key: String { get set }
    var importWallet_privateKey_hud_importing: String { get set }
    var importWallet_privateKey_hud_imported: String { get set }
    var importWallet_privateKey_label_setPwd: String { get set }
    var importWallet_privateKey_placeholder_walletPwd: String { get set }
    var importWallet_privateKey_placeholder_confirmPwd: String { get set }
    var importWallet_privateKey_placeholder_pwdHint: String { get set }
    var importWallet_privateKey_btn_startImport: String { get set }
    var importWallet_privateKey_error_pwd_invalid_format: String { get set }
    var importWallet_privateKey_error_pwd_invalid_format_content: String { get set }
    var importWallet_privateKey_error_confirmPwd_diff_with_pwd: String { get set }
    var importWallet_privateKey_error_confirmPwd_diff_with_pwd_content: String { get set }
    var importWallet_privateKey_error_wallet_exist_already: String { get set }
    var assetDetail_btn_deposit: String { get set }
    var assetDetail_btn_withdrawal: String { get set }
    var assetDetail_tab_total: String { get set }
    var assetDetail_tab_withdrawal: String { get set }
    var assetDetail_tab_deposit: String { get set }
    var assetDetail_tab_fail: String { get set }
    var assetDetail_label_tx_failed: String { get set }
    var assetDetail_label_tx_go_check: String { get set }
    func withdrawal_title(_ args: String...) -> String
    var withdrawal_btn_nextstep: String { get set }
    var withdrawal_error_same_address_content: String { get set }
    func withdrawal_error_asset_insuffient_content(_ args: String...) -> String
    func withdrawal_error_asset_insuffient_for_same_asset_fee_content(_ args: String...) -> String
    func withdrawal_error_fee_insufficient(_ args: String...) -> String
    func withdrawal_error_fee_rate_too_low(_ args: String...) -> String
    func withdrawal_error_unknown(_ args: String...) -> String
    func withdrawal_label_assetAmt(_ args: String...) -> String
    var withdrawal_placeholder_withdrawalAmt: String { get set }
    var withdrawal_label_toAddr: String { get set }
    var withdrawal_btn_common_used_addr: String { get set }
    var withdrawal_placeholder_toAddr: String { get set }
    var withdrawal_label_fromAddr: String { get set }
    var withdrawal_label_minerFee: String { get set }
    var withdrawal_placeholder_custom_btc_feeRate: String { get set }
    var withdrawal_placeholder_btc_feeRate_normal: String { get set }
    var withdrawal_placeholder_btc_feeRate_priority: String { get set }
    var withdrawal_label_advanced_mode: String { get set }
    var withdrawal_label_slow: String { get set }
    var withdrawal_label_fast: String { get set }
    var withdrawal_placeholder_eth_custom_gasPrice: String { get set }
    var withdrawal_placeholder_eth_custom_gas: String { get set }
    func withdrawal_label_eth_fee_content(_ args: String...) -> String
    var withdrawalConfirm_title: String { get set }
    var withdrawalConfirm_label_payment_detail: String { get set }
    var withdrawalConfirm_label_receipt_address: String { get set }
    var withdrawalConfirm_label_payment_address: String { get set }
    var withdrawalConfirm_label_miner_fee: String { get set }
    func withdrawalConfirm_label_payment_detail_content(_ args: String...) -> String
    var withdrawalConfirm_changeFee_title: String { get set }
    func withdrawalConfirm_changeWallet_label_assetAmt(_ args: String...) -> String
    var withdrawalConfirm_changeWallet_title: String { get set }
    var withdrawalConfirm_pwdVerify_title: String { get set }
    var withdrawalConfirm_pwdVerify_label_input_wallet_pwd: String { get set }
    var withdrawalConfirm_pwdVerify_placeholder_wallet_pwd: String { get set }
    var withdrawalConfirm_pwdVerify_error_pwd_is_wrong: String { get set }
    var withdrawalConfirm_pwdVerify_hud_signing: String { get set }
    var withdrawalConfirm_pwdVerify_hud_broadcasting: String { get set }
    var withdrawalConfirm_pwdVerify_error_btc_insufficient_fee_title: String { get set }
    func withdrawalConfirm_pwdVerify_error_btc_insufficient_fee_content(_ args: String...) -> String
    var withdrawalConfirm_pwdVerify_error_tx_save_fail: String { get set }
    var txRecord_title: String { get set }
    var txRecord_btn_deposit: String { get set }
    var txRecord_btn_withdrawal: String { get set }
    var txRecord_btn_fail: String { get set }
    var txRecord_empty_tx: String { get set }
    var lightningTx_title: String { get set }
    var lightningTx_label_rate: String { get set }
    var lightningTx_btn_exchange: String { get set }
    var lightningTx_placeholder_out_amt: String { get set }
    var lightningTx_placeholder_in_amt: String { get set }
    var lightningTx_label_txRecord: String { get set }
    var lightningTx_label_empty_tx: String { get set }
    func lightningTx_label_txRecord_miner_fee(_ args: String...) -> String
    var lightningTx_label_txRecord_failed: String { get set }
    var lightningTx_label_txRecord_go_check: String { get set }
    func lightningTx_error_insufficient_asset_amt(_ args: String...) -> String
    var lightningTx_error_empty_transRate_title: String { get set }
    var lightningTx_error_empty_transRate_content: String { get set }
    func lightningTx_error_no_asset_title(_ args: String...) -> String
    func lightningTx_error_no_asset_content(_ args: String...) -> String
    var lightningTx_label_custom: String { get set }
    func lightningTx_label_remain_amt(_ args: String...) -> String
    var ltTx_title: String { get set }
    var ltTx_label_pay_info: String { get set }
    var ltTx_label_changeTo: String { get set }
    var ltTx_label_exchangeRate: String { get set }
    var ltTx_label_toAddr: String { get set }
    var ltTx_label_toAddr_empty_tap_to_set: String { get set }
    var ltTx_label_fromAddr: String { get set }
    var ltTx_label_minerFee: String { get set }
    var ltTx_minerFee_title: String { get set }
    var ltTx_changeToAddress_title: String { get set }
    var ltTx_changeToAddress_label_toAddress: String { get set }
    var ltTx_changeToAddress_btn_common_used_addr: String { get set }
    func ltTx_changeToAddress_placeholder_input_valid_addr(_ args: String...) -> String
    var ltTx_changeToAddress_label_toWallet: String { get set }
    var ltTx_pwdVerify_title: String { get set }
    var ltTx_pwdVerify_label_input_wallet_pwd: String { get set }
    var ltTx_pwdVerify_placeholder_input_wallet_pwd: String { get set }
    var ltTx_pwdVerify_error_pwd_is_wrong: String { get set }
    var ltTx_pwdVerify_hud_signing: String { get set }
    var ltTx_pwdVerify_hud_broadcasting: String { get set }
    var ltTx_pwdVerify_error_btc_insufficient_fee_title: String { get set }
    func ltTx_pwdVerify_error_btc_insufficient_fee_content(_ args: String...) -> String
    var ltTx_pwdVerify_error_tx_save_fail: String { get set }
    var ltTx_pwdVerify_error_miner_fee_setting: String { get set }
    var ltTx_pwdVerify_error_miner_fee_input_p: String { get set }
    var ltTx_pwdVerify_error_payment_detail: String { get set }
    var me_btn_edit: String { get set }
    var me_label_common_used_addr: String { get set }
    var me_label_settings: String { get set }
    var me_label_qa: String { get set }
    var me_label_agreement: String { get set }
    var me_label_check_update: String { get set }
    var me_hud_checking: String { get set }
    var me_alert_already_latest_version_title: String { get set }
    func me_alert_version_content(_ args: String...) -> String
    var me_alert_able_to_update_version_title: String { get set }
    var me_btn_update: String { get set }
    var myIdentity_title: String { get set }
    var myIdentity_label_name: String { get set }
    var myIdentity_label_identityID: String { get set }
    var myIdentity_btn_backup_identity: String { get set }
    var myIdentity_btn_exit_current_identity: String { get set }
    var myIdentity_alert_changeName_title: String { get set }
    var myIdentity_alert_changeName_content: String { get set }
    var myIdentity_placeholder_changeName: String { get set }
    var myIdentity_error_name_invalid_format: String { get set }
    var myIdentity_error_unable_to_decrypt_mnemonic: String { get set }
    var myIdentity_error_pwd_is_wrong: String { get set }
    var myIdentity_alert_backup_identity_title: String { get set }
    var myIdentity_alert_input_pwd_content: String { get set }
    var myIdentity_alert_clearIdentity_title: String { get set }
    var myIdentity_alert_clearIdentity_ensure_wallet_backup_content: String { get set }
    var myIdentity_alert_clearIdentity_verify_pwd_title: String { get set }
    var myIdentity_alert_clearIdentity_verify_pwd_content: String { get set }
    var myIdentity_placeholder_pwd: String { get set }
    var myIdentity_hud_exiting: String { get set }
    var myIdentity_hud_exited: String { get set }
    var backupWallet_sourceChoose_label_title: String { get set }
    var backupWallet_sourceChoose_label_use_identity_qrcode: String { get set }
    var backupWallet_sourceChoose_label_identity_qrcode_desc: String { get set }
    var backupWallet_sourceChoose_label_use_mnemonic: String { get set }
    var backupWallet_sourceChoose_label_user_mnemonic_desc: String { get set }
    var settings_title: String { get set }
    var settings_label_localAuth: String { get set }
    var settings_label_privateMode: String { get set }
    var settings_label_privateMode_note: String { get set }
    var settings_label_language: String { get set }
    var settings_label_currencyUnit: String { get set }
    var settings_alert_verify_to_turn_off_functionality: String { get set }
    
    var account_setting_title: String { get set }
    var basic_setting_title: String { get set }
    var follow_us_title: String { get set }
    var others_title: String { get set }
    
    var changePrefFiat_title: String { get set }
    var changePrefFiat_btn_save: String { get set }
    var addressbook_title: String { get set }
    var addressbook_label_empty_addressbook: String { get set }
    var abInfo_title: String { get set }
    func abInfo_label_address_type(_ args: String...) -> String
    var abInfo_btn_edit: String { get set }
    var abInfo_label_name: String { get set }
    var abInfo_label_note: String { get set }
    var ab_update_title_create: String { get set }
    var ab_update_title_edit: String { get set }
    var ab_update_hud_saving: String { get set }
    var ab_update_placeholder_name: String { get set }
    var ab_update_placeholder_note: String { get set }
    var ab_update_btn_save: String { get set }
    var ab_update_error_unable_update_title: String { get set }
    var ab_update_error_unable_create_title: String { get set }
    var ab_update_error_already_has_same_unit_content: String { get set }
    func ab_update_actionsheet_createAddress_general(_ args: String...) -> String
    var ab_update_actionsheet_createAddress_btc: String { get set }
    var ab_update_actionsheet_createAddress_eth: String { get set }
    var ab_update_actionsheet_createAddress_cic: String { get set }
    var ab_update_label_createAddress: String { get set }
    var ab_update_placeholder_input_valid_address: String { get set }
    var ab_update_alert_confirm_delete_address_title: String { get set }
    var ab_update_btn_delete_addressbook: String { get set }
    var ab_update_alert_confirm_delete_addressbook_title: String { get set }
    var ab_update_alert_test_string: String { get set }
    var chat_list_alert_recover_message_history_title: String { get set }
    var chat_list_alert_recover_message_history_message: String { get set }
    var chat_list_placeholder_recover_message_history: String { get set }
    var chat_list_alert_recover_message_history_create: String { get set }
    var chat_list_alert_recover_message_history_recover: String { get set }
    var chat_list_title: String { get set }
    var chat_extend_item_sweep_qrcode: String { get set }
    var chat_extend_item_add_channel: String { get set }
    var chat_extend_item_add_friends: String { get set }
    var chat_extend_item_search_group: String { get set }
    var chat_extend_item_social_envelope: String { get set }
    var chat_extend_item_user_information: String { get set }
    var user_profile_title: String { get set }
    var user_profile_button_add_friend: String { get set }
    var user_profile_block_user: String { get set }
    var user_profile_transfer_account: String { get set }
    var user_profile_alert_transfer_account_title: String { get set }
    var user_profile_alert_transfer_account_message: String { get set }
    var user_profile_placeholder_transfer_account: String { get set }
    var add_friend_title: String { get set }
    var add_friend_alert_title: String { get set }
    var add_friend_alert_message: String { get set }
    var add_friend_placeholder_message: String { get set }
    var add_friend_alert_success: String { get set }
    var add_friend_placeholder_friend_id: String { get set }
    
    var friend_request_title: String { get set }
    var group_request_title: String { get set }
    var friend: String { get set }
    var group: String { get set }
    
    var trend: String { get set }
    var hot_group: String { get set }
    var media: String { get set }
    var blockchain_explorer: String { get set }
    
    var select_from_camera: String { get set }
    var select_from_gallery: String { get set }

    var create_group: String { get set }
    var chat_secret_setting: String { get set }
    var decentralize: String { get set }
    var time_limit: String { get set }
    var chat_secret_single: String { get set }
    var chat_secret_keep_5 : String { get set }
    var chat_secret_keep_10 : String { get set }
    var chat_secret_keep_20 : String { get set }
    
    var tab_explorer : String { get set }
    var tab_social : String { get set }
    var tab_setting : String { get set }

    var contact_title : String { get set }
    var contact_individual : String { get set }
    var contact_group : String { get set }
    
    var stable_coin : String { get set }
    var sto_coin : String { get set }
    var delete : String {get set}
    var forward : String {get set}

    var message_action : String {get set}
    var select_wallet_address : String {get set}
    var backupChat_alert_password_mismatch : String {get set}
    var copy_file_url : String {get set}
    var send_file_title : String {get set}
    var confirm_cancel_editing : String {get set}
    var exit_group : String {get set}
    var manage_group: String {get set}
    var confirm_exit: String {get set}
    var confirm_delete_group: String {get set}
    var delete_group: String {get set}
    var group_member: String {get set}
    var manage_currency: String {get set}

    var create_new_wallet: String {get set}
    var create_new_wallet_desc: String {get set}
    var create_new_btc_wallet: String {get set}
    var create_new_eth_wallet: String {get set}

    var myQRCode: String {get set}
    var chat_room_has_blocked: String {get set}

    var chat_room_receipt: String {get set}
    var chat_room_image: String {get set}
    var chat_room_camera : String {get set}
    var chat_room_audio_call : String {get set}
    var chat_room_video_call: String {get set}
    var chat_room_red_env: String {get set}
    
    var copied_successfully: String {get set}
    
    var secret_chat_on: String {get set}
    
    var accept_request: String {get set}
    var reject_request: String {get set}

    var trans_success: String {get set}
    var trans_failed: String {get set}

    var group_qr_code: String {get set}
    var account: String {get set}
    var assetDetail_receive: String {get set}
    
    var join_group: String {get set}
    var alert_cant_join_pvt_group: String {get set}
    
    var group_join_success:String {get set}
    
    var group_name:String {get set}
    var group_type:String {get set}
    
    var public_group:String {get set}
    var private_group:String {get set}
    var post_message:String {get set}
    var admin_only:String {get set}
    var all_members:String {get set}
    var group_description:String {get set}
    var show_qr_code:String {get set}
    
    var group_member_new:String {get set}
    var group_member_invited:String {get set}
    func group_text_too_long(_ args: String...) -> String
    
    var members_invitation_successfull :String {get set}
    var transfer_all_amount:String {get set}
    var invalid_mnemonic_phrase:String {get set}
    var image_saved_success:String {get set}
    var exists :String {get set}
    
    var access_denied_mic:String {get set}
    var recording_failed:String {get set}
    
    var record_audio_start_button:String {get set}
    var record_audio_stop_to_send_button:String {get set}
    
    var red_env_send_currency:String {get set}
    var red_env_send_balance:String {get set}
    var red_env_send_total_amount:String {get set}
    var red_env_send_enter_amount:String {get set}
    var red_env_send_number_title:String {get set}
    func red_env_send_number_of_members(_ args: String...) -> String
    var red_env_send_number_of_red_env:String {get set}
    var red_env_send_dist_rule:String {get set}
    var red_env_send_divide:String {get set}
    var red_env_send_random:String {get set}
    var red_env_send_comment:String {get set}
    var red_env_comment_placeholder:String {get set}
    var red_env_send_notice_one:String {get set}
    var red_env_send_notice_two:String {get set}
    var red_env_send_time_limit:String {get set}
    var red_env_send_reservationTime:String {get set}
    var red_env_send_day:String {get set}
    var red_env_send_hour:String {get set}
    var red_env_send_minute:String {get set}
    var red_env_send_infinite:String {get set}
    var red_env_send_please_select:String {get set}
    var red_env_money_sent:String {get set}
    var red_env_waiting_to_send:String {get set}
    func red_env_amount_received(_ args: String...) -> String
    func red_env_transfer_alert_message(_ args :String ...) -> String

    var red_env_send_sent_successfully :String {get set}
    func red_env_status_waiting_for_money(_ args:String ...) -> String
    var red_evn_send_by_me :String {get set}
    func red_env_sent_by_sender(_ args:String ...) -> String 
    var red_env_expired :String {get set}

    func red_env_money_sent_already_message(_ args:String ...) -> String
    func red_env_money_sent_to_user_message(_ args:String ...) -> String

    var view_red_envelope:String {get set}
    var red_env_view_record:String {get set}
    var red_env_view_record_substring:String {get set}
    var red_env_receive_expired_message:String {get set}
    var red_env_receive_no_remaining_envelopes:String {get set}
    var red_env_receive_status_not_yet_received:String {get set}
    var red_env_receive_status_received:String {get set}
    var red_env_send_confirm_transfer:String {get set}
    var red_env_send_records:String {get set}

    var receipt_receiving_currency:String{get set}
    var receiving_amount:String {get set}
    var red_evn_history_title:String {get set}

    var red_env_history_receive:String {get set}
    var red_env_history_sent:String {get set}
    
    var red_env_history_waiting_for_collection:String {get set}
    var red_env_history_waiting_for_money:String {get set}
    var red_env_history_money_transfered:String {get set}
    
    var receive_red_env_no_wallet_found:String {get set}
    var profile_edit_empty_name_error:String {get set}
    var red_env_history_from_title:String {get set}
    var red_env_history_create_time_title:String {get set}
    var red_env_history_receive_time_title:String {get set}
    var red_env_history_deposit_time_title:String {get set}

    var chat_keyboard_placeholder:String {get set}
    var chat_recovery_password_successful:String {get set}

    var chat_history_delete_chat_title:String {get set}
    var chat_history_delete_chat_message:String {get set}
    
    var receipt_request_error_string:String {get set}
    
    var use_edited_image_title:String {get set}
    var use_original_image_title:String {get set}
    
    var create_red_env_title:String {get set}

    var voice_message_string:String {get set}
    var image_message_string:String {get set}
    var call_message_string:String {get set}
    var receipt_message_string:String {get set}

    var download_file_title:String {get set}
    var file_download_successful_message:String {get set}
    
    var lightning_receipt_btn_title:String {get set}
    var transaction_details_btn_title:String {get set}
    
    var lightning_payment_title:String {get set}
    
    var light_withdraw_btn_title:String {get set}
    var light_deposit_btn_title:String {get set}
    
    var insufficient_unspend_error_msg:String{get set}

    var transfer_amount_title:String {get set}
    var transfer_note_placeholder:String {get set}
    
    var payment_wallet:String {get set}
    var transfer_all_coin_ttn_address:String {get set}

    var forward_message_title_string :String {get set}
}
