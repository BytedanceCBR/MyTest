//
//  TTVResolutionSelect.m
//  Article
//
//  Created by panxiang on 2017/5/24.
//
//

#import "TTVResolutionSelect.h"
#import "TTVResolutionSelectView.h"
#import "TTVPlayerControllerState.h"
#import "TTMoviePlayerControlBottomView.h"
#import "TTVPlayerStateStore.h"
#import "KVOController.h"
#import "TTVResolutionStore.h"
#import "EXTScope.h"
#import "EXTKeyPathCoding.h"
#import "UIViewAdditions.h"
#import "TTTrackerWrapper.h"

static const NSTimeInterval kAnimDuration = 0.35;

@interface TTVResolutionSelect ()<TTVResolutionSelectViewDelegate>
@property (nonatomic, strong) TTVResolutionSelectView *resolutionSelectView;
@property(nonatomic, copy)  NSString *resolutionString;
@end

@implementation TTVResolutionSelect


- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        _playerStateStore = playerStateStore;
        [self ttv_kvo];
    }
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,currentResolution) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        TTVPlayerResolutionType value = [[change valueForKey:NSKeyValueChangeNewKey] longLongValue];
        self.resolutionType = value;
    }];

    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,supportedResolutionTypes) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        NSArray *value = [change valueForKey:NSKeyValueChangeNewKey];
        [self.bottomBarView setEnableResolutionClicked:[value isKindOfClass:[NSArray class]] && value.count > 1];
    }];

}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{

}

- (void)setResolutionString:(NSString *)resolutionString
{
    if (![resolutionString isEqualToString:_resolutionString]) {
        _resolutionString = resolutionString;
        _bottomBarView.resolutionString = resolutionString;
    }
}

- (void)setResolutionType:(TTVPlayerResolutionType)resolutionType
{
    if (resolutionType != _resolutionType) {
        _resolutionType = resolutionType;
        NSString *typeString = [TTVResolutionSelectView typeStringForType:resolutionType];
        [self setResolutionString:typeString];
    }
}

- (void)hideResolutionView {
    UIView *v = _resolutionSelectView;
    _resolutionSelectView = nil;
    [UIView animateWithDuration:kAnimDuration animations:^{
        v.alpha = 0.f;
    } completion:^(BOOL finished) {
        [v removeFromSuperview];
    }];
}

- (TTVResolutionSelectView *)resolutionSelectView
{
    if (!_resolutionSelectView) {
        _resolutionSelectView = [[TTVResolutionSelectView alloc] init];
        _resolutionSelectView.delegate = self;
    }
    return _resolutionSelectView;
}

- (void)hidden
{
    [self hideResolutionView];
}

- (void)show
{
    [self showWithBottom:self.superView.height - 40];
}

- (void)showWithBottom:(CGFloat)bottom
{
    NSArray *types = [self.playerStateStore.state supportedResolutionTypes];

    TTVResolutionSelectView *view = self.resolutionSelectView;
    if (view.superview) {
        [self hideResolutionView];
    } else {
        [view setSupportTypes:types currentType:self.resolutionType];
        self.resolutionSelectView.frame = CGRectMake(0, 0, self.resolutionSelectView.viewSize.width, self.resolutionSelectView.viewSize.height);
        self.resolutionSelectView.bottom = bottom;
        self.resolutionSelectView.centerX = self.bottomBarView.resolutionButton.centerX;
        [self.superView addSubview:self.resolutionSelectView];
        self.resolutionSelectView.alpha = 0.f;
        [UIView animateWithDuration:kAnimDuration animations:^{
            self.resolutionSelectView.alpha = 1.f;
        }];
    }

    if (self.enableResolution) {
        NSDictionary *extra = @{@"num" : [@(types.count) stringValue]};
        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"video" label:@"clarity_click" value:self.playerStateStore.state.playerModel.groupID source:nil extraDic:extra];
        NSMutableDictionary *dic = [self.playerStateStore.state ttv_logV3CommonDic];
        [dic setValue:[@(types.count) stringValue] forKey:@"num"];
        [TTTrackerWrapper eventV3:@"video_clarity_click" params:dic isDoubleSending:YES];
    }

}


- (void)didSelectWithType:(TTVPlayerResolutionType)type
{
    [UIView animateWithDuration:kAnimDuration animations:^{
        self.resolutionSelectView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_resolutionSelectView removeFromSuperview];
        _resolutionSelectView = nil;
        NSString *typeString = [TTVResolutionSelectView typeStringForType:type];
        [self setResolutionString:typeString];
        [self.playerStateStore sendAction:TTVPlayerEventTypeSwitchResolution payload:[NSNumber numberWithInteger:type]];
    }];
    if (self.enableResolution) {
        NSString *str = @"360P";
        if (type == TTVPlayerResolutionTypeHD) {
            str = @"480P";
        } else if (type == TTVPlayerResolutionTypeFullHD) {
            str = @"720P";
        }
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] initWithCapacity:2];
        NSArray <NSNumber *> *supportTypes = [self.playerStateStore.state supportedResolutionTypes];
        [extra setValue:str forKey:@"definition"];
        [extra setValue:[@(supportTypes.count) stringValue] forKey:@"num"];
        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"video" label:@"clarity_select" value:self.playerStateStore.state.playerModel.groupID source:nil extraDic:extra];
        NSMutableDictionary *dic = [self.playerStateStore.state ttv_logV3CommonDic];
        [dic setValuesForKeysWithDictionary:extra];
        [TTTrackerWrapper eventV3:@"video_clarity_select" params:dic isDoubleSending:YES];
    }
}

@end
