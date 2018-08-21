//
//  TTVVideoDetailNatantInfoShareView.m
//  Article
//
//  Created by lishuangyang on 2017/10/11.
//

#import "TTVVideoDetailNatantInfoShareView.h"
#import "TTAlphaThemedButton.h"
#import "TTMessageCenter.h"
#import "TTActivityShareSequenceManager.h"
#import "TTWeChatShare.h"
#import "TTQQShare.h"
#import "TTDeviceUIUtils.h"
#import "TTSettingsManager.h"
#import "TTDiggButton.h"

extern NSString * const TTActivityContentItemTypeWechat;
extern NSString * const TTActivityContentItemTypeWechatTimeLine;
extern NSString * const TTActivityContentItemTypeQQFriend;
extern NSString * const TTActivityContentItemTypeQQZone;
//extern NSString * const TTActivityContentItemTypeDingTalk;
extern NSString * const TTActivityContentItemTypeForwardWeitoutiao;
extern BOOL ttvs_isShareIndividuatioEnable(void);
extern NSInteger ttvs_isVideoShowDirectShare(void);

NSString * const TTVVideodetailNatantInfoShareViewDigg = @"com.toutiao.TTVVideodetailNatantInfoShareViewDigg";
NSString * const TTVVideodetailNatantInfoShareViewExtendLink = @"com.toutiao.TTVVideoDetailNatantInfoShareViewExtendLink";
NSString * const TTVVideodetailNatantInfoShareViewShareAction = @"com.toutiao.TTVVideodetailNatantInfoShareViewShareAction";

typedef NS_ENUM(NSInteger, TTVVideoDetailNatantInfoShareViewShareAction)
{
    TTVVideoDetailNatantInfoShareViewShareAction_Digg = 1,
    TTVVideoDetailNatantInfoShareViewShareAction_Moments,
    TTVVideoDetailNatantInfoShareViewShareAction_QQ,
    TTVVideoDetailNatantInfoShareViewShareAction_Qzone,
    TTVVideoDetailNatantInfoShareViewShareAction_Weixin,
    TTVVideoDetailNatantInfoShareViewShareAction_Share,
    TTVVideoDetailNatantInfoShareViewShareAction_Extend
};

#define kNatantInfoShareViewHorizontalPadding [TTDeviceUIUtils tt_newPadding:15]
#define kNatantInfoShareViewGap [TTDeviceUIUtils tt_newPadding:8]
#define kNatantInfoShareDiggViewGap [TTDeviceUIUtils tt_newPadding:7]
#define kNatantInfoShareButtonHeight [TTDeviceUIUtils tt_newPadding:36]
#define kDirectShareBtnImgViewheight [TTDeviceUIUtils tt_newPadding:24]

@interface TTVVideoDetailNatantInfoShareView ()<TTActivityShareSequenceChangedMessage>

@property (nonatomic, strong) TTAlphaThemedButton *firstShareButton;
@property (nonatomic, strong) TTAlphaThemedButton *secondShareButton;
@property (nonatomic, strong) TTDiggButton        *digButton;
@property (nonatomic, strong) TTAlphaThemedButton *videoExtendLinkButton;
@property (nonatomic, strong) TTAlphaThemedButton *shareButton;


@end

@implementation TTVVideoDetailNatantInfoShareView

- (void)dealloc{
    UNREGISTER_MESSAGE(TTActivityShareSequenceChangedMessage, self);
}

- (instancetype)initWithWidth:(CGFloat)width  andinfoModel:(TTVVideoDetailNatantInfoViewModel *)infoModel
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        REGISTER_MESSAGE(TTActivityShareSequenceChangedMessage, self);
        self.viewModel = infoModel;
        [self initializeViews];
        [self themeChanged:nil];
    }
    return self;
}

#pragma mark - initializeViews

- (void)initializeViews
{
    [self addSubview:self.digButton];
    if ([self.viewModel showExtendLink]){
        if (!_videoExtendLinkButton) {
            NSString *title = [_viewModel.infoModel.VExtendLinkDic valueForKey:@"button_text"];
            title = title.length > 0 ? title : @"查看更多";
            if ([_viewModel.infoModel.VExtendLinkDic valueForKey:@"is_download_app"])
            {
                if (title.length <= 0) {
                    title = NSLocalizedString(@"立即下载", nil);
                }
            }
        UIImage *extendImage = [UIImage themedImageNamed:@"link"];
        self.videoExtendLinkButton = [self buttonWithImage:extendImage  title:title itemType:TTVVideodetailNatantInfoShareViewExtendLink];
        [self addSubview:self.videoExtendLinkButton];
        }
    }
    
    if (!self.videoExtendLinkButton ) {
        [self addDirectShareButtons];
    }else{
        [self addShareButton];
    }
}

- (void)addShareButton
{
    if (!_shareButton) {
        UIImage *shareImage = [UIImage themedImageNamed:[self ttv_shareImageIcon]];
        self.shareButton = [self buttonWithImage:shareImage  title:@"分享" itemType:TTVVideodetailNatantInfoShareViewShareAction];
        [self addSubview:self.shareButton];
    }
}

- (NSString *)ttv_shareImageIcon {
    NSInteger shareIconStye = [[[TTSettingsManager sharedManager] settingForKey:@"tt_share_icon_type" defaultValue:@0 freeze:NO] integerValue];
    switch (shareIconStye) {
        case 1:
            return @"tab_share";
            break;
        case 2:
            return @"tab_share1";
            break;
        case 3:
            return @"tab_share4";
            break;
        case 4:
            return @"tab_share3";
            break;
        default:
            return @"tab_share";
            break;
    }
}


- (TTDiggButton *)digButton
{
    if (!_digButton) {
        _digButton = [TTDiggButton diggButtonWithStyleType:TTDiggButtonStyleTypeBoth];
        _digButton.imageName = @"details_like_icon";
        _digButton.selectedImageName = @"details_like_icon_press";
        _digButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, -10, 0, -10);
        _digButton.titleColorThemeKey = kColorText1;
        _digButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _digButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        _digButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        _digButton.layer.cornerRadius = kNatantInfoShareButtonHeight/2;
        _digButton.layer.borderWidth = 0.5f;
        _digButton.manuallySetSelectedEnabled = YES;
        
        __weak typeof(self) wself = self;
        [_digButton setClickedBlock:^(TTDiggButtonClickType type) {
            __strong typeof(wself) self = wself;
            if (self.shareActionBlock) {
                self.shareActionBlock(TTVVideodetailNatantInfoShareViewDigg);
            }
            
        }];

    }
    return _digButton;
}


- (void)configurationDirectShareButtons
{
    [self.firstShareButton removeFromSuperview];
    self.firstShareButton = nil;
    [self.secondShareButton removeFromSuperview];
    self.secondShareButton = nil;
}

- (void)addDirectShareButtons
{
    [self configurationDirectShareButtons];
    NSArray *activitySequenceArr;
    if (!ttvs_isShareIndividuatioEnable()) {
        activitySequenceArr = @[TTActivityContentItemTypeWechatTimeLine, TTActivityContentItemTypeWechat];
    }else{
        activitySequenceArr = [[TTActivityShareSequenceManager sharedInstance_tt] getAllShareServiceSequence];
    }
    
    int hasbutton = 0;
    for (int i = 0; i < activitySequenceArr.count; i++){
        
        id obj = [activitySequenceArr objectAtIndex:i];
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *itemType = (NSString *)obj;
            if (/*[itemType isEqualToString:TTActivityContentItemTypeDingTalk] ||*/ [itemType isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]) {
                continue;
            }
            UIImage *img = [self activityImageNameWithActivity:itemType];
            NSString *title = [self activityTitleWithActivity:itemType];
            
            TTAlphaThemedButton *button = [self buttonWithImage:img title:title itemType:itemType];
            [self addSubview:button];
                if (hasbutton == 0) {
                    _firstShareButton = button;
                }else{
                    _secondShareButton = button;
                }
        }
        hasbutton++;
        if (hasbutton == 2) {
            break;
        }
    }
}

- (TTAlphaThemedButton *)buttonWithImage:(UIImage *)image title:(NSString *)title itemType:(NSString *)itemType{
    TTAlphaThemedButton *button = [[TTAlphaThemedButton alloc] init];
    button.enableHighlightAnim = YES;
    button.tag = [self shareActionFromButtonItemType:itemType].integerValue;
    button.borderColorThemeKey = kColorLine7;
    button.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    button.layer.cornerRadius = kNatantInfoShareButtonHeight/2;
    button.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]]];
    [button setImage:image forState:UIControlStateNormal];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageLeft imageTitlespace:[TTDeviceUIUtils tt_newPadding:4]];
    [button addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIImage *)activityImageNameWithActivity:(NSString *)itemType{
    UIImage *image = nil;
    if (itemType) {
        if ([itemType isEqualToString:TTActivityContentItemTypeWechat]){
            image = [UIImage imageNamed:@"video_center_share_weChat"];
        }else if ([itemType isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
            image = [UIImage imageNamed:@"video_center_share_pyq"];
        }else if ([itemType isEqualToString:TTActivityContentItemTypeQQZone]){
            image = [UIImage imageNamed:@"video_center_share_qzone"];
        }else if ([itemType isEqualToString:TTActivityContentItemTypeQQFriend]){
            image = [UIImage imageNamed:@"video_center_share_qq"];
        }else if ([itemType isEqualToString:TTVVideodetailNatantInfoShareViewDigg]){
            image = [UIImage themedImageNamed:@"like"];
        }
        
        if (image) {
            image = [self scaleImage:image toSize:CGSizeMake(kDirectShareBtnImgViewheight, kDirectShareBtnImgViewheight)];
            if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
                image = [self imageByApplyingAlpha:0.5 image:image];
            }
        }
        
    }
    return image;
}

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (NSString *)activityTitleWithActivity:(NSString *)itemType{
    if ([itemType isEqualToString:TTActivityContentItemTypeWechat]){
        return @"分享微信";
    }else if ([itemType isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
        return @"分享朋友圈";
    }else if ([itemType isEqualToString:TTActivityContentItemTypeQQZone]){
        return @"分享空间";
    }else if ([itemType isEqualToString:TTActivityContentItemTypeQQFriend]){
        return @"分享QQ";
    }else if ([itemType isEqualToString:TTVVideodetailNatantInfoShareViewDigg]){
        return @"0";
    }
    return nil;
}

- (NSNumber *)shareActionFromButtonItemType:(NSString *)itemType{
    if ([itemType isEqualToString:TTActivityContentItemTypeWechat]){
        return @(TTVVideoDetailNatantInfoShareViewShareAction_Weixin);
    }else if ([itemType isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
        return @(TTVVideoDetailNatantInfoShareViewShareAction_Moments);
    }else if ([itemType isEqualToString:TTActivityContentItemTypeQQZone]){
        return @(TTVVideoDetailNatantInfoShareViewShareAction_Qzone);
    }else if ([itemType isEqualToString:TTActivityContentItemTypeQQFriend]){
        return @(TTVVideoDetailNatantInfoShareViewShareAction_QQ);
    }else if ([itemType isEqualToString:TTVVideodetailNatantInfoShareViewDigg]){
        return @(TTVVideoDetailNatantInfoShareViewShareAction_Digg);
    }else if ([itemType isEqualToString:TTVVideodetailNatantInfoShareViewShareAction]){
        return @(TTVVideoDetailNatantInfoShareViewShareAction_Share);
    }else if ([itemType isEqualToString:TTVVideodetailNatantInfoShareViewExtendLink]){
        return @(TTVVideoDetailNatantInfoShareViewShareAction_Extend);
    }
    return @(0);
}

- (NSString  *)shareActionTypeFromButtonTag:(NSInteger )buttonTag{
    if (buttonTag == TTVVideoDetailNatantInfoShareViewShareAction_Weixin){
        return TTActivityContentItemTypeWechat;
    }else if (buttonTag == TTVVideoDetailNatantInfoShareViewShareAction_Moments){
        return TTActivityContentItemTypeWechatTimeLine;
    }else if (buttonTag == TTVVideoDetailNatantInfoShareViewShareAction_QQ){
        return TTActivityContentItemTypeQQFriend;
    }else if (buttonTag == TTVVideoDetailNatantInfoShareViewShareAction_Qzone){
        return TTActivityContentItemTypeQQZone;
    }else if (buttonTag == TTVVideoDetailNatantInfoShareViewShareAction_Digg){
        return TTVVideodetailNatantInfoShareViewDigg;
    }else if (buttonTag == TTVVideoDetailNatantInfoShareViewShareAction_Share){
        return TTVVideodetailNatantInfoShareViewShareAction;
    }else if (buttonTag == TTVVideoDetailNatantInfoShareViewShareAction_Extend){
        return TTVVideodetailNatantInfoShareViewExtendLink;
    }
    return nil;
}

#pragma mark - layout subviews

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = (self.width - 2 * kNatantInfoShareViewHorizontalPadding - kNatantInfoShareViewGap - kNatantInfoShareDiggViewGap) / 3.0f;
      self.digButton.width = width;
      self.digButton.height = kNatantInfoShareButtonHeight;
      self.digButton.left = kNatantInfoShareViewHorizontalPadding;
      self.digButton.centerY = self.height / 2;

    if (self.videoExtendLinkButton) {
        self.shareButton.width = width;
        self.shareButton.height = kNatantInfoShareButtonHeight;
        self.shareButton.centerY = self.digButton.centerY;
        self.shareButton.left = self.digButton.right + kNatantInfoShareViewGap;
        self.videoExtendLinkButton.width = width;
        self.videoExtendLinkButton.height = kNatantInfoShareButtonHeight;
        self.videoExtendLinkButton.centerY = self.digButton.centerY;
        self.videoExtendLinkButton.left = self.shareButton.right + kNatantInfoShareDiggViewGap;
    }else{
        self.firstShareButton.width = width;
        self.secondShareButton.width = width;
        self.firstShareButton.height = kNatantInfoShareButtonHeight;
        self.secondShareButton.height = kNatantInfoShareButtonHeight;
        self.firstShareButton.left = self.digButton.right + kNatantInfoShareViewGap;
        self.secondShareButton.left = self.firstShareButton.right + kNatantInfoShareDiggViewGap;
        self.firstShareButton.centerY = self.digButton.centerY;
        self.secondShareButton.centerY = self.digButton.centerY;
    }
}

- (void)updateDiggButton
{
    self.digButton.selected = self.viewModel.infoModel.userDiged.boolValue;
    [self.digButton setDiggCount:self.viewModel.infoModel.digCount.integerValue];
    if (self.viewModel.infoModel.userDiged.boolValue) {
        self.digButton.borderColorThemeKey = @"ff0031";
    }else{
        self.digButton.borderColorThemeKey = kColorLine7;
    }
}

#pragma mark - button action

- (void)shareAction:(id)sender
{
    if ([sender isKindOfClass:[TTAlphaThemedButton class]]) {
       TTAlphaThemedButton *button = (TTAlphaThemedButton *)sender;
        if (self.shareActionBlock) {
            self.shareActionBlock([self shareActionTypeFromButtonTag:button.tag]);
        }
    }
}

#pragma mark - TTActivityShareSequenceChangedMessage

- (void)message_shareActivitySequenceChanged
{
    if (self.firstShareButton && self.secondShareButton) {
        [self addDirectShareButtons];
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    //避免触发diggbutton动画
    self.digButton.manuallySetSelectedEnabled = NO;
    [super themeChanged:notification];
    [self updateDiggButton];
    [_videoExtendLinkButton setImage:[UIImage themedImageNamed:@"link"] forState:UIControlStateNormal];
    [_videoExtendLinkButton setImage:[UIImage themedImageNamed:@"link_press"] forState:UIControlStateHighlighted];
    [self.shareButton setImage:[UIImage themedImageNamed:[self ttv_shareImageIcon]] forState:UIControlStateNormal];
    [self.shareButton setImage:[UIImage themedImageNamed:[self ttv_shareImageIcon]] forState:UIControlStateHighlighted];
    [self.shareButton setTintColor:SSGetThemedColorWithKey(kColorText1)];
    [self.videoExtendLinkButton setTintColor:SSGetThemedColorWithKey(kColorText1)];
    [self.shareButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
    [self.videoExtendLinkButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
    if (self.firstShareButton && self.secondShareButton) {
        [self addDirectShareButtons];
    }
    //恢复手动diggbutton设置
    self.digButton.manuallySetSelectedEnabled = YES;
}


/// 压缩到制定尺寸 - 保真
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}

@end
