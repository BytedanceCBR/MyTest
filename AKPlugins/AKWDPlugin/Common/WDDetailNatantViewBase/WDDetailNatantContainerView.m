//
//  WDDetailNatantContainerView.m
//  Article
//
//  Created by Ray on 16/4/5.
//
//

#import "WDDetailNatantContainerView.h"

#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "TTWDDetailADContainerView.h"
#import "WDDetailNatantHeaderItemBase.h"
#import "WDDefines.h"

@implementation WDDetailNatantContainerView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColors = @[ [UIColor colorWithHexString:@"ffffff"],[UIColor colorWithHexString:@"252525"] ];
        self.contentOffsetWhenLeave = NSNotFound;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fontChanged:) name:kSettingFontSizeChangedNotification object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)willAppear{
    [super willAppear];
    if (_contentOffsetWhenLeave != NSNotFound) {
        [self checkVisibleAtContentOffset:self.contentOffsetWhenLeave referViewHeight:self.referHeight];
    }
}

- (void)willDisappear{
    
}

- (void)setItems:(NSMutableArray<WDDetailNatantViewBase *> *)items{
    _items = items;
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for(WDDetailNatantViewBase * view in self.items){
        if (view) {
            [self addSubview:view];
            if ([NSStringFromClass([view class]) isEqualToString:@"TTWDDetailADContainerView"] && [view respondsToSelector:@selector(setDelegate:)]) {
                [view performSelector:@selector(setDelegate:) withObject:self];
            }
        }
    }
    [self _reloadUI];
}

- (void)removeNatantView:(WDDetailNatantViewBase *)natantView animated:(BOOL)animated {
    if ([self.items containsObject:natantView]) {
        NSInteger index =  [self.items indexOfObject:natantView];
        if (index < self.items.count - 1 && index > 0) {
            WDDetailNatantViewBase *spaceItem = self.items[index + 1];
            if ([NSStringFromClass([spaceItem class]) isEqualToString:@"WDDetailNatantHeaderPaddingView"]) {
                [self.items removeObject:spaceItem];
                [spaceItem removeFromSuperview];
            }
        }
        [self.items removeObject:natantView];
        [natantView removeFromSuperview];
        [self _reloadUI];
    }
}

- (void)_fontChanged:(NSNotification *)notify{
    for(WDDetailNatantViewBase * view in self.items){
        if (view) {
            [view fontChanged];
        }
    }
}

- (void)_reloadUI{
    CGFloat height = CGFLOAT_MIN; //作为Grouped Style Tableview的header时 height必须大于0.f 否则顶部会出现留白 @zengruihuan
    for(WDDetailNatantHeaderItemBase * view in self.items){
        if (view) {
            if ([view respondsToSelector:@selector(refreshUI)]) {
                [view refreshUI];
            }
            view.top = ceilf(height);
            height = view.bottom;
        }
    }
    self.height = height;
}

- (void)resetAllRelatedItemsWhenNatantDisappear{
    for(WDDetailNatantViewBase * view in self.items){
        if (view && [view respondsToSelector:@selector(resetAllRelatedItemsWhenNatantDisappear)]) {
            [view performSelector:@selector(resetAllRelatedItemsWhenNatantDisappear)];
        }
    }
}

//修复视频详情页banner广告show事件时机问题，新增方法，增加scrollview和self.sourceType，从videoDetail进入走新判断，从article进入走老判断
- (void)sendNatantItemsShowEventWithContentOffset:(CGFloat)natantContentoffsetY scrollView:(UIScrollView*)scrollView isScrollUp:(BOOL)isScrollUp
{
    if (self.sourceType == WDDetailNatantContainerViewSourceType_VideoDetail) {
        [self sendNatantItemsShowEventWithContentOffset:natantContentoffsetY isScrollUp: isScrollUp scrollView: scrollView shouldSendShowTrack:YES];
    }
    else
    {
        [self sendNatantItemsShowEventWithContentOffset:natantContentoffsetY isScrollUp:isScrollUp shouldSendShowTrack:YES];
    }
}

- (void)sendNatantItemsShowEventWithContentOffset:(CGFloat)natantContentoffsetY isScrollUp:(BOOL)isScrollUp{
    [self sendNatantItemsShowEventWithContentOffset:natantContentoffsetY isScrollUp:isScrollUp shouldSendShowTrack:YES];
}

- (void)sendNatantItemsShowEventWithContentOffset:(CGFloat)natantContentoffsetY isScrollUp:(BOOL)isScrollUp shouldSendShowTrack:(BOOL)shouldSend style:(NSString *)style {
    if (isScrollUp) {
        for(WDDetailNatantViewBase<WDDetailNatantViewBase> * view in self.items){
            if (view && natantContentoffsetY < view.bottom) {
                if (shouldSend) {
                    [view trackEventIfNeededWithStyle:style];
                }
                if (view.scrollInOrOutBlock) {
                    view.scrollInOrOutBlock(YES);
                }
            }else{
                if (view.scrollInOrOutBlock) {
                    view.scrollInOrOutBlock(NO);
                }
            }
        }
    }else{
        for(WDDetailNatantViewBase<WDDetailNatantViewBase> * view in self.items){
            if (view && natantContentoffsetY > view.top) {
                if (shouldSend) {
                    [view trackEventIfNeededWithStyle:style];
                }
                if (view.scrollInOrOutBlock) {
                    view.scrollInOrOutBlock(YES);
                }
            }else{
                if (view.scrollInOrOutBlock) {
                    view.scrollInOrOutBlock(NO);
                }
            }
        }
    }
}

//从article进入走老判断
- (void)sendNatantItemsShowEventWithContentOffset:(CGFloat)natantContentoffsetY isScrollUp:(BOOL)isScrollUp shouldSendShowTrack:(BOOL)shouldSend
{
    if (isScrollUp) {
        for(WDDetailNatantViewBase<WDDetailNatantViewBase> * view in self.items){
            if (view && natantContentoffsetY < view.bottom) {
                if (shouldSend) {
                    [view trackEventIfNeeded];
                }
                if (view.scrollInOrOutBlock) {
                    view.scrollInOrOutBlock(YES);
                }
            }else{
                if (view.scrollInOrOutBlock) {
                    view.scrollInOrOutBlock(NO);
                }
            }
        }
    }else{
        for(WDDetailNatantViewBase<WDDetailNatantViewBase> * view in self.items){
            if (view && natantContentoffsetY > view.top) {
                if (shouldSend) {
                    [view trackEventIfNeeded];
                }
                if (view.scrollInOrOutBlock) {
                    view.scrollInOrOutBlock(YES);
                }
            }else{
                if (view.scrollInOrOutBlock) {
                    view.scrollInOrOutBlock(NO);
                }
            }
        }
    }
}

//从videoDetail进入走新判断
- (void)sendNatantItemsShowEventWithContentOffset:(CGFloat)natantContentoffsetY isScrollUp:(BOOL)isScrollUp scrollView:(UIScrollView*)scrollView shouldSendShowTrack:(BOOL)shouldSend
{
    if (isScrollUp) {
        for(WDDetailNatantViewBase<WDDetailNatantViewBase> * view in self.items){
            if (view && natantContentoffsetY + scrollView.height > view.top) {
                if (shouldSend) {
                    [view trackEventIfNeeded];
                }
                if (view.scrollInOrOutBlock) {
                    view.scrollInOrOutBlock(YES);
                }
            }else{
                if (view.scrollInOrOutBlock) {
                    view.scrollInOrOutBlock(NO);
                }
            }
        }
    }else{
        for(WDDetailNatantViewBase<WDDetailNatantViewBase> * view in self.items){
            if (view && natantContentoffsetY > view.top) {
                if (shouldSend) {
                    [view trackEventIfNeeded];
                }
                if (view.scrollInOrOutBlock) {
                    view.scrollInOrOutBlock(YES);
                }
            }else{
                if (view.scrollInOrOutBlock) {
                    view.scrollInOrOutBlock(NO);
                }
            }
        }
    }
}

- (void)checkVisibleAtContentOffset:(CGFloat)contentOffset referViewHeight:(CGFloat)referHeight{
    self.contentOffsetWhenLeave = contentOffset;
    self.referHeight = referHeight;
    for(WDDetailNatantViewBase<WDDetailNatantViewBase> * view in self.items){
        if (view) {
            [view checkVisableRelatedArticlesAtContentOffset:contentOffset referViewHeight:referHeight];
        }
    }
}

-(void)reloadData:(nullable id)object{
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.items];
    for (WDDetailNatantViewBase *view in tempArray) {
        if (view) {
            __weak typeof(self) wself = self;
            [view setRelayOutBlock:^(BOOL animated){
                __strong typeof(wself) self = wself;
                [self _reloadUI];
            }];
            [view reloadData:object];
            
            if ([view isKindOfClass:[TTWDDetailADContainerView class]]) {
                TTWDDetailADContainerView *adView = (TTWDDetailADContainerView*)view;
                TTAdDetailViewModel *adViewModel = [TTAdDetailViewModel new];
                adViewModel.fromSource = 0;
                adViewModel.mediaInfo = nil;
                adView.viewModel = adViewModel;
            }
        }
    }
    
    [self _reloadUI];
    
}

- (void)layoutSubviews
{
    [self _reloadUI];
    [super layoutSubviews];
}

- (void)removeObject:(nonnull id)obj{
    if ([self.items containsObject:obj]) {
        [self.items removeObject:obj];
    }
    [self _reloadUI];
}

- (void)insertObject:(nonnull id)obj atIndex:(NSUInteger)index{
    if (!obj) {
        return;
    }
    if ([self.items containsObject:obj]) {
        return;
    }
    if (![obj isKindOfClass:[UIView class]]) {
        return;
    }
    if (index>self.items.count) {
        return;
    }
    [self.items insertObject:obj atIndex:index];
    [self addSubview:obj];
    [self _reloadUI];
}

- (nullable WDDetailNatantViewBase *)itemViewForClassName:(NSString *)className{
    if (!className) {
        return nil;
    }
    for(WDDetailNatantViewBase<WDDetailNatantViewBase> * view in self.items){
        if ([view isKindOfClass:NSClassFromString(className)]) {
            return view;
        }
    }
    return nil;
}

@end
