//
//  TTActivity.m
//  Article
//
//  Created by 王霖 on 15/9/20.
//
//

#import "TTActivity.h"
#import "SSThemed.h"
#import "UIImageView+WebCache.h"
#import "TTQQShare.h"
#import "TTThirdPartyAccountsHeader.h"
#import "SSCommonLogic.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"
#import "SSCommonLogic.h"
#import <TTURLUtils.h>
//#import "TTWeitoutiaoRepostIconDownloadManager.h"
#import "TTAdPromotionManager.h"
#import <TTKitchen/TTKitchen.h>
#import <BDWebImage/SDWebImageAdapter.h>

#pragma mark - Class Cluster

#pragma mark -- _TTDigUpActivity
@interface _TTDigUpActivity : TTActivity @end

@implementation _TTDigUpActivity

- (_TTDigUpActivity *) initWithCount:(NSString *) count
{
    self = [super init];
    if(self){
        self.count = count;
    }
    return self;
}

- (TTActivityType)activityType
{
    return TTActivityTypeDigUp;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"顶 ", nil);
}

- (NSString *)activityImageName
{
    return @"digup_allshare";
}

@end


#pragma mark -- _TTDigDownActivity
@interface _TTDigDownActivity : TTActivity @end

@implementation _TTDigDownActivity

- (_TTDigDownActivity *) initWithCount:(NSString *) count
{
    self = [super init];
    if(self){
        self.count = count;
    }
    return self;
}

- (TTActivityType)activityType
{
    return TTActivityTypeDigDown;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"踩 ", nil);
}

- (NSString *)activityImageName
{
    return @"digdown_allshare";
}

@end


#pragma mark -- _TTCopyActivity
@interface _TTCopyActivity : TTActivity @end

@implementation _TTCopyActivity

- (TTActivityType)activityType
{
    return TTActivityTypeCopy;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"复制链接", nil);
}

- (NSString *)activityImageName
{
    return @"copy_allshare";
}

@end

#pragma mark -- _TTMyMomentActivity
@interface _TTMyMomentActivity : TTActivity @end
@implementation _TTMyMomentActivity

- (TTActivityType)activityType
{
    return TTActivityTypeMyMoment;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"我的动态", nil);
}

- (NSString *)activityImageName
{
    return @"topic_allshare";
}

@end

#pragma mark -- _TTCopyContentActivity
@interface _TTCopyContentActivity : TTActivity @end
@implementation _TTCopyContentActivity

- (TTActivityType)activityType
{
    return TTActivityTypeCopy;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"复制正文", nil);
}

- (NSString *)activityImageName
{
    return @"copy_allshare";
}

@end

#pragma mark -- _TTWeixinActivity
@interface _TTWeixinActivity : TTActivity @end
@implementation _TTWeixinActivity

- (TTActivityType)activityType
{
    return TTActivityTypeWeixinShare;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"微信", nil);
}

- (NSString *)activityImageName
{
    return @"weixin_allshare";
}

@end

#pragma mark -- _TTWeiXinMomentActivity
@interface _TTWeiXinMomentActivity : TTActivity @end
@implementation _TTWeiXinMomentActivity

- (TTActivityType)activityType
{
    return TTActivityTypeWeixinMoment;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"朋友圈", nil);
}

- (NSString *)activityImageName
{
    return @"pyq_allshare";
}

@end

#pragma mark -- _TTFacebookShareActivity
@interface _TTFacebookShareActivity : TTActivity @end
@implementation _TTFacebookShareActivity

- (TTActivityType)activityType
{
    return TTActivityTypeFacebook;
}

- (NSString *)activityTitle
{
    return @"Facebook";
}

- (UIImage *)activityImage
{
    return [UIImage themedImageNamed:@"facebook_popover.png"];
}

@end

#pragma mark -- _TTTwitterShareActivity
@interface _TTTwitterShareActivity : TTActivity @end
@implementation _TTTwitterShareActivity

- (TTActivityType)activityType
{
    return TTActivityTypeTwitter;
}

- (NSString *)activityTitle
{
    return @"Twitter";
}

- (UIImage *)activityImage
{
    return [UIImage themedImageNamed:@"twitter_popover.png"];
}

@end

#pragma mark -- _TTMailShareActivity
@interface _TTMailShareActivity : TTActivity @end
@implementation _TTMailShareActivity

- (TTActivityType)activityType
{
    return TTActivityTypeEMail;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"邮件", nil);
}

- (NSString *)activityImageName
{
    return @"mail_allshare";
}

@end

#pragma mark -- _TTMessageShareActivity
@interface _TTMessageShareActivity : TTActivity @end
@implementation _TTMessageShareActivity

- (TTActivityType)activityType
{
    return TTActivityTypeMessage;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"短信", nil);
}

- (NSString *)activityImageName
{
    return @"message_allshare";
}
@end

#pragma mark -- _TTQQShareActivity
@interface _TTQQShareActivity : TTActivity @end
@implementation _TTQQShareActivity

- (TTActivityType)activityType
{
    return TTActivityTypeQQShare;
}

- (NSString *)activityTitle
{
    if ([SSCommonLogic isZoneVersion]) {
        return NSLocalizedString(@"QQ", nil);
    }else{
        return NSLocalizedString(@"QQ", nil);
    }
}

- (NSString *)activityImageName
{
    return @"qq_allshare";
}

@end

#pragma mark -- _TTSinaWeiboShareActivity
@interface _TTSinaWeiboShareActivity : TTActivity @end
@implementation _TTSinaWeiboShareActivity

- (TTActivityType)activityType
{
    return TTActivityTypeSinaWeibo;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"微博", nil);
}

- (NSString *)activityImageName
{
    return @"sina_allshare";
}

@end

#pragma mark -- _TTQQWeiboShareActivity
@interface _TTQQWeiboShareActivity : TTActivity @end
@implementation _TTQQWeiboShareActivity

- (TTActivityType)activityType
{
    return TTActivityTypeQQWeibo;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"腾讯微博", nil);
}

- (NSString *)activityImageName
{
    return @"qqwb_allshare";
}

@end

#pragma mark -- _TTKaiXinShareActivity
@interface _TTKaiXinShareActivity : TTActivity @end
@implementation _TTKaiXinShareActivity

- (TTActivityType)activityType
{
    return TTActivityTypeKaiXin;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"开心网", nil);
}

- (UIImage *)activityImage
{
    return [UIImage themedImageNamed:@"kaixin_popover"];
}

@end

#pragma mark -- _TTRenRenShareActivity
@interface _TTRenRenShareActivity : TTActivity @end
@implementation _TTRenRenShareActivity

- (TTActivityType)activityType
{
    return TTActivityTypeRenRen;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"人人网", nil);
}

- (NSString *)activityImageName
{
    return @"renren_allshare";
}

@end

#pragma mark -- _TTQQZoneShareActivity
@interface _TTQQZoneShareActivity : TTActivity @end
@implementation _TTQQZoneShareActivity

- (TTActivityType)activityType
{
    return TTActivityTypeQQZone;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"QQ空间", nil);
}

- (NSString *)activityImageName
{
    return @"qqkj_allshare";
}
@end

#pragma mark -- _TTPGCActivity
@interface _TTPGCActivity : TTActivity
@property(nonatomic, retain) NSString *url;
@property(nonatomic, retain) NSString *showName;
@end
@implementation _TTPGCActivity

- (_TTPGCActivity *)initWithAvatarUrl:(NSString *)url showName:(NSString *)showName
{
    self = [super init];
    if (self) {
        _url = url;
        _showName = showName;
        if (!isEmptyString(_url)) {
            [self setImageWithUrl:_url
                      placeholder:[UIImage themedImageNamed:@"pgcloading_allshare.png"]];
        }
        self.iconImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel] * 2;
        [self reloadThemeUI];
    }
    return self;
}

- (TTActivityType)activityType
{
    return TTActivityTypePGC;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    if (!isDayModel) {
        [self.nightModeMaskView setHidden:NO];
    } else {
        [self.nightModeMaskView setHidden:YES];
    }
    self.iconImageView.layer.borderColor = [SSGetThemedColorInArray(@[@"cacaca", @"363636"]) CGColor];
}

- (NSString *)activityTitle
{
    return isEmptyString(_showName) ? NSLocalizedString(@"查看头条号", nil) : _showName;
}

- (NSString *)activityImageUrl
{
    return _url;
}

@end

#pragma mark -- _TTNightModeActivity
@interface _TTNightModeActivity : TTActivity @end
@implementation _TTNightModeActivity

- (TTActivityType)activityType
{
    return TTActivityTypeNightMode;
}

- (NSString *)activityTitle
{
    if(([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay))
    {
        return NSLocalizedString(@"夜间模式", nil);
    }
    else{
        return NSLocalizedString(@"日间模式", nil);
    }
}

- (NSString *)activityImageName
{
    if(([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay))
    {
        return @"night_allshare";
    }
    else
    {
        return @"day_allshare";
    }
}
@end

#pragma mark -- _TTFontSettingActivity
@interface _TTFontSettingActivity : TTActivity @end
@implementation _TTFontSettingActivity

- (TTActivityType)activityType
{
    return TTActivityTypeFontSetting;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"字体设置", nil);
}

- (NSString *)activityImageName
{
    return @"type_allshare";
}

@end

#pragma mark -- _TTReportActivity
@interface _TTReportActivity : TTActivity @end
@implementation _TTReportActivity

- (TTActivityType)activityType
{
    return TTActivityTypeReport;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"举报", nil);
}

- (NSString *)activityImageName
{
    return @"report_allshare";
}

@end

#pragma mark -- _TTFavoriteActivity
@interface _TTFavoriteActivity : TTActivity @end
@implementation _TTFavoriteActivity

- (TTActivityType)activityType
{
    return TTActivityTypeFavorite;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"收藏", nil);
}

- (NSString *)activityImageName
{
    return @"love_allshare";
}

@end

#pragma mark -- _TTVideoFavoriteActivity
@interface _TTVideoFavoriteActivity : TTActivity @end
@implementation _TTVideoFavoriteActivity

- (TTActivityType)activityType
{
    return TTActivityTypeFavorite;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"收藏", nil);
}

- (NSString *)activityImageName
{
    return @"love_allshare";
}

@end

#pragma mark -- _TTZhiFuBaoActivity
@interface _TTZhiFuBaoActivity : TTActivity @end
@implementation _TTZhiFuBaoActivity

- (TTActivityType)activityType
{
    return TTActivityTypeZhiFuBao;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"支付宝", nil);
}

- (NSString *)activityImageName
{
    return @"aliplay_allshare";
}

@end

#pragma mark -- _TTZhiFuBaoMomentActivity
@interface _TTZhiFuBaoMomentActivity : TTActivity @end
@implementation _TTZhiFuBaoMomentActivity

- (TTActivityType)activityType
{
    return TTActivityTypeZhiFuBaoMoment;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"支付宝生活圈", nil);
}

- (NSString *)activityImageName
{
    return @"alishq_allshare";
}

@end

#pragma mark -- _TTDingTalkActivity
@interface _TTDingTalkActivity : TTActivity

@end

@implementation _TTDingTalkActivity

- (TTActivityType)activityType {
    return TTActivityTypeDingTalk;
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"钉钉", nil);
}

- (NSString *)activityImageName {
    return @"dingding_allshare";
}

@end

#pragma mark -- _TTSystemActivity
@interface _TTSystemActivity : TTActivity @end
@implementation _TTSystemActivity

- (TTActivityType)activityType
{
    return TTActivityTypeSystem;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"系统分享", nil);
}

- (NSString *)activityImageName
{
    return @"airdrop_allshare";
}

@end

#pragma mark -- _TTDeleteActivity
@interface _TTDeleteActivity : TTActivity @end
@implementation _TTDeleteActivity

- (TTActivityType)activityType
{
    return TTActivityTypeDetele;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"删除", nil);
}

- (NSString *)activityImageName
{
    return @"delete_allshare";
}

@end

#pragma mark -- _TTCantDeleteActivity
@interface _TTCantDeleteActivity : TTActivity @end
@implementation _TTCantDeleteActivity

- (TTActivityType)activityType
{
    return TTActivityTypeCantDetele;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"删除", nil);
}

- (NSString *)activityImageName
{
    return @"delete_allshare_disable";
}

@end

#pragma mark -- _TTAllowCommentActivity
@interface _TTAllowCommentActivity : TTActivity @end
@implementation _TTAllowCommentActivity

- (TTActivityType)activityType
{
    return TTActivityTypeAllowComment;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"允许评论", nil);
}

- (NSString *)activityImageName
{
    return @"allow_comments_allshare";
}

@end

#pragma mark -- _TTForbidCommentActivity
@interface _TTForbidCommentActivity : TTActivity @end
@implementation _TTForbidCommentActivity

- (TTActivityType)activityType
{
    return TTActivityTypeForbidComment;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"禁止评论", nil);
}

- (NSString *)activityImageName
{
    return @"unlike_allshare";
}

@end

#pragma mark -- _TTEditActivity
@interface _TTEditActivity : TTActivity @end
@implementation _TTEditActivity

- (TTActivityType)activityType
{
    return TTActivityTypeEdit;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"编辑", nil);
}

- (NSString *)activityImageName
{
    return @"editor_allshare";
}

@end
#pragma mark -- _TTCantEditActivity
@interface _TTCantEditActivity : TTActivity @end
@implementation _TTCantEditActivity

- (TTActivityType)activityType
{
    return TTActivityTypeCantEdit;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"编辑", nil);
}

- (NSString *)activityImageName
{
    return @"editor_allshare_disable";
}

@end
#pragma mark -- _TTDislikeActivity
@interface _TTDislikeActivity : TTActivity @end
@implementation _TTDislikeActivity

- (TTActivityType)activityType
{
    return TTActivityTypeDislike;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"不感兴趣", nil);
}

- (NSString *)activityImageName
{
    return @"unlike_allshare";
}

@end

@interface _TTBlockUserActivity : TTActivity
@end
@implementation _TTBlockUserActivity
- (TTActivityType)activityType {
    return TTActivityTypeBlockUser;
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"拉黑", nil);
}

- (NSString *)activityImageName {
    return @"shield_allshare";
}
@end

@interface _TTUnBlockUserActivity : TTActivity
@end
@implementation _TTUnBlockUserActivity
- (TTActivityType)activityType {
    return TTActivityTypeUnBlockUser;
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"取消拉黑", nil);
}

- (NSString *)activityImageName {
    return @"shield_allshare";
}
@end

@interface _TTWeitoutiaoActivity : TTActivity
@property (nonatomic, strong) UIImage * dayImage;
@property (nonatomic, strong) UIImage * nightImage;
@end
@implementation _TTWeitoutiaoActivity

- (TTActivityType)activityType {
    return TTActivityTypeWeitoutiao;
}

- (NSString *)activityTitle {
    return [TTKitchen getString:kTTKUGCRepostWordingShareIconTitle];
}

- (UIImage *)activityImage {
//    UIImage * dayImage = [[TTWeitoutiaoRepostIconDownloadManager sharedManager] getWeitoutiaoRepostDayIcon];
//    UIImage * nightImage = [[TTWeitoutiaoRepostIconDownloadManager sharedManager] getWeitoutiaoRepostNightIcon];
//    if (nil == dayImage || nil == nightImage) {
//        //使用本地图片
        self.dayImage = [UIImage imageNamed:@"share_toutiaoweibo"];
        self.nightImage = [UIImage imageNamed:@"share_toutiaoweibo_night"];
//    }else {
//        //网络图片已下载
//        self.dayImage = dayImage;
//        self.nightImage = nightImage;
//    }
    if (TTThemeModeDay == [[TTThemeManager sharedInstance_tt] currentThemeMode]) {
        return self.dayImage;
    }else {
        return self.nightImage;
    }
}

@end

@interface _TTSaveVideoActivity : TTActivity
@end

@implementation _TTSaveVideoActivity
- (TTActivityType)activityType {
    return TTActivityTypeSaveVideo;
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"保存视频", nil);
}

- (NSString *)activityImageName {
    return @"hs_download_allshare";
}
@end


#pragma mark -- _TTDigDownActivity
@interface _TTCommodityActivity : TTActivity @end

@implementation _TTCommodityActivity

- (TTActivityType)activityType
{
    return TTActivityTypeCommodity;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"推荐商品", nil);
}

- (UIImage *)activityImage
{
    return [UIImage themedImageNamed:[self activityImageName]];
}

- (NSString *)activityImageName
{
    return @"video_commodity_goods";
}

@end

#pragma mark - Base Class

@interface TTActivity ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *activityButton;

@end

@implementation TTActivity

+ (TTActivity *)activityOfDigUpWithCount:(NSString *)count{
    return [[_TTDigUpActivity alloc] initWithCount:count];
}
+ (TTActivity *)activityOfDigDownWithCount:(NSString *)count{
    return [[_TTDigDownActivity alloc] initWithCount:count];
}
+ (TTActivity *)activityOfCopy {
    return [[_TTCopyActivity alloc] init];
}
+ (TTActivity *)activityOfMyMoment {
    return [[_TTMyMomentActivity alloc] init];
}
+ (TTActivity *)activityOfCopyContent {
    return [[_TTCopyContentActivity alloc] init];
}
+ (TTActivity *)activityOfWeixin {
    return [[_TTWeixinActivity alloc] init];
}
+ (TTActivity *)activityOfWeixinMoment {
    return [[_TTWeiXinMomentActivity alloc] init];
}
+ (TTActivity *)activityOfFacebookShare {
    return [[_TTFacebookShareActivity alloc] init];
}
+ (TTActivity *)activityOfTwitterShare {
    return [[_TTTwitterShareActivity alloc] init];
}
+ (TTActivity *)activityOfMailShare {
    return [[_TTMailShareActivity alloc] init];
}
+ (TTActivity *)activityOfMessageShare {
    return [[_TTMessageShareActivity alloc] init];
}
+ (TTActivity *)activityOfQQShare {
    return [[_TTQQShareActivity alloc] init];
}
+ (TTActivity *)activityOfSinaWeiboShare {
    return [[_TTSinaWeiboShareActivity alloc] init];
}
+ (TTActivity *)activityOfQQWeiboShare {
    return [[_TTQQWeiboShareActivity alloc] init];
}
+ (TTActivity *)activityOfKaiXinShare {
    return [[_TTKaiXinShareActivity alloc] init];
}
+ (TTActivity *)activityOfRenRenShare {
    return [[_TTRenRenShareActivity alloc] init];
}
+ (TTActivity *)activityOfQQZoneShare {
    return [[_TTQQZoneShareActivity alloc] init];
}
+ (TTActivity *)activityOfPGCWithAvatarUrl:(NSString *)url showName:(NSString *)showName {
    return [[_TTPGCActivity alloc] initWithAvatarUrl:url showName:showName];
}
+ (TTActivity *)activityOfNightMode {
    return [[_TTNightModeActivity alloc] init];
}
+ (TTActivity *)activityOfFontSetting {
    return [[_TTFontSettingActivity alloc] init];
}
+ (TTActivity *)activityOfReport {
    return [[_TTReportActivity alloc] init];
}
+ (TTActivity *)activityOfFavorite {
    return [[_TTFavoriteActivity alloc] init];
}
+ (TTActivity *)activityOfVideoFavorite {
    return [[_TTVideoFavoriteActivity alloc] init];
}
+ (TTActivity *)activityOfZhiFuBao {
    return [[_TTZhiFuBaoActivity alloc] init];
}
+ (TTActivity *)activityOfZhiFuBaoMoment {
    return [[_TTZhiFuBaoMomentActivity alloc] init];
}
+ (TTActivity *)activityOfDingTalk {
    return [[_TTDingTalkActivity alloc] init];
}
+ (TTActivity *)activityOfSystem {
    return [[_TTSystemActivity alloc] init];
}

+ (TTActivity *)activityOfDelete{
    return [[_TTDeleteActivity alloc] init];
}
+ (TTActivity *)activityOfCantDelete{
    return [[_TTCantDeleteActivity alloc] init];
}
+ (TTActivity *)activityOfAllowComment{
    return [[_TTAllowCommentActivity alloc] init];
}
+ (TTActivity *)activityOfForbidComment{
    return [[_TTForbidCommentActivity alloc] init];
}
+ (TTActivity *)activityOfEdit{
    return [[_TTEditActivity alloc] init];
}
+ (TTActivity *)activityOfCantEdit{
    return [[_TTCantEditActivity alloc] init];
}
+ (TTActivity *)activityOfDislike
{
    return [[_TTDislikeActivity alloc] init];
}

+ (TTActivity *)activityOfBlockUser {
    return [_TTBlockUserActivity new];
}

+ (TTActivity *)activityOfUnBlockUser {
    return [_TTUnBlockUserActivity new];
}

+ (TTActivity *)activityOfWeitoutiao {
    return [_TTWeitoutiaoActivity new];
}

+ (TTActivity *)activityOfSaveVideo {
    return [_TTSaveVideoActivity new];
}

+ (TTActivity *)activityOfVideoCommodity
{
    return [[_TTCommodityActivity alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.iconImageView = [[UIImageView alloc] initWithImage:[self activityImage]];
        
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconImageView.clipsToBounds = YES;
        _iconImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_iconImageView];
        
        self.nightModeMaskView = [[UIView alloc] init];
        self.nightModeMaskView.clipsToBounds = YES;
        _nightModeMaskView.backgroundColor = [UIColor blackColor];
        _nightModeMaskView.alpha = 0.5f;
        [_nightModeMaskView setHidden:YES];
        [self addSubview:_nightModeMaskView];
        
        self.titleLabel =  [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [_titleLabel setText:[self activityTitle]];
        [_titleLabel sizeToFit];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleLabel setFont:[UIFont systemFontOfSize:([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? 11.f : 10.f)]];
        [self addSubview:_titleLabel];
        
        self.activityButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _activityButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_activityButton addTarget:self action:@selector(activityButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_activityButton];
        
        [self reloadThemeUI];
    }
    
    return self;
}

- (void)setImageWithUrl:(NSString *)url placeholder:(UIImage *)placeholder
{
    [self.iconImageView sda_setImageWithURL:[TTStringHelper URLWithURLString:url] placeholderImage:placeholder];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    UIImage *image = [self activityImage];
    if (image) {
        _iconImageView.image = image;
    }
    
    [_titleLabel setText:[self activityTitle]];
    [_titleLabel setTextColor:SSGetThemedColorWithKey(kColorText1)];
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;

    if (!isDayModel) {
        _iconImageView.alpha = 0.7f;
    } else {
        _iconImageView.alpha = 1.0f;
    }
}

- (void)activityButtonClicked
{
    [self performActionIfSelected];
    if (_delegate && [_delegate respondsToSelector:@selector(activity:activityButtonClicked:)]) {
        [_delegate activity:self activityButtonClicked:[self activityType]];
    }
}

- (void)refreshSubViewFrame
{
    CGRect frame = CGRectZero;
    frame.size.width = frame.size.height = self.frame.size.width;
    _iconImageView.frame = frame;
    _nightModeMaskView.frame = frame;
    _activityButton.frame = _iconImageView.bounds;

    _titleLabel.origin = CGPointMake((self.frame.size.width - _titleLabel.frame.size.width) / 2.f, CGRectGetMaxY(_iconImageView.frame) + 8);
    _iconImageView.layer.cornerRadius = CGRectGetWidth(_iconImageView.frame)/2;
    _nightModeMaskView.layer.cornerRadius = CGRectGetWidth(_iconImageView.frame)/2;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshSubViewFrame];
}

#pragma mark -- data source

- (TTActivityType)activityType
{
    return TTActivityTypeNone;
}

- (NSString *)activityTitle
{
    return nil;
}

- (UIImage *)activityImage
{
    return [UIImage themedImageNamed:[self activityImageName]];
}

- (NSString *)activityImageName
{
    return nil;
}

- (NSString *)activityImageUrl
{
    return nil;
}

- (void)performActionIfSelected { }

@end

@interface _TTActivityOfPromotion : TTActivity
@property (nonatomic, strong) TTActivityModel *model;
@end

@implementation _TTActivityOfPromotion

- (instancetype)initWithModel:(TTActivityModel *)model {
    self = [super init];
    if (self) {
        _model = model;
        if (!isEmptyString(model.icon_url)) {
            [self setImageWithUrl:model.icon_url placeholder:[UIImage themedImageNamed:@"pgcloading_allshare.png"]];
        }
        [self reloadThemeUI];
    }
    return self;
}

- (TTActivityType)activityType {
    return TTActivityTypePromotion;
}

- (NSString *)activityImageUrl {
    return self.model.icon_url;
    
}

- (NSString *)activityTitle {
    return self.model.label;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    [self.nightModeMaskView setHidden:isDayModel];
}

@end

@implementation TTActivity (TTAdPromotion)

+ (instancetype)activityWithModel:(TTActivityModel *)model {
    _TTActivityOfPromotion *activity = [[_TTActivityOfPromotion alloc] initWithModel:model];
    return activity;
}

@end
