//
//  AgreementMeViewController.swift
//  OfflineWallet
//
//  Created by Patato on 2018/10/2.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
import LocalAuthentication

final class AgreementMeViewController: KLModuleViewController, KLVMVC {
    
    typealias ViewModel = AgreementMeViewModel
    typealias Constructor = Config
    var viewModel: AgreementMeViewModel!
    struct Config {
        let identity: Identity
        let text:String
        let title:String
    }
    var bag: DisposeBag = DisposeBag.init()
    
    
    private func createContentHTML() -> String {
        return "<p>《Hope Seed隐私政策》<br />最近更新于：2018年10月05日</p><p>尊敬的用户：<br />此版本为公測版本（beta \(C.Application.version)），若任何问题均为請自行評估風險，本公司一概不负担任何賠償责任，再次与您告知此版本仅供测试，也請提供給我們您的寶貴意見。</p><p>恩智区块链科技有限公司（以下简称“恩智”或“我们”）尊重并保护用户（以下简称“您”或“用户”）的隐私，您使用Hope Seed时，恩智将按照本隐私政策（以下简称“本政策”）收集、使用您的个人信息。</p><p>建议您在使用本产品（以下简称“Hope Seed”）之前仔细阅读并理解本政策全部内容, 针对免责声明等条款在内的重要信息将以加粗的形式体现。本政策有关关键词定义与恩智《Hope Seed服务协议》保持一致。</p><p>本政策可由恩智在线随时更新，更新后的政策一旦公布即代替原来的政策，如果您不接受修改后的条款，请立即停止使用Hope Seed，您继续使用Hope Seed将被视为接受修改后的政策。经修改的政策一经在Hope Seed上公布，立即自动生效。</p><p>您知悉本政策及其他有关规定适用于Hope Seed及Hope Seed上恩智所自主拥有的DApp。</p><p>一、 我们收集您的哪些信息<br />请您知悉，我们收集您的以下信息是出于满足您在Hope Seed服务需要的目的，且我们十分重视对您隐私的保护。在我们收集您的信息时，将严格遵守“合法、正当、必要”的原则。且您知悉，若您不提供我们服务所需的相关信息，您在Hope Seed的服务体验可能因此而受到影响。</p><p>1. 我们将收集您的移动设备信息、操作记录、交易记录、钱包地址等个人信息。<br />2. 为满足您的特定服务需求，我们将收集您的姓名、银行卡号、手机号码、邮件地址等信息。<br />3. 您知悉：您在Hope Seed 上的钱包密码、私钥、助记词、并不存储或同步至恩智服务器。恩智不提供找回您的钱包密码、私钥、助记词、的服务。<br />4. 除上述内容之外，您知悉在您使用Hope Seed特定功能时，我们将在收集您的个人信息前向您作出特别提示，要求向您收集更多的个人信息。如您选择不同意，则视为您放弃使用Hope Seed该特定功能。<br />5. 当您跳转到第三方DApp后，第三方DApp会向您收集个人信息。Hope Seed不持有第三方DApp向您收集的个人信息。<br />6. 在法律法规允许的范围内，恩智可能会在以下情形中收集并使用您的个人信息无需征得您的授权同意：</p><p>（1） 与国家安全、国防安全有关的；<br />（2） 与公共安全、公共卫生、重大公共利益有关的；<br />（3） 与犯罪侦查、起诉、审判和判决执行等有关的；<br />（4） 所收集的个人信息是您自行向社会公众公开的；<br />（5） 从合法公开披露的信息中收集您的个人信息，如合法的新闻报道，政府信息公开等渠道；<br />（6） 用于维护服务的安全和合规所必需的，例如发现、处理产品和服务的故障；<br />（7） 法律法规规定的其他情形。<br />7. 我们收集信息的方式如下：</p><p>（1） 您向我们提供信息。例如，您在“个人中心”页面中填写姓名、手机号码或银行卡号，或在反馈问题时提供邮件地址，或在使用我们的特定服务时，您额外向我们提供。<br />（2） 我们在您使用Hope Seed的过程中获取信息，包括您移动设备信息以及您对Hope Seed的操作记录等信息；<br />（3） 我们通过区块链系统，拷贝您全部或部分的交易记录。但交易记录以区块链系统的记载为准。<br />二、 我们如何使用您的信息<br />1. 我们通过您移动设备的唯一序列号，确认您与您的钱包的对应关系。<br />2. 我们将向您及时发送重要通知，如软件更新、服务协议及本政策条款的变更。<br />3. 我们在Hope Seed的“系统设置”中为您提供“指纹登录”选项，让您方便且更安全地管理您的数字代币。<br />4. 我们通过收集您公开的钱包地址和提供的移动设备信息来处理您向我们提交的反馈。<br />5. 我们收集您的个人信息进行恩智内部审计、数据分析和研究等，以期不断提升我们的服务水平。<br />6. 依照《Hope Seed服务协议》及恩智其他有关规定，恩智将利用用户信息对用户的使用行为进行管理及处理。<br />7. 法律法规规定及与监管机构配合的要求。<br />三、 您如何控制自己的信息<br />您在Hope Seed中拥有以下对您个人信息自主控制权：</p><p>1. 您可以通过同步钱包的方式，将您的其他钱包导入Hope Seed中，或者将您在Hope Seed的钱包导入到其他数字代币管理钱包中。Hope Seed将向您显示导入钱包的信息。<br />2. 您知悉您可以通过“资产”版块内容修改您的数字代币种类、进行转账及收款等活动。<br />3. 您知悉在Hope Seed“我”的版块您可以自由选择进行如下操作：</p><p>（1） 在“联系人”中，您可以随时查看并修改您的“联系人”；<br />（2） 在“系统设置”中，您可以选择不开启“指纹登录”选项，即您可以选择不使用苹果公司提供的Touch ID验证服务；<br />（3） 在“个人中心”中，您并不需要提供自己的姓名、手机号码、银行卡等信息，但当您使用特定服务时，您需要提供以上信息；<br />（4） 在“提交反馈”中，您可以随时向我们提出您对Hope Seed问题及改进建议，我们将非常乐意与您沟通并积极改进我们的服务。<br />4. 您知悉当我们出于特定目的向您收集信息时，我们会提前给予您通知，您有权选择拒绝。但同时您知悉，当您选择拒绝提供有关信息时，即表示您放弃使用Hope Seed的有关服务。<br />5. 您知悉，您及我们对于您交易记录是否公开并没有控制权，因为基于区块链交易系统的开源属性，您的交易记录在整个区块链系统中公开透明。<br />6. 您知悉当您使用Hope Seed的功能跳转至第三方DApp之后，我们的《Hope Seed服务协议》、《Hope Seed隐私政策》将不再适用，针对您在第三方DApp上对您个人信息的控制权问题，我们建议您在使用第三方DApp之前详细阅读并了解其隐私规则和有关用户服务协议等内容。<br />7. 您有权要求我们更新、更改、删除您的有关信息。<br />8. 您知悉我们可以根据本政策第一条第6款的要求收集您的信息而无需获得您的授权同意。<br />四、 我们可能分享或传输您的信息<br />1. 恩智在中华人民共和国境内收集和产生的用户个人信息将存储在中华人民共和国境内的服务器上。若恩智确需向境外传输您的个人信息，将在事前获得您的授权，且按照有关法律法规政策的要求进行跨境数据传输，并对您的个人信息履行保密义务。<br />2. 未经您事先同意，恩智不会将您的个人信息向任何第三方共享或转让，但以下情况除外：</p><p>（1） 事先获得您明确的同意或授权；<br />（2） 所收集的个人信息是您自行向社会公众公开的；<br />（3） 所收集的个人信息系从合法公开披露的信息中收集，如合法的新闻报道，政府信息公开等渠道；<br />（4） 与恩智的关联方共享，我们只会共享必要的用户信息，且受本隐私条款中所声明的目的的约束；<br />（5） 根据适用的法律法规、法律程序的要求、行政机关或司法机关的要求进行提供；<br />（6） 在涉及合并、收购时，如涉及到个人信息转让，恩智将要求个人信息接收方继续接受本政策的约束。<br />五、 我们如何保护您的信息<br />1. 如恩智停止运营，恩智将及时停止继续收集您个人信息的活动，将停止运营的通知公告在Hope Seed上，并对所持有的您的个人信息在合理期限内进行删除或匿名化处理。<br />2. 为了保护您的个人信息，恩智将采取数据安全技术措施，提升内部合规水平，增加内部员工信息安全培训，并对相关数据设置安全访问权限等方式安全保护您的隐私信息。<br />3. 我们将在Hope Seed“消息中心”中向您发送有关信息安全的消息，并不时在Hope Seed“帮助中心”版块更新钱包使用及信息保护的资料，供您参考。<br />六、 对未成年人的保护<br />我们对保护未满18周岁的未成年人做出如下特别约定：</p><p>1. 未成年人应当在父母或监护人指导下使用恩智相关服务。<br />2. 我们建议未成年人的父母和监护人应当在阅读本政策、《Hope Seed服务协议》及我们的其他有关规则的前提下，指导未成年人使用Hope Seed。<br />3. Hope Seed将根据国家相关法律法规的规定保护未成年人的个人信息的保密性及安全性。<br />七、 免责声明<br />1. 请您注意，您通过Hope Seed接入第三方DApp后，将适用该第三方DApp发布的隐私政策。该第三方DApp对您个人信息的收集和使用不为恩智所控制，也不受本政策的约束。恩智无法保证第三方DApp一定会按照恩智的要求采取个人信息保护措施。<br />2. 您应审慎选择和使用第三方DApp，并妥善保护好您的个人信息，恩智对其他第三方DApp的隐私保护不负任何责任。<br />3. 恩智将在现有技术水平条件下尽可能采取合理的安全措施来保护您的个人信息，以避免信息的泄露、篡改或者毁损。恩智系利用无线方式传输数据，因此，恩智无法确保通过无线网络传输数据的隐私性和安全性。<br />八、 其他<br />1. 如您是中华人民共和国以外的用户，您需全面了解并遵守您所在司法辖区与使用恩智服务所有相关法律、法规及规则。<br />2. 您在使用恩智服务过程中，如遇到任何有关个人信息使用的问题，您可以通过在Hope Seed提交反馈等方式联系我们。<br />3. 您可以在Hope Seed中查看本政策及恩智其他服务规则。我们鼓励您在每次访问Hope Seed时都查阅恩智的服务协议及隐私政策。<br />4. 本政策的任何译文版本仅为方便用户而提供，无意对本政策的条款进行修改。如果本政策的中文版本与非中文版本之间存在冲突，应以中文版本为准。<br />5. 本政策自2018年8月15日起适用。<br />本政策未尽事宜，您需遵守恩智不时更新的公告及相关规则。</p><p>恩智区块链科技有限公司</p>"
    }
    
    var content: NSAttributedString {
        return try! NSAttributedString.init(
            data: createContentHTML().data(using: .utf8)!,
            options: [
                .documentType :
                    NSAttributedString.DocumentType.html,
                .characterEncoding : String.Encoding.utf8.rawValue],
            documentAttributes: nil
        )
    }
    
    func config(constructor: AgreementMeViewController.Config) {
        print(view)
        view.layoutIfNeeded()
        viewModel = ViewModel.init(input: AgreementMeViewModel.InputSource(identity: constructor.identity,content:constructor.text),
                                   output: ())
        self.title = constructor.title
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    
    @IBOutlet weak var agreementLabel: UILabel!
    
    override func renderLang(_ lang: Lang) {
//        let dls = lang.dls
//        title = dls.me_label_agreement
        agreementLabel.attributedText = NSAttributedString.init(string: viewModel.input.content)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        changeLeftBarButtonToDismissToRoot(tintColor: palette.nav_item_1, image: #imageLiteral(resourceName: "btn_previous_light"), title: nil)
        changeNavShadowVisibility(true)
        view.backgroundColor = palette.bgView_sub
    }
    
    override func viewDidLoad() {
         super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
