//
//  TTVCommodityFloatView.m
//  Article
//
//  Created by panxiang on 2017/8/8.
//
//

#import "TTVCommodityFloatView.h"
#import "KVOController.h"
#import "TTURLUtils.h"
#import "TTRoute.h"
#import "TTVCommodityItemView.h"
#import "TTVCommodityEntity.h"
#import "TTDeviceHelper.h"
#import "UIView+CustomTimingFunction.h"
#import "TTVDemandPlayer.h"
#import "TTSettingsManager.h"

static NSString *kTTPlayerSpecialSellItemCellDismisToMoreButtonTimesKey = @"kTTPlayerSpecialSellItemCellDismisToMoreButtonTimesKey";

@interface TTVCommodityFloatView ()<TTVCommodityItemViewDelegate>
@property (nonatomic ,strong)NSArray *commoditys;
@property (nonatomic ,assign)BOOL isAnimationing;
@property (nonatomic ,assign)BOOL didHidden;

@property (nonatomic ,strong)TTVCommodityItemView *itemView;
@end

@implementation TTVCommodityFloatView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        CGFloat scale = [TTDeviceHelper isScreenWidthLarge320] ? 1.0 : 0.9;
        _itemView = [[TTVCommodityItemView alloc] initWithFrame:CGRectMake(0, 0, 190 * scale, 52 * scale)];
        _itemView.delegate = self;
        [self addSubview:_itemView];
        self.didHidden = YES;
    }
    return self;
}

- (void)dealloc
{
    [self.playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (UIView *)backgroundView
{
    return self.itemView;
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
    if ([action isKindOfClass:[TTVPlayerStateAction class]] && ([state isKindOfClass:[TTVPlayerStateModel class]] || state == nil)) {
        switch (action.actionType) {
            case TTVPlayerEventTypePlayerStop:
                [self.itemView removeFromSuperview];
                break;
            default:
                break;
        }
    }
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.itemView.isFullScreen = self.playerStateStore.state.isFullScreen;
        [self setNeedsLayout];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,toolBarState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (!self.isAnimationing) {
            [self setNeedsLayout];
        }
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isInDetail) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        NSDictionary *dic = [[TTSettingsManager sharedManager] settingForKey:@"tt_video_commodity" defaultValue:@{} freeze:NO];
        BOOL show = [[dic valueForKey:@"detail_show_commodity_in_play"] boolValue];
        if (self.playerStateStore.state.isInDetail && !show) {
            self.hidden = YES;
        }else{
            if (!self.playerStateStore.state.resolutionAlertShowed) {
                self.hidden = NO;
            }
        }
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,currentPlaybackTime) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if ([[change objectForKey:NSKeyValueChangeOldKey] integerValue] == [[change objectForKey:NSKeyValueChangeNewKey] integerValue] || self.playerStateStore.state.currentPlaybackTime <= 0) {
            return ;
        }
        NSDictionary *dic = [[TTSettingsManager sharedManager] settingForKey:@"tt_video_commodity" defaultValue:@{} freeze:NO];
        BOOL show = [[dic valueForKey:@"detail_show_commodity_in_play"] boolValue];
        if (self.playerStateStore.state.isInDetail && !show) {
            self.didHidden = YES;
            return;
        }
        for (TTVCommodityEntity *entity in self.playerStateStore.state.commodityEngitys) {
            if (entity) {
                if (self.playerStateStore.state.currentPlaybackTime - entity.insert_time >= 0 &&
                    self.playerStateStore.state.currentPlaybackTime - entity.insert_time < entity.display_duration) {
                    if (self.didHidden && !entity.isShowed && !self.playerStateStore.state.isCommodityButtonShow) {
                        entity.isShowed = YES;
                        self.itemView.entity = entity;
                        self.didHidden = NO;
                        entity.isDismissed = NO;
                        [self addSubview:self.itemView];
                        if (!self.playerStateStore.state.isCommodityButtonShow) {
                            [self displayCommodityViewWithEntity:entity];
                        }
                    }
                } else {
                    if (!entity.isDismissed && entity.isShowed) {
                        [self ttv_dismissCommodityView];
                        entity.isDismissed = YES;
                    }
                    entity.isShowed = NO;
                }
            }
        }
        
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,resolutionAlertShowed) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.hidden = self.playerStateStore.state.resolutionAlertShowed;
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isCommodityButtonShow) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (self.playerStateStore.state.isCommodityButtonShow) {
            self.hidden = YES;
            self.itemView.hidden = YES;
        }
        if (!self.playerStateStore.state.resolutionAlertShowed && self.playerStateStore.state.commodityEngitys.count > 0 && !self.playerStateStore.state.isCommodityButtonShow) {
            if (self.itemView.shouldShow) {
                [self.itemView show];
            }
        }
    }];
}

- (NSString *)ttv_position
{
    if (self.playerStateStore.state.isFullScreen) {
        return @"fullscreen";
    }
    if (self.playerStateStore.state.isInDetail) {
        return @"detail";
    }
    return @"list";
}

- (NSMutableDictionary *)commonDic
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"right_bottom_player" forKey:@"section"];
    [dic setValue:[self ttv_position] forKey:@"position"];
    [dic setValue:@(self.itemView.entity.insert_time) forKey:@"insert_time"];
    if (self.playerStateStore.state.playerModel.itemID) {
        [dic setValue:self.playerStateStore.state.playerModel.itemID forKey:@"item_id"];
    }
    if (self.playerStateStore.state.playerModel.groupID) {
        [dic setValue:self.playerStateStore.state.playerModel.groupID forKey:@"group_id"];
    }
    [dic setValue:@"TEMAI" forKey:@"EVENT_ORIGIN_FEATURE"];
    [dic setValue:self.playerStateStore.state.isFullScreen ? @"fullscreen" : @"nofullscreen" forKey:@"fullscreen"];
    NSMutableDictionary *commodity_attr = [NSMutableDictionary dictionary];
    [commodity_attr setValue:@([self.playerStateStore.state.commodityEngitys indexOfObject:self.itemView.entity] + 1) forKey:@"commodity_no"];
    [commodity_attr setValue:@(self.playerStateStore.state.commodityEngitys.count) forKey:@"commodity_num"];
    [commodity_attr setValue:self.itemView.entity.commodity_id forKey:@"commodity_id"];
    [dic setValue:commodity_attr forKey:@"commodity_attr"];
    [dic setValue:@"right_bottom_player" forKey:@"section"];

    return dic;
}

- (void)ttv_showCommodityTrack
{
    if (!self.hidden) {
        [TTTrackerWrapper eventV3:@"commodity_show" params:[self commonDic]];
    }
}

- (void)ttv_clickCommodityTrack
{
    if (!self.hidden) {
        [TTTrackerWrapper eventV3:@"commodity_click" params:[self commonDic]];
    }
}

- (void)ttv_didOpenCommodityByWeb:(BOOL)isWeb
{
    [self ttv_clickCommodityTrack];
    
    self.player.superview.hidden = YES;
    [self.player exitFullScreen:YES completion:^(BOOL finished) {
        self.player.superview.hidden = NO;
    }];
}

- (void)ttv_dimissItemViewWithTargetAnimation:(BOOL)isToTarget{
    if (isToTarget) {
        [self ttv_dismissCommodityView];
    }else{
        [self ttv_dismissNormal];
    }
}

- (void)displayCommodityViewWithEntity:(TTVCommodityEntity *)entity
{
    [self.itemView show];
    [self ttv_showCommodityTrack];
    self.itemView.origin = CGPointMake(self.width, [self itemViewOrigin].y);
    self.isAnimationing = YES;
    self.itemView.isAnimationing = YES;
    self.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.7 customTimingFunction:CustomTimingFunctionQuintOut animation:^{
        self.itemView.origin = [self itemViewOrigin];
    } completion:^(BOOL finished) {
        self.isAnimationing = NO;
        self.itemView.isAnimationing = NO;
        self.itemView.origin = [self itemViewOrigin];
        if (!self.playerStateStore.state.isCommodityButtonShow) {
            [self.itemView show];
        }else{
            self.itemView.shouldShow = YES;
        }
    }];
}


- (void)ttv_dismissNormal
{
    self.itemView.shouldShow = NO;
    self.isAnimationing = YES;
    self.itemView.isAnimationing = YES;
    [UIView animateWithDuration:0.38 customTimingFunction:CustomTimingFunctionQuintOut animation:^{
        self.itemView.origin = CGPointMake(self.width, self.itemView.origin.y);
    } completion:^(BOOL finished) {
        self.isAnimationing = NO;
        self.itemView.isAnimationing = NO;
        self.itemView.origin = CGPointMake(self.width, self.itemView.origin.y);
        self.itemView.hidden = YES;
        self.didHidden = YES;
        self.userInteractionEnabled = YES;
    }];
}

- (void)ttv_dismissCommodityView
{
    if (!self.itemView.superview) {
        
        return;
    }
    self.userInteractionEnabled = NO;
    if ([self ttv_shouldDismissToMoreButton]) {
        [self ttv_dismissToTargetView];
    } else {
        [self ttv_dismissNormal];
    }
}

- (void)ttv_dismissToTargetView
{
    [self ttv_increaseDismissToMoreButtonTimes];
    
    UIView *target = self.animationToView;
    UIView *commonView = self.animationSuperView;
    
    [commonView addSubview:self.itemView];

    CGPoint dest = [target convertPoint:target.center toView:commonView];
    dest.x = target.centerX;
    [UIView animateWithDuration:0.38 customTimingFunction:CustomTimingFunctionQuadInOut animation:^{
        self.itemView.alpha = 0;
        self.itemView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        self.itemView.center = dest;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.didHidden = YES;
        self.itemView.transform = CGAffineTransformIdentity;
        [self.itemView removeFromSuperview];
        [self ttv_zoomOutMoreButton];
        self.userInteractionEnabled = YES;
    }];
}

- (void)ttv_zoomOutMoreButton
{
    UIButton *target = [[UIButton alloc] initWithFrame:self.animationToView.frame];
    [target setImage:[UIImage themedImageNamed:@"More"] forState:UIControlStateNormal];
    [self.animationToView.superview addSubview:target];
    self.animationToView.alpha = 0;
    
    self.isAnimationing = YES;
    self.itemView.isAnimationing = YES;
    [UIView animateWithDuration:0.2 customTimingFunction:CustomTimingFunctionCubicOut delay:0.34 options:0 animation:^{
        target.transform = CGAffineTransformMakeScale(1.4, 1.4);
    } completion:^(BOOL finished) {
        self.isAnimationing = NO;
        self.itemView.isAnimationing = NO;
        target.transform = CGAffineTransformIdentity;
        [target removeFromSuperview];
        self.animationToView.alpha = 1;
    }];
}

- (void)ttv_increaseDismissToMoreButtonTimes
{
    if (!self.playerStateStore.state.isFullScreen) {
        NSInteger times = [[NSUserDefaults standardUserDefaults] integerForKey:kTTPlayerSpecialSellItemCellDismisToMoreButtonTimesKey];
        [[NSUserDefaults standardUserDefaults] setInteger:++times forKey:kTTPlayerSpecialSellItemCellDismisToMoreButtonTimesKey];
    }
}

- (BOOL)ttv_shouldDismissToMoreButton
{
    NSInteger times = [[NSUserDefaults standardUserDefaults] integerForKey:kTTPlayerSpecialSellItemCellDismisToMoreButtonTimesKey];
    NSInteger max = 3;
    return times < max && self.animationToView && !self.playerStateStore.state.isFullScreen;
}

- (void)setCommoditys:(NSArray *)commoditys
{
    if (_commoditys != commoditys) {
        _commoditys = commoditys;
        
        NSMutableArray *insertTimes = [NSMutableArray arrayWithCapacity:commoditys.count];
        
        NSMutableArray *entitys = [NSMutableArray array];
        for (NSDictionary *dic in commoditys) {
            if ([dic isKindOfClass:[NSDictionary class]]) {
                TTVCommodityEntity *entity = nil;
                for (TTVCommodityEntity *aEntity in self.playerStateStore.state.commodityEngitys) {
                    if ([[dic valueForKey:@"commodity_id"] isEqualToString:aEntity.commodity_id]) {
                        entity = aEntity;
                        break;
                    }
                }
                if (!entity) {
                    entity = [TTVCommodityEntity entityWithDictionary:dic];
                }
                if (entity.coupon_num > 0 && entity.coupon_type > 0) {
                    CGFloat scale = [TTDeviceHelper isScreenWidthLarge320] ? 1.0 : 0.9;
                    _itemView.frame = CGRectMake(0, 0, 200 * scale, 52 * scale);
                }
                [entitys addObject:entity];
                [insertTimes addObject:@(entity.insert_time)];    
            }
        }
        
        _playerStateStore.state.insertTimes = insertTimes;
        [entitys sortUsingComparator:^NSComparisonResult(TTVCommodityEntity *obj1, TTVCommodityEntity *obj2) {
            if (obj1.insert_time < obj2.insert_time) return NSOrderedAscending;
            if (obj1.insert_time > obj2.insert_time) return NSOrderedDescending;
            return NSOrderedSame;
        }];
        _playerStateStore.state.commodityEngitys = entitys;
        [self setNeedsLayout];
    }
}

- (CGPoint)itemViewOrigin
{
    CGPoint origin = CGPointZero;
    if (self.playerStateStore.state.isFullScreen) {
        origin = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(_itemView.frame), CGRectGetHeight(self.frame) - [TTDeviceUIUtils tt_newPadding:72 - 20] - _itemView.height);
    }else{
        origin = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(_itemView.frame), CGRectGetHeight(self.frame) - [TTDeviceUIUtils tt_newPadding:40 - 20] - _itemView.height);
    }
    if (self.playerStateStore.state.toolBarState == TTVPlayerControlViewToolBarStateWillShow ||
        self.playerStateStore.state.toolBarState == TTVPlayerControlViewToolBarStateDidShow) {
        origin.y -= 20;
    }
    return origin;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.isAnimationing) {
        return;
    }
    if ([_itemView.superview isKindOfClass:[self class]]) {
        CGPoint point = [self itemViewOrigin];
        _itemView.origin = point;
        [_itemView setNeedsLayout];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (CGRectContainsPoint(self.itemView.frame, point)) {
        return YES;
    }
    return NO;
}

@end
