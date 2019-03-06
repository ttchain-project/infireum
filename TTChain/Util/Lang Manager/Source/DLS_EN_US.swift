import Foundation

struct DLS_EN_US: DLS {
    var g_ok = "Ok"
    var g_cancel = "Cancel"
    var g_loading = "Loading, please wait."
    var g_close = "Close"
    var g_done = "Done"
    var g_success = "Success"
    var g_confirm = "Confirm"
    var g_update = "Refresh"
    var g_copy = "Copy"
    var g_edit = "Edit"
    var g_next = "Next"
    var g_error_exit = "Are you sure you want to leave?"
    var g_error_networkIssue = "Network connection failed, please try again"
    var g_error_networkTimeout = "Connection has expired, please try again"
    var g_error_emptyform = "Please enter"
    var g_error_networkUnreachable = "There is currently no network"
    var g_error_tokenInvalid = "Invalid Token found"
    var g_error_apiReject = "The server is busy, please try again later"
    var g_error_tokenExpired = "Logged-in token has expired"
    var g_error_appDisabled = "Under maintenance"
    var g_error_appDisabled_detail = "App is currently under maintenance"
    var g_error_invalidVersion = "Version outdated "
    var g_error_emptyData = "Data not found"
    var g_error_broadcastFail = "Broadcast failed"
    var g_error_encryptFail_mnemonic = "Unable to encrypt mnemonic"
    var g_error_encryptFail_privateKey = "Unable to encrypt private key"
    var g_error_decryptFail_mnemonic = "Unable to decrypt mnemonic"
    var g_error_decryptFail_privateKey = "Unable to decrypt private key"
    var g_camera_permission_requestion = "To enable QR code scanning, please enable access to camera"
    var g_error_mnemonic_wrong = "The mnemonic is wrong. Please remove extra white space or enter the correct word."
    var g_toast_addr_copied = "Address copied"
    var lang_zh_cn = "Simplified Chinese"
    var lang_zh_tw = "Traditional Chinese"
    var lang_en_us = "English"
    func strValidate_error_common_spacePrefixOrSuffix(_ args: String...) -> String { return String.init(format: "%@ must not be blank at the beginning and end", arguments: args) }
    func strValidate_error_common_lengthInvalid(_ args: String...) -> String { return String.init(format: "%@ length must be %@-%@ characters", arguments: args) }
    func strValidate_error_common_allowAlphanumericOnly(_ args: String...) -> String { return String.init(format: "%@ are only allowed to use letters and numbers", arguments: args) }
    var strValidate_error_mnemonic_12WordsAtLeast = "The mnemonic has an incorrect format and must contain more than 12 words"
    func strValidate_error_mnemonic_containUppercase(_ args: String...) -> String { return String.init(format: "The mnemonic has an incorrect format, detecting %@ with a non-lowercase word", arguments: args) }
    func strValidate_error_mnemonic_invalidCharacter(_ args: String...) -> String { return String.init(format: "The mnemonic has an incorrect format, detecting the word %@ with a non-English character, please confirm entered contant and separate each word with a half-shaped blank", arguments: args) }
    var strValidate_error_confirmPwd_diffWithPwd = "Two password entries do not match"
    var strValidate_field_identityName = "Name"
    var strValidate_field_mnemonic = "Mnemonic"
    var strValidate_field_pwd = "Password"
    var strValidate_field_confirmPwd = "Confirm password"
    var strValidate_field_walletName = "Wallet name"
    var strValidate_field_pwdHint = "Password reminder message"
    var strValidate_field_pwdHintSame = "Password and password hint can\'t be the same"
    var strValidate_field_addressInvalid = "Please confirm the receipt address format"
    var fee_cic_per_byte = "cic/b"
    var fee_eth_gas_price = "gas price"
    var fee_sat_per_byte = "sat/b"
    var fee_eth_gwei = "gwei"
    var fee_ether = "ether"
    var intro_title_page_one = "Welcome !\nWelcome to HopeSeed"
    var intro_title_page_two = "Multi-currency transaction"
    var intro_title_page_three = "Innovative fast and safe"
    var qrCodeImport_alert_error_wrong_pwd_title = "Incorrect password"
    func qrCodeImport_info_g_alert_error_title_error_field(_ args: String...) -> String { return String.init(format: "%@ incorrect format", arguments: args) }
    var qrCodeImport_info_g_alert_error_field_pwd = "Password"
    var qrCodeImport_info_g_alert_error_field_idName = "User name"
    var qrCodeImport_info_g_alert_error_field_hint = "Password hint"
    var qrCodeImport_alert_error_wrong_pwd_content = "Incorrect QR CODE password"
    var qrCodeImport_alert_input_pwd = "Enter password"
    var qrCodeImport_alert_content = "Please enter a QR CODE password to unlock"
    func qrCodeImport_alert_placeholder_pwd(_ args: String...) -> String { return String.init(format: "Password hint: %@", arguments: args) }
    var qrCodeImport_list_user_system_wallets = "User\'s system wallet"
    var qrCodeImport_list_imported_wallets = "Externally imported wallet"
    var qrCodeImport_list_title = "Identity QR CODE content"
    var qrCodeImport_list_label_will_not_import_existed_wallets = "Existing wallet addresses will not be imported."
    var qrCodeImport_info_title = "Identity QR CODE content"
    var qrCodeImport_info_label_intro = "Do you want to restore the contents of this QR CODE? \nAll wallets will use your newly set payment password and hint after importing"
    var qrCodeImport_info_placeholder_idName = "Please enter user name"
    var qrCodeImport_info_placeholder_pwd = "Set user password"
    var qrCodeImport_info_placeholder_hint = "Set password hint"
    var qrCodeImport_info_btn_startImport = "Start importing"
    var qrCodeExport_alert_backup_title = "Do you want to start QR CODE backup?"
    var qrCodeExport_alert_note_content = "The passwords and hints you enter will enable secure encryption protection and booting for the QR Code. Please use a password that is easy to remember and an appropriate hint message."
    var qrCodeExport_alert_placeholder_pwd = "Password (8 or more letters and numbers, no blanks at the beginning or end)"
    var qrCodeExport_alert_placeholder_hint = "Password hint (no blank at the beginning or end)"
    var qrCodeExport_title = "Backup QR CODE"
    var qrCodeExport_btn_save_qrcode = "Save QR CODE"
    var qrCodeExport_btn_qrcode_saved = "QR CODE has been saved"
    var qrCodeExport_btn_backup_qrcode = "Backup QRCODE"
    var qrCodeExport_label_desc = "After storing the QR CODE, you can use the QR CODE for identity recovery and wallet import. Be sure to remember the QR CODE password you set, and you will be required to enter it to verify your identity when you use it."
    var qrCodeExport_label_user_system_wallets = "Wallet of user\'s current identity"
    var qrCodeExport_label_imported_wallets = "Externally imported wallet"
    var qrcodeExport_toast_qrcode_saved_to_album = "QR CODE has been saved to album"
    var qrcodeExport_alert_title_did_not_backup_qrcode = "You have not backed up QR CODE"
    var qrcodeExport_alert_content_did_not_backup_qrcode = "QR CODE has not been saved to album. Do you want to make a backup?"
    var qrcodeExport_alert_btn_backup = "Back up"
    var qrcodeExport_alert_btn_skip = "Skip"
    var qrcodeProcess_alert_title_cannot_find_qrcode_in_img = "QR CODE cannot be found in picture"
    var qrcodeProcess_alert_content_cannot_find_qrcode_in_img = "Please confirm that the image contains a QR Code"
    var qrcodeProcess_alert_title_cannot_decode_qrcode_in_img = "Unable to analyze QR CODE content"
    var qrcodeProcess_alert_content_cannot_decode_qrcode_in_img = "Please confirm if the QR CODE contains the corresponding information"
    var qrcodeProcess_alert_title_album_permission_denied = "Permissions has not been open"
    var qrcodeProcess_alert_content_album_permission_denied = "You have not enabled access to the album. Please go to Settings to enable access to save QR Code."
    var qrcodeProcess_alert_content_camera_permission_denied = "You have not enabled access to the camera. Please go to Settings to enable access to save QR Code."
    var qrcodeProcess_hud_decoding = "Analyzing"
    var tab_wallet = "Wallet"
    var tab_trade = "Trade"
    var tab_me = "Me"
    var tab_chat = ""
    var tab_alert_newSystemWallet_title = "Hope Seed supports a new wallets!"
    var tab_alert_newSystemWallet_content = "To add a wallet, please enter identity (wallet) password."
    var tab_alert_placeholder_identityPwd = "Identity (wallet) password"
    var tab_alert_error_mnemonic_decrypt_failed = "Incorrect password"
    var tab_alert_error_wallet_sync_failed = "The system is temporarily unable to add a wallet, please try again later"
    var agreement_title = "User Agreement"
    var agreement_dont_display_again_today = "Do not show again today"
    var qrcode_title = "Scan code"
    var qrcode_label_intro = "Please aim the camera at the QR code to scan"
    var qrcode_btn_withdrawal = "Transfer"
    var qrcode_btn_importWallet = "Import wallet"
    var qrcode_btn_contact = "Contact"
    var qrcode_actionSheet_pickChainTypeToImport_title = "Please select the type of wallet to import"
    var qrcode_actionSheet_pickChainTypeToImport_content = "Please select the same wallet type as in the original scan to avoid restoring imported assets"
    func qrcode_actionSheet_btn_mainCoinType(_ args: String...) -> String { return String.init(format: "%@ wallet", arguments: args) }
    var login_label_title = "Create your first digital identity\nEasily manage multi-chain wallets"
    var login_btn_create = "Create identity"
    var login_label_desc = "Multi-chain wallet will be created automatically when creating identity"
    var login_btn_restore = "Restore identity"
    var login_label_or = "Or"
    var login_actionsheet_restore_mnemonic = "Restore mnemonic"
    var login_actionsheet_restore_qrcode = "Restore QR CODE"
    var login_alert_title_camera_permission_denied = "Permissions have not been opened"
    var login_alert_content_camera_permission_denied = "You have not enabled access to the album. Please go to Settings to enable access to save QR Code."
    var login_alert_title_import_qrcode_failed = "Wallet import failed"
    var login_alert_content_import_qrcode_failed = "Your identity wallet could not be imported. Please try a different QR CODE"
    var createID_title = "Create identity"
    var createID_hud_creating = "Creating..."
    var createID_btn_create = "Create"
    var createID_placeholder_name = "Identity name"
    var createID_placeholder_password = "Password"
    var createID_placeholder_confirmPassword = "Reenter password"
    var createID_placeholder_passwordNote = "Password reminder message"
    var createID_error_pwd_title = "Incorrect password"
    var createID_error_confirmPwd_title = "Incorrect confirm password"
    var createID_error_identityName_title = "Incorrect identity name"
    var createID_error_pwdHint_title = "Incorrect password reminder"
    var backupWallet_title = "Backup wallet"
    var backupWallet_label_mainNote = "Asset security cannot be guaranteed without proper backup. After deleting the app or wallet, you need your back up files to restore wallet."
    var backupWallet_label_subNote = "Please make a backup in a safe environment with no cameras around."
    var backupWallet_btn_backupMnemonic = "Backup mnemonic"
    var backupMnemonic_title = "Backup mnemonic"
    var backupMnemonic_desc = "Please carefully record the mnemonic below and we will verify it in the next step."
    var sortMnemonic_title = "Sorting mnemonic"
    var sortMnemonic_desc = "Please click on the mnemonic in order to confirm that you are backing up correctly."
    var sortMnemonic_error_mnemonic_wrong_order = "Incorrect mnemonic order"
    var sortMnemonic_error_create_user_fail = "User creation failed"
    var sortMnemonic_error_create_wallet_fail = "Wallet creation failed"
    var restoreIdentity_label_settingPwd = "Set password"
    var restoreIdentity_placeholder_walletPwd = "Wallet password"
    var restoreIdentity_placeholder_walletConfirmPwd = "Reenter password"
    var restoreIdentity_placeholder_mnemonic = "Enter mnemonics, separated by spaces"
    var restoreIdentity_placeholder_pwdHint = "Password reminder information"
    var restoreIdentity_btn_import = "Start importing"
    var restoreIdentity_title = "Restore identity"
    var restoreIdentity_label_able_to_change_pwd_note = "The wallet password can be modified while the mnemonic is being imported."
    var restoreIdentity_hud_restoring = "Restoring..."
    var restoreIdentity_hud_restoreSuccess = "Import successful"
    var restoreIdentity_error_create_user_fail = "User creation failed"
    var restoreIdentity_error_create_wallet_fail = "Wallet creation failed"
    var restoreIdentity_error_pwd_title = "Incorrect password"
    var restoreIdentity_error_confirmPwd_title = "Incorrect confirm password"
    var restoreIdentity_error_mnemonic_title = "Incorrect mnemonic"
    var restoreIdentity_error_pwdHint_title = "Incorrect password reminder"
    var localAuth_btn_tapToStartVerify = "Tap to start verification"
    var localAuth_alert_verifyToBrowse_title = "Please verify your identity to browse your wallet"
    var localAuth_alert_inputIdentiyPwd_title = "Please enter identity password"
    var walletOverview_refresher_status_pulling = "Pull down to refresh"
    var walletOverview_refresher_status_overpulled = "Release to refresh"
    var walletOverview_refresher_status_loading = "Loading"
    var walletOverview_refresher_status_finished = "Complete"
    var walletOverview_btn_deposit = "Deposit"
    var walletOverview_btn_manageAsset = "Add assets"
    var walletOverview_btn_txRecord = "Transfer history"
    var walletOverview_btn_switchWallet = "Switch wallet"
    func walletOverview_alert_withdrawal_noAsset_title(_ args: String...) -> String { return String.init(format: "No %@ assets yet", arguments: args) }
    func walletOverview_alert_withdrawal_noAsset_content(_ args: String...) -> String { return String.init(format: "You can open/search to add %@ on the manage assets page to transfer funds", arguments: args) }
    func deposit_label_depositAddress(_ args: String...) -> String { return String.init(format: "%@ deposit address", arguments: args) }
    var deposit_btn_changeAsset = "Change asset"
    var changeAsset_label_remainAmt = "Balance:"
    var changeAsset_title = "Select asset type"
    var manageAsset_searchBar_search_token_and_contract = "Enter Token name or contract address"
    var manageAsset_btn_manage = "Manage"
    var manageAsset_label_myAsset = "My asset"
    var manageAsset_actoinSheet_hideEmptyAsset = "Hide empty assets"
    var manageAsset_actoinSheet_sortAlphabatically = "Sort by alphabet"
    var manageAsset_actoinSheet_sortAlphabatically_cancel = "Cancel sort by alphabet"
    var manageAsset_actoinSheet_sortByAssetAmt = "Sort by balance"
    var manageAsset_actoinSheet_sortByAssetAmt_cancel = "Cancel sort by balance"
    var manageAsset_actoinSheet_removeAsset = "Remove assets"
    var searchAsset_label_myAsset = "My assets"
    var searchAsset_label_resultNotFound = "No results found, you can re-search with another word"
    var changeWallet_label_wallets_current_identity = "Wallet under current identity"
    var changeWallet_label_wallets_imported = "Import external wallet"
    var changeWallet_label_offline = "Offline"
    var changeWallet_alert_import_fail = "Import failed, has reached the maximum number of external wallets"
    var walletManage_title = "Manage"
    var walletManage_label_pwdHint = "Password reminder message"
    var walletManage_label_exportPKey = "Export private key"
    var walletManage_error_pwd = "Incorrect password"
    var walletManage_alert_exportPKey_title = "Export private key"
    var walletManage_alert_exportPKey_content = "Please enter password"
    var walletManage_alert_placeholder_exportPKey_pwd = "Password"
    var walletManage_alert_changeWalletName_title = "Change wallet name"
    var walletManage_alert_changeWalletName_content = "Please enter the name of the wallet you want to replace"
    var walletManage_error_walletName_invalidFormat_title = "Incorrect allet name format"
    var walletManage_alert_placeholder_walletName_char_range = "1-30 characters, please do not leave blank at the beginning and end"
    var walletManage_btn_delete_wallet = "Delete wallet"
    var walletManage_alert_title_delete_wallet = "Delete wallet"
    var pwdHint_title = "Password reminder message"
    var pwdHint_hud_updating = "Updating"
    var pwdHint_hud_updated = "Updated"
    var exportPKey_title = "Export private key"
    var exportPKey_tab_privateKey = "Private key"
    var exportPKey_tab_qrcode = "QR code"
    var exportPKey_label_offline_save = "Save offline"
    var exportPKey_label_offline_save_message = "Don\'t save to email, notepad, web, chat, etc., it\'s very dangerous"
    var exportPKey_label_dont_trans_by_internet = "Please do not transmit with the internet"
    var exportPKey_label_dont_trans_by_internet_message = "Please do not transmit with the internet, once acquired by a hacker, it will cause irreparable loss of assets. It is recommended to transmit with offline devices by scanning QR code."
    var exportPKey_label_pwd_manage_tool_save = "Password management tool save"
    var exportPKey_label_pwd_manage_tool_save_message = "It is recommended to manage with the password management tool"
    var exportPKey_label_provide_scan_directly_only = "Direct scanning only"
    var exportPKey_label_provide_scan_directly_only_message = "The QR code is forbidden to save, take screenshots or photos. It is only for users to scan directly in a secure environment to easily import the wallet"
    var exportPKey_label_use_in_save_environment = "Use in a safe environment"
    var exportPKey_label_use_in_save_environment_message = "Please make sure there is no one or no camera around before use. Once the QR code is acquired by others, it will cause irreparable loss of assets."
    var exportPKey_btn_copy_private_key = "Copy private key"
    var importWallet_sourceChoose_label_title = "Select wallet type"
    var importWallet_sourceChoose_label_use_identity_qrcode = "Use identity QR CODE"
    var importWallet_sourceChoose_label_identity_qrcode_desc = "When you choose to use the identity QR CODE to import the wallet, you can quickly import all the contents of the wallet contained in the QR CODE to the current identity. When importing, you will be asked to enter the QR CODE password you set when you backed up."
    var importWallet_sourceChoose_label_use_pKey = "Use wallet private key"
    var importWallet_sourceChoose_label_user_pKey_desc = "To choose to import using the wallet private key, you need to select the specific imported wallet type (BTC/ ETH...), and the system will import the content of the private key corresponding to the wallet type into the identity."
    var importWallet_typeChoose_title = "Select wallet type"
    var importWallet_typeChoose_btn_ethWallet = "ETH  wallet"
    var importWallet_typeChoose_btn_btcWallet = "BTC wallet"
    var importWallet_typeChoose_btn_cicWallet = "CIC wallet"
    func importWallet_typeChoose_btn_generalWallet(_ args: String...) -> String { return String.init(format: "%@ wallet", arguments: args) }
    var importWallet_privateKey_import_etherum_wallet = "Import ETHERUM wallet"
    var importWallet_privateKey_import_bitcoin_wallet = "Import BITCOIN wallet"
    var importWallet_privateKey_import_cic_wallet = "Import CIC wallet"
    var importWallet_privateKey_import_guc_wallet = "Import GUC wallet"
    func importWallet_privateKey_import_general_wallet(_ args: String...) -> String { return String.init(format: "Import %@ wallet", arguments: args) }
    var importWallet_privateKey_error_import = "Import failed"
    var importWallet_privateKey_label_desc_private_key = "Copy and paste the contents of the PrivateKey file into the input box. Or enter the QR code generated by scanning the Private Key content."
    var importWallet_privateKey_placeholder_hint_fill_in_private_key = "Enter the plaintext private key"
    var importWallet_privateKey_hud_importing = "Importing..."
    var importWallet_privateKey_hud_imported = "Successful import"
    var importWallet_privateKey_label_setPwd = "Set password"
    var importWallet_privateKey_placeholder_walletPwd = "Wallet password"
    var importWallet_privateKey_placeholder_confirmPwd = "Reenter password"
    var importWallet_privateKey_placeholder_pwdHint = "Restore identity"
    var importWallet_privateKey_btn_startImport = "Restore identity"
    var importWallet_privateKey_error_pwd_invalid_format = "Incorrect password format"
    var importWallet_privateKey_error_pwd_invalid_format_content = "Must contain at least 8 characters"
    var importWallet_privateKey_error_confirmPwd_diff_with_pwd = "The two password do not match"
    var importWallet_privateKey_error_confirmPwd_diff_with_pwd_content = "Please confirm that the two entered passwords match"
    var importWallet_privateKey_error_wallet_exist_already = "Wallet already exists"
    var assetDetail_btn_deposit = "Receipt"
    var assetDetail_btn_withdrawal = "Transfer"
    var assetDetail_tab_total = "Total"
    var assetDetail_tab_withdrawal = "Withdrawal"
    var assetDetail_tab_deposit = "Deposit"
    var assetDetail_tab_fail = "Fail"
    var assetDetail_label_tx_failed = "Failed"
    var assetDetail_label_tx_go_check = "Go check TXID"
    func withdrawal_title(_ args: String...) -> String { return String.init(format: "%@ transfer", arguments: args) }
    var withdrawal_btn_nextstep = "Next step"
    var withdrawal_error_same_address_content = "The receipt address must not be the same as the payment address"
    func withdrawal_error_asset_insuffient_content(_ args: String...) -> String { return String.init(format: "Insufficient balance: \nYour asset %@ %@\nTransfer amount %@ %@", arguments: args) }
    func withdrawal_error_asset_insuffient_for_same_asset_fee_content(_ args: String...) -> String { return String.init(format: "Insufficient balance: Unable to pay the handling fee\nYour assets: %@ %@\nTransfer costs: (transfer)%@ + (handling fee)%@ ", arguments: args) }
    func withdrawal_error_fee_insufficient(_ args: String...) -> String { return String.init(format: "Insufficient balance: Unable to pay %@ handling fee\n handling fee: %@ %@\n holding amount: %@ %@", arguments: args) }
    func withdrawal_error_fee_rate_too_low(_ args: String...) -> String { return String.init(format: "%@ is too low, it is recommended to be higher than %@ %@", arguments: args) }
    func withdrawal_error_unknown(_ args: String...) -> String { return String.init(format: "Unknown verification error\n system message: %@", arguments: args) }
    func withdrawal_label_assetAmt(_ args: String...) -> String { return String.init(format: "Balance: %@ %@", arguments: args) }
    var withdrawal_placeholder_withdrawalAmt = "Enter amount"
    var withdrawal_label_toAddr = "Receipt address"
    var withdrawal_btn_common_used_addr = "Common used address"
    var withdrawal_placeholder_toAddr = "Please enter address"
    var withdrawal_label_fromAddr = "Payment address"
    var withdrawal_label_minerFee = "Miner fee"
    var withdrawal_placeholder_custom_btc_feeRate = "Custom handling fee (btc)"
    var withdrawal_placeholder_btc_feeRate_normal = "Normal:"
    var withdrawal_placeholder_btc_feeRate_priority = "Priority:"
    var withdrawal_label_advanced_mode = "Advanced mode"
    var withdrawal_label_slow = "Slow"
    var withdrawal_label_fast = "Fast"
    var withdrawal_placeholder_eth_custom_gasPrice = "Custom Gas Price"
    var withdrawal_placeholder_eth_custom_gas = "Custom Gas"
    func withdrawal_label_eth_fee_content(_ args: String...) -> String { return String.init(format: "Gas(%@) * Gas Price (%@ gwei)", arguments: args) }
    var withdrawalConfirm_title = "Payment details"
    var withdrawalConfirm_label_payment_detail = "Payment information"
    var withdrawalConfirm_label_receipt_address = "Receipt address"
    var withdrawalConfirm_label_payment_address = "Payment address"
    var withdrawalConfirm_label_miner_fee = "Miner fee"
    func withdrawalConfirm_label_payment_detail_content(_ args: String...) -> String { return String.init(format: "%@ transfer", arguments: args) }
    var withdrawalConfirm_changeFee_title = "Miner fee setting"
    func withdrawalConfirm_changeWallet_label_assetAmt(_ args: String...) -> String { return String.init(format: "Amount: %@ %@", arguments: args) }
    var withdrawalConfirm_changeWallet_title = "Switch wallet"
    var withdrawalConfirm_pwdVerify_title = "Please enter password"
    var withdrawalConfirm_pwdVerify_label_input_wallet_pwd = "Enter wallet password"
    var withdrawalConfirm_pwdVerify_placeholder_wallet_pwd = "Please enter wallet password"
    var withdrawalConfirm_pwdVerify_error_pwd_is_wrong = "Incorrect password"
    var withdrawalConfirm_pwdVerify_hud_signing = "Signing"
    var withdrawalConfirm_pwdVerify_hud_broadcasting = "Broadcasting"
    var withdrawalConfirm_pwdVerify_error_btc_insufficient_fee_title = "Insufficient balance"
    func withdrawalConfirm_pwdVerify_error_btc_insufficient_fee_content(_ args: String...) -> String { return String.init(format: "Your BTC balance is insufficient, the transaction will charge an additional miner fee %@ BTC, please confirm that your balance is sufficient to pay the miner fee.", arguments: args) }
    var withdrawalConfirm_pwdVerify_error_tx_save_fail = "Failed storage"
    var txRecord_title = "Transfer history"
    var txRecord_btn_deposit = "Deposit"
    var txRecord_btn_withdrawal = "Withdrawal"
    var txRecord_btn_fail = "Fail"
    var txRecord_empty_tx = "No transfer history"
    var lightningTx_title = "Lightning transfer"
    var lightningTx_label_rate = "Exchange rate"
    var lightningTx_btn_exchange = "Quick exchange"
    var lightningTx_placeholder_out_amt = "Transfer quantity"
    var lightningTx_placeholder_in_amt = "Received quantity"
    var lightningTx_label_txRecord = "Local exchange hostory"
    var lightningTx_label_empty_tx = "No local exchange histoy"
    func lightningTx_label_txRecord_miner_fee(_ args: String...) -> String { return String.init(format: "Miner fee: %@ %@", arguments: args) }
    var lightningTx_label_txRecord_failed = "Fail"
    var lightningTx_label_txRecord_go_check = "Go check"
    func lightningTx_error_insufficient_asset_amt(_ args: String...) -> String { return String.init(format: "%@ insufficient balance", arguments: args) }
    var lightningTx_error_empty_transRate_title = "Unable to get conversion rate"
    var lightningTx_error_empty_transRate_content = "Please check if the network is working. Click OK to try to refresh the exchange rate."
    func lightningTx_error_no_asset_title(_ args: String...) -> String { return String.init(format: "The wallet has no %@ assets yet", arguments: args) }
    func lightningTx_error_no_asset_content(_ args: String...) -> String { return String.init(format: "Please go to \"Add and Manage Assets\" to add %@ assets before trading", arguments: args) }
    var lightningTx_label_custom = "Custom"
    func lightningTx_label_remain_amt(_ args: String...) -> String { return String.init(format: "Balance %@", arguments: args) }
    var ltTx_title = "Payment details"
    var ltTx_label_pay_info = "Payment information"
    var ltTx_label_changeTo = "Change to"
    var ltTx_label_exchangeRate = "Conversion rate"
    var ltTx_label_toAddr = "Receipt address"
    var ltTx_label_toAddr_empty_tap_to_set = "Tap to set the payment address"
    var ltTx_label_fromAddr = "Payment address"
    var ltTx_label_minerFee = "Miner fee"
    var ltTx_minerFee_title = "Miner fee setting"
    var ltTx_changeToAddress_title = "Choose payment address"
    var ltTx_changeToAddress_label_toAddress = "Receipt address"
    var ltTx_changeToAddress_btn_common_used_addr = "Common used address"
    func ltTx_changeToAddress_placeholder_input_valid_addr(_ args: String...) -> String { return String.init(format: "Enter a valid %@ address", arguments: args) }
    var ltTx_changeToAddress_label_toWallet = "Receipt wallet"
    var ltTx_pwdVerify_title = "Please enter password"
    var ltTx_pwdVerify_label_input_wallet_pwd = "Enter your wallet password"
    var ltTx_pwdVerify_placeholder_input_wallet_pwd = "Please enter wallet password"
    var ltTx_pwdVerify_error_pwd_is_wrong = "Incorrect password"
    var ltTx_pwdVerify_hud_signing = "Signing"
    var ltTx_pwdVerify_hud_broadcasting = "Broadcasting"
    var ltTx_pwdVerify_error_btc_insufficient_fee_title = "Insufficient balance"
    func ltTx_pwdVerify_error_btc_insufficient_fee_content(_ args: String...) -> String { return String.init(format: "Your BTC balance is insufficient, the transaction will charge an additional miner fee %@ BTC, please confirm that your balance is sufficient to pay the miner fee.", arguments: args) }
    var ltTx_pwdVerify_error_tx_save_fail = "Failed storage"
    var ltTx_pwdVerify_error_miner_fee_setting = "Miner fee setting"
    var ltTx_pwdVerify_error_miner_fee_input_p = "Please enter miner fee"
    var ltTx_pwdVerify_error_payment_detail = "Payment details"
    var me_btn_edit = "Edit"
    var me_label_common_used_addr = "Common used address"
    var me_label_settings = "User settings"
    var me_label_qa = "QA"
    var me_label_agreement = "Member agreement"
    var me_label_check_update = "Check for version updates"
    var me_hud_checking = "Checking"
    var me_alert_already_latest_version_title = "You currently have the latest version"
    func me_alert_version_content(_ args: String...) -> String { return String.init(format: "Current version: %@\nlatest version: %@", arguments: args) }
    var me_alert_able_to_update_version_title = "There is a new version, please update now to enjoy full functionality"
    var me_btn_update = "Update"
    var myIdentity_title = "My identity"
    var myIdentity_label_name = "Name"
    var myIdentity_label_identityID = "Identity ID"
    var myIdentity_btn_backup_identity = "Backup identity"
    var myIdentity_btn_exit_current_identity = "Exit current identity"
    var myIdentity_alert_changeName_title = "Change identity name"
    var myIdentity_alert_changeName_content = "Please enter the name you want to replace"
    var myIdentity_placeholder_changeName = "1-30 characters, please do not leave blank at the beginning and end"
    var myIdentity_error_name_invalid_format = "Incorrect identity name format"
    var myIdentity_error_unable_to_decrypt_mnemonic = "Unable to decrypt mnemonic, please make sure password is correct"
    var myIdentity_error_pwd_is_wrong = "Password verification failed, please enter again"
    var myIdentity_alert_backup_identity_title = "Backup identity"
    var myIdentity_alert_input_pwd_content = "Please enter password"
    var myIdentity_alert_clearIdentity_title = "Exit current identity"
    var myIdentity_alert_clearIdentity_ensure_wallet_backup_content = "Removing identity and all imported wallets, please make sure all wallets are backed up"
    var myIdentity_alert_clearIdentity_verify_pwd_title = "Please enter password"
    var myIdentity_alert_clearIdentity_verify_pwd_content = "Warning: If you do not properly back up, you will not be able to retrieve your wallet after deleting. Please handle this operation carefully."
    var myIdentity_placeholder_pwd = "Passwod"
    var myIdentity_hud_exiting = "Exiting"
    var myIdentity_hud_exited = "Exited"
    var backupWallet_sourceChoose_label_title = "Select wallet type"
    var backupWallet_sourceChoose_label_use_identity_qrcode = "Backup identity QR CODE"
    var backupWallet_sourceChoose_label_identity_qrcode_desc = "Selecting to use the identity QR CODE backup will back up all wallets (system wallet + external wallet) under the current identity. A unique QRCODE will be provided to restore all wallets when you restore your identity or import your wallet later."
    var backupWallet_sourceChoose_label_use_mnemonic = "Backup identity mnemonic"
    var backupWallet_sourceChoose_label_user_mnemonic_desc = "When you choose to back up your identity mnemonics, the system will help you to export the wallet mnemonics under \"Original Identity.\" Please note that this mnemonic does not include your externally imported wallet information. If you restore your identity with this mnemonic, you will not restore the externally imported wallet content."
    var settings_title = "User settings"
    var settings_label_localAuth = "Touch ID / Face ID verification"
    var settings_label_privateMode = "Privacy mode"
    var settings_label_privateMode_note = "The wallet’s assets and amount will be hidden when privacy mode is turned on."
    var settings_label_language = "Language"
    var settings_label_currencyUnit = "Currency unit"
    var settings_alert_verify_to_turn_off_functionality = "Verify to turn off function"
    var changePrefFiat_title = "Currency unit"
    var changePrefFiat_btn_save = "Save"
    
    var account_setting_title = "Account Setting"
    var basic_setting_title = "Basic Setting"
    var follow_us_title = "Follow Us"
    var others_title = "Others"
    
    var addressbook_title = "Common used address"
    var addressbook_label_empty_addressbook = "No history"
    var abInfo_title = "Contact information"
    func abInfo_label_address_type(_ args: String...) -> String { return String.init(format: "%@ address", arguments: args) }
    var abInfo_btn_edit = "Edit"
    var abInfo_label_name = "Name"
    var abInfo_label_note = "Note"
    var ab_update_title_create = "Add contact"
    var ab_update_title_edit = "Edit contact"
    var ab_update_hud_saving = "Saving..."
    var ab_update_placeholder_name = "Name"
    var ab_update_placeholder_note = "Note (optional)"
    var ab_update_btn_save = "Save"
    var ab_update_error_unable_update_title = "Unable to update"
    var ab_update_error_unable_create_title = "Unable to add"
    var ab_update_error_already_has_same_unit_content = "Same history has been made."
    func ab_update_actionsheet_createAddress_general(_ args: String...) -> String { return String.init(format: "Add %@ address", arguments: args) }
    var ab_update_actionsheet_createAddress_btc = "Add Bitcoin Address"
    var ab_update_actionsheet_createAddress_eth = "Add Ethernet address"
    var ab_update_actionsheet_createAddress_cic = "Add CIC address"
    var ab_update_label_createAddress = "Creat address"
    var ab_update_placeholder_input_valid_address = "Please enter a valid address"
    var ab_update_alert_confirm_delete_address_title = "Are you sure you want to delete the address?"
    var ab_update_btn_delete_addressbook = "Delete contact"
    var ab_update_alert_confirm_delete_addressbook_title = "Are you sure you want to delete the contact?"
    var ab_update_alert_test_string = ""
    var chat_list_alert_recover_message_history_title = "Recover message history"
    var chat_list_alert_recover_message_history_message = "Please remember to set it in User Profile"
    var chat_list_placeholder_recover_message_history = "Please enter the password"
    var chat_list_alert_recover_message_history_create = "Create Account"
    var chat_list_alert_recover_message_history_recover = "Recover Account"
    var chat_list_title = "Chat"
    var chat_extend_item_sweep_qrcode = ""
    var chat_extend_item_add_channel = ""
    var chat_extend_item_add_friends = "Add Friends"
    var chat_extend_item_search_group = ""
    var chat_extend_item_social_envelope = ""
    var chat_extend_item_user_information = ""
    var user_profile_title = "User Profile"
    var user_profile_button_add_friend = "Add Friend"
    var user_profile_block_user = "Block User"
    var user_profile_transfer_account = "Transfer Account"
    var user_profile_alert_transfer_account_title = "Setting transfer account password"
    var user_profile_alert_transfer_account_message = "After setting password, you can transfer your IM account to another phone"
    var user_profile_placeholder_transfer_account = "Input transfer account password"
    var add_friend_title = "Add Friend"
    var add_friend_alert_title = "Add Friend"
    var add_friend_alert_message = "Do you want to add as a friend."
    var add_friend_placeholder_message = "Please enter a message"
    var add_friend_alert_success = "Request sent"
    var add_friend_placeholder_friend_id = "Scan friend QR Code"
    var friend_request_title = "Friend Request"
    var group_request_title = "Group Request"
    var friend = "Friend"
    var group = "Group"
    
    var trend = "Trend"
    var hot_group = "Hot Group"
    var media =  "Media"
    var blockchain_explorer = "BlockChain Explorer"

    var select_from_camera = "Camera"
    var select_from_gallery = "Select From Gallery"
    
    var create_group = "Create Group"
    var join_group = "Join a group"
    
    var chat_secret_setting = "Chat secret setting"
    var decentralize = "Decentralize"
    var time_limit = "Time limit"
    var chat_secret_single = "Delete after turn off decentralize"
    var chat_secret_keep_5 = "Keep 5 minutes"
    var chat_secret_keep_10 = "Keep 10 minutes"
    var chat_secret_keep_20 = "Keep 20 minutes"
    
    var tab_explorer = "Discovery"
    var tab_social = "Social"
    var tab_setting = "Setting"
    
    var contact_title = "Contact"
    var contact_individual = "Individual"
    var contact_group = "Group"

    var stable_coin = "Stable Coin"
    var sto_coin = "Listed Coin"
    var delete = "Delete"
    var forward = "Forward"
    var message_action = "Message Action"
    
    var select_wallet_address = "Please select wallet address"
    var backupChat_alert_password_mismatch = "Wallet account does not match the backup password"

    var copy_file_url = "Copy file url"
    
    var confirm_cancel_editing = "Do you want to cancel editing and undo changes?"
    
    var exit_group = "Exit Group"
    var manage_group = "Manage Group"
    var confirm_exit = "Are you sure you want to exit the group?"
    var confirm_delete_group = "Are you sure you want to delete the group?"
    var delete_group = "Delete group"
    var group_member = "Group Member"
    
    var manage_currency = "Manage Currency"
    var create_new_wallet = "Create new wallet"
    var create_new_wallet_desc = "Using mnemonics to generate new wallet"
    var create_new_btc_wallet = "Create new BTC wallet"
    var create_new_eth_wallet = "Create new ETH wallet"
    
    var myQRCode = "My QR code"
    
    var chat_room_has_blocked = "Chat room is blocked"
    
    var chat_room_receipt = "Receipt"
    var chat_room_image = "Image"
    var chat_room_camera = "Camera"
    
    var copied_successfully = "Copied sucessfully"
    
    var secret_chat_on = "Secret chat is open"
    
    var accept_request = "Accept"
    var reject_request = "Reject"
    
    var trans_success = "Transaction Success"
    var trans_failed = "Transaction Failed"
    
    var group_qr_code = "Group QR Code"
    var account = "Account"
    var assetDetail_receive = "Receive"
    
    var alert_cant_join_pvt_group = "Can't join this group because this is a private group"
    var group_join_success = "Group joined successfully"

    var group_name = "Group Name"
    var group_type = "Group Type"
 
    var public_group = "Public"
    var private_group = "Private"
    var post_message = "Post Message"
    var admin_only = "Admin"
    var all_members = "Members"
    var group_description = "Group Description"
    
    var show_qr_code =  "Display QR code"
    
    var group_member_new = "New"
    var group_member_invited = "Invite"
    
    func group_text_too_long(_ args: String...) -> String { return String.init(format: "The text is too long (%@)/%@", arguments: args) }
    
    var members_invitation_successfull = "Members invited successfully"
    var transfer_all_amount = "Transfer all coins(exclude miner fee)"
    var invalid_mnemonic_phrase = "Invalid mnemonic phrase"
    
    var image_saved_success = "Image saved to album"
    var exists = "Existing"
}
