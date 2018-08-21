//
//  TTVVideoPlayerViewShareCointainerView.m
//  Article
//
//  Created by lishuangyang on 2017/10/12.
//

#import "TTVVideoPlayerViewShareCointainerView.h"
#import "TTAlphaThemedButton.h"
#import "TTActivityShareSequenceManager.h"
#import "TTMessageCenter.h"
#import "KVOController.h"
#import "TTVideoShareThemedButton.h"

#define kSCreenSizeWidth [TTUIResponderHelper screenSize].width
#define KShareItemsPadding (([TTDeviceHelper is736Screen]) ? 24 : (0.053 * (kSCreenSizeWidth)))
#define KshareItemsGroupWith (3 * KShareItemsPadding + 4 * shareButtonWidth)

static const CGFloat shareButtonWidth     =  44;
static const CGFloat shareButtonHeight    =  65;

extern NSString * const TTActivityContentItemTypeWechat;
extern NSString * const TTActivityContentItemTypeWechatTimeLine;
extern NSString * const TTActivityContentItemTypeQQFriend;
extern NSString * const TTActivityContentItemTypeQQZone;
//extern NSString * const TTActivityContentItemTypeDingTalk;
extern NSString * const TTActivityContentItemTypeForwardWeitoutiao;

extern BOOL ttvs_isShareIndividuatioEnable(void);

@interface TTVVideoPlayerViewShareCointainerView () <TTActivityShareSequenceChangedMessage>

@property (nonatomic, strong) NSMutableArray *shareButtonArray;
@property (nonatomic, assign) BOOL isFullScreen;

@end

@implementation TTVVideoPlayerViewShareCointainerView

- (void)dealloc
{
    [self.playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
    UNREGISTER_MESSAGE(TTActivityShareSequenceChangedMessage, self);
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        self.height = shareButtonHeight;
        CGFloat buttonGap = self.playerStateStore.state.enableRotate ? 16 : 10;
        self.width = shareButtonWidth * 4 + buttonGap * 3;
        [self ttv_kvo];
        self.hidden = YES;
        [self initializeSubViews];
        REGISTER_MESSAGE(TTActivityShareSequenceChangedMessage, self);
        self.alpha = 0;
        
    }
}

- (void)ttv_kvo
{
    __weak typeof(self) wself = self;
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        __strong typeof(wself) self = wself;
        self.isFullScreen = self.playerStateStore.state.isFullScreen;
    }];
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,toolBarState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        __strong typeof(wself) self = wself;
        [self showSelf];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,tipType) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        __strong typeof(wself) self = wself;
        TTVPlayerControlTipViewType value = [[change valueForKey:NSKeyValueChangeNewKey] integerValue];
        if (value != TTVPlayerControlTipViewTypeNone && value != TTVPlayerControlTipViewTypeUnknow) {
            self.alpha = 0;
        }}];


}

- (void)showSelf
{
    if (self.isFullScreen ) {
        if (self.playerStateStore.state.toolBarState == TTVPlayerControlViewToolBarStateWillShow )
        {
            if (!self.playerStateStore.state.resolutionAlertShowed) {
                self.hidden = NO;
                [UIView animateWithDuration:.35f animations:^{
                    self.alpha = 1;
                } completion:^(BOOL finished) {
                    
                }];
            }

        }else if (self.playerStateStore.state.toolBarState == TTVPlayerControlViewToolBarStateWillHidden){
            [UIView animateWithDuration:.35f animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    if (isFullScreen)
    {
        if (self.playerStateStore.state.toolBarState == TTVPlayerControlViewToolBarStateDidShow)
        {
            if (!self.playerStateStore.state.resolutionAlertShowed) {
                self.hidden = NO;
                [UIView animateWithDuration:.3f animations:^{
                    self.alpha = 1;
                } completion:^(BOOL finished) {
                    
                }];
            }

        }else{
            self.alpha = 0;
        }
    }else{
        self.alpha = 0;
    }
}

- (void)initializeSubViews
{
    [self ttv_addShareActionButtons];
}

- (void)ttv_addShareActionButtons
{
    [self configurationShareButtonArray];
    NSArray *activitySequenceArr;
    if (!ttvs_isShareIndividuatioEnable()) {
        activitySequenceArr = @[TTActivityContentItemTypeWechatTimeLine, TTActivityContentItemTypeWechat, TTActivityContentItemTypeQQFriend, TTActivityContentItemTypeQQZone];
    }else{
        activitySequenceArr = [[TTActivityShareSequenceManager sharedInstance_tt] getAllShareServiceSequence];
    }
    
    if (activitySequenceArr.count > 0) {
        
        int hasbutton = 0;
        for (int i = 0; i < activitySequenceArr.count; i++){
            
            id obj = [activitySequenceArr objectAtIndex:i];
            if ([obj isKindOfClass:[NSString class]]) {
                
                NSString *itemType = (NSString *)obj;
                if (/*[itemType isEqualToString:TTActivityContentItemTypeDingTalk] || */[itemType isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]) {
                    continue;
                }
                UIImage *img = [self activityImageNameWithActivity:itemType];
                NSString *title = [self activityTitleWithActivity:itemType];
                
                if (img && title)
                {
                    TTVideoShareThemedButton *button = [self cellViewWithIndex:hasbutton image:img title:title];
                    button.activityType = itemType;
                    
                    [self addSubview:button];
                    if (![self.shareButtonArray containsObject:button]){
                        [self.shareButtonArray addObject:button];
                    }
                    
                    hasbutton++;
                    if (hasbutton == 4) {
                        break;
                    }

                }
            }
        }
    }
    
}

- (UIImage *)activityImageNameWithActivity:(NSString *)itemType
{
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
    return nil;
}

- (NSString *)activityTitleWithActivity:(NSString *)itemType
{
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
    return nil;
}

- (TTVideoShareThemedButton *)cellViewWithIndex:(int)index image:(UIImage *)image title:(NSString *)title
{
    CGRect frame;
    TTVideoShareThemedButton *view = nil;
    frame = CGRectMake(index*shareButtonWidth, 0, shareButtonWidth, shareButtonHeight);
    view = [[TTVideoShareThemedButton alloc] initWithFrame:frame index:index image:image title:title needLeaveWhite:YES];//需要显示nameLabel
//    view.iconImage.frame = CGRectMake(10.f, 1.f, 40.f, 40.f);
//    view.nameLabel.frame = CGRectMake(-1.f, 50.f, 62.f, 15.f);
    view.nameLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
    [view addTarget:self action:@selector(ShareActionDidPress:) forControlEvents:UIControlEventTouchUpInside];
    return view;
}

#pragma mark - layoutSubView

- (void)layoutSubviews
{
    CGFloat buttonGap = self.playerStateStore.state.enableRotate ? 16 : 10;
    for (int i = 0; i < self.shareButtonArray.count; i++) {
        TTVideoShareThemedButton * button = self.shareButtonArray[i];
        button.origin = CGPointMake(i*(shareButtonWidth+buttonGap), 0);
    }

}

- (void)ShareActionDidPress:(id )sender
{
    if ([sender isKindOfClass:[TTVideoShareThemedButton class]]) {
        TTVideoShareThemedButton *btn = (TTVideoShareThemedButton *)sender;
        if (self.shareCointainerViewShareAction) {
            self.shareCointainerViewShareAction(btn.activityType);
        }
    }
}

#pragma mark - helper

- (void)configurationShareButtonArray
{
    if (_shareButtonArray)
    {
        [self.shareButtonArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[TTVideoShareThemedButton class]]) {
                TTVideoShareThemedButton *btn = (TTVideoShareThemedButton *)obj;
                [btn removeFromSuperview];
            }
        }];
        
        [self.shareButtonArray removeAllObjects];
    }
    else{
        _shareButtonArray = [NSMutableArray arrayWithCapacity:4];
    }
}

#pragma mark - TTActivityShareSequenceChangedMessage

- (void)message_shareActivitySequenceChanged{
    [self ttv_addShareActionButtons];
}

@end
