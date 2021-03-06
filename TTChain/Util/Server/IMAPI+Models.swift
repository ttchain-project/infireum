//
//  IMAPI+Models.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/24.
//  Copyright © 2018 gib. All rights reserved.
//
import Foundation
import Moya
import SwiftyJSON
import RxSwift
import SwiftMoment
import RxCocoa

struct Tokens{
    static func getUID() -> String {
        guard let imUser = IMUserManager.manager.userModel.value else {
            return ""
        }
        return imUser.uID
    }
    static func getAuthToken() -> String {
        
        guard let rocketChatUser = RocketChatManager.manager.rocketChatUser.value else {
            return ""
        }
        return rocketChatUser.authToken
    }
    static func getRocketChatUserID() -> String {
        guard let rocketChatUser = RocketChatManager.manager.rocketChatUser.value else {
            return ""
        }
        return rocketChatUser.rocketChatUserId
    }
}

enum IMAPI :KLMoyaAPISet {
    var api: KLMoyaAPIData {
        switch self {
        case .preLogin(let api): return api
        case .createUser(let api): return api
        case .recoverUser(let api): return api
        case .getUserData(let api): return api
        case .updateUserData(let api): return api
        case .getGroupList(let api): return api
        case .getPersonDirectory(let api): return api
        case .sendFriendRequest(let api): return api
        case .respondFriendRequest(let api): return api
        case .respondGroupRequest(let api): return api
        case .setRecoveryPassword(let api): return api
        case .getAllCommunications(let api): return api
        case .destructMessage(let api): return api
        case .getDestructMessageSetting(let api):return api
        case .postMessageSection(let api): return api
        case .getGroupInfo(let api): return api
        case .searchUser(let api): return api
        case .createGroup(let api): return api
        case .groupMembers(let api): return api
        case .updateGroup(let api): return api
        case .deleteGroup(let api): return api
        case .uploadHeadImage(let api): return api
        case .uploadFile(let api): return api
        case .sendMessage(let api): return api
        case .muteRoomNotifications(let api): return api
        case .getRoomNotificationStatus(let api): return api
        case .blockUser(let api): return api
        case .registerJiGuangPush(let api): return api
        case .inAppCall(let api): return api
        case .createRedEnvelope(let api): return api
        case .redEnvelopeInfo(let api):return api
        case .acceptRedEnvelope(let api):return api
        case .promiseRedEnvelopeSent(let api):return api
        case .sendRedEnvelopeHistory(let api):return api
        case .receiveRedEnvelopeHistory(let api):return api
        case .sendCoinRequest(let api):return api
        }
    }
    case preLogin(PreLoginAPI)
    case createUser(CreateUserAPI)
    case recoverUser(RecoverUserAPI)
    case getUserData(GetUserDataAPI)
    case updateUserData(UpdateUserAPI)
    case getGroupList(GetGroupListAPI)
    case getPersonDirectory(GetPersonalDirectoryAPI)
    case sendFriendRequest(SendFriendRequestAPI)
    case respondFriendRequest(RespondFriendRequestAPI)
    case respondGroupRequest(RespondGroupRequestAPI)
    case setRecoveryPassword(SetRecoveryPasswordAPI)
    case getAllCommunications(GetAllCommunicationsAPI)
    case destructMessage(SelfDestructMessageSettingAPI)
    case postMessageSection(PostMessageSectionAPI)
    case getGroupInfo(GetGroupInfoAPI)
    case searchUser(SearchUserAPI)
    case createGroup(CreateGroupAPI)
    case groupMembers(GroupMembersAPI)
    case updateGroup(UpdateGroupAPI)
    case deleteGroup(DeleteGroupAPI)
    case uploadHeadImage(UploadHeadImageAPI)
    case uploadFile(UploadFileAPI)
    case sendMessage(IMSendMessageAPI)
    case sendCoinRequest(IMSendCoinRequestAPI)
    case blockUser(BlockUserAPI)
    case muteRoomNotifications(MuteRoomNotificationAPI)
    case getRoomNotificationStatus(GetRoomNotificationStatusAPI)
    case getDestructMessageSetting(GetSelfDestructingStatusAPI)
    case registerJiGuangPush(JiGuangPushSettingAPI)
    case inAppCall(InAppCallApi)
    case createRedEnvelope(CreateRedEnvelopeAPI)
    case redEnvelopeInfo(RedEnvelopeInfoAPI)
    case acceptRedEnvelope(AcceptRedEnvelopeAPI)
    case promiseRedEnvelopeSent(PromiseRedEnvelopeSentAPI)
    case sendRedEnvelopeHistory(SendRedEnvelopeHistoryAPI)
    case receiveRedEnvelopeHistory(ReceiveRedEnvelopeHistoryAPI)
}

//MARK: - POST /IM/PreLogin -
struct PreLoginAPI : KLMoyaIMAPIData {
    
    let userId:String
    let deviceID: String
    
    var path: String {return "/IM/PreLogin" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "userID" : userId, "deviceID": deviceID ],
            encoding: JSONEncoding.default
        )
    }
    var stub: Data? {return nil}
    
}

struct PreLoginAPIModel:KLJSONMappableMoyaResponse {
    let uID: String
    let status: UserLoginStatus
    init(json: JSON, sourceAPI: PreLoginAPI) throws {
        guard let uID = json["uid"].string,
            let status = json["status"].int,
            let userStatus = UserLoginStatus.init(rawValue: status) else {
                throw GTServerAPIError.noData
        }
        self.uID = uID
        self.status = userStatus
    }
    typealias API = PreLoginAPI
}


//MARK: - POST /IM/CreateUser -

struct CreateUserAPI : KLMoyaIMAPIData {
    
    let userId:String
    let deviceID: String
    let nickName: String
    let headImg: String
    let introduction: String
    
    var path: String {return "/IM/CreateUser" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "userID" : userId,
                          "deviceID": deviceID,
                          "nickName":nickName,
                          "introduction":introduction ],
            encoding: JSONEncoding.default
        )
    }
    var stub: Data? {return nil}
}

struct CreateUserAPIModel:KLJSONMappableMoyaResponse {
    let uID: String
    let status: UserLoginStatus
    init(json: JSON, sourceAPI: CreateUserAPI) throws {
        guard let uID = json["uid"].string,
            let status = json["status"].int,
            let userStatus = UserLoginStatus.init(rawValue: status) else {
                throw GTServerAPIError.noData
        }
        self.uID = uID
        self.status = userStatus
    }
    typealias API = CreateUserAPI
}

//MARK: - POST /IM/UpdaetUser


struct UpdateUserAPI : KLMoyaIMAPIData {
    struct Parameters:Paramenter {
        var uid:String
//        var deviceID: String
        var nickName: String
        var introduction: String
    }
    var path: String {return "/IM/UpdateUser" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: parameters.asDictionary(),
            encoding: JSONEncoding.default
        )
    }
    let parameters : Parameters
    var stub: Data? {return nil}
}

struct UpdateUserAPIModel:KLJSONMappableMoyaResponse {
    var status:Bool
    init(json: JSON, sourceAPI: UpdateUserAPI) throws {
        guard let status = json.bool else {
                throw GTServerAPIError.noData
        }
        self.status = status
    }
    typealias API = UpdateUserAPI
}

//MARK: - POST /IM/RecoveryUser -

struct RecoverUserAPI : KLMoyaIMAPIData {
    
    let userId:String
    let deviceID: String
    let password: String
    
    var path: String {return "/IM/RecoveryUser" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "userID" : userId, "deviceID": deviceID, "recoveryKey": password ],
            encoding: JSONEncoding.default
        )
    }
    var stub: Data? {return nil}
}

struct RecoverUserAPIModel:KLJSONMappableMoyaResponse {
    let uID: String
    let status: UserLoginStatus
    
    init(json: JSON, sourceAPI: RecoverUserAPI) throws {
        guard let uID = json["uid"].string,
            let status = json["status"].int,
            let userStatus = UserLoginStatus.init(rawValue: status) else {
                throw GTServerAPIError.noData
        }
        self.uID = uID
        self.status = userStatus
        
    }
    typealias API = RecoverUserAPI
}

//MARK: - POST /IM/SetRecoveryKey -

struct SetRecoveryPasswordAPI : KLMoyaIMAPIData {
    
    let imUserId:String
    let password: String
    
    var path: String {return "/IM/SetRecoveryKey" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "uid" : imUserId, "recoveryKey": password ],
            encoding: JSONEncoding.default
        )
    }
    var stub: Data? {return nil}
}

struct SetRecoveryPasswordAPIModel:KLJSONMappableMoyaResponse {
    let response: Bool
    
    init(json: JSON, sourceAPI: SetRecoveryPasswordAPI) throws {
        guard let response = json.bool
            else {
                throw GTServerAPIError.noData
        }
        self.response = response
    }
    typealias API = SetRecoveryPasswordAPI
}

//MARK: - GET /IM/GetUserData -


struct GetUserDataAPI : KLMoyaIMAPIData {
    
    let userCode:String
    var path: String {return "/IM/GetUserData" }
    var method: Moya.Method { return .get }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "uid" : userCode ],
            encoding: URLEncoding.default
        )
    }
    var stub: Data? {return nil}
}

struct GetUserDataAPIModel:KLJSONMappableMoyaResponse {
    var nickName: String
    var introduction: String
    var headImg :String
    var status : Int
    init(json: JSON, sourceAPI: GetUserDataAPI) throws {
        guard let nickName = json["nickName"].string,
            let introduction = json["introduction"].string,
            let status = json["status"].int else {
                throw GTServerAPIError.noData
        }
        let headImg = json["headImg"].dictionary
        let headImgM = headImg?["original"]?.string ?? ""

        self.nickName = nickName
        self.introduction = introduction
        self.headImg = headImgM
        self.status = status
    }
    
    typealias API = GetUserDataAPI
}

//MARK: - GET /IM/GetGroupList -

struct GetGroupListAPI : KLMoyaIMAPIData {
    
    let userCode:String
    var path: String {return "/IM/GetGroupList" }
    var method: Moya.Method { return .get }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "uid" : userCode ],
            encoding: URLEncoding.default
        )
    }
    var stub: Data? {return nil}
}

struct GetGroupListAPIModel:KLJSONMappableMoyaResponse {
    
    var groupList = [UserGroupInfoModel]()
    var invitationList = [UserGroupInfoModel]()
    
    init(json: JSON, sourceAPI: GetGroupListAPI) throws {
        guard let groupListdata = json["groupList"].array, let invitationListData = json["invitationList"].array else {
            throw GTServerAPIError.noData
        }
        groupList = groupListdata.compactMap ({ (dict) in
            guard let groupID = dict["groupID"].string,
                let groupOwnerUID = dict["groupOwnerUID"].string,
                let ownerName = dict["ownerName"].string,
                let groupName = dict["groupName"].string,
                let isPrivate = dict["isPrivate"].bool,
                let introduction = dict["introduction"].string,
                let imGroupId = dict ["imGroupID"].string,
                let isPostMsg = dict["isPostMsg"].bool,
                let status = dict["status"].int else {
                    return nil
            }
            let headImg = dict["headImg"].dictionary
            let headImgM = headImg?["small"]?.string ?? ""

            return UserGroupInfoModel.init(groupID: groupID, groupOwnerUID: groupOwnerUID, ownerName: ownerName, status: status, groupName: groupName, isPrivate: isPrivate, introduction: introduction, headImg: headImgM, imGroupId: imGroupId, isPostMsg: isPostMsg)
        })
        
        invitationList = invitationListData.compactMap ({ (dict) in
            guard let groupID = dict["groupID"].string,
                let groupOwnerUID = dict["groupOwnerUID"].string,
                let ownerName = dict["ownerName"].string,
                let groupName = dict["groupName"].string,
                let isPrivate = dict["isPrivate"].bool,
                let introduction = dict["introduction"].string,
                let imGroupId = dict ["imGroupID"].string,
                let isPostMsg = dict["isPostMsg"].bool,
                let status = dict["status"].int else {
                    return nil
            }
            let headImg = dict["headImg"].dictionary
            let headImgM = headImg?["small"]?.string ?? ""

            return UserGroupInfoModel.init(groupID: groupID, groupOwnerUID: groupOwnerUID, ownerName: ownerName, status: status, groupName: groupName, isPrivate: isPrivate, introduction: introduction, headImg: headImgM, imGroupId: imGroupId, isPostMsg: isPostMsg)
        })
    }
    typealias API = GetGroupListAPI
}

//MARK: - GET /IM/personaldirectory -

struct GetPersonalDirectoryAPI : KLMoyaIMAPIData {
    
    let userCode:String
    var path: String {return "/IM/personaldirectory" }
    var method: Moya.Method { return .get }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "uid" : userCode ],
            encoding: URLEncoding.default
        )
    }
    var stub: Data? {return nil}
}

struct GetPersonalDirectoryAPIModel:KLJSONMappableMoyaResponse {
    
    var personalDirectoryModel : MemberPersonalChatAndGroupsModel
    
    init(json: JSON, sourceAPI: GetPersonalDirectoryAPI) throws {
        guard let invitationList = json["invitationList"].array, let friendList = json["friendList"].array else {
            throw GTServerAPIError.noData
        }
        let inviationListArray : [FriendRequestInformationModel] = invitationList.compactMap ( { (dict) in
            guard let invitationId = dict["invitationId"].int,
                let uid = dict["uid"].string,
                let nickname = dict["nickname"].string,
                let message = dict["message"].string
            else {
                return nil
            }
            let img = dict["headImg"].dictionary
            let headImg = img?["medium"]?.string ?? ""
            return FriendRequestInformationModel.init(invitationID:invitationId, uid:uid,nickName:nickname,message:message, headShotImage: headImg)
        })
        let friendListArray : [FriendInfoModel] = friendList.compactMap ({ (dict) in
            guard let uid = dict["uid"].string,
                let nickname = dict["nickname"].string,
                let roomId = dict["roomId"].string
            
            else {
                return nil
            }
            let img = dict["headImg"].dictionary
            let headImg = img?["medium"]?.string ?? ""
            return FriendInfoModel.init(uid:uid,nickName:nickname,roomId:roomId,headhShotImgString: headImg)
            }
        )
        self.personalDirectoryModel = MemberPersonalChatAndGroupsModel.init(invitationList:inviationListArray, friendList:friendListArray)
    }
    
    typealias API = GetPersonalDirectoryAPI
}



//MARK: - POST /IM/friendship

struct SendFriendRequestAPI : KLMoyaIMAPIData {
    
    let inviterUserID: String
    let inviteeUserID: String
    let invitationMessage: String
    
    var path: String {return "/IM/friendship" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "inviterUID" : inviterUserID, "inviteeUID": inviteeUserID,"invitationMessage":invitationMessage ],
            encoding: JSONEncoding.default
        )
    }
    var stub: Data? {return nil}
}

struct SendFriendRequestAPIModel:KLJSONMappableMoyaResponse {
    let response: Bool
    init(json: JSON, sourceAPI: SendFriendRequestAPI) throws {
        guard let response = json.bool
            else {
                throw GTServerAPIError.noData
        }
        self.response = response
    }
    typealias API = SendFriendRequestAPI
}

//MARK: - PUT /IM/friendship/{invitationId}

struct RespondFriendRequestAPI : KLMoyaIMAPIData {
    
    let invitationId: Int
    let accept: Bool
    
    var path: String {return "/IM/friendship/\(invitationId)" }
    var method: Moya.Method { return .put }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "inviteeUID": Tokens.getUID(),"accept":accept, "authToken":Tokens.getAuthToken(), "rocketChatUserId":Tokens.getRocketChatUserID() ],
            encoding: JSONEncoding.default
        )
    }
    var stub: Data? {return nil}
}

struct RespondFriendRequestAPIModel:KLJSONMappableMoyaResponse {
    let response: Bool
    
    init(json: JSON, sourceAPI: RespondFriendRequestAPI) throws {
        guard let response = json.bool
            else {
                throw GTServerAPIError.noData
        }
        self.response = response
    }
    typealias API = RespondFriendRequestAPI
}

//MARK: - POST /IM/GroupInviteReply

struct RespondGroupRequestAPI : KLMoyaIMAPIData {
    
    let groupID: String
    let groupAction: GroupAction
    
    var path: String {return "/IM/GroupInviteReply" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "groupID": groupID,"uid":Tokens.getUID(),"status":groupAction.rawValue, "authToken":Tokens.getAuthToken(), "rocketChatUserId":Tokens.getRocketChatUserID() ],
            encoding: JSONEncoding.default
        )
    }
    var stub: Data? {return nil}
}

struct RespondGroupRequestAPIModel:KLJSONMappableMoyaResponse {
    let response: Bool
    
    init(json: JSON, sourceAPI: RespondGroupRequestAPI) throws {
        guard let response = json.bool
            else {
                throw GTServerAPIError.noData
        }
        self.response = response
    }
    typealias API = RespondGroupRequestAPI
}


//MARK: - GET /IM/communications -

struct GetAllCommunicationsAPI : KLMoyaIMAPIData {
    var stub: Data? {return nil}
    var path: String {return "/IM/communications" }
    var method: Moya.Method { return .get }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "uid":Tokens.getUID(), "authToken":Tokens.getAuthToken(), "rocketChatUserId":Tokens.getRocketChatUserID() ],
            encoding: URLEncoding.default
        )
    }
}

struct GetAllCommunicationsAPIModel:KLJSONMappableMoyaResponse {
    var communicationList = [CommunicationListModel]()
    
    init(json: JSON, sourceAPI: GetAllCommunicationsAPI) throws {
        guard let response = json.array
            else {
                throw GTServerAPIError.noData
        }
        self.communicationList = response.compactMap ( { (dict) in
            guard let roomId = dict["roomId"].string,
                let displayName = dict["displayName"].string,
                let lastMessage = dict["lastMessage"].string,
                let roomType = dict["roomType"].string,
                let updateTime = dict["updateTime"].string
                else {
                    return nil
            }
            let img = dict["headImg"].dictionary
            let headImg = img?["small"]?.string ?? ""
            return CommunicationListModel.init(roomId: roomId, displayName: displayName, img: headImg, lastMessage: lastMessage, roomType: roomType, updateTime:updateTime, privateMessageTargetUid: dict["privateMessageTargetUid"].string)
        })
    }
    typealias API = GetAllCommunicationsAPI
}


//MARK: - Post /IM/message/section -

struct PostMessageSectionAPI : KLMoyaIMAPIData {
   
    var startTime:String
    var endTime:String
    var roomID:String
    var stub: Data? {return nil}
    var path: String {return "/IM/message/section" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "roomId": roomID,"uid":Tokens.getUID(),"startTime":startTime,"endTime":endTime ],
            encoding: JSONEncoding.default
        )
    }
}

struct PostMessageSectionAPIModel:KLJSONMappableMoyaResponse {
    
    init(json: JSON, sourceAPI: PostMessageSectionAPI) throws {
        guard let response = json.bool, response == true
            else {
                throw GTServerAPIError.noData
        }
    }
    typealias API = PostMessageSectionAPI
}


//MARK: - POST /IM/selfdestructingmessagesetting

struct SelfDestructMessageSettingAPI : KLMoyaIMAPIData {
    struct Parameter:Paramenter {
        var roomId:String
        var roomType:String
        var uid:String
        var selfDestructingMessageType:String
    }
    let parameter:Paramenter
    var stub: Data? {return nil}
    var path: String {return "/IM/selfdestructingmessagesetting" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: parameter.asDictionary(),
            encoding: JSONEncoding.default
        )
    }
}

struct SelfDestructMessageSettingAPIModel:KLJSONMappableMoyaResponse {
    
    init(json: JSON, sourceAPI: SelfDestructMessageSettingAPI) throws {
        guard let response = json.bool, response == true
            else {
                throw GTServerAPIError.noData
        }
    }
    typealias API = SelfDestructMessageSettingAPI
}

//MARK: - GET /IM/selfdestructingmessagesetting

struct GetSelfDestructingStatusAPI : KLMoyaIMAPIData {
    struct Parameter:Paramenter {
        var roomId:String
        var roomType:String
    }
    let parameter:Paramenter
    var stub: Data? {return nil}
    var path: String {return "/IM/selfdestructingmessagesetting" }
    var method: Moya.Method { return .get }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: parameter.asDictionary(),
            encoding: URLEncoding.default
        )
    }
}

struct GetSelfDestructingStatusAPIModel:KLJSONMappableMoyaResponse {
    var isOpenSelfDestructingMessage: Bool
    var privateChatType:PrivateChatDuration?
    init(json: JSON, sourceAPI: GetSelfDestructingStatusAPI) throws {
        guard let dict = json.dictionary
            else {
                throw GTServerAPIError.noData
        }
        self.isOpenSelfDestructingMessage = dict["isOpenSelfDestructingMessage"]?.bool ??  false
        guard let chatTypeString = dict ["selfDestructingMessageType"]?.string,
            let privateChatType = PrivateChatDuration.init(rawValue:chatTypeString) else {
                return
        }
        self.privateChatType = privateChatType
    }
    typealias API = GetSelfDestructingStatusAPI
}




//MARK: - GET /IM/GetGroupInfo -

struct GetGroupInfoAPI:KLMoyaIMAPIData {
    var rocketChatAuthNeeded: Bool {return true}
    
    var roomID: String?
    var groupID: String?
    
    var path: String {return "/IM/GetGroupInfo" }
    var method: Moya.Method { return .get }
    var task: Task {
        if roomID != nil {
            return Moya.Task.requestParameters(
            parameters: ["roomId" : roomID!,  "uid":Tokens.getUID(),],
                encoding: URLEncoding.default
            )
        }
        return Moya.Task.requestParameters(
            parameters: ["groupID" : groupID!,  "uid":Tokens.getUID(),],
            encoding: URLEncoding.default
        )
    }
    var stub: Data? {return nil}
}


struct GetGroupInfoAPIModel:KLJSONMappableMoyaResponse {
    
    var groupInfo : UserGroupInfoModel
    
    init(json: JSON, sourceAPI: GetGroupInfoAPI) throws {
        
        
        guard let dict = json.dictionary else {
            throw  GTServerAPIError.noData
        }
        
        guard let groupID = dict["groupID"]?.string,
            let groupOwnerUID = dict["groupOwnerUID"]?.string,
            let ownerName = dict["ownerName"]?.string,
            let groupName = dict["groupName"]?.string,
            let isPrivate = dict["isPrivate"]?.bool,
            let introduction = dict["introduction"]?.string,
            let imGroupId = dict ["imGroupID"]?.string,
            let isPostMsg = dict["isPostMsg"]?.bool,
            let status = dict["status"]?.int,
            let invitationMemberDict = dict ["invitationMembers"]?.array,
            let membersDict = dict["members"]?.array
            else {
                throw GTServerAPIError.noData
        }
        let img = dict["headImg"]?.dictionary
        let groupHeadImg = img?["small"]?.string ?? ""
        let invitedMembersArray:[GroupMemberModel] = invitationMemberDict.compactMap ( { (dict) in
            guard let uid = dict["uid"].string,
                let nickName = dict["nickName"].string,
                let status = dict["status"].int,
                let isFriend = dict["isFriend"].bool,
                let isBlocked = dict["isBlock"].bool
                else {
                    return nil
            }
            let img = dict["headImg"].dictionary
            let memberHeadImg = img?["medium"]?.string ?? ""
            return GroupMemberModel.init(uid:uid, nickName:nickName, headImg:memberHeadImg, status:status,isFriend:isFriend, isBlocked:isBlocked)
        })

        let membersArray:[GroupMemberModel] = membersDict.compactMap ({ (dict) in
            guard let uid = dict["uid"].string,
                let nickName = dict["nickName"].string,
                let status = dict["status"].int,
                let isFriend = dict["isFriend"].bool,
                let isBlocked = dict["isBlock"].bool
                else {
                    return nil
            }
            let img = dict["headImg"].dictionary
            let memberHeadImg = img?["medium"]?.string ?? ""

            return GroupMemberModel.init(uid:uid, nickName:nickName, headImg:memberHeadImg, status:status,isFriend:isFriend, isBlocked:isBlocked)
        })

        self.groupInfo = UserGroupInfoModel.init(groupID: groupID, groupOwnerUID: groupOwnerUID, ownerName: ownerName, status: status, groupName: groupName, isPrivate: isPrivate, introduction: introduction, headImg: groupHeadImg, imGroupId: imGroupId, isPostMsg: isPostMsg,membersArray:membersArray, invitedMembersArray:invitedMembersArray)
    }
    
    typealias API = GetGroupInfoAPI

}

// MARK: - /IM/SearchUser

struct SearchUserAPI : KLMoyaIMAPIData {
    let uid: String
    let targetUid: String
    var stub: Data? { return nil}
    var path: String { return "/IM/SearchUser" }
    var method: Moya.Method { return .get }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: ["uid": uid, "targetUid": targetUid],
            encoding: URLEncoding.default
        )
    }
}

struct SearchUserAPIModel:KLJSONMappableMoyaResponse {
    typealias API = SearchUserAPI
    
    let imUser: IMUser
    let isFriend: Bool
    let isBlock: Bool
    
    init(json: JSON, sourceAPI: SearchUserAPI) throws {
        guard let uid = json["uid"].string,
            let nickname = json["nickname"].string,
            
            let isFriend = json["isFriend"].bool,
            let isBlock = json["isBlock"].bool
            else {
                throw GTServerAPIError.noData
                
        }
        let headImg = json["headImg"].dictionary
        let headshotImg = headImg?["medium"]?.string ?? ""
        self.imUser = IMUser(uID: uid, nickName: nickname, introduction: String(), headImg: headshotImg)
        self.isFriend = isFriend
        self.isBlock = isBlock
    }
}

//MARK: - POST /IM/UploadHeadImage

struct UploadHeadImageAPI: KLMoyaIMAPIData {
    struct Parameters:Paramenter {
        var personalOrGroupId :String
        var isGroup: Bool
        var image : Data
    }
    let parameters: Parameters

    var path: String {return "/IM/UploadHeadImage"}
    
    var method: Moya.Method {return .post}
    
    var task: Task {
        let multiPartData : [MultipartFormData] =
            [MultipartFormData.init(provider: .data(parameters.image), name: "file", fileName: "file.jpeg", mimeType:"image/jpeg"),
             MultipartFormData.init(provider: .data(parameters.isGroup.string.data(using: .utf8)!), name: "isGroup"),
             MultipartFormData.init(provider: .data(parameters.personalOrGroupId.data(using: .utf8)!), name: "personalOrGroupId")
             ]
        return .uploadMultipart(multiPartData)}
    
    var stub: Data? {return nil}
    
    var headers: [String : String]? {
        return ["Content-Type" : "multipart/form-data", "SystemId":"2"]
    }
    
}

struct UploadHeadImageAPIModel:KLJSONMappableMoyaResponse {
    
    typealias API = UploadHeadImageAPI
    let image :String
    init(json: JSON, sourceAPI: UploadHeadImageAPI) throws {
        guard let mediumImg = json["original"].string else {
            throw GTServerAPIError.noData
        }
        self.image = mediumImg
    }
}

//MARK: - POST /IM/FileUpload

struct UploadFileAPI: KLMoyaIMAPIData {
    struct Parameters:Paramenter {
        var uid :String
        var isGroup: Bool
        var image : Data
        var roomId:String
        var fileName:String
    }
    let parameters: Parameters
    
    var path: String {return "/IM/FileUpload"}
    
    var method: Moya.Method {return .post}
    
    var task: Task {
        let multiPartData : [MultipartFormData] =
            [MultipartFormData.init(provider: .data(parameters.image), name: "file", fileName: parameters.fileName, mimeType:"*/*"),
             MultipartFormData.init(provider: .data(parameters.isGroup.string.data(using: .utf8)!), name: "isGroup"),
             MultipartFormData.init(provider: .data(parameters.uid.data(using: .utf8)!), name: "uid"),
             MultipartFormData.init(provider: .data(parameters.roomId.data(using: .utf8)!), name: "roomId"),
             MultipartFormData.init(provider: .data("file".data(using: .utf8)!), name: "fileType"),
             MultipartFormData.init(provider: .data(Tokens.getAuthToken().data(using: .utf8)!), name: "authToken"),
             MultipartFormData.init(provider: .data(Tokens.getRocketChatUserID().data(using: .utf8)!), name: "rocketChatUserId")
        ]
        return .uploadMultipart(multiPartData)}
    
    var stub: Data? {return nil}
    
    var headers: [String : String]? {
        return ["Content-Type" : "multipart/form-data", "SystemId":"2"]
    }
}

struct UploadFileAPIModel:KLJSONMappableMoyaResponse {
    typealias API = UploadFileAPI
    init(json: JSON, sourceAPI: UploadFileAPI) throws {
        guard json["fileUrl"].string != nil else {
            throw GTServerAPIError.noData
        }
    }
}


//MARK: - /IM/message/SendMessage

struct IMSendMessageAPI:KLMoyaIMAPIData {
    
    struct Parameter:Paramenter {
        var uid:String
        var roomId :String
        var isGroup : Bool
        var msg : String
    }
    let parameters: Parameter
    var path: String { return "/IM/message/SendMessage" }
    var method: Moya.Method { return .post }
    var task: Task {
        
        var dict = parameters.asDictionary()
        dict["authToken"] = Tokens.getAuthToken()
        dict["rocketChatUserId"] = Tokens.getRocketChatUserID()
        return Moya.Task.requestParameters(
            parameters: dict,
            encoding: JSONEncoding.default
        )
    }
    var stub: Data? {return nil}
}


struct IMSendMessageAPIModel:KLJSONMappableMoyaResponse {
    typealias API = IMSendMessageAPI
    var status : Bool
    init(json: JSON, sourceAPI: IMSendMessageAPI) throws {
        guard let success = json["success"].bool
            else {
                throw GTServerAPIError.noData
        }
        self.status = success
    }
}

// MARK: - POST /IM/RedEnvelope/Request

struct IMSendCoinRequestAPI:KLMoyaIMAPIData {
    
    struct Parameter:Paramenter {
        let uid:String = Tokens.getUID()
        let rocketChatUserId:String = Tokens.getRocketChatUserID()
        let authToken:String = Tokens.getAuthToken()
        let roomId :String
        let isGroup : Bool
        let msg : String
    }
    let parameters: Parameter

    var path: String {return "/IM/RedEnvelope/Request"}
    
    var method: Moya.Method { return .post }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: parameters.asDictionary(),
            encoding: JSONEncoding.default
        )
    }
    
    var stub: Data? {return nil}
}

struct IMSendCoinRequestAPIModel:KLJSONMappableMoyaResponse {
    typealias API = IMSendCoinRequestAPI
    var status : Bool

    init(json: JSON, sourceAPI: API) throws {
        guard let success = json["success"].bool
            else {
                throw GTServerAPIError.noData
        }
        self.status = success
    }
}
// MARK: - /IM/CreateGroup

struct CreateGroupAPI: KLMoyaIMAPIData {
    struct Parameters: Paramenter {
        let groupOwnerUID: String = IMUserManager.manager.userModel.value!.uID
        let isPrivate: Bool
        let authToken: String = RocketChatManager.manager.rocketChatUser.value!.authToken
        let rocketChatUserId: String =  RocketChatManager.manager.rocketChatUser.value!.rocketChatUserId
        let groupName: String
        let isPostMsg: Bool
        let introduction: String
    }
    
    var path: String { return "/IM/CreateGroup" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(parameters: parameters.asDictionary(), encoding: JSONEncoding.default)
    }
    var stub: Data? { return nil }
    let parameters: Parameters
}

struct CreateGroupAPIModel: KLJSONMappableMoyaResponse {
    typealias API = CreateGroupAPI
    
    let groupID: String
    
    init(json: JSON, sourceAPI: CreateGroupAPI) throws {
        guard let groupID = json["groupID"].string else {throw GTServerAPIError.noData }
        self.groupID = groupID
    }
}

// MARK: - /IM/GroupMembers

struct GroupMembersAPI: KLMoyaIMAPIData {
    struct Parameters: Paramenter {
        let authToken: String = RocketChatManager.manager.rocketChatUser.value!.authToken
        let rocketChatUserId: String = RocketChatManager.manager.rocketChatUser.value!.rocketChatUserId
        let groupID: String
        let members: [String]
        let action: Int = 2
    }
    
    var path: String { return "/IM/GroupMembers" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(parameters: parameters.asDictionary(), encoding: JSONEncoding.default)
    }
    var stub: Data? { return nil }
    let parameters: Parameters
}

struct GroupMembersAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GroupMembersAPI
    
    let isSuccess: Bool
    
    init(json: JSON, sourceAPI: GroupMembersAPI) throws {
        guard let response = json.bool else { throw GTServerAPIError.noData }
        self.isSuccess = response
    }
}

// MARK: - /IM/UpdateGroup

struct UpdateGroupAPI: KLMoyaIMAPIData {
    struct Parameters: Paramenter {
        let groupID: String
        let groupName: String
        let isPostMsg: Bool
        let introduction: String
    }
    
    var path: String { return "/IM/UpdateGroup" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(parameters: parameters.asDictionary(), encoding: JSONEncoding.default)
    }
    var stub: Data? { return nil }
    let parameters: Parameters
}

struct UpdateGroupAPIModel: KLJSONMappableMoyaResponse {
    typealias API = UpdateGroupAPI
    
    let isSuccess: Bool
    
    init(json: JSON, sourceAPI: UpdateGroupAPI) throws {
        guard let response = json.bool else { throw GTServerAPIError.noData }
        self.isSuccess = response
    }
}

// MARK: - /IM/DeleteGroup

struct DeleteGroupAPI: KLMoyaIMAPIData {
    struct Parameters: Paramenter {
        let authToken: String = RocketChatManager.manager.rocketChatUser.value!.authToken
        let rocketChatUserId: String = RocketChatManager.manager.rocketChatUser.value!.rocketChatUserId
        let uid: String = IMUserManager.manager.userModel.value!.uID
        let groupID: String
        
        init(userGroupInfoModel: UserGroupInfoModel) {
            groupID = userGroupInfoModel.groupID
        }
    }
    
    var path: String { return "/IM/DeleteGroup" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(parameters: parameters.asDictionary(), encoding: JSONEncoding.default)
    }
    var stub: Data? { return nil }
    let parameters: Parameters
}

struct DeleteGroupAPIModel: KLJSONMappableMoyaResponse {
    typealias API = DeleteGroupAPI
    
    let isSuccess: Bool
    
    init(json: JSON, sourceAPI: DeleteGroupAPI) throws {
        guard let response = json.bool else { throw GTServerAPIError.noData }
        self.isSuccess = response
    }
}


//GET /IM/Member/MuteRooms
struct GetRoomNotificationStatusAPI:KLMoyaIMAPIData {
    var path: String {
        return "/IM/Member/MuteRooms"
    }
    var method: Moya.Method {return .get}
    var task: Task {
        return Moya.Task.requestParameters(parameters: ["uid":parameters.uid], encoding: URLEncoding.default)
    }
    var stub: Data? {return nil}
    var parameters:Parameter
    struct Parameter:Paramenter {
        let uid:String
        let roomId:String
    }
}

struct GetRoomNotificationStatusAPIModel: KLJSONMappableMoyaResponse {
    typealias API = GetRoomNotificationStatusAPI
    let isMute: Bool
    init(json: JSON, sourceAPI: GetRoomNotificationStatusAPI) throws {
        guard let response = json.array else { throw GTServerAPIError.noData }
        isMute = response.compactMap {
            $0.dictionaryObject as? [String:String]
            }.compactMap {$0["roomId"]}
            .contains(sourceAPI.parameters.roomId)
    }
}

//POST /{lang}/IM/Member/MuteRoom
struct MuteRoomNotificationAPI:KLMoyaIMAPIData {
    var path: String {
        return "/IM/Member/MuteRoom"
    }
    
    var method: Moya.Method {return .post}
    
    var task: Task {
        return Moya.Task.requestParameters(parameters: parameters.asDictionary(), encoding: JSONEncoding.default)
    }
    var stub: Data? {return nil}
    var parameters:Parameter
    struct Parameter:Paramenter {
        let uid:String
        let roomId:String
        let isNotificaitonActive:Bool
    }
    
}

struct MuteRoomNotificationAPIModel: KLJSONMappableMoyaResponse {
    typealias API = MuteRoomNotificationAPI
    let isSuccess: Bool
    init(json: JSON, sourceAPI: MuteRoomNotificationAPI) throws {
        guard let response = json.bool else { throw GTServerAPIError.noData }
        self.isSuccess = response
    }
}

// MARK: - /IM/blocklist

struct BlockUserAPI: KLMoyaIMAPIData {
    
    struct Parameters: Paramenter {
        enum Action: String, Codable {
            case block = "Block"
            case unblock = "Unblock"
        }
        
        let uid: String
        let blockedUid: String
        let action: Action
    }
    
    var path: String { return "/IM/blocklist" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(parameters: parameters.asDictionary(), encoding: JSONEncoding.default)
    }
    var stub: Data? { return nil }
    let parameters: Parameters
}

struct BlockUserAPIModel: KLJSONMappableMoyaResponse {
    typealias API = BlockUserAPI
    
    let isSuccess: Bool
    
    init(json: JSON, sourceAPI: BlockUserAPI) throws {
        guard let response = json.bool else { throw GTServerAPIError.noData }
        self.isSuccess = response
    }
}


// MARK: - PUT /IM/member/JiguangPushSetting

struct JiGuangPushSettingAPI : KLMoyaIMAPIData {
    let registrationId: String
    var stub: Data? { return nil}
    var path: String { return "/IM/member/JiguangPushSetting" }
    var method: Moya.Method { return .put }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: ["uid": IMUserManager.manager.userModel.value?.uID ?? "", "deviceType": 1, "registrationId": registrationId],
            encoding: URLEncoding.default
        )
    }
}

struct JiGuangPushSettingAPIModel: KLJSONMappableMoyaResponse {
    typealias API = JiGuangPushSettingAPI
    
    let isSuccess: Bool
    
    init(json: JSON, sourceAPI: JiGuangPushSettingAPI) throws {
        guard let response = json.bool else { throw GTServerAPIError.noData }
        self.isSuccess = response
    }
}

//POST /IM/CallVideo
struct InAppCallApi:KLMoyaIMAPIData {
    
    struct Parameter:Paramenter {
        
        let type:CallType
        let roomId:String
        let isGroup:Bool
        let isConnect:Bool
        var streamId: String? = nil
        private let uid = Tokens.getUID()
        private let rocketChatUserId = Tokens.getRocketChatUserID()
        private let authToken = Tokens.getAuthToken()
        
    }
    
    let parameter: InAppCallApi.Parameter
    var path: String {
        return "/IM/CallVideo"
    }
    var method: Moya.Method {
        return .post
    }
    var task: Task {
        return Moya.Task.requestParameters(parameters: parameter.asDictionary(), encoding: JSONEncoding.default)
    }
    var stub: Data? {
        return nil
    }
}


struct InAppCallApiModel:KLJSONMappableMoyaResponse {
    
    let streamId:String
    init(json: JSON, sourceAPI: InAppCallApi) throws {
        guard let streamId = json["streamId"].string else {
            throw GTServerAPIError.noData
        }
        self.streamId = streamId
    }
    
    typealias API = InAppCallApi
}



struct CreateRedEnvelopeAPI : KLMoyaIMAPIData {
    var stub: Data? {return nil}
    
    struct Parameters: Paramenter {
        let senderUID = Tokens.getUID()
        let authToken = Tokens.getAuthToken()
        let rocketChatUserId = Tokens.getRocketChatUserID()
        let senderAddress: String
        let identifier: String
        let amount: Decimal
        let message: String?
        let roomId: String
        let expireMinute: Int
        let limitCount: Int?
        let type: RedEnvelopeType?
    }
    
    let parameters: Parameters
    var path: String { return parameters.limitCount == nil ? "IM/RedEnvelope/Create" : "IM/RedEnvelope/CreateGroup" }
    var method: Moya.Method { return .post }
    var task: Task { return .requestParameters(parameters: parameters.asDictionary(),
                                               encoding: JSONEncoding.default) }

}

struct CreateRedEnvelopeAPIModel: KLJSONMappableMoyaResponse {
    typealias API = CreateRedEnvelopeAPI
    let status : Bool
    init(json: JSON, sourceAPI: API) throws {
        guard let status = json.bool else {
            throw GTServerAPIError.noData
        }
        self.status = status
    }
}

struct RedEnvelopeInfoAPI:KLMoyaIMAPIData {
    var path: String {
        return "IM/RedEnvelope/InfoLog"
    }
    
    var method: Moya.Method { return .get }

    var task: Task { return .requestParameters(parameters: parameters.asDictionary(),
                                               encoding: URLEncoding.default) }
    let parameters: Parameters

    var stub: Data? {return nil}
    
    struct Parameters: Paramenter {
        let uid: String = Tokens.getUID()
        let redEnvelopeId: String
    }
}

struct RedEnvelopeInfoAPIModel: KLJSONMappableMoyaResponse {
    typealias API = RedEnvelopeInfoAPI
    let redEnvelopeInfo : RedEvelopeInfoModel
    init(json: JSON, sourceAPI: API) throws {
        
        let decode = JSONDecoder()
        guard let info = try? decode.decode(RedEvelopeInfoModel.self, from: json.rawData()) else {
            throw GTServerAPIError.noData
        }
        self.redEnvelopeInfo = info
    }
}

struct AcceptRedEnvelopeAPI: KLMoyaIMAPIData {
    struct Parameters: Paramenter {
        let receiveUID = Tokens.getUID()
        let redEnvelopeId: String
        let receiveAddress: String
        let authToken = Tokens.getAuthToken()
        let rocketChatUserId = Tokens.getRocketChatUserID()
    }
    let parameters: Parameters
    var path: String { return "IM/RedEnvelope/Receive" }
    var method: Moya.Method { return .put }
    var task: Task { return .requestParameters(parameters: parameters.asDictionary(),
                                               encoding: JSONEncoding.default) }
    var stub: Data? {return nil}

}

struct AcceptRedEnvelopeAPIModel:KLJSONMappableMoyaResponse {
    typealias API = AcceptRedEnvelopeAPI
    let status : Bool
    init(json: JSON, sourceAPI: API) throws {
        guard let status = json.bool else {
            throw GTServerAPIError.noData
        }
        self.status = status
    }
}


struct PromiseRedEnvelopeSentAPI: KLMoyaIMAPIData {
    var path: String {return "IM/RedEnvelope/PromiseSend"}
    
    var method: Moya.Method { return .put }
    var task: Task { return .requestParameters(parameters: parameters.asDictionary(),
                                               encoding: JSONEncoding.default) }
    
    var stub: Data? {return nil}
    
    struct Parameters: Paramenter {
        let senderUID = Tokens.getUID()
        let redEnvelopeId: String
        let members: [String]
    }
    
    let parameters:Parameters
}

struct PromiseRedEnvelopeSentAPIModel:KLJSONMappableMoyaResponse {
    
    typealias API = PromiseRedEnvelopeSentAPI
    let status : Bool
    init(json: JSON, sourceAPI: API) throws {
        guard let status = json.bool else {
            throw GTServerAPIError.noData
        }
        self.status = status
    }
}


struct ReceiveRedEnvelopeHistoryAPI:KLMoyaIMAPIData {
    var stub: Data? {return nil}
    
    struct Parameters: Paramenter {
        let uid = Tokens.getUID()
        let pageNow = 1
        let pageSize = 50
        let sortType = "time"
        let isDescending = "true"
    }
    
    let parameters: Parameters
    var path: String { return "IM/RedEnvelope/ReceiveHistory" }
    var method: Moya.Method { return .get }
    var task: Task { return .requestParameters(parameters: parameters.asDictionary(),
                                               encoding: JSONEncoding.default) }

}

struct ReceiveRedEnvelopeHistoryAPIModel: KLJSONMappableMoyaResponse {
   typealias API = ReceiveRedEnvelopeHistoryAPI
    let receiveHistoryArray: [ReceiveRedEnvelopeHistoryModel]
    
    init(json: JSON, sourceAPI: API) throws {
        
        let decode = JSONDecoder()
        guard let response = json.array
            else {
                throw GTServerAPIError.noData
        }
        self.receiveHistoryArray = response.compactMap({ (json) -> ReceiveRedEnvelopeHistoryModel? in
            guard let info = try? decode.decode(ReceiveRedEnvelopeHistoryModel.self, from: json.rawData()) else {
                return nil
            }
            return info
        })
    }
}



struct SendRedEnvelopeHistoryAPI:KLMoyaIMAPIData {
    var stub: Data? {return nil}
    
    struct Parameters: Paramenter {
        let uid = Tokens.getUID()
        let pageNow = 1
        let pageSize = 50
        let sortType = "time"
        let isDescending = "true"
    }
    
    let parameters: Parameters
    var path: String { return "IM/RedEnvelope/SendingHistory" }
    var method: Moya.Method { return .get }
    var task: Task { return .requestParameters(parameters: parameters.asDictionary(),
                                               encoding: JSONEncoding.default) }
    
}

struct SendRedEnvelopeHistoryAPIModel: KLJSONMappableMoyaResponse {
    typealias API = SendRedEnvelopeHistoryAPI
    let sendHistoryArray: [SendRedEnvelopeHistoryModel]
    
    init(json: JSON, sourceAPI: API) throws {
        
        let decode = JSONDecoder()
        guard let response = json.array
            else {
                throw GTServerAPIError.noData
        }
        self.sendHistoryArray = response.compactMap({ (json) -> SendRedEnvelopeHistoryModel? in
            guard let info = try? decode.decode(SendRedEnvelopeHistoryModel.self, from: json.rawData()) else {
                return nil
            }
            return info
        })
    }
}

//MARK: - ROCKETCHAT API AND MODELS

enum RocketChatAPI: KLMoyaAPISet {
    
    var api: KLMoyaAPIData {
        switch self {
        case .rocketChatLogin(let api): return api
        case .rocketChatHistory(let api): return api
        case .groupChatHistory(let api): return api
        case .sendChatMessage(let api): return api
        case .joinPublicGroupRocketChat(let api): return api
        case .deleteMessage(let api):return api
        case .deleteChatHistory (let api):return api
        }
    }
    case rocketChatLogin(RocketChatLoginAPI)
    case rocketChatHistory(GetRocketChatMessageHistoryAPI)
    case sendChatMessage(RocketChatSendMessageAPI)
    case groupChatHistory(GetRocketChatGroupMessageHistoryAPI)
    case joinPublicGroupRocketChat(JoinPubliGroupRocketChatAPI)
    case deleteMessage(DeleteChatMessageAPI)
    case deleteChatHistory(DeleteChatHistoryAPI)
}

//MARK: - /api/v1/login
struct RocketChatLoginAPI:KLMoyaRocketChatAPIData {
    var rocketChatAuthNeeded: Bool {return false}
    
    let userName:String
    let password: String
    var path: String {return "/api/v1/login" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: [ "username" : userName,"password":password ],
            encoding: JSONEncoding.default
        )
    }
    var stub: Data? {return nil}
}


struct  RocketChatLoginAPIModel:KLJSONMappableMoyaResponse {
    
    var rocketChatUserId: String
    var authToken: String
    var username: String
    
    init(json: JSON, sourceAPI: RocketChatLoginAPI) throws {
        guard let rocketChatUserId = json["userId"].string,
            let authToken = json["authToken"].string,
            let username = json["me"]["username"].string
            else {
                if let status = json["status"].string, status == "error",
                    let error = json["error"].string, error == "Unauthorized" {
                    throw GTServerAPIError.expiredToken
                }
                throw GTServerAPIError.noData
        }
        self.rocketChatUserId = rocketChatUserId
        self.authToken = authToken
        self.username = username
    }
    typealias API = RocketChatLoginAPI
}

//MARK: - /api/v1/chat.sendMessage

struct RocketChatSendMessageAPI:KLMoyaRocketChatAPIData {
    
    var rocketChatAuthNeeded: Bool {return true}
    
    let message:String
    let roomID: String
    var path: String {return "/api/v1/chat.sendMessage" }
    var method: Moya.Method { return .post }
    var task: Task {
        let messageDict = ["rid" : roomID, "msg": message]
        return Moya.Task.requestParameters(
            parameters: [ "message" : messageDict ],
            encoding: JSONEncoding.default
        )
    }
    var stub: Data? {return nil}
}


struct  RocketChatSendMessageAPIModel:KLJSONMappableMoyaResponse {
    typealias API = RocketChatSendMessageAPI
//    var roomID: String
//    var msgTxt: String
//    var timeStamp: String
    var msgId: String
    var status : Bool
    init(json: JSON, sourceAPI: RocketChatSendMessageAPI) throws {
        guard let success = json["success"].bool, let messageID = json["message"]["_id"].string
            else {
                throw GTServerAPIError.noData
        }
        self.status = success
        self.msgId = messageID
        //        self.roomID = roomId
        //        self.msgTxt = msg
        //        self.msgId = msgId
        //        self.timeStamp = timeStamp
        
    }
}


//MARK: - /api/v1/im.history


struct GetRocketChatMessageHistoryAPI:KLMoyaRocketChatAPIData {
  
    var rocketChatAuthNeeded: Bool {return true}
    
    var roomType:RoomType
    let roomID: String
    var path: String {
        switch self.roomType {
        case .channel:
            return "/api/v1/channels.history"
        case .group:
            return "/api/v1/groups.history"
        case .pvtChat:
            return "/api/v1/im.history"
        }
    }
    var method: Moya.Method { return .get }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: ["roomId" : roomID,  "count":"50"],
            encoding: URLEncoding.default
        )
    }
    var stub: Data? {return nil}
}


struct  GetRocketChatMessageHistoryAPIModel:KLJSONMappableMoyaResponse {
    
    var messageArray = [MessageModel]()
    
    init(json: JSON, sourceAPI: GetRocketChatMessageHistoryAPI) throws {
        
        guard let messagesJSON = json["messages"].array else {
            throw GTServerAPIError.noData
        }
        guard let status = json["success"].bool, status == true else {
            throw GTServerAPIError.incorrectResult("", json["error"].string ?? "")
        }
        self.messageArray = messagesJSON.compactMap({ (jsonDict)  in
           return MessageModel.init(messageResponse: jsonDict)
        })
        
    }
    typealias API = GetRocketChatMessageHistoryAPI

}


//MARK: - /api/v1/groups.history

struct GetRocketChatGroupMessageHistoryAPI:KLMoyaRocketChatAPIData {
    var rocketChatAuthNeeded: Bool {return true}
    
    let roomID: String
    var path: String {return "/api/v1/groups.history" }
    var method: Moya.Method { return .get }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: ["roomId" : roomID,  "count":"50"],
            encoding: URLEncoding.default
        )
    }
    var stub: Data? {return nil}
}


struct  GetRocketChatGroupMessageHistoryAPIModel:KLJSONMappableMoyaResponse {
    
    var messageArray = [MessageModel]()
    
    init(json: JSON, sourceAPI: GetRocketChatGroupMessageHistoryAPI) throws {
        
        guard let messagesJSON = json["messages"].array else {
            throw GTServerAPIError.noData
        }
        guard let status = json["success"].bool, status == true else {
            throw GTServerAPIError.incorrectResult("", json["error"].string ?? "")
        }
        self.messageArray = messagesJSON.compactMap({ (jsonDict)  in
            guard let msgID = jsonDict["_id"].string,
                let roomId = jsonDict["rid"].string,
                let message = jsonDict["msg"].string,
                let timeStampString = jsonDict["ts"].string,
                let userDict = jsonDict["u"].dictionary,
                let userId = userDict["_id"]?.string,
                let name = userDict["name"]?.string,
                let userName = userDict["username"]?.string
                else {
                    return nil
            }
            
            
            let msgType = jsonDict["msgType"].string ?? "general"
            var messageType : MessageType = {
                switch msgType {
                case "file":
                    return .file
                default:
                    return .general
                }
            }()
            
            var msg:String = ""
            if case .file = messageType {
                if let url = jsonDict["msg"].string  {
                    if let data = url.data(using: .utf8) {
                        let dict :[String:Any]? = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if dict != nil, dict!["fileUrl"] != nil {
                            msg = dict!["fileUrl"] as! String
                        }
                    }
                }
            }else {
                msg = jsonDict["msg"].string ?? ""
                if msg.contains("address"),msg.contains("amount"),msg.contains("coinID") {
                    if let url = jsonDict["msg"].string  {
                        if let data = url.data(using: .utf8) {
                            let dict :[String:Any]? = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            if dict != nil, dict!["address"] != nil,dict!["amount"] != nil,dict!["coinID"] != nil {
                                messageType = .receipt(messageDict: dict as! [String : String])
                            }
                        }
                    }
                }
            }
            
            let date = DateFormatter.date(from: timeStampString, withFormat: C.IMDateFormat.dateFormatForIM)
            let messageModel = MessageModel.init(messageId: msgID, roomId: roomId, msg: message, senderId:userId, senderName:name, timestamp: date!, messageType: messageType,userName:userName)
            return messageModel
        })
        
    }
    typealias API = GetRocketChatGroupMessageHistoryAPI

}


//MARK: - /api/v1/channels.join

struct JoinPubliGroupRocketChatAPI:KLMoyaRocketChatAPIData {
    var rocketChatAuthNeeded: Bool {return true}
    
    let roomID: String
    var path: String {return "/api/v1/channels.join" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: ["roomId" : roomID,  "joinCode":"1234"],
            encoding: JSONEncoding.default
        )
    }
    var stub: Data? {return nil}
}


struct  JoinPubliGroupRocketChatAPIModel:KLJSONMappableMoyaResponse {
    
    typealias API = JoinPubliGroupRocketChatAPI
    init(json: JSON, sourceAPI: JoinPubliGroupRocketChatAPI) throws {
        guard let channel = json["channel"].dictionary else {
             throw GTServerAPIError.noData
        }
        if channel["_id"]?.string == sourceAPI.roomID {
            print(sourceAPI.roomID)
        }
    }
}

//MARK: POST - /api/v1/chat.delete

struct DeleteChatMessageAPI:KLMoyaRocketChatAPIData {
    var rocketChatAuthNeeded: Bool {return true}
    
    let roomID: String
    let msgID: String
    
    var path: String {return "/api/v1/chat.delete" }
    var method: Moya.Method { return .post }
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: ["roomId" : roomID,  "msgId":msgID],
            encoding: JSONEncoding.default
        )
    }
    var stub: Data? {return nil}
}

struct  DeleteChatMessageAPIModel:KLJSONMappableMoyaResponse {
    
    typealias API = DeleteChatMessageAPI
    init(json: JSON, sourceAPI: DeleteChatMessageAPI) throws {
        guard json["success"].bool != nil else {
            throw GTServerAPIError.noData
        }
        if json["_id"].string == sourceAPI.msgID {
            print(sourceAPI.msgID)
        }
    }
}


struct DeleteChatHistoryAPI:KLMoyaRocketChatAPIData {
    var rocketChatAuthNeeded: Bool {return false}
    
    let parameter : Parameter
  
    struct Parameter:Paramenter {
        let roomId:String
        let latest:String = "2020-09-30T13:42:25.304Z"
        let oldest:String = "2018-09-30T13:42:25.304Z"
    }
    var headers: [String : String]? {return ["X-Auth-Token":"5GnhnZQQUmDtw3NrJjgaDKL_nLyn69b-M4kb8vCHiuB","X-User-Id":"PaeuSQobQwNzcS6jy"]}
    var path: String {return "/api/v1/rooms.cleanHistory"}
    
    var method: Moya.Method { return .post }
    
    var task: Task {
        return Moya.Task.requestParameters(
            parameters: parameter.asDictionary(),
            encoding: JSONEncoding.default
        )
    }
    
    var stub: Data? {return nil}
}

struct DeleteChatHistoryAPIModel:KLJSONMappableMoyaResponse {
    typealias API = DeleteChatHistoryAPI
    
    let status :Bool
    
    init(json: JSON, sourceAPI: DeleteChatHistoryAPI) throws {
        guard let status = json["success"].bool else {
            throw GTServerAPIError.noData
        }
        self.status = status
    }
}
