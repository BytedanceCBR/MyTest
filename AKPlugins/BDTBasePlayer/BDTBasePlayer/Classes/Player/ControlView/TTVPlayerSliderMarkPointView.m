//
//  TTVPlayerSliderMarkPointView.m
//  Article
//
//  Created by lijun.thinker on 2017/8/13.
//

#import "TTVPlayerSliderMarkPointView.h"
#import "KVOController.h"
#import "TTVPlayerStateStore.h"
#import "EXTScope.h"
#import "EXTKeyPathCoding.h"
#import "UIViewAdditions.h"

@interface TTVPlayerSliderMarkPoint : UIView
@property (nonatomic ,assign)float currentPlayBackTime;
@property (nonatomic ,assign)float insertTime;
@end

@implementation TTVPlayerSliderMarkPoint

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:248/255.f green:89/255.f blue:89/255.f alpha:1.f];
    }
    return self;
}

- (void)setCurrentPlayBackTime:(float)currentPlayBackTime
{
    _currentPlayBackTime = currentPlayBackTime;
    if (self.insertTime > currentPlayBackTime) {
        self.backgroundColor = [UIColor colorWithRed:248/255.f green:89/255.f blue:89/255.f alpha:1.f];
    }else{
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end


@interface TTVPlayerMiniSliderMarkPoint : TTVPlayerSliderMarkPoint
@property (nonatomic ,assign)float currentPlayBackTime;
@property (nonatomic ,assign)float insertTime;
@end

@implementation TTVPlayerMiniSliderMarkPoint

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:248/255.f green:89/255.f blue:89/255.f alpha:1.f];
    }
    return self;
}

- (void)setCurrentPlayBackTime:(float)currentPlayBackTime
{
    [super setCurrentPlayBackTime:currentPlayBackTime];
    if (self.insertTime > currentPlayBackTime) {
        self.backgroundColor = [UIColor colorWithRed:248/255.f green:89/255.f blue:89/255.f alpha:1.f];
    }else{
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end

@interface TTVPlayerSliderMarkPointView()

@property (nonatomic, strong) NSMutableDictionary <NSNumber*, UIView *> *itemViews;
@property (nonatomic, assign) TTVPlayerSliderMarkPointStyle pointStyle;


@end

@implementation TTVPlayerSliderMarkPointView

- (void)dealloc {
    [self.playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (instancetype)initWithFrame:(CGRect)frame style:(TTVPlayerSliderMarkPointStyle)style {
    
    if (self = [super initWithFrame:frame]) {
        self.pointStyle = style;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)ttv_addKVO {
    
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state, duration) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        
        if (self.playerStateStore.state.duration > 0) {
            self.hidden = NO;
            [self ttv_updateitemViewsFrame];
        }
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state, insertTimes) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (self.playerStateStore.state.insertTimes.count > 0) {
            
            [self ttv_refreshSliderViewWithInsertTimes];
        }
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state, currentPlaybackTime) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (self.itemViews.count > 0) {
            for (TTVPlayerSliderMarkPoint *point in [self.itemViews allValues]) {
                if ([point isKindOfClass:[TTVPlayerSliderMarkPoint class]]) {
                    point.currentPlayBackTime = self.playerStateStore.state.currentPlaybackTime;
                }
            }
        }
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state, isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self updateFrame];
    }];
    
}

- (void)updateFrame {
    
    [self ttv_updateitemViewsFrame];
}

- (void)ttv_refreshSliderViewWithInsertTimes {
    for (UIView *view in [self.itemViews allValues]) {
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    [self.itemViews removeAllObjects];
    for (NSNumber *insertTime in self.playerStateStore.state.insertTimes) {
        TTVPlayerSliderMarkPoint *itemView = nil;
        if (self.pointStyle == TTVPlayerSliderMarkPointStyleNormal) {
            itemView = [[TTVPlayerSliderMarkPoint alloc] initWithFrame:[self itemViewFrame]];
        }else if (self.pointStyle == TTVPlayerSliderMarkPointStyleMini){
            itemView = [[TTVPlayerMiniSliderMarkPoint alloc] initWithFrame:[self itemViewFrame]];
        }
        itemView.centerY = self.centerY;
        itemView.insertTime = [insertTime floatValue];
        
        [self addSubview:itemView];
        
        self.itemViews[insertTime] = itemView;
    }
}

- (CGRect)itemViewFrame
{
    return CGRectMake(0, 0, self.height * 2, self.height);
}

- (void)ttv_updateitemViewsFrame {
    
    if (self.playerStateStore.state.duration <= 0) {
        
        return;
    }
    
    [self.itemViews enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIView * _Nonnull obj, BOOL * _Nonnull stop) {
        obj.frame = [self itemViewFrame];
        obj.left = self.width * (key.floatValue / self.playerStateStore.state.duration);
        obj.centerY = self.centerY;
    }];
}

#pragma mark - Getter & Setter

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore {
    
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        
        [self ttv_addKVO];
    }
}

- (NSMutableDictionary<NSNumber *,UIView *> *)itemViews {
    
    if (!_itemViews) {
        
        _itemViews = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    
    return _itemViews;
}

@end
