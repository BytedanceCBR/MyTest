//
//  TTVPlayerTipRelatedFinishedForward.m
//  Article
//
//  Created by panxiang on 2017/10/19.
//

#import "TTVPlayerTipRelatedFinishedForward.h"
#import "KVOController.h"
#import "TTVideoFinishRelatedViewService.h"
#import "TTSettingsManager.h"
#import "TTVPlayerTipRelatedFinished.h"
#import "TTVPlayerTipShareFinished.h"
#import "TTSettingsManager.h"
#import "TTInstallIDManager.h"
#import "TTTrackerWrapper.h"

extern NSString *ttvs_playerFinishedRelatedType(void);
@interface TTVPlayerTipRelatedFinishedForward()
@property (nonatomic, strong) TTVPlayerTipRelatedFinished *relatedView;
@property (nonatomic, strong) TTVPlayerTipShareFinished *shareView;
@property (nonatomic, assign) float requestPercent;
@property (nonatomic, assign) BOOL canContinueRequest;
@property (nonatomic, assign) float preRemainderTime;
@property (nonatomic, strong) NSDictionary *dataInfo;
@property (nonatomic, strong) NSError *netError;
@property (nonatomic, strong) TTVideoFinishRelatedViewService *netService;
@end

@implementation TTVPlayerTipRelatedFinishedForward

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _relatedView = [[TTVPlayerTipRelatedFinished alloc] initWithFrame:self.bounds];
        [self addSubview:_relatedView];
        _shareView = [[TTVPlayerTipShareFinished alloc] initWithFrame:self.bounds];
        [self addSubview:_shareView];
        self.netService = [[TTVideoFinishRelatedViewService alloc] init];
        self.hidden = YES;
        self.canContinueRequest = YES;
    }
    return self;
}

- (void)dealloc
{
    [self.playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _shareView.frame = self.bounds;
    _relatedView.frame = self.bounds;
}

- (void)setPlayerStateStore:(TTVVideoPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [self ttv_kvo];
        self.relatedView.playerStateStore = playerStateStore;
        self.shareView.playerStateStore = playerStateStore;
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
            self.backgroundColor = [UIColor clearColor];
            NSArray *array = [self.dataInfo tt_arrayValueForKey:@"data"];
            if (ttvs_playerFinishedRelatedType().length > 0 &&
                array.count > 0 &&
                self.playerStateStore.state.bannerHeight <= 0) {//有底部banner的不出.
                self.relatedView.hidden = NO;
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setValue:@"video_over" forKey:@"direct_source"];
                [dic setValue:self.playerStateStore.state.playerModel.enterFrom forKey:@"enter_from"];
                [dic setValue:self.playerStateStore.state.playerModel.categoryID forKey:@"category_name"];
                [dic setValue:self.playerStateStore.state.playerModel.groupID forKey:@"group_id"];
                [dic setValue:self.playerStateStore.state.ttv_position forKey:@"position"];
                [TTTrackerWrapper eventV3:@"app_direction_icon_show" params:dic isDoubleSending:NO];
                self.shareView.hidden = YES;
                if (!self.playerStateStore.state.pasterADIsPlaying) {
                    [self.relatedView startTimer];
                }
            }else{
                if (ttvs_playerFinishedRelatedType().length > 0) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    if (self.netError) {
                        [dic setValue:self.netError.description forKey:@"enter_from"];
                    }else{
                        [dic setValue:@"网络错误" forKey:@"error"];
                    }
                    [dic setValue:@"video_over" forKey:@"direct_source"];
                    [dic setValue:self.playerStateStore.state.playerModel.enterFrom forKey:@"enter_from"];
                    [dic setValue:self.playerStateStore.state.playerModel.categoryID forKey:@"category_name"];
                    [dic setValue:self.playerStateStore.state.playerModel.groupID forKey:@"group_id"];
                    [dic setValue:self.playerStateStore.state.ttv_position forKey:@"position"];
                    [TTTrackerWrapper eventV3:@"app_direction" params:dic isDoubleSending:NO];
                    
                }
                
                self.shareView.hidden = NO;
                self.relatedView.hidden = YES;
            }
        }
            break;
        case TTVPlayerEventTypeFinishUIReplay:
        {
            self.canContinueRequest = YES;
            self.dataInfo = nil;
        }
            break;
        default:
            break;
    }
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    self.relatedView.isFullScreen = isFullScreen;
    self.shareView.isFullScreen = isFullScreen;
}

- (void)setFinishAction:(FinishAction)finishAction
{
    _finishAction = finishAction;
    self.relatedView.finishAction = finishAction;
    self.shareView.finishAction = finishAction;
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,currentPlaybackTime) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self playPasterWhenRemainderTime:self.playerStateStore.state.duration - self.playerStateStore.state.currentPlaybackTime];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,pasterADIsPlaying) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        if (self.playerStateStore.state.pasterADIsPlaying) {
            [self.relatedView pauseTimer];
        }else {
            [self.relatedView startTimer];
        }
    }];
}

//获取当前时间戳
- (NSString *)currentTimeStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970];// *精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}


- (void)playPasterWhenRemainderTime:(NSTimeInterval)remainderTime
{
    if (!self.canContinueRequest || !self.relatedView.hasSettingRelated) {
        return;
    }
    if (self.preRemainderTime <= 0) {
        self.preRemainderTime = self.playerStateStore.state.duration;
    }
    if (remainderTime > 0 &&
        self.playerStateStore.state.duration > 0 &&
        remainderTime / self.playerStateStore.state.duration <= 1 - self.requestPercent && self.preRemainderTime - remainderTime >= 5 && ![self.netService isAllInstalled]) {
        self.preRemainderTime = remainderTime;
        TTVideoFinishRelatedRecommondURLRequestInfo *requestInfo = [[TTVideoFinishRelatedRecommondURLRequestInfo alloc] init];
        requestInfo.groupID = self.playerStateStore.state.playerModel.groupID;
        requestInfo.parentRID = [NSString stringWithFormat:@"%@_%@_%@",[self currentTimeStr],self.playerStateStore.state.playerModel.groupID,[TTInstallIDManager sharedInstance].installID];
        requestInfo.pageType = @"video";
        requestInfo.siteID = @"5000804";
        if (self.playerStateStore.state.isInDetail) {
            requestInfo.codeId = @"900804101";
        }else{
            requestInfo.codeId = @"900804100";
        }
        requestInfo.style = ttvs_playerFinishedRelatedType();
        [self.netService fetchRelatedRecommondInfoWithRequestInfo:requestInfo completion:^(id response, NSError *error) {
            NSArray *array = [response tt_arrayValueForKey:@"data"];
            self.canContinueRequest = NO;
            if (array.count > 0 && !error) {
                if (array.count > 0) {
                    self.dataInfo = response;
                    [self.relatedView setDataInfo:self.dataInfo];
                    self.preRemainderTime = self.playerStateStore.state.duration;
                }
            }
            self.netError = error;
            self.preRemainderTime = self.playerStateStore.state.duration;
        }];
    }
}

- (float)requestPercent
{
    if (_requestPercent > 0) {
        return _requestPercent;
    }else{
        float requestPercent = [[[TTSettingsManager sharedManager] settingForKey:@"video_ad_request_percent" defaultValue:@0 freeze:YES] floatValue];
        _requestPercent = (requestPercent > 0 && requestPercent < 1) ? requestPercent: 0.8;
    }
    return _requestPercent;
}

@end


