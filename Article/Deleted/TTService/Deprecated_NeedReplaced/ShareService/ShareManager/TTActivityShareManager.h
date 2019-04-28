//
//  TTActivityShareManager.h
//  Article
//
//  Created by 王霖 on 15/9/20.
//
//

#import <Foundation/Foundation.h>
#import "TTGroupModel.h"
#import "TTActivity.h"
#import <TTShareMacros.h>

@class TTActivityShareManager;

@protocol TTActivityShareManagerDelegate <NSObject>

@optional
- (void)activityShareManager:(nonnull TTActivityShareManager *)activityShareManager
    completeWithActivityType:(TTActivityType)activityType
                       error:(nullable NSError *)error;

@end

/**
 *  TTActivityShareManager保存待分享的数据，并且根据TTActivityType完成相应的分享动作。
 */
@interface TTActivityShareManager : NSObject

@property (nonatomic, weak)id <TTActivityShareManagerDelegate> _Nullable delegate;

#pragma mark -- weixin
@property(nonatomic, copy)NSString * _Nullable weixinTitleText;       //微信
@property(nonatomic, copy)NSString * _Nullable weixinText;
@property(nonatomic, copy)NSString * _Nullable weixinMomentText;      //微信朋友圈


#pragma mark -- dingtalk
@property (nonatomic, copy) NSString *_Nullable dingtalkTitleText; // 钉钉
@property (nonatomic, copy) NSString *_Nullable dingtalkText;

#pragma mark -- qq
@property(nonatomic, copy)NSString * _Nullable qqShareTitleText;      //手机QQ
@property(nonatomic, copy)NSString * _Nullable qqShareText;

#pragma mark -- sns
@property(nonatomic, copy)NSString * _Nullable sinaWeiboText;
@property(nonatomic, copy)NSString * _Nullable qqZoneText;        //QQ空间
@property(nonatomic, copy)NSString * _Nullable qqZoneTitleText;

#pragma mark -- message
@property(nonatomic, copy)NSString * _Nullable messageText;     //短信

#pragma mark -- mail
@property(nonatomic, copy)NSString * _Nullable mailSubject;
@property(nonatomic, copy)NSString * _Nullable mailBody;
@property(nonatomic, copy)NSData   * _Nullable mailData;
@property(nonatomic, assign)BOOL     mailBodyIsHTML;

#pragma mark -- system
@property(nonatomic, copy)NSString * _Nullable systemShareText;
@property(nonatomic, copy)NSString * _Nullable systemShareUrl;
@property(nonatomic, copy)UIImage   * _Nullable systemShareImage;

#pragma mark -- fb
@property(nonatomic, copy)NSString * _Nullable facebookText;

#pragma mark -- twitter
@property(nonatomic, copy)NSString * _Nullable twitterText;

#pragma mark -- copy
@property(nonatomic, copy, getter=theCopyText)NSString * _Nullable copyText;      // 复制本文链接
@property(nonatomic, copy, getter=theCopyContent)NSString * _Nullable copyContent;   // 复制正文

#pragma mark -- all
@property(nonatomic, assign)BOOL    hasImg;     //default NO
@property(nonatomic, copy)NSString * _Nullable itemTag;
@property(nonatomic, retain)UIImage * _Nullable shareImage;
@property(nonatomic, assign)BOOL useDefaultImage; //没有取得图片，使用的比如icon的默认图片
@property(nonatomic, copy)NSString *_Nullable shareImageURL;
//added 4.9:晓东让改分享到朋友圈和QZone的图片
//https://jira.bytedance.com/browse/XWTT-3398
@property(nonatomic, retain)UIImage * _Nullable shareToWeixinMomentOrQZoneImage;
@property(nonatomic, retain)UIImage * _Nullable shareToWeixinMomentScreenQRCodeImage;
@property(nonatomic, assign)BOOL sendItemActionStatistics;//发送统计, 默认YES
@property(nonatomic, copy)NSString * _Nullable adID;
@property(nonatomic, strong) TTGroupModel *_Nullable groupModel;
@property(nonatomic, strong) NSString *_Nullable clickSource;
//必须传的参数
@property(nonatomic, copy)NSString * _Nullable mediaID;    //如果是分享一个Group信息， 传入groupID；如果分享一个PGCAccount，传入mediaID
@property(nonatomic, copy)NSString * _Nullable shareURL;
@property(nonatomic, assign)BOOL isShareMedia;//是否是分享媒体， 默认为NO

/**
 *  added 5.4:图集单张图片分享，走各sdk图片分享方式
 */
@property(nonatomic, strong)UIImage * _Nullable shareImageStyleImage;
@property(nonatomic, copy) NSString * _Nullable shareImageStyleImageURL;

@property(nonatomic, assign) BOOL forwardToWeitoutiao;
//ArticleSubType
@property(nonatomic, assign) BOOL miniProgramEnable;

//是否是视频,决定分享的图片是否需要合成视频播放icon【三角、摄像机】，非必传
@property(nonatomic, assign) BOOL isVideoSubject;
//视频share_done 事件需要用埋点字段
@property(nonatomic, copy) NSString * _Nullable authorId;


/**
 *  返回TTActivity数组
 *
 *  @return TTActivity数组
 */
- (nonnull NSMutableArray *)defaultShareItems;

/**
 *  根据当前已经设置的property条件，调整activitys, 需要设置完所有property后调用
 */
- (void)refreshActivitys;
- (void)refreshActivitysWithReport:(BOOL)containReport;
- (void)refreshActivitysWithReport:(BOOL)containReport withQQ:(BOOL)qq;
- (void)refreshActivitysForSingleGallery;

/**
 *  生成个人中心的activity items
 */
- (void)refreshActivitysForProfileWithAccountUser:(BOOL)isAccountUser isBlocking:(BOOL)isBlocking;

/**
 *  清空所有已经设置的property条件
 */
- (void)clearCondition;

- (void)performActivityActionByType:(TTActivityType)activityType inViewController:(nonnull UIViewController *)tController sourceObjectType:(TTShareSourceObjectType)sourceType;

- (void)performActivityActionByType:(TTActivityType)activityType inViewController:(nonnull UIViewController *)tController sourceObjectType:(TTShareSourceObjectType)sourceType uniqueId:(nullable NSString *)uniqueId;

- (void)performActivityActionByType:(TTActivityType)activityType inViewController:(nonnull UIViewController *)tController sourceObjectType:(TTShareSourceObjectType)sourceType uniqueId:(nullable NSString *)uniqueId adID:(nullable NSString *)adID;

- (void)performActivityActionByType:(TTActivityType)activityType inViewController:(nonnull UIViewController *)tController sourceObjectType:(TTShareSourceObjectType)sourceType uniqueId:(nullable NSString *)uniqueId adID:(nullable NSString *)adID platform:(TTSharePlatformType)platformType groupFlags:(nullable NSNumber *)flags;

- (void)performActivityActionByType:(TTActivityType)activityType inViewController:(nonnull UIViewController *)tController sourceObjectType:(TTShareSourceObjectType)sourceType uniqueId:(nullable NSString *)uniqueId adID:(nullable NSString *)adID platform:(TTSharePlatformType)platformType groupFlags:(nullable NSNumber *)flags isFullScreenShow:(BOOL)isFullScreen;


/**
 *  复制文本到剪切板
 *
 *  @param text 复制文本到剪切板
 */
+ (void)copyText:(nonnull NSString *)text;



/*********************
 以下统计相关类方法
 *********************/

/**
 *  返回对应于TTShareSourceObjectType的统计tag
 *
 *  @param sourceType 分享源
 *
 *  @return 统计tag
 */
+ (nullable NSString *)tagNameForShareSourceObjectType:(TTShareSourceObjectType)sourceType;

/**
 *  返回对应TTActivityType的统计label
 *
 *  @param activityType activity类型
 *
 *  @return 统计label
 */
+ (nullable NSString *)labelNameForShareActivityType:(TTActivityType)activityType;

/**
 *  use for log2.0
 *
 *  @param activityType 分享类型
 *
 *  @return 打点event字符串
 */
+ (nullable NSString *)shareTargetStrForTTLogWithType:(TTActivityType)activityType;

/**
 *  返回对应于TTActivityType以及分享结果（success）的统计label
 *
 *  @param activityType activity类型
 *  @param success      分享结果
 *
 *  @return 统计label
 */
+ (nullable NSString *)labelNameForShareActivityType:(TTActivityType)activityType shareState:(BOOL)success;

@end
