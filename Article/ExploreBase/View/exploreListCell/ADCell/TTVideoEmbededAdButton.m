//
//  TTVideoEmbededAdButton.m
//  Article
//
//  Created by 刘廷勇 on 16/6/8.
//
//

#import "TTVideoEmbededAdButton.h"

#import "ExploreMovieView.h"
#import "SSADEventTracker.h"
#import "SSURLTracker.h"
#import "TTAdManagerProtocol.h"
#import "TTDeviceUIUtils.h"
#import "UIButton+TTAdditions.h"
#import <TTServiceKit/TTServiceCenter.h>

@implementation TTVideoEmbededAdButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground13;
        self.titleColorThemeKey = kColorText8;
        self.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:[self fontSize]]];
        [self addTarget:self action:@selector(adButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 0;
        self.hitTestEdgeInsets = UIEdgeInsetsMake(-24, -24, -24, -24);
    }
    return self;
}

- (void)setAdModel:(id<TTAdFeedModel>)adModel
{
    [super setAdModel:adModel];
    [self.titleLabel sizeToFit];
    self.width = MAX(self.titleLabel.width + [TTDeviceUIUtils tt_padding:kCornerButtonInsetLeft] * 2, 44);
    self.height = [TTDeviceUIUtils tt_padding:kCornerButtonHeight];
    self.layer.cornerRadius = self.height / 2;
}

- (void)adButtonClicked:(id)sender
{
    if ([self.attachedMovie.moviePlayerController isMovieFullScreen]) {
        [self.attachedMovie exitFullScreen:YES completion:^(BOOL finished) {
            [self adButtonClicked:sender];
        }];
        return;
    }
    switch (self.adModel.adType) {
        case ExploreActionTypeApp:
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionModel label:@"click_start" eventName:@"feed_download_ad" clickTrackUrl:NO];//@"click" 已发,不需要重复发
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionModel label:@"click" eventName:@"feed_download_ad"];
            break;
        case ExploreActionTypeAction:
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionModel label:@"click_call" eventName:@"feed_call" clickTrackUrl:NO];
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionModel label:@"click" eventName:@"feed_call"];
            [self listenCall:self.adModel];
            break;
        case ExploreActionTypeWeb:
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionModel label:@"ad_click" eventName:@"embeded_ad" clickTrackUrl:NO];
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionModel label:@"click" eventName:@"embeded_ad"];
            break;
        default:
            break;
    }
    [self actionButtonClicked:sender showAlert:NO];
}

//监听电话状态
- (void)listenCall:(id<TTAdFeedModel>)adModel
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:adModel.ad_id forKey:@"ad_id"];
    [dict setValue:adModel.log_extra forKey:@"log_extra"];
    [dict setValue:[NSDate date] forKey:@"dailTime"];
    [dict setValue:@"feed_call" forKey:@"position"];
    [dict setValue:adModel.dialActionType forKey:@"dailActionType"];
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance call_callAdDict:dict];
}

- (CGFloat)fontSize
{
    return 10;
}

@end
