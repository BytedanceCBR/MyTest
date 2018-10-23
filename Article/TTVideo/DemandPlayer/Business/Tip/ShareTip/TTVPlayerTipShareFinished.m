//
//  TTVPlayerTipShareFinished.m
//  Article
//
//  Created by lishuangyang on 2017/7/16.
//
//

#import "TTVPlayerTipShareFinished.h"
#import "SSThemed.h"
#import "TTAlphaThemedButton.h"
#import "KVOController.h"
#import "TTUIResponderHelper.h"
#import "TTVideoShareThemedButton.h"
#import "TTActivity.h"
//#import "TTWeitoutiaoRepostIconDownloadManager.h"
#import "TTActivityShareSequenceManager.h"
#import "TTQQShare.h"
#import "TTWeChatShare.h"
//#import "TTAliShare.h"
//#import "TTDingTalkShare.h"
#import "TTMessageCenter.h"
#import "TTKitchenHeader.h"
#import "TTVVideoPlayerStateStore.h"

static const CGFloat kPrePlayBtnBottom    =  11.5;
static const CGFloat shareButtonWidth     =  44;
static const CGFloat shareButtonHeight    =  65;
static const CGFloat KMoreButtonCenterY   =  22;

extern NSString * const TTVPlayerFinishActionTypeNone;
extern NSString * const TTVPlayerFinishActionTypeShare;
extern NSString * const TTVPlayerFinishActionTypeReplay;
extern NSString * const TTVPlayerFinishActionTypeMoreShare;

extern NSString * const TTActivityContentItemTypeWechat;
extern NSString * const TTActivityContentItemTypeWechatTimeLine;
extern NSString * const TTActivityContentItemTypeQQFriend;
extern NSString * const TTActivityContentItemTypeQQZone;
//extern NSString * const TTActivityContentItemTypeDingTalk;
extern NSString * const TTActivityContentItemTypeForwardWeitoutiao;

extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern BOOL ttvs_isShareIndividuatioEnable(void);

#define kSCreenSizeWidth fminf([TTUIResponderHelper screenSize].width, [TTUIResponderHelper screenSize].height)
#define KShareItemsPadding (([TTDeviceHelper is736Screen]) ? 24 : (0.053 * (kSCreenSizeWidth)))
#define  KshareItemsGroupWith (3 * KShareItemsPadding + 4 * shareButtonWidth)

@interface TTVPlayerTipShareFinished ()<TTActivityShareSequenceChangedMessage>

@property (nonatomic, strong) TTVideoShareThemedButton *qqZoneShare;
@property (nonatomic, strong) TTVideoShareThemedButton *qqShare;
@property (nonatomic, strong) TTVideoShareThemedButton *weixinMoment;
@property (nonatomic, strong) TTVideoShareThemedButton *weixinShare;
@property (nonatomic, strong) NSMutableArray *directShareButtons;
@property (nonatomic, strong) TTAlphaThemedButton *replayButton;
@property (nonatomic, strong) TTAlphaThemedButton *moreButton;
@property (nonatomic, strong) SSThemedLabel *shareLabel;
@property (nonatomic, strong) SSThemedView *leftLine;
@property (nonatomic, strong) SSThemedView *rightLine;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) CGFloat bannerHeight; // 兼容banner出现的情况
@property (nonatomic, assign) NSInteger avaliableitems;

@end

@implementation TTVPlayerTipShareFinished

- (void)dealloc
{
    [self.playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
    UNREGISTER_MESSAGE(TTActivityShareSequenceChangedMessage, self);
}

- (void)setPlayerStateStore:(TTVVideoPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [self ttv_kvo];
    }
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.isFullScreen = self.playerStateStore.state.isFullScreen;
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,bannerHeight) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.bannerHeight = self.playerStateStore.state.bannerHeight;
        [self setNeedsLayout];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isInDetail) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self setMoreButtonHidden];
    }];
}

- (void)ShareActionDidPress:(TTVideoShareThemedButton *)sender
{
    if (self.finishAction) {
        self.finishAction(sender.activityType);
    }
    [self disableInterface:sender];
}

- (void)moreButtonClicked:(UIButton *)sender
{
    if (self.finishAction) {
        self.finishAction(TTVPlayerFinishActionTypeMoreShare);
    }
    [self disableInterface:sender];
}

- (void)replayButtonClicked:(UIButton *)sender
{
    if (self.finishAction) {
        self.finishAction(TTVPlayerFinishActionTypeReplay);
    }
    [self disableInterface:sender];
    [self ttv_addShareActionButtons];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        REGISTER_MESSAGE(TTActivityShareSequenceChangedMessage, self);
        _bannerHeight = 0;
        //背景view
        _backView = [[UIView alloc] initWithFrame:self.bounds];
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        [self addSubview:_backView];
        
        _containerView = [[UIView alloc] initWithFrame:_backView.bounds];
        [_backView addSubview:_containerView];
        
        _shareLabel = [[SSThemedLabel alloc] init];
        _shareLabel.text = NSLocalizedString(@"分享到", nil);
        _shareLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        _shareLabel.textColor = [UIColor tt_defaultColorForKey:kColorText9];
        //        _shareLabel.alpha = 0.8;
        [_shareLabel sizeToFit];
        
        _leftLine = [[SSThemedView alloc] init];
        _leftLine.backgroundColor = [UIColor whiteColor];
        _leftLine.alpha = 0.3;
        _leftLine.size = CGSizeMake(32.f, 1.f);
        
        _rightLine = [[SSThemedView alloc] init];
        _rightLine.backgroundColor = [UIColor whiteColor];
        _rightLine.alpha = 0.3;
        _rightLine.size = CGSizeMake(32.f, 1.f);
        
        [_containerView addSubview:_shareLabel];
        [_containerView addSubview:_leftLine];
        [_containerView addSubview:_rightLine];

        //重播按钮
        UIImage *img =[UIImage imageNamed: @"replay_small"];
        _replayButton = [[TTAlphaThemedButton alloc] init];
        _replayButton.frame = CGRectMake(12, _containerView.height - kPrePlayBtnBottom - img.size.height, img.size.width, img.size.height);
        _replayButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        UIImage *replayImg = [self imageByApplyingAlpha:0.8 image:img];
        [_replayButton setImage:replayImg forState:UIControlStateNormal];
        [_replayButton setTitle:NSLocalizedString(@"重播", nil) forState:UIControlStateNormal];
        _replayButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.f];
        [_replayButton setTitleColor:[UIColor tt_defaultColorForKey:kColorText9] forState:UIControlStateNormal];
        [_replayButton setTitleColor:[UIColor tt_defaultColorForKey:kColorText9Highlighted] forState:UIControlStateHighlighted];
        [_replayButton layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageLeft imageTitlespace:2.f];
        
        [_replayButton sizeToFit];
        [_containerView addSubview: _replayButton];
        //更多按钮
        [self ttv_addMoreButton];
        //分享Action按钮
        [self ttv_addShareActionButtons];
        [_replayButton addTarget:self action:@selector(replayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_moreButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)ttv_addShareActionButtons
{
    NSArray *activitySequenceArr;
    if (!ttvs_isShareIndividuatioEnable()) {
        activitySequenceArr = @[@(TTActivityTypeWeixinMoment), @(TTActivityTypeWeixinShare), @(TTActivityTypeQQShare), @(TTActivityTypeQQZone)];
    }else{
        activitySequenceArr = [[TTActivityShareSequenceManager sharedInstance_tt] getAllShareServiceSequence];
    }
    
    if (activitySequenceArr.count > 0) {
        
        int hasbutton = 0;
        for (int i = 0; i < activitySequenceArr.count; i++){
            
            id obj = [activitySequenceArr objectAtIndex:i];
            if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
                    NSString *itemType;
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        TTActivityType objType = [obj integerValue];
                        itemType = [TTActivityShareSequenceManager activityStringTypeFromActivityType:objType];
                    }else{
                        itemType = (NSString *)obj;
                    }
                    if (/*[itemType isEqualToString:TTActivityContentItemTypeDingTalk] ||*/ [itemType isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]) {
                        continue;
                    }
                UIImage *img = [self activityImageNameWithActivity:itemType];
                NSString *title = [self activityTitleWithActivity:itemType];
                if (_weixinMoment && _weixinShare && _qqShare && _qqZoneShare) {
                    TTVideoShareThemedButton *button;
                    if (hasbutton == 0) {
                        button = _weixinMoment;
                    }else if(hasbutton == 1){
                        button = _weixinShare;
                    }else if(hasbutton == 2){
                        button = _qqShare;
                    }else if(hasbutton == 3){
                        button = _qqZoneShare;
                    }
                    button.iconImage.image = img;
                    button.nameLabel.text = title;
                    button.activityType = itemType;
                }
                else{
                    TTVideoShareThemedButton *button = [self cellViewWithIndex:hasbutton image:img title:title];
                    [_containerView addSubview:button];
                    button.activityType = itemType;
                    if (hasbutton == 0) {
                        _weixinMoment = button;
                    }else if(hasbutton == 1){
                        _weixinShare = button;
                    }else if(hasbutton == 2){
                        _qqShare = button;
                    }else if(hasbutton == 3){
                        _qqZoneShare = button;
                    }
                }
                hasbutton++;
                if (hasbutton == 4) {
                    break;
                }
            }
            
        }
    }

}

- (TTVideoShareThemedButton *)cellViewWithIndex:(int)index image:(UIImage *)image title:(NSString *)title{
    CGRect frame;
    TTVideoShareThemedButton *view = nil;
    frame = CGRectMake(index*shareButtonWidth, 0, shareButtonWidth, shareButtonHeight);
    view = [[TTVideoShareThemedButton alloc] initWithFrame:frame index:index image:image title:title needLeaveWhite:YES];//需要显示nameLabel
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addTarget:self action:@selector(ShareActionDidPress:) forControlEvents:UIControlEventTouchUpInside];
    return view;
}

- (void)ttv_addMoreButton
{
    if (ttvs_isVideoShowOptimizeShare() > 0) {
        self.moreButton = [[TTAlphaThemedButton alloc] init];
        _moreButton.backgroundColor = [UIColor clearColor];
        _moreButton.enableHighlightAnim = NO;
        _moreButton.width = 30.f;
        _moreButton.height = 30.f;
        [_moreButton setImage:[UIImage imageNamed:@"new_morewhite_titlebar"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"new_morewhite_titlebar"] forState:UIControlStateHighlighted];
        _moreButton.imageView.center = CGPointMake(_moreButton.frame.size.width/2, _moreButton.frame.size.height/2);
        _moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        [_containerView addSubview:_moreButton];
    }else{
        self.moreButton = nil;
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    _backView.frame = self.bounds;
    _containerView.frame = _backView.frame;
    _containerView.height -= _bannerHeight;
    
    CGFloat height = _containerView.frame.size.height;
    CGFloat width = _containerView.frame.size.width;

    _shareLabel.centerX = width/2;
    _leftLine.right = _shareLabel.left - 8;
    _rightLine.left = _shareLabel.right + 8;
    _replayButton.bottom = height - ((_bannerHeight > 0) ? 8 : kPrePlayBtnBottom);
    _moreButton.center = CGPointMake(self.width - 24, KMoreButtonCenterY);
    
    CGFloat shareOriginalY = self.replayButton.origin.y;

    CGFloat originY = (shareOriginalY - shareButtonHeight - 12 - _shareLabel.height)/2;
    if (self.playerStateStore.state.isInDetail){
        originY += self.tt_safeAreaInsets.top;
    }

    _shareLabel.top = originY;
    _leftLine.centerY = _shareLabel.centerY;
    _rightLine.centerY = _leftLine.centerY;
    [self layoutShareActionButtonsWithOriginY:(_shareLabel.bottom + 12)];
    [self setMoreButtonHidden];
}

- (void)layoutShareActionButtonsWithOriginY:(CGFloat )originalY
{
    CGFloat width = _containerView.frame.size.width;
    CGFloat oneActionWidth = (shareButtonWidth + KShareItemsPadding);
    CGFloat originalX = width/2 - KshareItemsGroupWith/2;
    originalX = ceilf(originalX);
    oneActionWidth = ceilf(oneActionWidth);
    _weixinMoment.frame = CGRectMake(originalX, originalY, shareButtonWidth, shareButtonHeight);
    _weixinShare.frame = CGRectMake(originalX + 1*oneActionWidth, originalY, shareButtonWidth, shareButtonHeight);
    _qqZoneShare.frame = CGRectMake(originalX + 3*oneActionWidth, originalY, shareButtonWidth, shareButtonHeight);
    _qqShare.frame = CGRectMake(originalX + 2*oneActionWidth, originalY, shareButtonWidth, shareButtonHeight);
    
    
    if (_bannerHeight > 0) {
        _weixinShare.nameLabel.hidden = YES;
        _qqShare.nameLabel.hidden = YES;
        _qqZoneShare.nameLabel.hidden = YES;
        _weixinMoment.nameLabel.hidden = YES;
    }
}

- (void)setMoreButtonHidden
{
    if (self.playerStateStore.state.isInDetail) {
        _moreButton.hidden = NO;
    }else{
        _moreButton.hidden = YES;
    }

}

- (void)disableInterface:(UIButton *)sender
{
    sender.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.userInteractionEnabled = YES;
    });
}


- (UIImage *)activityImageNameWithActivity:(NSString *)itemType{
    if ([itemType isEqualToString:TTActivityContentItemTypeWechat]){
        return [UIImage imageNamed:@"weixin_allshare"];
    }else if ([itemType isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
        return [UIImage imageNamed:@"pyq_allshare"];
    }else if ([itemType isEqualToString:TTActivityContentItemTypeQQZone]){
        return [UIImage imageNamed:@"qqkj_allshare"];
    }else if ([itemType isEqualToString:TTActivityContentItemTypeQQFriend]){
        return [UIImage imageNamed:@"qq_allshare"];
    }
//    else if ([itemType isEqualToString:TTActivityContentItemTypeDingTalk]){
//        return [UIImage imageNamed:@"dingding_allshare"];
//    }
    else {
//        UIImage * dayImage = [[TTWeitoutiaoRepostIconDownloadManager sharedManager] getWeitoutiaoRepostDayIcon];
//        if (nil == dayImage) {
//            //使用本地图片
            return [UIImage imageNamed:@"share_toutiaoweibo"];
//        }else {
//            //网络图片已下载
//            return dayImage;
//        }
    }
}

- (NSString *)activityTitleWithActivity:(NSString *)itemType{
    if ([itemType isEqualToString:TTActivityContentItemTypeWechat]){
        return @"微信";
    }else if ([itemType isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
        return @"朋友圈";
    }else if ([itemType isEqualToString:TTActivityContentItemTypeQQZone]){
        return @"QQ空间";
    }else if ([itemType isEqualToString:TTActivityContentItemTypeQQFriend]){
        return @"QQ";
    }
//    else if ([itemType isEqualToString:TTActivityContentItemTypeDingTalk]){
//        return @"钉钉";
//    }
    else {
        return [KitchenMgr getString:kKCUGCRepostWordingShareIconTitle];
    }
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

#pragma mark - TTActivityShareSequenceChangedMessage

- (void)message_shareActivitySequenceChanged{
    [self ttv_addShareActionButtons];
}

@end
