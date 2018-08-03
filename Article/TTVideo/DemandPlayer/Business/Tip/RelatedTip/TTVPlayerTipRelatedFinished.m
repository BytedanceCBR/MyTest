//
//  TTVPlayerTipRelatedFinished.m
//  Article
//
//  Created by lishuangyang on 2017/7/16.
//
//

#import "TTVPlayerTipRelatedFinished.h"
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
#import "TTVPlayerTipRelatedRed.h"
#import "TTVPlayerTipRelatedSimple.h"
#import "TTVPlayerTipRelatedImageIcon.h"
#import "TTVideoFinishRelatedViewService.h"
#import "TTSettingsManager.h"
#import "TTAccountManager.h"
#import "TTInstallIDManager.h"
#import "TTVPlayerStateAction.h"
#import "TTVVideoPlayerStateStore.h"

extern NSString *ttvs_playerFinishedRelatedType(void);

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
extern BOOL ttvs_isPlayerShowRelated(void);

#define kSCreenSizeWidth fminf([TTUIResponderHelper screenSize].width, [TTUIResponderHelper screenSize].height)
#define KShareItemsPadding (([TTDeviceHelper is736Screen]) ? 24 : (0.053 * (kSCreenSizeWidth)))

@interface TTVPlayerTipRelatedFinished ()<TTActivityShareSequenceChangedMessage ,TTVPlayerTipRelatedViewDelegate>

@property (nonatomic, strong) TTVideoShareThemedButton *replayButton;
@property (nonatomic, strong) UIView *dividingLine;
@property (nonatomic, strong) TTVideoShareThemedButton *thirdButton;
@property (nonatomic, strong) TTVideoShareThemedButton *firstButton;
@property (nonatomic, strong) TTVideoShareThemedButton *secondButton;
@property (nonatomic, strong) TTAlphaThemedButton *moreButton;
@property (nonatomic, strong) SSThemedLabel *shareLabel;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) CGFloat bannerHeight; // 兼容banner出现的情况
@property (nonatomic, strong) TTVPlayerTipRelatedView *relatedView;
@property (nonatomic, strong) TTVideoFinishRelatedViewService *netService;
@end

@implementation TTVPlayerTipRelatedFinished

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

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    if (![action isKindOfClass:[TTVPlayerStateAction class]] || ![state isKindOfClass:[TTVPlayerStateModel class]]) {
        return;
    }
    switch (action.actionType) {
        case TTVPlayerEventTypeFinishUIShow:
        {
            if (!self.playerStateStore.state.pasterADIsPlaying) {
                [self.relatedView startTimer];
            }
        }
            break;
        default:
            break;
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

- (void)setDataInfo:(NSDictionary *)dataInfo
{
    [self.relatedView setDataInfo:dataInfo];
}

- (void)startTimer
{
    [self.relatedView startTimer];
}

- (void)pauseTimer
{
    [self.relatedView pauseTimer];
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
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_containerView];

        //更多按钮
        [self ttv_addMoreButton];
        //分享Action按钮
        [self ttv_addShareActionButtons];
        
        _dividingLine = [[UIView alloc] init];
        _dividingLine.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        _dividingLine.width = 1.0;
        _dividingLine.height = 12;
        [_containerView addSubview:_dividingLine];
        
        UIImage *replayImage = [UIImage imageNamed:@"player_share_replay"];
        _replayButton = [[TTVideoShareThemedButton alloc] initWithFrame:CGRectMake(0, 0, shareButtonWidth, shareButtonHeight) index:0 image:replayImage title:@"重播" needLeaveWhite:YES];
        [_replayButton addTarget:self action:@selector(replayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_containerView addSubview:_replayButton];

        [_moreButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.hasSettingRelated = ttvs_isPlayerShowRelated();
        if ([ttvs_playerFinishedRelatedType() isEqualToString:@"only_title"]) {
            _relatedView = [[TTVPlayerTipRelatedImageIcon alloc] initWithFrame:CGRectMake(0, 0, self.width, 40)];
        }else if ([ttvs_playerFinishedRelatedType() isEqualToString:@"change_colour"]){
            _relatedView = [[TTVPlayerTipRelatedRed alloc] initWithFrame:CGRectMake(0, 0, self.width, 40)];
        }else if ([ttvs_playerFinishedRelatedType() isEqualToString:@"with_picture"]){
            _relatedView = [[TTVPlayerTipRelatedImageIcon alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
        }else if ([ttvs_playerFinishedRelatedType() isEqualToString:@"with_icon"]){
            _relatedView = [[TTVPlayerTipRelatedImageIcon alloc] initWithFrame:CGRectMake(0, 0, self.width, 38)];
        }
        if (_relatedView) {
            self.hasSettingRelated = YES;
        }
        _relatedView.delegate = self;
        if (_relatedView) {
            [self addSubview:_relatedView];
        }
        self.hidden = YES;
        self.netService = [[TTVideoFinishRelatedViewService alloc] init];
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
        
        int buttonIndex = 0;
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
                if (_firstButton && _secondButton && _thirdButton) {
                    TTVideoShareThemedButton *button;
                    if (buttonIndex == 0) {
                        button = _firstButton;
                    }else if(buttonIndex == 1){
                        button = _secondButton;
                    }else if(buttonIndex == 2){
                        button = _thirdButton;
                    }
                    button.iconImage.image = img;
                    button.nameLabel.text = title;
                    button.activityType = itemType;
                }
                else{
                    TTVideoShareThemedButton *button = [self cellViewWithIndex:buttonIndex image:img title:title];
                    [_containerView addSubview:button];
                    button.activityType = itemType;
                    if (buttonIndex == 0) {
                        _firstButton = button;
                    }else if(buttonIndex == 1){
                        _secondButton = button;
                    }else if(buttonIndex == 2){
                        _thirdButton = button;
                    }
                }
                buttonIndex++;
                if (buttonIndex == 4) {
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
        [self addSubview:_moreButton];
    }else{
        self.moreButton = nil;
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.playerStateStore.state.isInDetail &&
        !self.playerStateStore.state.isFullScreen &&
        [UIApplication sharedApplication].statusBarHidden == YES) {
        NSInteger diff = [ttvs_playerFinishedRelatedType() isEqualToString:@"change_colour"] ? 10 : 15;
        _containerView.frame = CGRectMake(0, diff, self.width, self.height - _bannerHeight - diff);
    }else{
        _containerView.frame = CGRectMake(0, 0, self.width, self.height - _bannerHeight);
    }
    
    _moreButton.center = CGPointMake(self.width - 24, KMoreButtonCenterY);
    CGFloat _relatedViewHeight = _relatedView.hidden ? 0 : _relatedView.height;
    CGFloat originY = (self.height - _relatedViewHeight - shareButtonHeight) / 2.0;
    if (self.playerStateStore.state.isInDetail){
        originY += self.tt_safeAreaInsets.top;
    }
    _relatedView.frame = CGRectMake(0, self.height - _relatedView.height, self.width, _relatedView.height);
    [self layoutShareActionButtonsWithOriginY:originY];
    [self setMoreButtonHidden];
}

- (void)layoutButtonsWithOriginY:(CGFloat )originalY originalX:(CGFloat)originalX
{
    CGFloat oneActionWidth = KShareItemsPadding;
    _replayButton.frame = CGRectMake(originalX, originalY, shareButtonWidth, shareButtonHeight);
    _dividingLine.frame = CGRectMake(_replayButton.right + 12, _replayButton.top + (36 - _dividingLine.height) / 2.0, _dividingLine.width, _dividingLine.height);
    _firstButton.frame = CGRectMake(_dividingLine.right + 12, originalY, shareButtonWidth, shareButtonHeight);
    _secondButton.frame = CGRectMake(_firstButton.right + oneActionWidth, originalY, shareButtonWidth, shareButtonHeight);
    _thirdButton.frame = CGRectMake(_secondButton.right + oneActionWidth, originalY, shareButtonWidth, shareButtonHeight);
}

- (void)layoutShareActionButtonsWithOriginY:(CGFloat )originalY
{
    CGFloat originalX = 0;
    [self layoutButtonsWithOriginY:originalY originalX:originalX];
    CGFloat totalWidth = _thirdButton.right - _replayButton.left;
    originalX = (self.width - totalWidth) / 2.0;
    originalX = ceilf(originalX);
    [self layoutButtonsWithOriginY:originalY originalX:originalX];
    
    if (_bannerHeight > 0) {
        _secondButton.nameLabel.hidden = YES;
        _thirdButton.nameLabel.hidden = YES;
        _replayButton.nameLabel.hidden = YES;
        _firstButton.nameLabel.hidden = YES;
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
        return @"微头条";
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

- (void)relatedViewSendShowTrack:(TTVPlayerTipRelatedEntity *)entity
{
    if (!entity) {
        return;
    }
    [self.netService postRelatedRecommondInfoWithPostInfo:entity.ack_valid_imprDic completion:^(id response, NSError *error) {
        
    }];
}

- (void)relatedViewClickAtItem:(TTVPlayerTipRelatedEntity *)entity
{
    if (!entity) {
        return;
    }
    [self.netService postRelatedRecommondInfoWithPostInfo:entity.ack_clickDic completion:^(id response, NSError *error) {
        
    }];
    
    if (!isEmptyString(entity.download_url)) {
        [self.netService requestDownloadUrl:entity.download_url completion:^(id response, NSError *error) {
            
        }];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"video_over" forKey:@"direct_source"];
    [dic setValue:self.playerStateStore.state.playerModel.enterFrom forKey:@"enter_from"];
    [dic setValue:self.playerStateStore.state.playerModel.categoryID forKey:@"category_name"];
    [dic setValue:self.playerStateStore.state.playerModel.groupID forKey:@"group_id"];
    [dic setValue:self.playerStateStore.state.ttv_position forKey:@"position"];
    [TTTrackerWrapper eventV3:@"app_direction_icon_click" params:dic isDoubleSending:NO];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://",entity.app_scheme]]]) {
        [dic setValue:@"has_install" forKey:@"direct_tag"];
        [TTTrackerWrapper eventV3:@"app_direction" params:dic isDoubleSending:NO];
    }
}

@end



