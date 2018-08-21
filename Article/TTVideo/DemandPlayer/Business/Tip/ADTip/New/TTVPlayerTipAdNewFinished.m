//
//  TTVPlayerTipAdNewFinished.m
//  Article
//
//  Created by panxiang on 2017/7/19.
//
//

#import "TTVPlayerTipAdNewFinished.h"
#import "Article.h"
#import "TTRoute.h"
#import "SSWebViewController.h"
#import "UIViewController+TTMovieUtil.h"
#import "TTURLTracker.h"
#import "TTVFeedItem+ComputedProperties.h"
#import "TTVFeedItem+Extension.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "Common.pbobjc.h"
#import "TTVAdPlayFinnishActionButton.h"
#import "TTVPlayerStateModel.h"
#import "TTVPlayerStateAction.h"
#import "SSADEventTracker.h"
#import "TTVAdPlayFinnishActionButton.h"
#import "TTVFeedListItem.h"
#import "TTVADInfo+ActionTitle.h"
#import "TTVFeedItem+Extension.h"
#import "TTImageView.h"
#import <StoreKit/StoreKit.h>
#import "TTVAdActionButtonCreation.h"
#import "TTVPlayerStateStore.h"
#import "TTTrackerProxy.h"

@interface TTVPlayerTipAdNewFinished ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *openURL;
@property (nonatomic, copy) NSString *actionTitle;
@property (nonatomic, strong) TTADEventTrackerEntity *trackerEntity;
@property (nonatomic, strong) id <TTVAdActionButtonCommandProtocol> ttv_command;
@property (nonatomic, strong) TTVAdPlayFinnishActionButton *actionBtn;
@end

@implementation TTVPlayerTipAdNewFinished
@dynamic data;

- (void)dealloc
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _actionBtn = [[TTVAdPlayFinnishActionButton alloc] init];
        _actionBtn.backgroundColorThemeKey = nil;
        _actionBtn.titleColorThemeKey = nil;
        _actionBtn.borderColorThemeKey = nil;
        _actionBtn.layer.borderWidth = 0;
        _actionBtn.frame = CGRectMake(0, 0, 72, 28);
        _actionBtn.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground8];
        [_actionBtn setTitleColor:[UIColor tt_defaultColorForKey:kColorText7] forState:UIControlStateNormal];
        _actionBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _actionBtn.layer.cornerRadius = 6;
        _actionBtn.layer.masksToBounds = YES;
        [_actionBtn addTarget:self action:@selector(actionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.backView addSubview:_actionBtn];
    }
    return self;
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    [super actionChangeCallbackWithAction:action state:state];
    if ([action isKindOfClass:[TTVPlayerStateAction class]] && ([state isKindOfClass:[TTVPlayerStateModel class]] || state == nil)) {
        switch (action.actionType) {
            case TTVPlayerEventTypeFinishUIShow:{
                [self sendTrackEvent:@"video_end_ad" label:@"show"];
            }
                break;
            default:
                break;
        }
    }
    
}

- (void)onLogoImageViewTapped
{
    [self.playerStateStore sendAction:TTVPlayerEventTypeAdDetailAction payload:nil];
    dispatch_block_t dismissBlock = ^ {
        if (!self.playerStateStore.state.isInDetail) {
            [self sendTrackEvent:@"video_end_ad" label:@"click"];
        }
        if (!isEmptyString(self.openURL)) {
            [self sendTrackEvent:@"video_end_ad" label:@"click_card"];
            [self sendTrackEvent:@"video_end_ad" label:@"detail_show"];
            UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor:self];
            ssOpenWebView([TTStringHelper URLWithURLString:self.openURL], nil, topController, NO, nil);
        } else {
            if (!isEmptyString(self.data.webUrl)) {
                [self sendTrackEvent:@"video_end_ad" label:@"click_card"];
                UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor:self];
                ssOpenWebView([TTStringHelper URLWithURLString:self.data.webUrl], nil, topController, NO, nil);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TTVDismissSKStoreProductViewController" object:nil];
            } else {
                [self openLogoActionWithCommand:self.ttv_command];
            }
        }
    };
    if ([TTDeviceHelper OSVersionNumber] < 8.0) {
        UIViewController *vc = [UIViewController ttmu_currentViewController];
        if ([vc isKindOfClass:[SKStoreProductViewController class]]) {
            [vc dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"StoreVCDismissFromVideoDetailViewController" object:nil];
                dismissBlock();
            }];
        } else {
            dismissBlock();
        }
    } else {
        dismissBlock();
    }
}

- (UIView *)onGetActionBtn
{
    return self.actionBtn;
}

- (void)executeAction
{
    self.ttv_command.showAlert = YES;
    [self.ttv_command executeAction];
}

- (void)setData:(TTVMoviePlayerControlFinishAdEntity *)data
{
    if ([data isKindOfClass:[TTVMoviePlayerControlFinishAdEntity class]]) {
        [super setData:data];
        self.title = data.title;
        self.actionTitle = data.actionTitle;
        self.imageURL = data.avatarUrl;
        self.openURL = data.openURL;
        self.trackerEntity = data.trackerEntity;
        self.ttv_command = data.ttv_command;
        
        NSDictionary *urlHeader = nil;
        if (_imageURL) {
            urlHeader = @{@"url":_imageURL};
        }
        TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithURL:_imageURL withHeader:urlHeader];
        [self.logoImageView setImageWithModel:imageModel placeholderView:[self placeholderViewWithTitle:self.title]];
        self.titleLabel.text = _title;
        [self.titleLabel sizeToFit];
        [_actionBtn setTitle:_actionTitle];
        [self layoutSubviews];
    }
}

- (void)openLogoActionWithCommand:(id <TTVAdActionButtonCommandProtocol>)command
{
    dispatch_block_t dimissBlock = ^ {
        [command playerControlLogoTappedAction];
    };
    if ([TTDeviceHelper OSVersionNumber] < 8.0) {
        UIViewController *vc = [UIViewController ttmu_currentViewController];
        if ([vc isKindOfClass:[SKStoreProductViewController class]]) {
            [vc dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"StoreVCDismissFromVideoDetailViewController" object:nil];
                dimissBlock();
            }];
        } else {
            dimissBlock();
        }
    } else {
        dimissBlock();
    }
}

- (void)openActionWithCommand:(id <TTVAdActionButtonCommandProtocol>)command
{
    [self.playerStateStore sendAction:TTVPlayerEventTypeAdDetailAction payload:nil];
    dispatch_block_t dimissBlock = ^ {
        [command playerControlFinishAdAction];
    };
    if ([TTDeviceHelper OSVersionNumber] < 8.0) {
        UIViewController *vc = [UIViewController ttmu_currentViewController];
        if ([vc isKindOfClass:[SKStoreProductViewController class]]) {
            [vc dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"StoreVCDismissFromVideoDetailViewController" object:nil];
                dimissBlock();
            }];
        } else {
            dimissBlock();
        }
    } else {
        dimissBlock();
    }
}

- (void)actionBtnClicked:(UIButton *)sender {
    if (!self.playerStateStore.state.isInDetail) {
        NSMutableDictionary *dict = [@{} mutableCopy];
        if ([self.ttv_command isKindOfClass:[TTVAdActionTypeAppButtonCommand class]]) {
            [dict setValue:@"1" forKey:@"has_v3"];
            [self trackRealTime];
        }
        [self sendTrackEvent:@"video_end_ad" label:@"click" extra:dict];
    }
    [self openActionWithCommand:self.ttv_command];
}

- (void)sendTrackEvent:(NSString *)event label:(NSString *)label{
    [[SSADEventTracker sharedManager] trackEventWithEntity:self.trackerEntity label:label eventName:event];
}

- (void)sendTrackEvent:(NSString *)event label:(NSString *)label extra:(NSDictionary *)extra{
    [[SSADEventTracker sharedManager] trackEventWithEntity:self.trackerEntity label:label eventName:event extra:extra duration:0];
}

- (void)trackRealTime
{
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"umeng" forKey:@"category"];
    [params setValue:self.trackerEntity.ad_id forKey:@"value"];
    [params setValue:@"realtime_ad" forKey:@"tag"];
    [params setValue:self.trackerEntity.log_extra forKey:@"log_extra"];
    [params setValue:@"2" forKey:@"ext_value"];
    [params setValue:@(connectionType) forKey:@"nt"];
    [params setValue:@"1" forKey:@"is_ad_event"];
    [TTTracker eventV3:@"realtime_click" params:params];
}

@end

