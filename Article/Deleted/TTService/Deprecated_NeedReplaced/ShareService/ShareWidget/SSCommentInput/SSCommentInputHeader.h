//
//  SSCommentInputHeader.h
//  Article
//
//  Created by Zhang Leonardo on 13-3-19.
//
//
/*
 *  评论,输入框常量类
 */

//最大可以输入的长度
#define kMaxCommentLength   2000
#define kMaxEssayPublishLength 300
#define KMaxtCommentAtNum 20

#define sBannCommentTip                 NSLocalizedString(@"该文章暂不支持评论", nil)
#define sPublishCommentStr              NSLocalizedString(@"发表评论", nil)
#define sOnlyWannaCommentTip            NSLocalizedString(@"如果不想转发，请不要勾选下方图标", nil)
#define sCommentInputHasLinkTip         NSLocalizedString(@"已附带原文链接", nil)
#define sCommentInputHasLinkAndImgTip   NSLocalizedString(@"已附带原文链接及图片", nil)
#define sCommentInputViewSharePGCUserTip @""
#define sCommentInputViewPlaceHolder @"" // 默认不显示， 请文明发言，传播正能量，坚守法律法规、信息真实性等“七条底线”
#define sNoLoginTip                     NSLocalizedString(@"请先绑定一个账号", nil)
#define sNoNetworkConnectedTip          NSLocalizedString(@"没有网络连接", nil)
#define sInputContentTooShortTip        NSLocalizedString(@"请输入评论", nil)
#define sInputContentTooLongTip         NSLocalizedString(@"发送内容不可以超过%d个字", nil)
#define sInputContentAtTooManyTip       NSLocalizedString(@"已超过@用户数上限，请调整后再发", nil)
#define sSending                        NSLocalizedString(@"发送中...", nil)
#define sSendDone                       NSLocalizedString(@"发送成功", nil)
#define sDefaultTitle                   NSLocalizedString(@"评论/转发", nil)
#define sShareTo                        NSLocalizedString(@"分享到", nil)
#define sReplyCommentTitle              NSLocalizedString(@"转发/回复评论", nil)
#define sOK                             NSLocalizedString(@"确定", nil)
#define sCancel                         NSLocalizedString(@"取消", nil)
#define sSend                           NSLocalizedString(@"发送", nil)

#define kSSCommentListViewConditionTopCommentIDKey      @"kSSCommentListViewConditionTopCommentIDKey"
#define kSSCommentListViewConditionGroupID              @"kSSCommentListViewConditionGroupID"
#define kSSCommentListViewConditionTag                  @"kSSCommentListViewConditionTag"
#define kSSCommentListViewConditionSortType             @"kSSCommentListViewConditionSortType"

#define kQuickInputViewConditionIsSharePGCUser          @"kQuickInputViewConditionIsSharePGCUser"

#define kQuickInputViewConditionGroupModel                  @"kQuickInputViewConditionGroupModel"

#define kQuickInputViewConditionMediaID @"kQuickInputViewConditionMediaID"

#define kQuickInputViewConditionADIDKey                 @"kQuickInputViewConditionADIDKey"
#define kQuickInputViewConditionItemTag                 @"kQuickInputViewConditionItemTag"
#define kQuickInputViewConditionInputViewText           @"kQuickInputViewConditionInputViewText"
#define kQuickInputViewConditionInputMessageTypeKey     @"kQuickInputViewConditionInputMessageTypeKey"
#define kQuickInputViewConditionReplyToCommentID        @"kQuickInputViewConditionReplyToCommentID"
#define kQuickInputViewConditionHasImageKey             @"kQuickInputViewConditionHasImageKey"
#define kQuickInputViewCOnditionPlatformType            @"kQuickInputViewConditionPlatformType"
#define kQuickInputViewConditionShareSourceObjectType   @"kQuickInputViewConditionShareSourceObjectType"
#define kQuickInputViewConditionUniqueId                @"kQuickInputViewConditionUniqueId"
#define kQuickInputViewConditionReplyToComment          @"kQuickInputViewConditionReplyToComment"
#define kQuickInputViewConditionShareUrl                @"kQuickInputViewConditionShareUrl"
#define kQuickInputViewConditionShareImageUrl           @"kQuickInputViewConditionShareImageUrl"
#define kQuickInputViewConditionShowRepostEntrance      @"kQuickInputViewConditionShowRepostEntrance"

//评论列表排序方式
typedef enum SSCommentListViewSortType{
    SSCommentListViewSortTypeNone,
    SSCommentListViewSortTypeRecent,
    SSCommentListViewSortTypeHot
}SSCommentListViewSortType;

//评论的样式
typedef enum{
    SSCommentListViewTypeNormal,//普通，没有section, 默认为该样式
    SSCommentListViewTypeHotSection//展示区分最热Section和普通section
}SSCommentListViewType;

