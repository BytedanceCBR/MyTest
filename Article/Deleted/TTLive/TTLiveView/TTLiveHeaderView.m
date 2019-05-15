//
//  TTLiveHeaderView.m
//  TTLive
//
//  Created by matrixzk on 7/17/16.
//
//

#import "TTLiveHeaderView.h"

#import "TTImageView.h"
#import <Masonry.h>
#import "TTAdapterManager.h"
#import "TTRoute.h"

// temp
#import "UIImageView+WebCache.h"


#import "UIButton+WebCache.h"

#import "TTLiveStreamDataModel.h"

#import "TTLiveCellHelper.h"

#import "TTAlphaThemedButton.h"

#import "TTLiveHeaderView+Match.h"
#import "TTLiveHeaderView+Star.h"
#import "TTLiveHeaderView+Video.h"


@interface TTLiveHeaderView ()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong)  TTLiveTopBannerInfoModel *dataModel;
@property (nonatomic, strong)  UIImageView *avatarImageView;

@property (nonatomic, weak) TTLiveMainViewController *chatroom;

@end


@implementation TTLiveHeaderView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    LOGD(@">>>>>>> TTLiveHeaderView Dealloced !!!");
}

- (instancetype)initWithFrame:(CGRect)frame dataModel:(TTLiveTopBannerInfoModel *)model chatroom:(TTLiveMainViewController *)chatroom heightOffset:(CGFloat)offset
{
    self = [super initWithFrame:frame];
    if (self) {
        _dataModel = model;
        _chatroom = chatroom;
        _currentLiveStatus = _dataModel.status.integerValue;
        _heightOffset = offset;
        [self setupSubviews];
    }
    return self;
}


#pragma mark - Subviews Setup

- (void)setupSubviews
{
    // 背景图
    _backgroundImageView = [TTImageView new];
    _backgroundImageView.backgroundColor = [UIColor clearColor];
    _backgroundImageView.userInteractionEnabled = YES;
    [self addSubview:_backgroundImageView];
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    _maskView = [UIView new];
    _maskView.backgroundColor = [[UIColor tt_themedColorForKey:kColorBackground9] colorWithAlphaComponent:0.15];
    [_backgroundImageView addSubview:_maskView];
    [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_backgroundImageView);
    }];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [_maskView addGestureRecognizer:tapGR];
    
    switch (_dataModel.background_type.integerValue) {
            
        case TTLiveTypeSimple:
            [self setupSubviews4LiveTypeSimple];
            break;
            
        case TTLiveTypeStar:
            [self setupSubviews4LiveTypeStar];
            break;
            
        case TTLiveTypeMatch:
            [self setupSubviews4LiveTypeMatch];
            break;
            
        case TTLiveTypeVideo:
            [self setupSubviews4LiveTypeVideo];
            break;
            
        default:
            break;
    }
}

///... public
- (void)refreshHeaderViewWithModel:(TTLiveStreamDataModel *)model
{
    NSInteger liveStatus = model.status.integerValue;
    
    switch (_dataModel.background_type.integerValue) {
            
        case TTLiveTypeSimple:
        case TTLiveTypeStar:
        {
            // 如果状态发生改变，刷新直播视频view和状态view。
            if (_currentLiveStatus != liveStatus) {
                _currentLiveStatus = liveStatus;
                [self refreshStatusViewWithModel:model];
            } else {
                [self refreshNumOfParticipantsViewWithNum:model.participated];
            }
        }
            break;
            
        case TTLiveTypeMatch:
        {
            [self refreshMatchStatusWithModel:model];
        }
            break;
            
        case TTLiveTypeVideo:
        {
            // 如果状态发生改变，刷新直播视频view和状态view。
            if (_currentLiveStatus != liveStatus) {
                _currentLiveStatus = liveStatus;
                [self refreshLiveVideoViewWithModel:model];
            }
            
            // 刷新参与人数view
            if (TTLiveStatusOver == liveStatus && _dataModel.background.video.playbackEnable) {
                [_numOfParticipantsView removeFromSuperview];
            } else {
                [self refreshNumOfParticipantsViewWithNum:model.participated];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)refreshStatusViewWithModel:(TTLiveStreamDataModel *)model
{
    if (_statusView.superview) {
        [_statusView removeFromSuperview];
        _statusView = nil;
    }
    
    if (_numOfParticipantsView.superview) {
        [_numOfParticipantsView removeFromSuperview];
        _numOfParticipantsView = nil;
    }
    
    if (!isEmptyString(model.status_display)) {
        _statusView = [self customView];
        [self addSubview:_statusView];
        [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(15);
            make.bottom.equalTo(self.mas_bottom).offset(-10);
        }];
        [self.statusView setTitle:model.status_display forState:UIControlStateNormal];
    }
    
    switch (model.status.integerValue) {
        case TTLiveStatusPre:
        {
            if (_statusView) {
                NSString *imageName = @"chatroom_icon_picture1";
                if (TTLiveTypeVideo == self.dataModel.background_type.integerValue) {
                    imageName = @"chatroom_icon_video1";
                }
                
                [self.statusView setImage:[UIImage themedImageNamed:imageName] forState:UIControlStateNormal];
                self.statusView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground16];
                self.statusView.layer.borderColor = [[UIColor colorWithHexString:@"#FFFFFF"] colorWithAlphaComponent:0.1].CGColor;
                [self.statusView setTitleColor:[UIColor tt_themedColorForKey:kColorText12] forState:UIControlStateNormal];
            }
        }
            break;
            
        case TTLiveStatusPlaying:
        {
            if (_statusView) {
                NSString *imageName = @"chatroom_icon_picture1";
                if (TTLiveTypeVideo == self.dataModel.background_type.integerValue) {
                    imageName = @"chatroom_icon_video1";
                }
                [self.statusView setImage:[UIImage themedImageNamed:imageName] forState:UIControlStateNormal];
                self.statusView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground7];
                self.statusView.layer.borderColor = [UIColor tt_themedColorForKey:kColorBackground7].CGColor;
                [self.statusView setTitleColor:[UIColor tt_themedColorForKey:kColorText12] forState:UIControlStateNormal];
            }
        }
            break;
            
        case TTLiveStatusOver:
            
            if (TTLiveTypeVideo == self.dataModel.background_type.integerValue &&
                _dataModel.background.video.playbackEnable) {
                // 视频直播，且有回放，则直播结束后显示回放
                [_statusView removeFromSuperview];
                
            } else {
                
                if (_statusView) {
                    [self.statusView setImage:[UIImage themedImageNamed:@"chatroom_icon_end"] forState:UIControlStateNormal];
                    NSString *colorHex = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? @"E8E8E8" : @"999999";
                    self.statusView.backgroundColor = [UIColor colorWithHexString:colorHex];
                    self.statusView.layer.borderColor = [UIColor colorWithHexString:colorHex].CGColor;
                    colorHex = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? @"999999" : @"CACACA";
                    [self.statusView setTitleColor:[UIColor colorWithHexString:colorHex] forState:UIControlStateNormal];
                }
            }
            
            break;
            
        default:
            break;
    }
    
    // 视频直播 && 已结束 && 有直播回放，则不显示状态view
    if (TTLiveTypeVideo == self.dataModel.background_type.integerValue &&
        TTLiveStatusOver == model.status.integerValue &&
        _dataModel.background.video.playbackEnable) {
        return;
    }
    
    _numOfParticipantsView = [self customView];
    [_numOfParticipantsView setImage:[UIImage themedImageNamed:@"chatroom_icon_fans_new"] forState:UIControlStateNormal];
    _numOfParticipantsView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground16];
    _numOfParticipantsView.layer.borderColor = [[UIColor colorWithHexString:@"#FFFFFF"] colorWithAlphaComponent:0.1].CGColor;
    [_numOfParticipantsView setTitleColor:[UIColor tt_themedColorForKey:kColorText12] forState:UIControlStateNormal];
    [self addSubview:_numOfParticipantsView];
    [_numOfParticipantsView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (_statusView) {
            make.left.equalTo(_statusView.mas_right).offset(5);
            make.bottom.equalTo(_statusView);
        } else {
            make.left.equalTo(self.mas_left).offset(15);
            make.bottom.equalTo(self.mas_bottom).offset(-10);
        }
    }];
    [self refreshNumOfParticipantsViewWithNum:model.participated];
    
    if (TTLiveTypeStar == self.dataModel.background_type.integerValue) {
        [self.avatarButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.numOfParticipantsView.mas_top).offset(-TTLivePadding(26));
        }];
    }
}

- (void)refreshNumOfParticipantsViewWithNum:(NSNumber *)numOfParticipants
{
    [self.numOfParticipantsView setTitle:[numOfParticipants descriptionWithLocale:[NSLocale currentLocale]]
                                forState:UIControlStateNormal];
}

- (SSThemedLabel *)labelWithColorKey:(NSString *)colorKey fontSize:(CGFloat)fontSize
{
    SSThemedLabel *label = [SSThemedLabel new];
    label.textColorThemeKey = colorKey;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)setupSubviews4LiveTypeSimple
{
    TTLiveStreamDataModel *model = [TTLiveStreamDataModel new];
    model.status = self.dataModel.status;
    model.status_display = self.dataModel.status_display;
    model.participated = self.dataModel.participated;
    [self refreshStatusViewWithModel:model];
}

- (UIButton *)customView
{
    UIButton *customView = [UIButton buttonWithType:UIButtonTypeCustom];
    customView.layer.cornerRadius = 5;
    customView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    customView.titleLabel.font = [UIFont systemFontOfSize:12];
    customView.contentEdgeInsets = UIEdgeInsetsMake(3, 5, 3, 8);
    customView.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5);
    customView.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -3);
    customView.userInteractionEnabled = NO;
    return customView;
}

- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer
{
    NSURL *openURL;
    if (gestureRecognizer.view == self.maskView) {
        openURL = [NSURL URLWithString:_dataModel.background.video.openURL];
    }
    if (!isEmptyString(openURL.absoluteString)) {
        [[TTRoute sharedRoute] openURLByPushViewController:openURL];
    }
}

@end
