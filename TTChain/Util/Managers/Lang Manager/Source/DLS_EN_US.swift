import Foundation

struct DLS_EN_US: DLS {
    var g_alert_title: String = "Please confirm entered contant "
    var strValidate_error_mnemonic_with_space: String = "The mnemonic has an incorrect format"
    
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
    var g_something_went_wrong = "Something went wrong. Please try again."
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
    var lang_zh_cn = "簡體中文"
    var lang_zh_tw = "繁體中文"
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
    var strValidate_field_pwdHint = "Password hint message"
    var strValidate_field_pwdHintSame = "Password and password hint can\'t be the same"
    var strValidate_field_addressInvalid = "Please confirm the receipt address format"
    var fee_cic_per_byte = "cic/b"
    var fee_eth_gas_price = "gas price"
    var fee_sat_per_byte = "sat/b"
    var fee_eth_gwei = "gwei"
    var fee_ether = "ether"
    var intro_title_page_one = "Welcome !\nWelcome to Infireum"
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
    var tab_chat = "Chat"
    var tab_alert_newSystemWallet_title = "Infireum supports a new wallets!"
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
    var qrcode_btn_select_photo = "Select Photo"
    var qrcode_actionSheet_pickChainTypeToImport_title = "Please select the type of wallet to import"
    var qrcode_actionSheet_pickChainTypeToImport_content = "Please select the same wallet type as in the original scan to avoid restoring imported assets"
    func qrcode_actionSheet_btn_mainCoinType(_ args: String...) -> String { return String.init(format: "%@ wallet", arguments: args) }
    var login_label_title = "Create your first digital identity\nEasily manage multi-chain wallets"
    var login_btn_create = "Create identity"
    var login_label_desc = "Multi-chain wallet will be created automatically when creating identity"
    var login_btn_restore = "Restore identity"
    var login_label_or = "Or"
    var login_actionsheet_restore_mnemonic = "Retrieve via Mnemonics"
    var login_actionsheet_restore_qrcode = "Retrieve via QR Code"
    var login_alert_title_camera_permission_denied = "Permissions have not been opened"
    var login_alert_content_camera_permission_denied = "You have not enabled access to the album. Please go to Settings to enable access to save QR Code."
    var login_alert_title_import_qrcode_failed = "Wallet import failed"
    var login_alert_content_import_qrcode_failed = "Your identity wallet could not be imported. Please try a different QR CODE"
    var createID_title = "Create identity"
    var createID_hud_creating = "Creating..."
    var createID_btn_create = "Create"
    var createID_placeholder_name = "Identity name"
    var createID_placeholder_password = "Password"
    var createID_placeholder_confirmPassword = "Confirm Password"
    var createID_placeholder_passwordNote = "Password Hint"
    var createID_error_pwd_title = "Incorrect password"
    var createID_error_confirmPwd_title = "Incorrect confirm password"
    var createID_error_identityName_title = "Incorrect identity name"
    var createID_error_pwdHint_title = "Incorrect password hint"
    var backupWallet_title = "Backup wallet"
    var backupWallet_label_mainNote = "Asset security cannot be guaranteed without proper backup. After deleting the app or wallet, you need your back up files to restore wallet."
    var backupWallet_label_subNote = "Warning: Do not disclose your QR code to anyone."
    var backupWallet_btn_backupMnemonic = "Recovery Seed Phrase"
    var backupMnemonic_title = "Recovery Seed Phrase"
    var backupMnemonic_desc = "Important: This 12-word phrase is vital for account recovery. Please make sure that you note down this seed phrase, as you will not be able to recover your account nor digital assets stored without it. Infireum takes no responsibility for lost assets due to the loss of your seed phrase.\n\nWarning: To prevent hacking, users are strongly advised against storing your recovery seed phrase in any digital form."
    var sortMnemonic_title = "Sorting mnemonic"
    var sortMnemonic_desc = "Please click on the mnemonic in order to confirm that you are backing up correctly."
    var sortMnemonic_error_mnemonic_wrong_order = "Incorrect mnemonic order"
    var sortMnemonic_error_create_user_fail = "User creation failed"
    var sortMnemonic_error_create_wallet_fail = "Wallet creation failed"
    var restoreIdentity_label_settingPwd = "Set password"
    var restoreIdentity_placeholder_walletPwd = "Wallet password"
    var restoreIdentity_placeholder_walletConfirmPwd = "Reenter password"
    var restoreIdentity_placeholder_mnemonic = "Enter mnemonics, separated by spaces"
    var restoreIdentity_placeholder_pwdHint = "Password hint information"
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
    var restoreIdentity_error_pwdHint_title = "Incorrect password hint"
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
    var walletManage_label_pwdHint = "Password hint message"
    var walletManage_label_exportPKey = "Export private key"
    var walletManage_error_pwd = "Incorrect password"
    var walletManage_alert_exportPKey_title = "Export private key"
    var walletManage_alert_exportPKey_content = "Please enter password"
    var walletManage_alert_placeholder_exportPKey_pwd = "Password"
    var walletManage_alert_changeWalletName_title = "Change wallet name"
    var walletManage_alert_changeWalletName_content = "Please enter the name of the wallet you want to replace"
    var walletManage_error_walletName_invalidFormat_title = "Incorrect wallet name format"
    var walletManage_alert_wallet_name_changed_title = "Wallet name changed"
    var walletManage_alert_wallet_name_changed_message = "Wallet name will be updated to the new name"
    
    var walletManage_alert_placeholder_walletName_char_range = "1-30 characters, please do not leave blank at the beginning and end"
    var walletManage_btn_delete_wallet = "Delete wallet"
    var walletManage_alert_title_delete_wallet = "Delete wallet"
    var pwdHint_title = "Password hint message"
    var pwdHint_hud_updating = "Updating"
    var pwdHint_hud_updated = "Updated"
    var exportPKey_title = "Export private key"
    var exportPKey_tab_privateKey = "Private key"
    var exportPKey_tab_qrcode = "QR code"
    var exportPKey_label_offline_save = "Do Not Save Online"
    var exportPKey_label_offline_save_message = "Please do not save the Private Key to your email, notepad, cloud, chat etc. as it would compromise the security of your assets."
    var exportPKey_label_dont_trans_by_internet = "Do Not Transmit Online"
    var exportPKey_label_dont_trans_by_internet_message = "Please make sure that your Private Key is not sent over the internet. Leaving a copy of your Private Key online increases the risk of it being acquired by malicious actors who will be able to access all the assets in this wallet. It is recommended to scan your QR instead."
    var exportPKey_label_pwd_manage_tool_save = "Password Management Tool"
    var exportPKey_label_pwd_manage_tool_save_message = "It is recommended that you use our password management tool to ensure that your account remains accessible even if you forget your password."
    var exportPKey_label_provide_scan_directly_only = "Direct Scanning Only"
    var exportPKey_label_provide_scan_directly_only_message = "Please do not save the QR code by taking a photograph or screenshot. The QR code should only be scanned in a secure environment to ensure the safety of your assets."
    var exportPKey_label_use_in_save_environment = "Ensure the Safety of your Environment"
    var exportPKey_label_use_in_save_environment_message = "Please make sure there are no other persons and/or cameras around before using your QR code. Once your QR code is acquired by others, your assets are no longer secure."
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
    var assetDetail_label_tx_go_check = "Check TXID here"
    func withdrawal_title(_ args: String...) -> String { return String.init(format: "%@ transfer", arguments: args) }
    var withdrawal_btn_nextstep = "Next step"
    var withdrawal_error_same_address_content = "The receipt address must not be the same as the payment address"
    func withdrawal_error_asset_insuffient_content(_ args: String...) -> String { return String.init(format: "Insufficient balance: \nYour asset %@ %@\nTransfer amount %@ %@", arguments: args) }
    func withdrawal_error_asset_insuffient_for_same_asset_fee_content(_ args: String...) -> String { return String.init(format: "Insufficient balance: Unable to pay the handling fee\nYour assets: %@ %@\nTransfer costs: (transfer)%@ + (handling fee)%@ ", arguments: args) }
    func withdrawal_error_fee_insufficient(_ args: String...) -> String { return String.init(format: "Insufficient balance: Unable to pay %@ handling fee\n handling fee: %@ %@\n holding amount: %@ %@", arguments: args) }
    func withdrawal_error_fee_rate_too_low(_ args: String...) -> String { return String.init(format: "%@ is too low, it is recommended to be higher than %@ %@", arguments: args) }
    func withdrawal_error_unknown(_ args: String...) -> String { return String.init(format: "Unknown verification error\n system message: %@", arguments: args) }
    func withdrawal_label_assetAmt(_ args: String...) -> String { return String.init(format: "%@ Balance: %@", arguments: args) }
    var withdrawal_placeholder_withdrawalAmt = "Enter amount"
    var withdrawal_label_toAddr = "Receipt address"
    var withdrawal_btn_common_used_addr = "Commonly Used Addresses"
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
    var lightningTx_title = "Lightning Transfer"
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
    var ltTx_changeToAddress_btn_common_used_addr = "Addresses"
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
    var me_label_common_used_addr = "Addresses"
    var me_label_settings = "User settings"
    var me_label_qa = "QA"
    var me_label_agreement = "Member agreement"
    var me_label_check_update = "Check for version updates"
    var me_hud_checking = "Checking"
    var me_alert_already_latest_version_title = "You have the Latest version."
    func me_alert_version_content(_ args: String...) -> String { return String.init(format: "Current version: %@\nLatest version: %@", arguments: args) }
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
    var settings_label_currencyUnit = "Currency"
    var settings_alert_verify_to_turn_off_functionality = "Verify to turn off function"
    var changePrefFiat_title = "Currency"
    var changePrefFiat_btn_save = "Save"
    
    var settings_notification_title:String = "Message Notifications"
    var setting_export_key_title:String = "Export"
    var setting_export_btc_wallet_title:String  = "Bitcoin Wallet"
    var setting_export_eth_wallet_title:String = "Ethereum Wallet"

    var setting_delete_account_title:String = "Delete Account"
    
    var switch_on_notification_setting = "Switch on notifications"
    var switch_off_notification_setting = "Switch on notifications"

    
    var account_setting_title = "Account Setting"
    var basic_setting_title = "Basic Setting"
    var follow_us_title = "Follow Us"
    var others_title = "Others"
    var system_settings_title:String = "System Setting"
    var wallet_settings_title:String = "Wallet Settings"

    var account_safety_settings_title:String = "Security Setting"
    var addressbook_title = "Addresses"
    var addressbook_label_empty_addressbook = "No history"
    var abInfo_title = "Contact information"
    func abInfo_label_address_type(_ args: String...) -> String { return String.init(format: "%@ address", arguments: args) }
    var abInfo_btn_edit = "Edit"
    var abInfo_label_name = "Name"
    var abInfo_label_note = "Note (optional)"
    var ab_update_title_create = "Add new wallet address"
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
    var ab_update_label_createAddress = "Create address"
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
    var hot_group_sub = "Amazing groups you like"

    var media =  "News"
    var media_sub = "Latest announcements and updates"
    
    var dapp = "Decentralised Applications"
    var dapp_sub = "Hottest dApps on the block"
    
    var blockchain_explorer = "Block Explorer"
    var blockchain_explorer_sub = "Explore blocks, transactions, hashrates and more!"

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
    
    var tab_explorer = "Discover"
    var tab_social = "Social"
    var tab_setting = "Setting"
    
    var contact_title = "Contact"
    var contact_individual = "Individual"
    var contact_group = "Group"

    var stable_coin = "InBIQ"
    var sto_coin = "Listed Coin"
    var delete = "Delete"
    var forward = "Forward"
    var message_action = "Message Action"
    
    var select_wallet_address = "Please select wallet address"
    var backupChat_alert_password_mismatch = "Wallet account does not match the backup password"

    var copy_file_url = "Copy file url"
    var send_file_title = "File"
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
    var chat_room_audio_call = "Audio Call"
    var chat_room_video_call = "Video Call"
    var chat_room_red_env = "Red Env"
    var copied_successfully = "Copied sucessfully"
    
    var secret_chat_on = "Secret chat is open"
    
    var accept_request = "Accept"
    var reject_request = "Reject"
    
    var trans_success = "Transaction Success"
    var trans_failed = "Transaction Failed"
    
    var group_qr_code = "Group QR Code"
    var account = "Account"
    var assetDetail_receive = "Deposit"
    
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
    var display_pvt_key_btn_title = "Display private key"
    var precaution_before_exporting_msg = "Warning"
    
    var group_member_new = "New"
    var group_member_invited = "Invite"
    
    func group_text_too_long(_ args: String...) -> String { return String.init(format: "The text is too long (%@)/%@", arguments: args) }
    
    var members_invitation_successfull = "Members invited successfully"
    var transfer_all_amount = "Total Transfer "
    var invalid_mnemonic_phrase = "Invalid mnemonic phrase"
    
    var image_saved_success = "Image saved to album"
    var exists = "Existing"
    
    var access_denied_mic = "You have denied access to mic. Please go to setting and give access to mic to perform this functionality."
    
    var recording_failed = "Recording Failed"
    
    var record_audio_start_button = "Press to record audio"
    var record_audio_stop_to_send_button = "Release to send audio"

    var red_env_send_balance: String = "Balance"
    
    var red_env_send_total_amount: String = "Total Amount"
    
    var red_env_send_enter_amount: String = "Enter Amount"
    
    var red_env_send_number_title = "Number "
    func red_env_send_number_of_members(_ args: String...) -> String { return String.init(format: "(%@ members in the group)", arguments: args) }
    
    var red_env_send_number_of_red_env: String  = "Number of Red Envelopes"
    
    var red_env_send_dist_rule: String = "Distribution Rule"
    
    var red_env_send_divide: String = "Divide"
    
    var red_env_send_random: String = "Random"
    
    var red_env_send_comment: String = "Comment"
    var red_env_comment_placeholder: String = "Write some auspicious words on the red envelope!"
    var red_env_send_notice_one: String = " *Notice that every transaction would charge miner fee"
    
    var red_env_send_notice_two: String = "*If receiver do not retrieve red envelopes by the time limit, the remain amount will automatically send back to sender"
    
    var red_env_send_currency: String = "Currency"
    
    var red_env_send_time_limit:String = "Time Limit"
    var red_env_send_reservationTime:String = "Reservation Time"
    
    var red_env_send_day = "day"
    var red_env_send_hour = "hour"
    var red_env_send_minute = "minutes"
    var red_env_send_infinite = "Infinite"
    
    var red_env_send_please_select = "Please select"
    var red_env_money_sent:String = "Money Sent"
    var red_env_waiting_to_send:String = "Waiting to send"
    func red_env_amount_received(_ args:String ...) -> String {return String.init(format: "%@/%@ received",arguments: args) }
    func red_env_transfer_alert_message(_ args :String ...) -> String {return String.init(format: "You will insert the money into the red envelope, please enter the wallet password (additional miner fee %@%@)", arguments: args)}
    
    var red_env_send_sent_successfully = "Congratulations, the red envelope is credited"
    func red_env_status_waiting_for_money(_ args:String ...) -> String {return String.init(format: "Waiting for %@ to put money in red envelope", arguments: args)}
    var red_evn_send_by_me = "I sent the Red Envelope"
    func red_env_sent_by_sender(_ args:String ...) -> String {return String.init(format: "%@'s Red Envelope", arguments: args)}
    var red_env_expired = "Available time expired"
    func red_env_money_sent_already_message(_ args:String ...) -> String {return String.init(format: "Already sent money in red envelope to %@. Do you want to give more lucky money", arguments: args)}
    func red_env_money_sent_to_user_message(_ args:String ...) -> String {return String.init(format: "Money sent to %@", arguments: args)}

    var view_red_envelope:String = "View Red Envelope"
    
    var red_env_view_record:String = "View Red Envelope record"
    var red_env_view_record_substring:String = "View"

    var red_env_receive_expired_message:String = "You are too late! Red envelope has expired."
    var red_env_receive_no_remaining_envelopes:String = "You are too late! There are no red envelopes remaining."
    var red_env_receive_status_not_yet_received:String  = "Not yet received"
    var red_env_receive_status_received:String  = "Already received"
    var red_env_send_confirm_transfer:String = "Confirm red envelope transfer"

    var red_env_send_records:String = "Red envelope sent records"
    var red_env_history_receive:String = "Receive Records"
    var red_env_history_sent:String = "Sent Records"
    
    var red_evn_history_title:String = "Red envelope record"
    
    var red_env_history_waiting_for_collection:String = "Waiting for Collection"
    var red_env_history_waiting_for_money:String  = "Waiting for Transfer"
    var red_env_history_money_transfered:String  = "Transfer complete"
    
    
    
    var receipt_receiving_currency:String = "Receiving Currency"
    var receiving_amount:String = "Collection Amount"
    
    var receive_red_env_no_wallet_found = "Can't find a wallet that supports this coin"
    var profile_edit_empty_name_error = "Please enter a valid name"
    
    var red_env_history_from_title:String = "From"
    var red_env_history_create_time_title:String = "Red Envelope Create Time"
    var red_env_history_receive_time_title:String = "Red Envelope Received Time"
    var red_env_history_deposit_time_title:String = "Red Envelope Deposit Time"
    
    var chat_keyboard_placeholder:String = "Write something here"
    var chat_recovery_password_successful:String = "Password set successfully"
    
    var chat_history_delete_chat_title:String = "Delete Chat"
    var chat_history_delete_chat_message:String = "Are you sure you want to delete all messages from this chat?"

    var receipt_request_error_string:String = "Please select a coin and enter the amount"
    
    var use_edited_image_title:String = "Use edited image"
    var use_original_image_title:String = "Use original image"
    var create_red_env_title:String = "Create Red Envelope"
    
    var voice_message_string:String = "Voice"
    var image_message_string:String = "Image"
    var call_message_string:String = "Voice Call"
    var receipt_message_string:String = "Receipt"
    
    var download_file_title:String = "Download File"
    var file_download_successful_message:String = "File Downloaded successfully"

    var lightning_receipt_btn_title:String = "Lightning Deposit"
    var transaction_details_btn_title:String = "Transaction Details"
    
    var lightning_payment_title:String = "Lightning Transfer"

    var light_withdraw_btn_title:String = "Withdraw"
    var light_deposit_btn_title:String = "Deposit"
    var transfer_amount_title:String = "Transfer Amount"

    var insufficient_unspend_error_msg:String = "The transferable balance is insufficient. If it is USDT transfer, please check if the BTC wallet balance is enough to pay the miner fee."

    var transfer_note_placeholder:String = "Please enter a description within 20 characters"
    
    var payment_wallet:String = "Payment Wallet"
    
    var transfer_all_coin_ttn_address:String = "Transfer all coins"
    
    var forward_message_title_string :String = "Select Messages"
    
    var light_withdrawal_placeholder_toAddr : String  = "Please enter IFRC address or scan the QR code"
    
    var alert_post_message_restriction = "Only administrators can post messages in this group"
    
    var total_assets_title = "Total assets"
    var asset_management_btn_title :String = "Asset Management"
    
    var wallet_type_btn_main_chain:String  = "Digital Assets"
    
    var total_amount_transfer_info_alert_title:String = "What is the total amount of transfer?"
    var total_amount_transfer_info_alert_message:String  = "After clicking this option, the system will automatically transfer all the coins in the wallet without having to calculate the input. The system will also automatically deduct the selected miner's fees."

    var transfer_success_check_record_message = "Your transfer request has been successful. You can check the status of this transaction by going to the transfer record."
    
    var check_record_btn_title = "View history"
    
    var tx_number_title = "Transaction Number"
    
    var tx_block_number_title = "Block numbers"
    
    func tx_record_detail_title(_ args: String...) -> String {
        return String.init(format: "%@ transfer record", arguments: args)
    }

    var chat_msg_tab_title:String = "Message"
    var loading_please_wait_label:String  = "System loading, please wait"
    
    
    var register_new_account_btn_title = "Sign Up"
    
    var register_account_msg_label_login = "An e-wallet will automatically be created once you set up a new account"
    
    var original_account_login = "Log In"

    var transfer_back_button_title = "Revise"
    var import_key_string = "Import"
 
    var add_wallet_password_warning_one = "The Infireum team will not save your wallet password, nor will you be able to assist in the recovery if you lose your wallet password. Please set a password and password prompt."

    var add_wallet_password_warning_two = "If you forget the password, you will lose the assets in your wallet. Please pay special attention."
    
    var new_wallet_name = "Please name your new wallet"
    
    var chat_nick_name = "Chat nick name"
    
    var personal_information = "Personal Information"
    
    var receipt_request_warning_label = "When sending a payment request, the miner fee will be paid by the payer."

    var receipt_request_coin_address_placeholder = "Please select the coin first. The system will detect the address"
    
    var group_info_label_title_string:String = "Group Announcement"
    
    var group_setting_title:String = "Group Settings"
    var group_member_mgmgt_title:String = "Member Management"
    
    var group_invite_member_title:String = "Invite members"
    
    var group_info_title:String = "Community Information"

    var backup_qrcode_message_label = "This QR code grants access to all Infireum wallets, chat history, account identity, and will allow you to recover your account. It is recommended to keep a physical copy of your QR code. It is always advised to have multiple copies of your recovery phrase and store it in multiple locations to prevent loss from calamities like floods, earthquake, fire, etc."
    
    var back_up_skip_warning_msg = "Backup account action code is very important for you to maintain asset security and restore account in the future. If you lose your phone or have accidents caused by a backup account, you will never be able to retrieve it."
    
    var backup_skip_msg_title = "Are you sure you want to skip it?"
    
    var create_identity_username_placeholder = "Use letters and numbers, need 8 characters or more"
    
    var create_identity_password_placeholder = "Password"
    
    var create_identity_reenter_password_placeholder = "Re-enter password"
    
    var create_identity_password_reminder_placeholder = "Password hint message"
    var create_identity_privacy_policy_btn_title = "I agree 《InfiniteChain Privacy Policy》"
    
    var agree_bnt_title:String = "Agree"
    
    var sign_in_using_mnemonic_title = "Login account using Mnemonics"
    
    var sign_in_mnemonic_subtitle = "Enter mnemonics, a total of 12 words"
    
    var new_wallet_created_msg = "New wallet created"
    
    var new_wallet_imported_msg = "The wallet has been successfully imported"
    var wallet_import_success_subtitle_msg = "You can start using this wallet feature"

    var chat_notifications_turn_off_title = "Turn off notification"
    
    var chat_community_mgmt_label = "Community Management"
    var only_admin_post_title = "Only admins can post"
    var imported_wallets = "Imporeted Wallets"
    var login_success = "You have successfully logged in"
    var welcome_back = "Welcome Back"
}

