//
//  TTActivity.h
//  Article
//
//  Created by 王霖 on 15/9/20.
//
//

#import "SSViewBase.h"
@class TTActivityModel;

typedef NS_ENUM (NSInteger, TTActivityType){
    TTActivityTypeNone = 0,     //取消按钮或点击屏幕其他地方取消
    TTActivityTypeWeixinShare,
    TTActivityTypeWeixinMoment, //微信朋友圈
    TTActivityTypeSinaWeibo,
    TTActivityTypeQQZone,
    TTActivityTypeQQWeibo,
    TTActivityTypeRenRen,
    TTActivityTypeKaiXin,
    TTActivityTypeQQShare,          //手机QQ
    TTActivityTypeZhiFuBao,         //支付宝好友
    TTActivityTypeZhiFuBaoMoment,   //支付宝生活圈
    TTActivityTypeDingTalk,         // 钉钉分享
    TTActivityTypeFacebook,
    TTActivityTypeTwitter,
    TTActivityTypeMyMoment,     //转发到我的动态
    TTActivityTypeShareButton,  //仅仅点击分享按钮
    TTActivityTypeWeitoutiao,   //转发到微头条
    
    //新增顶踩
    TTActivityTypeDigUp,
    TTActivityTypeDigDown,
    
    TTActivityTypePromotion, //号外推广
    //系统分享
    TTActivityTypeSystem,
    // System Actions
    TTActivityTypeMessage,
    TTActivityTypeEMail,
    TTActivityTypeCopy,
    //navigationBar更多按钮; Settings for App
    TTActivityTypePGC,
    TTActivityTypeNightMode,
    TTActivityTypeFontSetting,
    TTActivityTypeReport, //举报
    TTActivityTypeFavorite,
    
    TTActivityTypeDetele,
    TTActivityTypeCantDetele,
    TTActivityTypeAllowComment,
    TTActivityTypeForbidComment,
    TTActivityTypeEdit,
    TTActivityTypeCantEdit,
    
    //对此推荐是否感兴趣
    TTActivityTypeDislike,
    
    TTActivityTypeBlockUser, //拉黑
    TTActivityTypeUnBlockUser, //取消拉黑
    
    TTActivityTypeSaveVideo,//保存视频
    TTActivityTypeCommodity,//视频特卖
    
};

@protocol TTActivityDelegate;

@interface TTActivity : SSViewBase

@property (nonatomic, strong) UIView *nightModeMaskView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, retain) NSString *count;
@property (nonatomic, weak)   id<TTActivityDelegate>delegate;


+ (TTActivity *)activityOfDigUpWithCount:(NSString *) count;
+ (TTActivity *)activityOfDigDownWithCount:(NSString *) count;
+ (TTActivity *)activityOfCopy;
+ (TTActivity *)activityOfMyMoment;
+ (TTActivity *)activityOfCopyContent;
+ (TTActivity *)activityOfWeixin;
+ (TTActivity *)activityOfWeixinMoment;
+ (TTActivity *)activityOfFacebookShare;
+ (TTActivity *)activityOfTwitterShare;
+ (TTActivity *)activityOfMailShare;
+ (TTActivity *)activityOfMessageShare;
+ (TTActivity *)activityOfQQShare;
+ (TTActivity *)activityOfSinaWeiboShare;
+ (TTActivity *)activityOfQQWeiboShare;
+ (TTActivity *)activityOfKaiXinShare;
+ (TTActivity *)activityOfRenRenShare;
+ (TTActivity *)activityOfQQZoneShare;
+ (TTActivity *)activityOfPGCWithAvatarUrl:(NSString *)url showName:(NSString *)showName;
+ (TTActivity *)activityOfNightMode;
+ (TTActivity *)activityOfFontSetting;
+ (TTActivity *)activityOfReport;
+ (TTActivity *)activityOfFavorite;
+ (TTActivity *)activityOfVideoFavorite;
+ (TTActivity *)activityOfZhiFuBao;
+ (TTActivity *)activityOfZhiFuBaoMoment;
+ (TTActivity *)activityOfDingTalk;
+ (TTActivity *)activityOfSystem;

+ (TTActivity *)activityOfDelete;
+ (TTActivity *)activityOfCantDelete;
+ (TTActivity *)activityOfAllowComment;
+ (TTActivity *)activityOfForbidComment;
+ (TTActivity *)activityOfEdit;
+ (TTActivity *)activityOfCantEdit;

+ (TTActivity *)activityOfDislike;

+ (TTActivity *)activityOfBlockUser;
+ (TTActivity *)activityOfUnBlockUser;

+ (TTActivity *)activityOfWeitoutiao;

+ (TTActivity *)activityOfSaveVideo;
+ (TTActivity *)activityOfVideoCommodity;

- (TTActivityType)activityType;
- (NSString *)activityTitle;      // default returns nil. subclass must override and must return non-nil value
- (UIImage *)activityImage;       // default returns nil. subclass must override and must return non-nil value
- (NSString *)activityImageName;  // default returns nil. subclass must override and must return non-nil value
- (NSString *)activityImageUrl; // default returns nil. subclass must override and must return non-nil value

- (void)setImageWithUrl:(NSString *)url placeholder:(UIImage *)placeholder;

- (void)performActionIfSelected;//选中后执行的方法

@end


@protocol TTActivityDelegate <NSObject>

@optional
- (void)activity:(TTActivity*)activity activityButtonClicked:(TTActivityType)type;

@end

/**
 * 号外入口 图标
 */
@interface TTActivity(TTAdPromotion)

+ (instancetype)activityWithModel:(TTActivityModel *)model;

@end
