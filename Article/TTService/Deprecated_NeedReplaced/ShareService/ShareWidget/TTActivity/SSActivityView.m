//
//  SSActivityView.m
//  Article
//
//  Created by Zhang Leonardo on 13-3-7.
//
//

#import "SSActivityView.h"

#import <QuartzCore/QuartzCore.h>
#import "UIImageAdditions.h"
#import "SSThemed.h"

#import "TTPanelController.h"
#import "TTPanelControllerItem.h"

#import "ExploreDetailFontSettingView.h"
#import <Masonry/Masonry.h>
#import "UIColor+TTThemeExtension.h"
#import "UIViewAdditions.h"
#import "TTTrackerWrapper.h"

#import "TTDeviceHelper.h"
#import "TTNewPanelControllerItem.h"
#import "TTNewPanelController.h"

#define kTopPading          24
#define kItemWidth          60
#define kItemHeight         83
#define kCancelButtonHeight 48
#define kItemContentHeight  174

@interface SSActivityView()<UIScrollViewDelegate, TTActivityDelegate>
{
    BOOL _showTTPanelController;
}
@property(nonatomic, strong)UIView * itemContentView;
@property(nonatomic, strong)UIView * bgView;
@property(nonatomic, strong)SSThemedView *bottomSafeAreaView;
@property(nonatomic, strong)SSThemedButton * cancelButton;
@property(nonatomic, assign)TTActivityType actionItemType;
@property(nonatomic, strong)UIButton *hideButton;
@property(nonatomic, strong)ExploreDetailFontSettingView  *fontSettingView;
@property(nonatomic, strong)UIView * cancelButtonTopDivideLineView;

@end

@implementation SSActivityView


- (void)dealloc
{
    self.hideButton = nil;
    self.dataSource = nil;
    self.delegate = nil;
    self.activityItems = nil;
    self.itemContentView = nil;
    self.bgView = nil;
    self.cancelButton = nil;
    self.fontSettingView = nil;
    self.cancelButtonTopDivideLineView = nil;
    //    [super dealloc];
}

- (id)init
{
    CGRect activityRect = CGRectZero;
    activityRect = [UIScreen mainScreen].bounds;
    self = [self initWithFrame:activityRect];
    if (self) {
    }
    return self;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = [UIApplication sharedApplication].keyWindow.frame;
        _layoutScheme = ActivityLayoutSchemeFixed;
        [self buildViews];
        [self reloadThemeUI];
    }
    return self;
}

- (void)buildViews
{
    CGFloat bottomSafeAreaInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    CGFloat itemContentHeight = kItemContentHeight + bottomSafeAreaInset;
    self.hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _hideButton.backgroundColor = [UIColor clearColor];
    [_hideButton addTarget:self action:@selector(hideButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentBaseView addSubview:_hideButton];
    
    [_hideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.contentBaseView);
        make.bottom.equalTo(self.contentBaseView).offset(-itemContentHeight);
    }];
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - itemContentHeight, self.width, itemContentHeight - kCancelButtonHeight - [TTDeviceHelper ssOnePixel] - bottomSafeAreaInset)];
    self.bgView.alpha = 0.98;
    //    _bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.contentBaseView addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hideButton.mas_bottom);
        make.left.right.equalTo(self.contentBaseView);
        make.height.mas_equalTo(itemContentHeight - kCancelButtonHeight - [TTDeviceHelper ssOnePixel] - bottomSafeAreaInset);
    }];
    
    self.itemContentView = [[UIView alloc] initWithFrame:_bgView.frame];
    _itemContentView.backgroundColor = [UIColor clearColor];
    _itemContentView.clipsToBounds = NO;
    _itemContentView.alpha = 0.98;
    [self.bgView addSubview:_itemContentView];
    
    [self.itemContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bgView);
    }];
    
    self.cancelButtonTopDivideLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - kCancelButtonHeight - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel])];
    //    _cancelButtonTopDivideLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.contentBaseView addSubview:_cancelButtonTopDivideLineView];
    
    [_cancelButtonTopDivideLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentBaseView);
        make.top.equalTo(self.bgView.mas_bottom);
        make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
    }];
    
    self.cancelButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
    [_cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.frame = CGRectMake(0, self.height - kCancelButtonHeight, self.width,kCancelButtonHeight);
    //    _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.contentBaseView addSubview:_cancelButton];
    
    [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentBaseView);
        make.top.equalTo(self.cancelButtonTopDivideLineView);
        make.height.mas_equalTo(kCancelButtonHeight);
    }];
    if (bottomSafeAreaInset > 0){
        self.bottomSafeAreaView = [[SSThemedView alloc] init];
        self.bottomSafeAreaView.backgroundColors = @[[UIColor colorWithHexString:@"0xf8f8f8"], [UIColor colorWithHexString:@"0x303030"]];
        [self.contentBaseView addSubview:self.bottomSafeAreaView];
        [self.bottomSafeAreaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentBaseView);
            make.height.mas_equalTo(bottomSafeAreaInset + [TTDeviceHelper ssOnePixel]);
            //否则会有一条缝
        }];
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    UIColor *bgColor = SSGetThemedColorWithKey(kColorBackground18);
    _bgView.backgroundColor = bgColor;
    self.cancelButtonTopDivideLineView.backgroundColor = SSGetThemedColorWithKey(kColorLine10);
    _cancelButton.titleColorThemeKey = kColorText1;
    _cancelButton.backgroundColors = @[[UIColor colorWithHexString:@"0xf8f8f8"], [UIColor colorWithHexString:@"0x303030"]];
    _cancelButton.highlightedBackgroundColors = @[[UIColor colorWithHexString:@"0xe8e8e8"], [UIColor colorWithHexString:@"0x252525"]];
    _itemContentView.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_layoutScheme == ActivityLayoutSchemeNone) {
        [self removeActivityItemsAnimation];
    }
    else if (_layoutScheme == ActivityLayoutSchemeFixed){
        [self moveBackActivityItemsAnimation];
    }
}
- (void)cancelButtonClicked
{
    return [self cancelButtonClickedWithAnimation:YES];
}

- (void)cancelButtonClickedWithAnimation:(BOOL)animated
{
    if (_showTTPanelController) {
        [self completeByItemType:TTActivityTypeNone animation:animated];
        return;
    }
    if (_layoutScheme == ActivityLayoutSchemeNone) {
        _layoutScheme = ActivityLayoutSchemeFixed;
        _fontSettingView.transform = CGAffineTransformIdentity;
        if (animated) {
            [UIView animateWithDuration: 0.25 animations:^{
                [self moveBackActivityItemsAnimation];
                _fontSettingView.alpha = 0;
                _fontSettingView.transform = CGAffineTransformMakeScale(0.01, 1);
                [self refreshCancelButtonTitle:@"取消"];//字体设置返回
            } completion:^(BOOL finished) {
                [_fontSettingView removeFromSuperview];
            }];
        }
        else {
            [self moveBackActivityItemsAnimation];
            _fontSettingView.alpha = 0;
            _fontSettingView.transform = CGAffineTransformMakeScale(0.01, 1);
            [self refreshCancelButtonTitle:@"取消"];//字体设置返回
            [_fontSettingView removeFromSuperview];
        }
    }
    else{
        [self completeByItemType:TTActivityTypeNone animation:animated];
    }
}

- (void)hideButtonClicked:(id)sender
{
    if (_layoutScheme == ActivityLayoutSchemeNone) {
        _layoutScheme = ActivityLayoutSchemeFixed;
        [_fontSettingView removeFromSuperview];
    }
    [self cancelButtonClicked];
}

- (void)setActivityItems:(NSArray *)activityItems
{
    if (activityItems != _activityItems) {
        _activityItems = activityItems;
    }
    [self itemContentViewAdjustSubviews];
}

- (void)itemContentViewAdjustSubviews
{
    [[_itemContentView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self showActivitysWithSpringAnimation];
}

- (void)showActivitysWithSpringAnimation
{
    if (_layoutScheme == ActivityLayoutSchemePadShare){
        [self refreshCancelButtonTitle:@"取消分享"];
        [_hideButton removeFromSuperview];
        _bgView.frame = CGRectMake(0, 0, self.width, self.height - kCancelButtonHeight - [TTDeviceHelper ssOnePixel]);
        _itemContentView.frame = _bgView.frame;
    }
    CGSize contentSize = _itemContentView.frame.size;
    _itemContentView.alpha = 0;
    
    [UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _itemContentView.alpha = 0.98f;
    } completion:^(BOOL finished) {
    }];
    
    for (int i = 0; i < [_activityItems count]; i ++) {
        TTActivity * activity = [_activityItems objectAtIndex:i];
        activity.delegate = self;
        activity.frame = [self frameForActivityItemAtIndex:i contentViewSize:contentSize];
        CGFloat top = activity.top;
        activity.top = 100;
        [UIView animateWithDuration:0.75 delay:0.1+i*0.06 usingSpringWithDamping:0.6 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            activity.top = top;
        } completion:^(BOOL finished) {
        }];
        [_itemContentView addSubview:activity];
    }
}

- (void)completeByItemType:(TTActivityType)itemType animation:(BOOL)animated
{
    self.actionItemType = itemType;
    
    if (_delegate && [_delegate respondsToSelector:@selector(activityView:willCompleteByItemType:)]) {
        [_delegate activityView:self willCompleteByItemType:_actionItemType];
    }
    else {
        [self dismissWithAnimation:animated];
    }
    
}

- (void)refreshCancelButtonTitle:(NSString *)title
{
    [_cancelButton setTitle:NSLocalizedString(title, nil) forState:UIControlStateNormal];
}

/**
 *  点击字体设置后移出activitys
 */
- (void)removeActivityItemsAnimation
{
    for (int i = 0;i < [_activityItems count]; i++) {
        TTActivity *activity = [_activityItems objectAtIndex:i];
        activity.alpha = 0;
        activity.delegate = self;
        if ([_activityItems count] == 3) {
            switch (i) {
                case 0:
                    activity.left = -(activity.width);
                    break;
                case 1:
                    break;
                case 2:
                    activity.left = self.width;
                    break;
                default:
                    break;
            }
        }
        else if ([_activityItems count] == 4){
            switch (i) {
                case 0:
                    activity.left = -(activity.width);
                    break;
                case 1:
                    activity.left = -(activity.width);
                    break;
                case 2:
                    activity.left = self.width;
                    break;
                case 3:
                    activity.left = self.width;
                    break;
                default:
                    break;
            }
        }
    }
}

/**
 *  点击返回后移回activitys
 */
- (void)moveBackActivityItemsAnimation
{
    CGSize contentSize = self.frame.size;
    for (int i = 0; i < [_activityItems count]; i ++) {
        
        TTActivity * activity = [_activityItems objectAtIndex:i];
        activity.alpha = 1;
        activity.frame = [self frameForActivityItemAtIndex:i contentViewSize:contentSize];
    }
}

/**
 *  字体设置
 */
- (void)fontSettingPressed
{
    if (!_showTTPanelController) {
        _fontSettingView = [[ExploreDetailFontSettingView alloc] initWithFrame:CGRectMake(0, kTopPading, self.width, (_itemContentView.height) - kTopPading)];
        _fontSettingView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.itemContentView addSubview:_fontSettingView];
        _fontSettingView.transform = CGAffineTransformMakeScale(0, 1);
        _fontSettingView.alpha = 0;
        [UIView animateWithDuration: 0.25 animations:^{
            [self removeActivityItemsAnimation];
            _fontSettingView.alpha = 0.98;
            _fontSettingView.transform = CGAffineTransformMakeScale(1, 1);
            
        } completion:^(BOOL finished) {
            _fontSettingView.alpha = 0.98;
            _fontSettingView.transform = CGAffineTransformMakeScale(1, 1);
        }];
        _layoutScheme = ActivityLayoutSchemeNone;
    } else {
        _fontSettingView = [[ExploreDetailFontSettingView alloc] initWithFrame:CGRectMake(0, kTopPading, self.width, (_itemContentView.height))];
        [[self.itemContentView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj removeFromSuperview];
        }];
        [self.itemContentView addSubview:_fontSettingView];
        _layoutScheme = ActivityLayoutSchemeNone;
        [self.panelController hideWithBlock:^{
            UIWindow * window = SSGetMainWindow();
            if ([TTDeviceHelper OSVersionNumber] < 8.f && [TTDeviceHelper isPadDevice]) {
                [super showOnViewController:window.rootViewController];
            }
            else {
                [super showOnWindow:window];
            }
        }];
    }
    [self refreshCancelButtonTitle:@"取消"];
    wrapperTrackEvent(@"detail", @"display_setting");
}

#pragma mark -- protected
- (void)dismissWithAnimation:(BOOL)animation {
    if (_showTTPanelController && self.panelController) {
        [self.panelController hideWithBlock:^{
            [self dismissDone];
        } animation:animation];
    } else {
        [super dismissWithAnimation:animation];
    }
}

- (void)dismissDone
{
    if (_delegate && [_delegate respondsToSelector:@selector(activityView:didCompleteByItemType:)]) {
        [_delegate activityView:self didCompleteByItemType:_actionItemType];
    }
}

#pragma mark -- calculate frame
- (CGRect)frameForActivityItemAtIndex:(NSUInteger)index contentViewSize:(CGSize)viewSize
{
    if (_layoutScheme == ActivityLayoutSchemePadShare) {//ipad上面分享界面
        float aspect = 0.055f;
        CGFloat itemGap = ceilf(self.width * aspect);
        CGFloat edgeMargin = self.width/2 - kItemWidth*2 - itemGap - itemGap/2;
        CGFloat originX = 0;
        if(index <= 3){
            originX = edgeMargin + index * (kItemWidth + itemGap);
            return CGRectMake(originX, kTopPading, kItemWidth, kItemHeight);
        }
        else if (index <= 7){
            originX = edgeMargin + (index - 4) * (kItemWidth + itemGap);
            return CGRectMake(originX, kTopPading + kItemHeight + 15, kItemWidth, kItemHeight);
        }
        else if (index <= 11){
            originX = edgeMargin + (index - 8) * (kItemWidth + itemGap);
            return CGRectMake(originX, kTopPading + 2*kItemHeight + 30, kItemWidth, kItemHeight);
        }
        else{
            originX = edgeMargin + (index - 12) * (kItemWidth + itemGap);
            return CGRectMake(originX, kTopPading + 3*kItemHeight + 45, kItemWidth, kItemHeight);
        }
    }
    else{
        if(_activityItems.count == 2){
            //图片详情页
            float aspect = 0.1f;
            CGFloat itemGap = ceilf(viewSize.width * aspect);
            CGFloat edgeMargin = viewSize.width/2 - kItemWidth - itemGap/2;
            CGFloat originX = edgeMargin + index * (kItemWidth + itemGap);
            return CGRectMake(originX, kTopPading, kItemWidth, kItemHeight);
        }
        else if (_activityItems.count == 3) {
            float aspect = 0.08125f;
            CGFloat itemGap = ceilf(viewSize.width * aspect);
            CGFloat edgeMargin = viewSize.width/2 - kItemWidth/2 - itemGap - kItemWidth;
            CGFloat originX = edgeMargin + index * (kItemWidth + itemGap);
            return CGRectMake(originX, kTopPading, kItemWidth, kItemHeight);
        }
        else if(_activityItems.count == 4){
            float aspect = 0.055f;
            CGFloat itemGap = ceilf(viewSize.width * aspect);
            CGFloat edgeMargin = viewSize.width/2 - kItemWidth*2 - itemGap - itemGap/2;
            CGFloat originX = edgeMargin + index * (kItemWidth + itemGap);
            return CGRectMake(originX, kTopPading, kItemWidth, kItemHeight);
        }
        else{
            return CGRectZero;
        }
    }
}

#pragma mark -- SSActivityDelegate

- (void)activity:(TTActivity *)activity activityButtonClicked:(TTActivityType)type
{
    if (_delegate && [_delegate respondsToSelector:@selector(activityView:didCompleteByItemType:)]) {
        [_delegate activityView:self didCompleteByItemType:type];
    }
}
#pragma mark -- Special for moreSettingActivityView

- (void)showActivityOnWindow:(UIWindow *)window
{
    _showTTPanelController = NO;
    self.contentBaseView.origin = CGPointMake(0, [TTUIResponderHelper screenSize].height);
    self.backgroundColor = [UIColor clearColor];
    
    if(![self superview])
    {
        [window addSubview:self];
        [window bringSubviewToFront:self];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [UIColor colorWithHexString:@"00000066"];
        self.contentBaseView.origin = CGPointMake( 0, 0);
    }];
}

#pragma mark -- Wrapper for TTPanelController (workaround)

- (void)showOnWindow:(UIWindow *)window
{
    [self showTTPanelControllerWithShareGroupOnly:NO];
}

- (void)showOnViewController:(UIViewController *)controller
{
    [self showOnViewController:controller useShareGroupOnly:NO];
}

- (void)showOnViewController:(UIViewController *)controller useShareGroupOnly:(BOOL)useShareGroupOnly
{
    [self showTTPanelControllerWithShareGroupOnly:useShareGroupOnly];
}

- (void)showOnViewController:(UIViewController *)controller useShareGroupOnly:(BOOL)useShareGroupOnly isFullScreen:(BOOL)isFullScreen
{
    [self showTTPanelControllerWithShareGroupOnly:useShareGroupOnly isFullScreen:isFullScreen];
}

- (void)show
{
    [self showTTPanelControllerWithShareGroupOnly:NO];
}

- (void)setActivityItemsWithFakeLayout:(NSArray *)activityItems
{
    NSArray * fakeItems = [NSArray arrayWithObject:activityItems.firstObject];
    _layoutScheme = ActivityLayoutSchemeFixed;
    self.activityItems = fakeItems; // layout
    _activityItems = activityItems;
}

- (void)showTTPanelControllerWithShareGroupOnly:(BOOL)useShareGroupOnly
{
    [self showTTPanelControllerWithShareGroupOnly:useShareGroupOnly isFullScreen:NO];
}

- (void)showTTPanelControllerWithShareGroupOnly:(BOOL)useShareGroupOnly isFullScreen:(BOOL)isFullScreen
{
    _showTTPanelController = YES;
    NSArray *items = [self groupedItemsUseShareGroupOnly:useShareGroupOnly];
    TTNewPanelController * panelC = [[TTNewPanelController alloc] initWithItems:items cancelTitle:@"取消" isFullScreen:isFullScreen cancelBlock:^{
        if ([self.delegate respondsToSelector:@selector(activityView:willCompleteByItemType:)]) {
            [self.delegate activityView:self willCompleteByItemType:TTActivityTypeNone];
        }
        [self dismissWithAnimation:YES];
    }];
    self.panelController = panelC;
    [panelC show];
}

/**
 *  added 5.4 支持仅显示单行分享items
 */
- (NSArray *)groupedItemsUseShareGroupOnly:(BOOL)useShareGroupOnly
{
    TTActivityType splitType = TTActivityTypeSystem;
    for (TTActivity * activity in self.activityItems) {
        if (activity.activityType >= TTActivityTypePGC && activity.activityType != TTActivityTypeReport && activity.activityType != TTActivityTypeDetele) {
            splitType = TTActivityTypePGC;
        }
    }
    
    NSMutableArray * group1 = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray * group2 = [NSMutableArray arrayWithCapacity:10];
    for (TTActivity * activity in self.activityItems) {
        TTActivityType type = activity.activityType;
        if (![self activityIsEnable:type]) {
            continue;
        }
        TTPanelButtonClick itemClickBlock = ^(void) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(activityView:didCompleteByItemType:)]) {
                [self.delegate activityView:self didCompleteByItemType:type];
            }
        };
        TTNewPanelButtonClick newItemClickBlock = ^(UIButton *button){
            if (self.delegate && [self.delegate respondsToSelector:@selector(activityView:button:didCompleteByItemType:)]) {
                [self.delegate activityView:self button:button didCompleteByItemType:type];
            }else if (self.delegate && [self.delegate respondsToSelector:@selector(activityView:didCompleteByItemType:)]) {
                button.selected = !button.selected;
                [self.delegate activityView:self didCompleteByItemType:type];
            }
        };
        TTPanelControllerItem * item = nil;
        if (type == TTActivityTypeDigUp || type == TTActivityTypeDigDown) {
            item = [[TTPanelControllerItem alloc] initSelectedTypeIcon:activity.activityImageName title:activity.activityTitle];
            item.clickAction = itemClickBlock;
            item.itemType = TTPanelControllerItemTypeSelectedDigIcon;
            item.selected = activity.selected;
            if (item.selected) {
                item.banDig = YES;    //如果已经顶或踩，禁止再顶或踩
            }
            item.count = activity.count;
        }
        else if (type == TTActivityTypeFavorite || type == TTActivityTypeFontSetting ) {
            TTNewPanelControllerItem *newItem = [[TTNewPanelControllerItem alloc] initSelectedTypeIcon:activity.activityImageName title:activity.activityTitle];
            newItem.clickAction = itemClickBlock;
            newItem.selectedButtonClick = newItemClickBlock;
            newItem.itemType = TTPanelControllerItemTypeSelectedIcon;
            newItem.selected = activity.selected;
            item = newItem;
        }
        else if (type == TTActivityTypePromotion) {
            item = [[TTPanelControllerItem alloc] initWithAvatar:activity.activityImageUrl title:activity.activityTitle showBorder:NO block:itemClickBlock];
            item.iconKey = activity.activityImageUrl;
            item.itemType = TTPanelControllerItemTypeAvatarNoBorder;
        }
        else {
            item = [[TTPanelControllerItem alloc] initWithAvatar:nil title:activity.activityTitle showBorder:YES block:itemClickBlock];
            if (type == TTActivityTypePGC ) {
                item.iconKey = activity.activityImageUrl;
                item.itemType = TTPanelControllerItemTypeAvatar;
            }else if (type == TTActivityTypeWeitoutiao){
                item.iconImage = activity.activityImage;
                item.itemType = TTPanelControllerItemTypeIcon;
            }else {
                item.iconKey = activity.activityImageName;
                item.itemType = TTPanelControllerItemTypeIcon;
            }
        }
        
        if (type == TTActivityTypePromotion) { // 强插在第二列第一个位子
            [group2 addObject:item];
        } else {
            if (type < splitType) {
                [group1 addObject:item];
            } else {
                [group2 addObject:item];
            }
        }
    }
    
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:2];
    if (group1.count > 0) {
        [result addObject:group1];
    }
    if (group2.count > 0 && !useShareGroupOnly) {
        [result addObject:group2];
    }
    
    return result;
}

- (void)showActivityItems:(NSArray *)activityItems
{
    [self showActivityItems:activityItems isFullSCreen:NO];
}

- (void)showActivityItems:(NSArray *)activityItems isFullSCreen:(BOOL)isFullScreen
{
    _showTTPanelController = YES;
    NSArray * items = [self panelItemsFromActivityItems:activityItems];
    TTNewPanelController * panelC = [[TTNewPanelController alloc] initWithItems:items cancelTitle:@"取消" isFullScreen:isFullScreen cancelBlock:^{
        [self dismissWithAnimation:YES];
    }];
    self.panelController = panelC;
    [panelC show];
}


// activityItems为二维数组
- (NSArray *)panelItemsFromActivityItems:(NSArray *)activityItems
{
    if (![activityItems isKindOfClass:[NSArray class]] || activityItems.count == 0 || ![activityItems[0] isKindOfClass:[NSArray class]]) {
        NSLog(@"activityItems: wrong type");
        return nil;
    }
    
    NSMutableArray *groups = [NSMutableArray array];
    
    for (NSArray *groupItems in activityItems) {
        NSMutableArray *group = [NSMutableArray array];
        
        for (TTActivity * activity in groupItems) {
            TTActivityType type = activity.activityType;
            if (![self activityIsEnable:type]) {
                continue;
            }
            TTPanelButtonClick itemClickBlock = ^(void) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(activityView:didCompleteByItemType:)]) {
                    [self.delegate activityView:self didCompleteByItemType:type];
                }
            };
            
            TTNewPanelButtonClick newItemClickBlock = ^(UIButton *button){
                if (self.delegate && [self.delegate respondsToSelector:@selector(activityView:button:didCompleteByItemType:)]) {
                    [self.delegate activityView:self button:button didCompleteByItemType:type];
                }else if (self.delegate && [self.delegate respondsToSelector:@selector(activityView:didCompleteByItemType:)]) {
                    button.selected = !button.selected;
                    [self.delegate activityView:self didCompleteByItemType:type];
                }
            };
            TTPanelControllerItem * item = nil;
            if (type == TTActivityTypeDigUp || type == TTActivityTypeDigDown) {
                item = [[TTPanelControllerItem alloc] initSelectedTypeIcon:activity.activityImageName title:activity.activityTitle];
                item.clickAction = itemClickBlock;
                item.itemType = TTPanelControllerItemTypeSelectedDigIcon;
                item.selected = activity.selected;
                if (item.selected) {
                    item.banDig = YES;    //如果已经顶或踩，禁止再顶或踩
                }
                item.count = activity.count;
            }
            else if (type == TTActivityTypeFavorite || type == TTActivityTypeFontSetting) {
                TTNewPanelControllerItem *newItem = [[TTNewPanelControllerItem alloc] initSelectedTypeIcon:activity.activityImageName title:activity.activityTitle];
                newItem.clickAction = itemClickBlock;
                newItem.selectedButtonClick = newItemClickBlock;
                newItem.itemType = TTPanelControllerItemTypeSelectedIcon;
                newItem.selected = activity.selected;
                item = newItem;
            } else {
                item = [[TTPanelControllerItem alloc] initWithAvatar:nil title:activity.activityTitle showBorder:YES block:itemClickBlock];
                if (type == TTActivityTypePGC) {
                    item.iconKey = activity.activityImageUrl;
                    item.itemType = TTPanelControllerItemTypeAvatar;
                }else if (type == TTActivityTypeWeitoutiao){
                    item.iconImage = activity.activityImage;
                    item.itemType = TTPanelControllerItemTypeIcon;
                }else {
                    item.iconKey = activity.activityImageName;
                    item.itemType = TTPanelControllerItemTypeIcon;
                }
            }
            
            [group addObject:item];
        }
        
        [groups addObject:group];
    }
    
    return groups;
}

- (BOOL)activityIsEnable:(TTActivityType)type
{
    switch (type) {
        case TTActivityTypeNightMode:
        case TTActivityTypeBlockUser:
        case TTActivityTypeUnBlockUser:
        case TTActivityTypeEMail:
        case TTActivityTypeWeitoutiao:
        case TTActivityTypeDingTalk:
        case TTActivityTypeZhiFuBaoMoment:
        case TTActivityTypeZhiFuBao:
        case TTActivityTypeMyMoment:
        case TTActivityTypeTwitter:
        case TTActivityTypeFacebook:
        case TTActivityTypeKaiXin:
        case TTActivityTypeRenRen:
        case TTActivityTypeQQWeibo:
        case TTActivityTypeSinaWeibo:
        case TTActivityTypeSystem:
        case TTActivityTypeCopy:
        case TTActivityTypeMessage:
        case TTActivityTypeCommodity:
        case TTActivityTypePromotion:
            return NO;
            break;
        default:
            return YES;
            break;
    }
}

@end
