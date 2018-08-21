//
//  TTContactsGuideManager.h
//  Article
//  上传通讯录相关策略管理
//
//  Created by Jiyee Sheng on 6/30/17.
//
//

/**
 * 通讯录弹窗类型
 */
typedef NS_ENUM(NSInteger, TTContactsGuideViewType) {
    TTContactsGuideViewUnknown = 0, // 数据异常
    TTContactsGuideViewNoRedPacket = 1, // 通讯录弹窗
    TTContactsGuideViewRedPacket = 2, // 通讯录红包弹窗
};

/**
 * 通讯录红包状态
 */
typedef NS_ENUM(NSInteger, TTContactsRedPacketStatus) {
    TTContactsRedPacketUnavailable = 0,
    TTContactsRedPacketAvailable = 1,
    TTContactsRedPacketUsed = 2,
};

@interface TTContactsGuideManager : NSObject

+ (instancetype)sharedManager;

/**
 * 自动上传通讯录，根据 settings 下发的时间间隔和
 */
+ (void)autoUploadContactsIfNeeded;

/**
 * 根据缓存的服务端检查结果，弹出通讯录弹窗
 */
- (void)presentContactsGuideView;

/**
 * 请求通讯录弹窗服务端检查，如果有效则立即弹窗
 */
- (void)checkContactsValidation;

/**
 * 是否应该请求通讯录弹窗检查接口
 * @return
 */
- (BOOL)shouldCheckContactsValidation;

/**
 * 是否应该弹出通讯录弹窗，弹窗类型通过 presentingContactsGuideViewType 获取
 * @return 是否应该弹出通讯录弹窗
 */
- (BOOL)shouldPresentContactsGuideView;

/**
 * 本地缓存的通讯录弹窗数据
 * @return
 */
- (FRUserRelationContactcheckResponseModel *)contactsCheckResultInUserDefaults;

/**
 * 记录此次通讯录弹窗已经弹出过，作为此次的服务端检查数据就此终止
 */
- (void)setContactsGuideHasPresented;

/**
 * 通讯录弹窗次数, 不区分类型
 */
- (NSInteger)contactsGuidePresentingTimes;

/**
 * 弹出 loading 弹框
 * @param text 弹框里的文案
 */
- (void)showIndicatorView:(NSString *)text;

/**
 * 隐藏 loading 弹框
 */
- (void)hideIndicatorView;

/**
 * 用户是否停留在首页 Tab
 * @return
 */
- (BOOL)isUserStayInExploreMainViewController;

/**
 * Feed 流是否处于推荐频道
 * @return
 */
- (BOOL)isCurrentExploreCategoryIdEqualsToMainCategoryId;

@end
