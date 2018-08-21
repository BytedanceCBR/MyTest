//
//  AKShareView.m
//  Article
//
//  Created by 冯靖君 on 2018/3/12.
//

#import "AKShareView.h"
#import "AKHelper.h"
#import "AKShareManager.h"
#import <SSThemed.h>
#import <TTAlphaThemedButton.h>
#import <UIViewAdditions.h>
#import <TTDeviceUIUtils.h>
#import <BDWebImage/SDWebImageAdapter.h>

#define kFontSizeShareButtonLabel                   [TTDeviceUIUtils tt_newFontSize:12.f]
#define kFontSizeShareTitleLabel                    [TTDeviceUIUtils tt_newFontSize:18.f]

#define kWidthShareButton                           [TTDeviceUIUtils tt_newPadding:60.f]
#define kOriginWidthShareView                       [TTDeviceUIUtils tt_newPadding:312.f]
#define kOriginheightShareView                      [TTDeviceUIUtils tt_newPadding:90.f]
#define kHeightShareButtonLabel                     [TTDeviceUIUtils tt_newPadding:17.f]

#define kPaddingTopShareButtonLabel                 [TTDeviceUIUtils tt_newPadding:13.f]
#define kPaddingleftShareItem                       [TTDeviceUIUtils tt_newPadding:60.f]
#define kPaddingBottomShareTitleLabel               [TTDeviceUIUtils tt_newPadding:14.f]
@interface AKShareButton ()

@property (nonatomic, strong)SSThemedImageView                  *shareImageView;
//@property (nonatomic, strong)SSThemedLabel                      *shareLabel;
@property (nonatomic, assign)CGFloat                            shareButtonWidth;
@property (nonatomic, assign)AKSharePlatform                  type;
@property (nonatomic, assign)AKShareIconType                  iconType;

- (instancetype)initWithButtonWith:(CGFloat)width activityType:(AKSharePlatform)type;
@end

@implementation AKShareButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.shareButtonWidth = kWidthShareButton;
        [self addSubview:self.shareImageView];
//        [self addSubview:self.shareLabel];
    }
    return self;
}

- (instancetype)initWithButtonWith:(CGFloat)width activityType:(AKSharePlatform)type
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.shareButtonWidth = width;
        self.type = type;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    [self layoutIfNeeded];
    return CGSizeMake(self.shareButtonWidth, self.shareImageView.bottom);
}

- (void)setHighlighted:(BOOL)highlighted
{
    [UIView transitionWithView:self duration:.15 options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (highlighted) {
            self.alpha = 0.5f;
        }
        else{
            self.alpha = 1.f;
        }
    } completion:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    switch (self.type) {
        case AKSharePlatformWeChat:
//            self.shareLabel.text = @"微信好友";
            switch (self.iconType) {
                case AKShareIconTypeDefault:
                    self.shareImageView.image = [UIImage imageNamed:@"ak_share_weChat"];
                    break;
                case AKShareIconTypeFetch:
                    self.shareImageView.image = [UIImage imageNamed:@"ak_share_weChat"];
                    break;
                case AKShareIconTypeNoBorder:
                    self.shareImageView.image = [UIImage imageNamed:@"ak_share_weChat"];
                    break;
                default:
                    break;
            }
            break;
        case AKSharePlatformWeChatTimeLine:
//            self.shareLabel.text = @"微信朋友圈";
            switch (self.iconType) {
                case AKShareIconTypeDefault:
                    self.shareImageView.image = [UIImage imageNamed:@"ak_share_pyq"];
                    break;
                case AKShareIconTypeFetch:
                    self.shareImageView.image = [UIImage imageNamed:@"ak_share_pyq"];
                    break;
                case AKShareIconTypeNoBorder:
                    self.shareImageView.image = [UIImage imageNamed:@"ak_share_pyq"];
                    break;
                default:
                    break;
            }
            break;
        case AKSharePlatformQQ:
//            self.shareLabel.text = @"手机QQ";
            switch (self.iconType) {
                case AKShareIconTypeDefault:
                    self.shareImageView.image = [UIImage imageNamed:@"ak_share_qq"];
                    break;
                case AKShareIconTypeFetch:
                    self.shareImageView.image = [UIImage imageNamed:@"ak_share_qq"];
                    break;
                case AKShareIconTypeNoBorder:
                    self.shareImageView.image = [UIImage imageNamed:@"ak_share_qq"];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
//    [self.shareLabel sizeToFit];
    self.shareImageView.frame = CGRectMake(0, 0, self.shareButtonWidth, self.shareButtonWidth);
//    self.shareLabel.frame = CGRectMake(0, 0, self.shareLabel.width, kHeightShareButtonLabel);
//    self.shareLabel.centerX = self.shareImageView.centerX;
//    self.shareLabel.top = self.shareImageView.bottom + (self.shareButtonWidth / kWidthShareButton) * kPaddingTopShareButtonLabel;
}

#pragma Getter

- (SSThemedImageView *)shareImageView
{
    if (_shareImageView == nil) {
        _shareImageView = [[SSThemedImageView alloc] init];
    }
    return _shareImageView;
}

//- (SSThemedLabel *)shareLabel
//{
//    if (_shareLabel == nil) {
//        _shareLabel = [[SSThemedLabel alloc] init];
//        _shareLabel.font = [UIFont systemFontOfSize:kFontSizeShareButtonLabel];
//        _shareLabel.textColor = [UIColor colorWithHexString:@"#6D4B04"];
//        _shareLabel.textAlignment = NSTextAlignmentCenter;
//    }
//    return _shareLabel;
//}

@end


@interface AKShareView ()

@property (nonatomic, strong)AKShareButton            *shareWeiChatButton;
@property (nonatomic, strong)AKShareButton            *shareWeiChatFriendButton;
@property (nonatomic, strong)AKShareButton            *shareQQButton;

@property (nonatomic, copy, readwrite)  NSArray<AKShareButton *> *supportShareButton;
@property (nonatomic, strong)SSThemedLabel              *shareTitleLabel;
@property (nonatomic, assign)CGFloat                     viewWidth;
@property (nonatomic, strong)UIImage                    *thumbImage;
@property (nonatomic, copy) NSString                    *thumbImageURL;
@property (nonatomic, assign)BOOL                        disableTip;

@end

@implementation AKShareView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    [self layoutIfNeeded];
    __block CGFloat maxWidth = 0;
    __block CGFloat maxHeight = 0;
    [self.supportShareButton enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.hidden) {
            return ;
        }
        maxWidth = MAX(obj.right, maxWidth);
        maxHeight = MAX(obj.bottom, maxHeight);
    }];
    maxWidth += self.contentInset.left + self.contentInset.right;
    maxHeight += self.contentInset.top + self.contentInset.bottom;
    maxWidth = MIN(maxWidth, [UIScreen mainScreen].bounds.size.width);
    maxHeight = MIN(maxHeight,[UIScreen mainScreen].bounds.size.height);
    return CGSizeMake(maxWidth, maxHeight);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithShareBlock:nil viewWidth:-1 shareInfo:nil disableTip:NO];
}

- (instancetype)initWithShareBlock:(ShareBlock)shareBlock viewWidth:(CGFloat)viewWidth shareInfo:(NSDictionary *)shareInfo disableTip:(BOOL)disableTip
{
    return [self initWithShareBlock:shareBlock
                   shareResultBlock:nil
                          viewWidth:viewWidth
                          shareInfo:shareInfo
                         disableTip:disableTip];
}

- (instancetype)initWithShareBlock:(ShareBlock)shareBlock
                  shareResultBlock:(ShareResultBlock)shareResultBlock
                         viewWidth:(CGFloat)viewWidth
                         shareInfo:(NSDictionary *)shareInfo
                        disableTip:(BOOL)disableTip
{
    if (viewWidth == -1 ) {
        viewWidth = kOriginWidthShareView;
    }
    CGRect frame = CGRectMake(0, 0, viewWidth, kOriginheightShareView * (viewWidth / kOriginWidthShareView));
    if ([super initWithFrame:frame]) {
        self.shareBlock = shareBlock;
        self.shareResultBlock = shareResultBlock;
        self.viewWidth = viewWidth;
        self.shareInfo = shareInfo;
        self.disableTip = disableTip;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        self.showsHorizontalScrollIndicator = NO;
        self.clipsToBounds = NO;
        [self addSubview:self.shareWeiChatButton];
        [self addSubview:self.shareWeiChatFriendButton];
        [self addSubview:self.shareQQButton];
        [self addSubview:self.shareTitleLabel];
        [self setDisablePlatform:0];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat padding = kPaddingleftShareItem * (self.viewWidth / kOriginWidthShareView);
    UIColor *textColor = [UIColor colorWithHexString:self.labelTextColorHex];
    
    CGFloat viewWidth = self.supportShareButton.count * (kWidthShareButton + kPaddingleftShareItem) - kPaddingleftShareItem;
    self.shareTitleLabel.textColor = textColor;
    self.shareTitleLabel.centerX = viewWidth / 2;
    self.shareTitleLabel.top = 0;
    CGFloat buttonTop = self.shareTitleLabel.hidden ? 0 : self.shareTitleLabel.bottom + kPaddingBottomShareTitleLabel;
    __block CGFloat left = 0;
    [self.supportShareButton enumerateObjectsUsingBlock:^(AKShareButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = NO;
//        obj.shareLabel.textColor = textColor;
        obj.left = left;
        obj.top = buttonTop;
        left = obj.right + padding;
    }];

    AKShareButton *lastButton = self.supportShareButton.lastObject;
    self.contentSize = CGSizeMake(lastButton.right, lastButton.bottom);
}

// 分享渠道
NSString * const kAKSharePlatformWechat = @"weixin";
NSString * const kAKSharePlatformWechatTimeline = @"weixin_moments";
NSString * const kAKSharePlatformQQ = @"qq";
NSString * const kAKSharePlatformQZone = @"qzone";
NSString * const kAKSharePlatformSMS = @"sms";

// 分享类型
NSInteger const kAKShareTypeWebPage = 1;
NSInteger const kAKShareTypeImage = 2;
NSInteger const kAKShareTypeImageText = 3;
NSInteger const kAKShareTypeText = 4;

- (void)shareButtonClicked:(AKShareButton *)shareButton
{
    // 点击block
    if (self.shareBlock) {
        self.shareBlock(shareButton.type);
    }

    // 确定分享方式
    NSDictionary *sharePlatformInfo;
    if (shareButton.type == AKSharePlatformWeChat) {
        sharePlatformInfo = [self.shareInfo tt_dictionaryValueForKey:kAKSharePlatformWechat];
    } else if (shareButton.type == AKSharePlatformWeChatTimeLine) {
        sharePlatformInfo = [self.shareInfo tt_dictionaryValueForKey:kAKSharePlatformWechatTimeline];
    } else if (shareButton.type == AKSharePlatformQQ) {
        sharePlatformInfo = [self.shareInfo tt_dictionaryValueForKey:kAKSharePlatformQQ];
    } else if (shareButton.type == AKSharePlatformQZone) {
        sharePlatformInfo = [self.shareInfo tt_dictionaryValueForKey:kAKSharePlatformQZone];
    } else if (shareButton.type == AKSharePlatformSMS) {
        sharePlatformInfo = [self.shareInfo tt_dictionaryValueForKey:kAKSharePlatformSMS];
    }
    
    [self shareWithPlatform:shareButton.type info:sharePlatformInfo];
}

- (void)shareWithPlatform:(AKSharePlatform)platform info:(NSDictionary *)sharePlatformInfo
{
    NSInteger shareType = [sharePlatformInfo tt_integerValueForKey:@"type"];
    NSString *webPageTitle = [sharePlatformInfo tt_stringValueForKey:@"landing_title"];
    NSString *webPageDesc = [sharePlatformInfo tt_stringValueForKey:@"landing_desc"];
    NSString *webPageIconURL = [sharePlatformInfo tt_stringValueForKey:@"landing_icon_url"];
    NSString *webPageURL = [sharePlatformInfo tt_stringValueForKey:@"landing_url"];
    NSString *imageURL = [sharePlatformInfo tt_stringValueForKey:@"image_url"];
    NSString *qrCodeURL = [sharePlatformInfo tt_stringValueForKey:@"qr_code_url"];
    NSString *text = [sharePlatformInfo tt_stringValueForKey:@"text"];
    BOOL hasQRCode = [sharePlatformInfo tt_boolValueForKey:@"image_have_qrcode"];
    
    if (platform == AKSharePlatformSMS) {
        // 发短信
        [[AKShareManager sharedManager] sendSMSMessageWithBody:text recipients:nil presentingViewController:self.viewController sendCompletion:nil];
    } else {
        // sdk分享
        if (shareType == kAKShareTypeWebPage) {
            if (!isEmptyString(webPageIconURL)) {
                [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:webPageIconURL] options:SDWebImageHighPriority | SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if (!error && image) {
                        [[AKShareManager sharedManager] shareToPlatform:platform contentType:AKShareContentTypeWebPage text:text title:webPageTitle description:webPageDesc webPageURL:webPageURL thumbImage:image thumbImageURL:webPageIconURL image:nil videoURL:nil extra:nil completionBlock:nil];
                    }
                }];
            } else {
                [[AKShareManager sharedManager] shareToPlatform:platform contentType:AKShareContentTypeWebPage text:text title:webPageTitle description:webPageDesc webPageURL:webPageURL thumbImage:nil thumbImageURL:nil image:nil videoURL:nil extra:nil completionBlock:nil];
            }
        } else if (shareType == kAKShareTypeImage || shareType == kAKShareTypeImageText) {
            if (hasQRCode) {
                [AKQRShareHelper genQRImageWithOriImage:nil oriImageURL:imageURL qrImage:nil qrImageShortLink:qrCodeURL completionBlock:^(UIImage *imageWithQRCode) {
                    if (imageWithQRCode) {
                        [[AKShareManager sharedManager] shareToPlatform:platform contentType:AKShareContentTypeImage text:text title:nil description:nil webPageURL:nil thumbImage:nil thumbImageURL:nil image:imageWithQRCode videoURL:nil extra:nil completionBlock:nil];
                    }
                }];
            } else {
                [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imageURL] options:SDWebImageHighPriority | SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if (!error && image) {
                        [[AKShareManager sharedManager] shareToPlatform:platform contentType:AKShareContentTypeImage text:text title:nil description:nil webPageURL:nil thumbImage:nil thumbImageURL:nil image:image videoURL:nil extra:nil completionBlock:nil];
                    }
                }];
            }
        } else if (shareType == kAKShareTypeText) {
            [[AKShareManager sharedManager] shareToPlatform:platform contentType:AKShareContentTypeText text:text title:nil description:nil webPageURL:nil thumbImage:nil thumbImageURL:nil image:nil videoURL:nil extra:nil completionBlock:nil];
        }
    }
}

- (void)downloadThumbImageWithURL:(NSString *)imageURL;
{
    [[SDWebImageAdapter sharedAdapter] loadImageWithURL:[NSURL URLWithString:imageURL] options:SDWebImageRetryFailed | SDWebImageHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (!error && image) {
            self.thumbImage = image;
        }
    }];
}

- (void)setDisablePlatform:(AKShareSupportPlatform)disablePlatform
{
    _disablePlatform = disablePlatform;
    NSMutableArray *supportPlatformArray = [NSMutableArray array];
    NSArray<NSNumber *> *allSupportPlatform = [self allSupporPlatform];
    
    [allSupportPlatform enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AKShareButton *button = [self shareButtonWithSupportPlatform:obj.integerValue];
        button.hidden = YES;
        if (!(disablePlatform & obj.integerValue)) {
            [supportPlatformArray addObject:button];
        }
    }];
    self.supportShareButton = [supportPlatformArray copy];
    [self setNeedsLayout];
}

#pragma Getter

- (void)setTipTitle:(NSAttributedString *)tipTitle
{
    if (isEmptyString(tipTitle.string)) {
        self.shareTitleLabel.text = @"分享至";
        return;
    }
    self.shareTitleLabel.text = nil;
    self.shareTitleLabel.attributedText = tipTitle;
    [self.shareTitleLabel sizeToFit];
    [self layoutSubviews];
}

- (NSArray<NSNumber *> *)allSupporPlatform
{
    return @[@(AKShareSupportPlatformWeChat),@(AKShareSupportPlatformWeChatFriend),@(AKShareSupportPlatformQQ)];
}

- (AKShareButton *)shareButtonWithSupportPlatform:(AKShareSupportPlatform)platform
{
    switch (platform) {
        case AKShareSupportPlatformWeChat:
            return self.shareWeiChatButton;
            break;
        case AKShareSupportPlatformWeChatFriend:
            return self.shareWeiChatFriendButton;
            break;
        case AKShareSupportPlatformQQ:
            return self.shareQQButton;
            break;
        default:
            break;
    }
}

- (SSThemedLabel *)shareTitleLabel
{
    if (_shareTitleLabel == nil) {
        _shareTitleLabel = [[SSThemedLabel alloc] init];
        _shareTitleLabel.font = [UIFont boldSystemFontOfSize:kFontSizeShareTitleLabel];
        _shareTitleLabel.text = @"分享到";
        [_shareTitleLabel sizeToFit];
        _shareTitleLabel.hidden = _disableTip;
    }
    return _shareTitleLabel;
}

- (AKShareButton *)shareWeiChatButton
{
    if (_shareWeiChatButton == nil) {
        _shareWeiChatButton = [[AKShareButton alloc] initWithButtonWith:kWidthShareButton activityType:AKSharePlatformWeChat];
        [_shareWeiChatButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_shareWeiChatButton sizeToFit];
    }
    return _shareWeiChatButton;
}

- (AKShareButton *)shareWeiChatFriendButton
{
    if (_shareWeiChatFriendButton == nil) {
        _shareWeiChatFriendButton = [[AKShareButton alloc] initWithButtonWith:kWidthShareButton activityType:AKSharePlatformWeChatTimeLine];
        [_shareWeiChatFriendButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_shareWeiChatFriendButton sizeToFit];
    }
    return _shareWeiChatFriendButton;
}

- (AKShareButton *)shareQQButton
{
    if (_shareQQButton == nil) {
        _shareQQButton = [[AKShareButton alloc] initWithButtonWith:kWidthShareButton activityType:AKSharePlatformQQ];
        [_shareQQButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_shareQQButton sizeToFit];
    }
    return _shareQQButton;
}

- (UIImage *)thumbImage
{
    if (_thumbImage == nil) {
        return [UIImage imageNamed:@"sf_share_defaul_icon"];
    }
    return _thumbImage;
}

- (void)setShareInfo:(NSDictionary *)shareInfo
{
    _shareInfo = shareInfo;
    NSString *imageURL = [shareInfo tt_stringValueForKey:@"image_url"];
    self.thumbImageURL = imageURL;
    if (!isEmptyString(imageURL)) {
        [self downloadThumbImageWithURL:imageURL];
    }
}

- (void)setIconType:(AKShareIconType)iconType
{
    _iconType = iconType;
    self.shareWeiChatButton.iconType = iconType;
    [self.shareWeiChatButton setNeedsLayout];
    self.shareWeiChatFriendButton.iconType = iconType;
    [self.shareWeiChatFriendButton setNeedsLayout];
    self.shareQQButton.iconType = iconType;
    [self.shareQQButton setNeedsLayout];
}

@end
