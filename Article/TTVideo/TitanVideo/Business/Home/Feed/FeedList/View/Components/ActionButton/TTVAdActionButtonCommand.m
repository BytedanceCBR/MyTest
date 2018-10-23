//
//  TTVAdActionButtonCommand.m
//  Article
//
//  Created by pei yun on 2017/4/1.
//
//

#import "TTVAdActionButtonCommand.h"

#import "ExploreMovieView.h"
#import "SSADActionManager.h"
#import "SSADEventTracker.h"
#import "SSActionManager.h"
#import "SSURLTracker.h"
#import "TTAdAction.h"
#import "TTAdAppDownloadManager.h"
#import "TTAdAppointAlertView.h"
#import "TTAdCallManager.h"
#import "TTAdManager.h"
#import "TTAdMonitorManager.h"
#import "TTAppLinkManager.h"
#import "TTDeviceHelper.h"
#import "TTIndicatorView.h"
#import "TTMovieStore.h"
#import "TTStringHelper.h"
#import "TTThemedAlertController.h"
#import "TTUIResponderHelper.h"
#import "TTVADCell+ADInfo.h"
#import "TTVADCellApp+ComputedProperties.h"
#import "TTVFeedCellAction.h"
#import "TTVFeedItem+ComputedProperties.h"
#import "TTVFeedItem+Extension.h"
#import <TTVideoService/Common.pbobjc.h>
#import <TTVideoService/VideoFeed.pbobjc.h>
#import <libextobjc/extobjc.h>
#import "TTADEventTrackerEntity.h"

@implementation TTVAdActionButtonCommand

- (TTVADInfo *)adInfo
{
    return self.feedItem.adInfo;
}

- (TTVVideoArticle *)article
{
    return self.feedItem.article;
}


- (void)executeAction
{
    [[TTMovieStore shareTTMovieStore] removeAll];
}

- (void)sendClickTrackUrlList
{
    TTAdBaseModel *baseModel = [[TTAdBaseModel alloc] init];
    baseModel.ad_id = [self article].adId;
    baseModel.log_extra = [self article].logExtra;
    if (!SSIsEmptyArray([self adInfo].trackURL.clickTrackURLListArray)) {
        [[SSURLTracker shareURLTracker] trackURLs:[self adInfo].trackURL.clickTrackURLListArray model:baseModel];
    }
}

- (void)playerControlFinishAdAction
{
    [self sendClickTrackUrlList];
}

- (void)playerControlLogoTappedAction
{
    [self sendClickTrackUrlList];
}

- (TTVFeedItem *)videoFeed
{
    return self.feedItem;
}

- (void)trackerWithEvent:(NSString *)event label:(NSString *)label
{
    [self trackerWithEvent:event label:label clickTrackUrl:YES];
}

- (void)trackerWithEvent:(NSString *)event label:(NSString *)label clickTrackUrl:(BOOL)clickTrackUrl
{
    TTADEventTrackerEntity *trackerEntity = [TTADEventTrackerEntity entityWithData:self.videoFeed];
    [[SSADEventTracker sharedManager] trackEventWithEntity:trackerEntity label:label eventName:event clickTrackUrl:clickTrackUrl];
}

@end


@interface TTVAdActionTypeAppButtonCommand ()
@property (nonatomic, strong) TTVOpenAppParameter *openAppParameter;
@end
@implementation TTVAdActionTypeAppButtonCommand

- (TTVOpenAppParameter *)openAppParameter
{
    if (!_openAppParameter) {
        _openAppParameter = [TTVOpenAppParameter parameterWithFeedItem:self.videoFeed];
    }
    return _openAppParameter;
}

- (BOOL)openApp
{
    TTVADCellApp *app = self.videoFeed.adCell.app;
    TTVVideoArticle *article = self.videoFeed.article;
    
    TTAdAppModel *appModel  = [[TTAdAppModel alloc] init];
    appModel.ad_id = article.adId;
    appModel.log_extra = article.logExtra;
    appModel.apple_id = app.appleid;
    appModel.download_url = app.downloadURL;
    appModel.ipa_url = app.ipaURL;
    appModel.open_url = app.openURL;
    return [TTAdAction handleDownloadApp:appModel];
}

- (void)executeAction
{
    [super executeAction];
    [[TTMovieStore shareTTMovieStore] removeAll];
    [self trackerWithEvent:@"feed_download_ad" label:@"click_start" clickTrackUrl:NO];
    if ([self openApp]) {
        [self trackerWithEvent:@"embeded_ad" label:@"open"];
    }
}

- (void)playerControlFinishAdAction
{
    [super playerControlFinishAdAction];
    [self openApp];
    if ([self.openAppParameter isInstalledApp]) {
        [self trackerWithEvent:@"video_end_ad" label:@"click_open"];
    } else {
        [self trackerWithEvent:@"video_end_ad" label:@"click_start"];
    }
}

- (void)playerControlLogoTappedAction
{
    [super playerControlLogoTappedAction];
    [self openApp];
    [self trackerWithEvent:@"video_end_ad" label:@"click_card"];
    [self trackerWithEvent:@"video_end_ad" label:@"detail_show"];
}

@end

@implementation TTVADWebModel



@end

@implementation TTVAdActionTypeWebButtonCommand

- (void)openWebUrlWithParameter:(NSDictionary *)applinkParams
{
    
    TTVADCellWeb *web = self.videoFeed.adCell.web;

    //再尝试打开头条页面
    UINavigationController *tController = [TTUIResponderHelper topNavigationControllerFor:nil];
    [[SSActionManager sharedManager] openWebURL:web.base.webURL appName:self.videoFeed.adCell.article.source adID:self.videoFeed.adID logExtra:self.videoFeed.logExtra inNavigationController:tController];
    if (isEmptyString(web.base.webURL)) {
        [TTAdMonitorManager trackService:@"ad_actionButton_others" status:0 extra:self.videoFeed.mointerInfo];
    }
}

- (BOOL)openWebWithTag:(NSString *)event
{
    TTVADCellWeb *web = self.videoFeed.adCell.web;
    TTVVideoArticle *article = self.videoFeed.article;
    TTVADWebModel *model = [[TTVADWebModel alloc] init];
    model.ad_id = article.adId;
    model.log_extra = article.logExtra;
    model.web_url = web.base.webURL;
    model.open_url = web.openURL;
    if (isEmptyString(model.open_url)) {
        model.open_url = article.openURL;
    }
    model.web_title = web.webTitle;
    if ([TTAdAction handleDetailActionModel:model sourceTag:event]) {
        NSMutableDictionary *applinkParams = [NSMutableDictionary dictionary];
        [applinkParams setValue:self.videoFeed.logExtra forKey:@"log_extra"];
        if (!isEmptyString(model.web_url) && isEmptyString(model.open_url)) {
            wrapperTrackEventWithCustomKeys(@"embeded_ad", @"open_url_h5", self.videoFeed.adID, nil, applinkParams);
        }
        return YES;
    }
    return NO;
}

- (void)executeAction
{
    TTVADCellWeb *web = self.videoFeed.adCell.web;
    if (web == nil) {
        [TTAdMonitorManager trackService:@"ad_actionButton_web" status:0 extra:self.videoFeed.mointerInfo];
        return;
    }

    [super executeAction];
    if ([self openWebWithTag:@"embeded_ad"]) {
        [self trackerWithEvent:@"embeded_ad" label:@"ad_click"];
    }

}

- (void)playerControlFinishAdAction
{
    [super playerControlFinishAdAction];
    if ([self openWebWithTag:@"video_end_ad"]) {
        [self trackerWithEvent:@"video_end_ad" label:@"click_landingpage"];
    }
}

- (void)playerControlLogoTappedAction
{
    [super playerControlLogoTappedAction];
    [self trackerWithEvent:@"video_end_ad" label:@"click_card"];
}
@end


@interface TTVAdPhoneModel : NSObject <TTAdPhoneAction>
@property (nonatomic, copy) NSString *phoneNumber;
@end

@implementation TTVAdPhoneModel

@end


@implementation TTVAdActionTypePhoneButtonCommand

- (BOOL)openPhone
{
    TTVADCellPhone *phone = self.videoFeed.adCell.phone;

    TTVAdPhoneModel *model = [[TTVAdPhoneModel alloc] init];
    model.phoneNumber = phone.phoneNumber;
    return [TTAdAction handleCallActionModel:model];
}

- (void)executeAction
{
    [super executeAction];
    if ([self openPhone]) {
        [self trackerWithEvent:@"feed_call" label:@"click_call" clickTrackUrl:NO];
    }
}

- (void)playerControlFinishAdAction
{
    [super playerControlFinishAdAction];
    if ([self openPhone]) {
        [self trackerWithEvent:@"video_end_ad" label:@"click_call"];
    }
}

- (void)playerControlLogoTappedAction
{
    [super playerControlLogoTappedAction];
    [self trackerWithEvent:@"video_end_ad" label:@"detail_show"];
    if ([self openPhone]) {
        [self trackerWithEvent:@"video_end_ad" label:@"click_card"];
    }
}

@end

@interface TTVAdActionTypeFormButtonCommand ()


@end

@implementation TTVAdActionTypeFormButtonCommand

- (BOOL)openForm
{
    TTVADCellForm *form = self.videoFeed.adCell.form;
    if (form == nil) {
        [TTAdMonitorManager trackService:@"ad_actionButton_form" status:0 extra:self.videoFeed.mointerInfo];
        return NO;
    }
    TTAdAppointAlertModel* model = [[TTAdAppointAlertModel alloc] initWithAdId:self.videoFeed.adID logExtra:self.videoFeed.logExtra formUrl:form.formURL width:@(form.formWidth) height:@(form.formHeight) sizeValid:@(form.useSizeValidation)];
    
    [TTAdAction handleFormActionModel:model fromSource:TTAdApointFromSourceFeed completeBlock:^(TTAdApointCompleteType type) {
        switch (type) {
                case TTAdApointCompleteTypeCloseForm:
            {
                [self trackerWithEvent:@"feed_form" label:@"click_cancel"];
            }
                break;
                case TTAdApointCompleteTypeLoadFail:
            {
                [self trackerWithEvent:@"feed_form" label:@"load_fail"];
            }
                break;
            default:
                break;
        }
    }];
    return YES;
}

- (void)executeAction
{
    [super executeAction];
    if ([self openForm]) {
       [self trackerWithEvent:@"embeded_ad" label:@"click_button"];
    }
}

- (void)playerControlFinishAdAction
{
    [super playerControlFinishAdAction];
    if ([self openForm]) {
       [self trackerWithEvent:@"video_end_ad" label:@"click_button"];
    }
}

- (void)playerControlLogoTappedAction
{
    [super playerControlLogoTappedAction];
    if ([self openForm]) {
        [self trackerWithEvent:@"video_end_ad" label:@"click_card"];
    }
}
@end



@interface TTVAdActionTypeCounselButtonCommand ()

@end

@implementation TTVAdActionTypeCounselButtonCommand

- (TTVVideoArticle *)article
{
    return self.feedItem.article;
}

- (BOOL)openCounsel
{
    TTVADCellCounsel *counsel = self.feedItem.adCell.counsel;

    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:2];
    [infoDic setValue:[self article].adId forKey:@"ad_id"];
    [infoDic setValue:[self article].logExtra forKey:@"log_extra"];

    if (isEmptyString(counsel.formURL)) {
        [TTAdMonitorManager trackService:@"ad_actionButton_counsel" status:1 extra:infoDic];
        return NO;
    }
    UINavigationController *tController = [TTUIResponderHelper topNavigationControllerFor:nil];
    [[SSActionManager sharedManager] openWebURL:counsel.formURL appName:@" " adID:[self article].adId logExtra:[self article].logExtra inNavigationController:tController];
    return YES;
}
- (void)executeAction
{
    [super executeAction];
    [self openCounsel];
    [self trackerWithEvent:@"embeded_ad" label:@"click_counsel"];
}

- (void)playerControlFinishAdAction
{
    [super playerControlFinishAdAction];
    [self openCounsel];
    [self trackerWithEvent:@"video_end_ad" label:@"click_counsel"];
}

- (void)playerControlLogoTappedAction
{
    [super playerControlLogoTappedAction];
    [self openCounsel];
    [self trackerWithEvent:@"video_end_ad" label:@"click_card"];
}
@end

@implementation TTVAdActionTypeNormalButtonCommand

- (NSString *)screenName{
    if (!isEmptyString(self.categoryId)) {
        return [NSString stringWithFormat:@"channel_%@",self.categoryId];
    }
    return @"channel_unknown";
}

- (void)executeAction {
    [super executeAction];
}

- (void)playerControlFinishAdAction
{
    [super playerControlFinishAdAction];
}

- (void)playerControlLogoTappedAction
{
    [super playerControlLogoTappedAction];
}

@end
