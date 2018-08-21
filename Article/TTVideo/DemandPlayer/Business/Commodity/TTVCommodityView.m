//
//  TTVCommodityView.m
//  Article
//
//  Created by panxiang on 2017/8/8.
//
//

#import "TTVCommodityView.h"
#import "KVOController.h"
#import "TTVPlayerStateStore.h"
#import "TTVCommodityItemViewFull.h"
#import "TTVCommodityEntity.h"
#import "TTVSwipeView.h"
#import "TTDeviceHelper.h"
#import "TTVPlayVideo.h"
#import "StyledPageControl.h"

@protocol TTVCommodityViewCellDelegate <NSObject>

- (void)ttv_didOpenCommodity:(TTVCommodityEntity *)entity index:(NSInteger)index isClickButton:(BOOL)isClickButton;

@end

@interface TTVCommodityViewCell : UIView<TTVCommodityItemViewFullDelegate>
@property (nonatomic ,strong)NSMutableArray *entitys;
@property (nonatomic ,strong)NSMutableArray *itemViews;
@property (nonatomic, weak) TTVVideoPlayerStateStore *playerStateStore;
@property (nonatomic ,weak)NSObject <TTVCommodityViewCellDelegate> *delegate;
@end

@implementation TTVCommodityViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
        _itemViews = [NSMutableArray arrayWithCapacity:2];
    }
    return self;
}
- (void)setEntitys:(NSMutableArray *)entitys
{
    if (_entitys != entitys) {
        _entitys = entitys;
        [_itemViews removeAllObjects];
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        for (TTVCommodityEntity *entity in entitys) {
            TTVCommodityItemViewFull *item = [[TTVCommodityItemViewFull alloc] init];
            item.delegate = self;
            item.entity = entity;
            [self addSubview:item];
            [_itemViews addObject:item];
        }
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    BOOL isFullScreen = self.playerStateStore.state.isFullScreen;
    BOOL isLargeScreen = [TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice] ;
    NSInteger height = 62 * (isLargeScreen ? 1 : 0.9);
    NSInteger diff = self.playerStateStore ? 17 : 10;
    NSInteger leftFull = 14;
    NSInteger width = self.width - leftFull * 2;
    if (isFullScreen) {
        width = 337 * (isLargeScreen ? 1 : 0.9);
        leftFull = (self.width - width) / 2.0;
    }
    
    NSInteger top = 0;
    if (self.playerStateStore.state.isInDetail && !isFullScreen) {
        top = 33;
    }
    if (_itemViews.count == 1) {
        TTVCommodityItemViewFull *item = [_itemViews firstObject];
        item.frame = CGRectMake(leftFull, (self.height - top - height) / 2.0 + top, width, height);
        item.isFullScreen = isFullScreen;
    }
    if (_itemViews.count == 2) {
        TTVCommodityItemViewFull *first = [_itemViews firstObject];
        first.frame = CGRectMake(leftFull, (self.height - top - (height * 2 + diff)) / 2.0 + top, width, height);
        first.isFullScreen = isFullScreen;
        
        TTVCommodityItemViewFull *last = [_itemViews lastObject];
        if (!isLargeScreen && !isFullScreen && self.playerStateStore.state.isInDetail) {
            diff -= 8;
        }
        last.frame = CGRectMake(leftFull, first.bottom + diff, width, height);
        last.isFullScreen = isFullScreen;
    }
}

- (void)ttv_didOpenCommodity:(TTVCommodityEntity *)entity isClickButton:(BOOL)isClickButton
{
    if ([self.delegate respondsToSelector:@selector(ttv_didOpenCommodity:index:isClickButton:)]) {
        [self.delegate ttv_didOpenCommodity:entity index:[self.entitys indexOfObject:entity] isClickButton:isClickButton];
    }
}

@end

@interface TTVCommodityView ()<TTVSwipeViewDelegate ,TTVSwipeViewDataSource ,TTVCommodityViewCellDelegate>
@property (nonatomic ,strong)NSArray *commoditys;
@property (nonatomic ,strong)NSMutableArray *commodityEngitys;
@property (nonatomic ,strong)TTVSwipeView *swipeView;
@property (nonatomic ,strong)StyledPageControl *pageControl;
@property (nonatomic ,strong)UIButton *closeButton;
@property (nonatomic, assign) BOOL isFullScreen;
@end

@implementation TTVCommodityView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.9f];
        _swipeView = [[TTVSwipeView alloc] initWithFrame:frame];
        _swipeView.dataSource = self;
        _swipeView.pagingEnabled = YES;
        _swipeView.delegate = self;
        _swipeView.bounces = NO;
        [self addSubview:_swipeView];
        _commodityEngitys = [NSMutableArray array];
        
        self.pageControl = [[StyledPageControl alloc] initWithFrame:CGRectZero];
        self.pageControl.hidesForSinglePage = YES;
        self.pageControl.pageControlStyle = PageControlStyleDefault;
        self.pageControl.coreNormalColor = [UIColor colorWithWhite:1 alpha:0.15];
        self.pageControl.coreSelectedColor = [UIColor colorWithWhite:1 alpha:0.3];
        self.pageControl.gapWidth = 8;
        self.pageControl.diameter = 4;
        [self addSubview:self.pageControl];
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-8.f, -8.f, -8.f, -8.f);
        [self.closeButton setImage:[UIImage imageNamed:@"video_commodity_close.png"] forState:UIControlStateNormal];
        [self.closeButton sizeToFit];
        [self.closeButton addTarget:self action:@selector(closeCommodityAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];
        
        
    }
    return self;
}

- (void)dealloc
{
    [self.playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (void)setPlayerStateStore:(TTVVideoPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [self.playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        [self.KVOController unobserve:self.playerStateStore.state];
        _playerStateStore = playerStateStore;
        [self ttv_kvo];
        [self.playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
    }
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.isFullScreen = self.playerStateStore.state.isFullScreen;
    }];
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    if (_isFullScreen != isFullScreen) {
        _isFullScreen = isFullScreen;
        [self.swipeView reloadData];
        [self setNeedsLayout];
    }
}

- (void)setCommoditys:(NSArray *)commoditys
{
    if (_commoditys != commoditys) {
        _commoditys = commoditys;
        for (NSDictionary *dic in commoditys) {
            if ([dic isKindOfClass:[NSDictionary class]]) {
                TTVCommodityEntity *entity = [TTVCommodityEntity entityWithDictionary:dic];
                [self.commodityEngitys addObject:entity];
            }
        }
        [self.commodityEngitys sortUsingComparator:^NSComparisonResult(TTVCommodityEntity *obj1, TTVCommodityEntity *obj2) {
            if (obj1.insert_time < obj2.insert_time) return NSOrderedAscending;
            if (obj1.insert_time > obj2.insert_time) return NSOrderedDescending;
            return NSOrderedSame;
        }];
        self.pageControl.numberOfPages = [self numberOfPage];
        [_swipeView reloadData];
        [self setNeedsLayout];
    }
}

- (NSString *)position
{
    if (self.playerStateStore) {
        if (self.playerStateStore.state.isInDetail) {
            return @"detail";
        }
        return @"list";
    }
    return _position;
}

- (NSMutableDictionary *)commonDicWithEntity:(TTVCommodityEntity *)entity index:(NSInteger)index
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"all_screen_player" forKey:@"section"];
    if (self.position) {
        [dic setValue:self.position forKey:@"position"];
    }
    [dic setValue:@(entity.insert_time) forKey:@"insert_time"];
    if (self.playerStateStore.state.playerModel.itemID) {
        [dic setValue:self.playerStateStore.state.playerModel.itemID forKey:@"item_id"];
    }
    if (self.groupID) {
        [dic setValue:self.groupID forKey:@"group_id"];
    }
    [dic setValue:@"TEMAI" forKey:@"EVENT_ORIGIN_FEATURE"];
    [dic setValue:self.playerStateStore.state.isFullScreen ? @"fullscreen" : @"nofullscreen" forKey:@"fullscreen"];
    NSMutableDictionary *commodity_attr = [NSMutableDictionary dictionary];
    [commodity_attr setValue:@([self.commodityEngitys indexOfObject:entity] + 1) forKey:@"commodity_no"];
    [commodity_attr setValue:@(self.commodityEngitys.count) forKey:@"commodity_num"];
    [commodity_attr setValue:entity.commodity_id forKey:@"commodity_id"];
    [dic setValue:commodity_attr forKey:@"commodity_attr"];
    return dic;
}

- (void)ttv_showTrackWithEntity:(TTVCommodityEntity *)entity index:(NSInteger)index
{
    [TTTrackerWrapper eventV3:@"commodity_show" params:[self commonDicWithEntity:entity index:index]];
}

- (void)ttv_clickCommodityTrackWithEntity:(TTVCommodityEntity *)entity index:(NSInteger)index isClickButton:(BOOL)isClickButton
{
    [TTTrackerWrapper eventV3:@"commodity_click" params:[self commonDicWithEntity:entity index:index]];
    self.playVideo.player.superview.hidden = YES;
    [self.playVideo exitFullScreen:NO completion:^(BOOL finished) {
        self.playVideo.player.superview.hidden = NO;
    }];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat closeButtonOriginY = self.playerStateStore.state.isFullScreen ? [TTDeviceUIUtils tt_newPadding:30] : [TTDeviceUIUtils tt_newPadding:8];
    CGFloat closeButtonRightSpace = self.playerStateStore.state.isFullScreen ? [TTDeviceUIUtils tt_newPadding:16] : [TTDeviceUIUtils tt_newPadding:8];
    self.closeButton.frame = CGRectMake(self.width - closeButtonRightSpace - self.closeButton.width, closeButtonOriginY, self.closeButton.width, self.closeButton.height);
    NSInteger bottom = self.isFullScreen ? 40 : 10;
    self.pageControl.frame = CGRectMake(0, self.height - bottom, self.width, self.pageControl.diameter);
    [self.pageControl setNeedsDisplay];
    self.swipeView.frame = self.bounds;
}

- (NSInteger)numberOfPage
{
    return ceil(self.commodityEngitys.count / 2.0);
}

- (NSInteger)numberOfItemsInSwipeView:(TTVSwipeView *)swipeView
{
    return [self numberOfPage];
}

- (CGSize)swipeViewItemSize:(TTVSwipeView *)swipeView
{
    return self.bounds.size;
}

- (UIView *)swipeView:(TTVSwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(TTVCommodityViewCell *)view
{
    if (!view) {
        view = [[TTVCommodityViewCell alloc] initWithFrame:self.bounds];
        view.delegate = self;
    }
    if ([view isKindOfClass:[TTVCommodityViewCell class]]) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
        if (self.commodityEngitys.count > 2 * index) {
            [array addObject:[self.commodityEngitys objectAtIndex:2 * index]];
        }
        if (self.commodityEngitys.count > 2 * index + 1) {
            [array addObject:[self.commodityEngitys objectAtIndex:2 * index + 1]];
        }
        view.entitys = array;
        view.playerStateStore = self.playerStateStore;
    }
    return view;
}

- (void)swipeViewCurrentItemIndexDidChange:(TTVSwipeView *)swipeView
{
    if (self.swipeView.currentPage >= 0 && self.swipeView.currentPage <= self.commodityEngitys.count - 1) {
        NSInteger index = 2 * self.swipeView.currentPage;
        if (self.commodityEngitys.count > index) {
            [self ttv_showTrackWithEntity:[self.commodityEngitys objectAtIndex:index] index:index];
        }
        index = 2 * self.swipeView.currentPage + 1;
        if (self.commodityEngitys.count > index) {
            [self ttv_showTrackWithEntity:[self.commodityEngitys objectAtIndex:index] index:index];
        }
        
    }
    self.pageControl.currentPage = self.swipeView.currentPage;
}

- (void)swipeView:(TTVSwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index
{

}

- (void)showCommodity
{
    self.hidden = NO;
    [self.playVideo.player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
    self.playerStateStore.state.isCommodityViewShow = YES;
    if (self.commodityEngitys.count >= 1) {
        [self ttv_showTrackWithEntity:[self.commodityEngitys objectAtIndex:0] index:0];
    }
    if (self.commodityEngitys.count >= 2) {
        [self ttv_showTrackWithEntity:[self.commodityEngitys objectAtIndex:1] index:1];
    }
}

- (void)closeCommodityAction
{
    [self.playVideo.player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
    [self closeCommodity];
}

- (void)closeCommodity
{
    self.playerStateStore.state.isCommodityViewShow = NO;
    if ([self.delegate respondsToSelector:@selector(commodityViewClosed)]) {
        [self.delegate commodityViewClosed];
    }
    self.hidden = YES;
    [self removeFromSuperview];
}

- (void)ttv_removeFromSuperview
{
    self.playerStateStore.state.isCommodityViewShow = NO;
    self.hidden = YES;
    [self removeFromSuperview];
}

- (void)ttv_didOpenCommodity:(TTVCommodityEntity *)entity index:(NSInteger)index isClickButton:(BOOL)isClickButton
{
    [self ttv_clickCommodityTrackWithEntity:entity index:index isClickButton:isClickButton];
}
@end
