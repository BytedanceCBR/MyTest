//
//  TTVCommodityButtonView.m
//  Article
//
//  Created by panxiang on 2017/10/23.
//

#import "TTVCommodityButtonView.h"
#import "KVOController.h"
#import "TTURLUtils.h"
#import "TTRoute.h"
#import "TTVCommodityEntity.h"
#import "TTDeviceHelper.h"
#import "TTVDemandPlayer.h"
#import "TTImageView.h"
#import "TTVCommodityEntity.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import <BDWebImage/SDWebImageAdapter.h>
@interface TTVCommodityButton : UIView
@property (nonatomic ,strong)TTVCommodityEntity *entity;
@end

@interface TTVCommodityButton()
@property (nonatomic ,strong)UIImageView *imageView;
@property (nonatomic ,strong)UIImageView *recommandIcon;
@property (nonatomic ,strong)UIButton *button;
@property (nonatomic ,assign)BOOL isFull;
@end

@implementation TTVCommodityButton


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.backgroundColor = [UIColor clearColor];
        [self addSubview:self.button];
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground5];
        _imageView.userInteractionEnabled = NO;
        [self addSubview:_imageView];
        
        NSDictionary *dic = [[TTSettingsManager sharedManager] settingForKey:@"tt_video_commodity" defaultValue:@{} freeze:NO];
        NSString *imageUrl = [dic valueForKey:@"commodity_recommend_icon"];
        BOOL hide_recommend_commodity_icon_in_play = [[dic valueForKey:@"hide_recommend_commodity_icon_in_play"] boolValue];
        if (!hide_recommend_commodity_icon_in_play) {
            _recommandIcon = [[UIImageView alloc] init];
            _recommandIcon.backgroundColor = [UIColor clearColor];
            [_imageView addSubview:_recommandIcon];
            if (!isEmptyString(imageUrl)) {
                [_recommandIcon sda_setImageWithURL:[NSURL URLWithString:imageUrl]];
            }else{
                _recommandIcon.image = [UIImage imageNamed:@"video_commodity_default_recommand_icon"];
            }
        }
    }
    return self;
}

- (void)setEntity:(TTVCommodityEntity *)entity
{
    _entity = entity;
    if (!isEmptyString(entity.image_url)) {
        [_imageView sda_setImageWithURL:[NSURL URLWithString:entity.image_url]];
    }else{
        _imageView.image = nil;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    _button.frame = self.bounds;
    _imageView.frame = self.bounds;
    _recommandIcon.frame = self.bounds;
    [super layoutSubviews];
}


@end

@interface TTVCommodityButtonView ()
@property (nonatomic ,strong)NSArray *commoditys;
@property (nonatomic ,strong)TTVCommodityButton *buttonView;
@end

@implementation TTVCommodityButtonView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.87];
        _buttonView = [[TTVCommodityButton alloc] init];
        [_buttonView.button addTarget:self action:@selector(ttv_clickCommodityButton) forControlEvents:UIControlEventTouchUpInside];
        self.hidden = YES;
        [self addSubview:_buttonView];
    }
    return self;
}

- (void)ttv_clickCommodityButton
{
    if ([self.delegate respondsToSelector:@selector(ttv_clickCommodityButton)]) {
        [self.delegate ttv_clickCommodityButton];
        [self ttv_clickCommodityTrack];
    }
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

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self setNeedsLayout];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,commodityEngitys) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self.buttonView setEntity:[self.playerStateStore.state.commodityEngitys firstObject]];
        [self setNeedsLayout];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,currentPlaybackTime) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self changeEntityWithPlaybackTime:self.playerStateStore.state.currentPlaybackTime];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,toolBarState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (self.playerStateStore.state.commodityEngitys.count > 0) {
            switch (self.playerStateStore.state.toolBarState) {
                case TTVPlayerControlViewToolBarStateDidShow:
                case TTVPlayerControlViewToolBarStateWillShow:
                    if (!self.playerStateStore.state.resolutionAlertShowed) {
                        self.hidden = NO;
                        [self ttv_showCommodityTrack];
                        self.playerStateStore.state.isCommodityButtonShow = YES;
                    }
                    break;
                case TTVPlayerControlViewToolBarStateDidHidden:
                case TTVPlayerControlViewToolBarStateWillHidden:
                    self.hidden = YES;
                    self.playerStateStore.state.isCommodityButtonShow = NO;
                    break;
                default:
                    break;
            }
        }
    }];
    
}

- (void)changeEntityWithPlaybackTime:(CGFloat)playbackTime
{
    TTVCommodityEntity *entity = nil;
    NSInteger index = -1;
    for (NSNumber *number in self.playerStateStore.state.insertTimes) {
        index++;
        if (playbackTime > number.floatValue) {
            continue;
        }
        if (playbackTime <= number.floatValue) {
            index--;
            break;
        }
    }
    index = MAX(index, 0);
    if (index >= 0 && index < self.playerStateStore.state.insertTimes.count) {
        if (index == 0) {
            entity = [self.playerStateStore.state.commodityEngitys objectAtIndex:0];
        }else if (index > 0){
            entity = [self.playerStateStore.state.commodityEngitys objectAtIndex:index];
        }
        if (self.buttonView.entity != entity) {
            [self.buttonView setEntity:entity];
        }
    }
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    TTVPlayerStateAction *newAction = (TTVPlayerStateAction *)action;
    if (![newAction isKindOfClass:[TTVPlayerStateAction class]]) {
        return;
    }
    switch (action.actionType) {
        case TTVPlayerEventTypePlayerSeekEnd:
            [self changeEntityWithPlaybackTime:self.playerStateStore.state.currentPlaybackTime];
            break;
        case TTVPlayerEventTypeControlViewDragSlider:
            if (self.playerStateStore.state.playbackState != TTVVideoPlaybackStatePaused) {
                self.hidden = YES;
            }
            break;
        default:
            break;
    }
}

- (NSString *)ttv_position
{
    if (self.playerStateStore.state.isInDetail) {
        return @"detail";
    }
    return @"list";
}

- (NSMutableDictionary *)commonDic
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"click_player" forKey:@"section"];
    [dic setValue:self.playerStateStore.state.isFullScreen ? @"fullscreen" : @"nofullscreen" forKey:@"fullscreen"];
    [dic setValue:[self ttv_position] forKey:@"position"];
    if (self.playerStateStore.state.playerModel.itemID) {
        [dic setValue:self.playerStateStore.state.playerModel.itemID forKey:@"item_id"];
    }
    if (self.playerStateStore.state.playerModel.groupID) {
        [dic setValue:self.playerStateStore.state.playerModel.groupID forKey:@"group_id"];
    }
    [dic setValue:@"TEMAI" forKey:@"EVENT_ORIGIN_FEATURE"];
    
    NSMutableDictionary *commodity_attr = [NSMutableDictionary dictionary];
    [commodity_attr setValue:@([self.playerStateStore.state.commodityEngitys indexOfObject:self.buttonView.entity] + 1) forKey:@"commodity_no"];
    [commodity_attr setValue:@(self.playerStateStore.state.commodityEngitys.count) forKey:@"commodity_num"];
    [dic setValue:commodity_attr forKey:@"commodity_attr"];
    
    return dic;
}

- (void)ttv_showCommodityTrack
{
    [TTTrackerWrapper eventV3:@"commodity_recommend_show" params:[self commonDic]];
}

- (void)ttv_clickCommodityTrack
{
    [TTTrackerWrapper eventV3:@"commodity_recommend_click" params:[self commonDic]];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    _buttonView.frame = CGRectMake(4, 4, self.width - 8, self.height - 8);
}

@end

