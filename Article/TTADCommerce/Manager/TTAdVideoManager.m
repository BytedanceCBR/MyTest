//
//  TTAdVideoManager.m
//  Article
//
//  Created by yin on 16/8/19.
//
//

#import "TTAdVideoManager.h"

#import "TTAdAppDownloadManager.h"
#import "TTAdDetailViewHelper.h"
#import "TTAdManager.h"
#import "TTAdTrackManager.h"
#import "TTAdVideoViewFactory.h"
#import "TTAppLinkManager.h"
#import "TTRoute.h"
#import "TTURLTracker.h"
#import "TTURLUtils.h"
#import <Crashlytics/Crashlytics.h>
#import <TTTracker/TTTrackerProxy.h>
#import "TTAdVideoRelateAdModel.h"
#import "TTAdAppointAlertView.h"
#import "TTAdAction.h"

@interface TTAdVideoManager ()

@property (nonatomic, assign) BOOL inVideoDetailPage;

@end

@implementation TTAdVideoManager

+ (instancetype)sharedManager{
    static TTAdVideoManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        _sharedManager.inVideoDetailPage = NO;
    });
    return _sharedManager;
}

#pragma mark 相关视频列表小图广告
- (BOOL)relateIsSmallPicAdValid:(Article*)article
{
    return [article.videoAdExtra isValidAd];
}

- (BOOL)relateIsSmallPicAdCell:(Article *)aricle
{
    //小图广告ad_textlink、原来视频广告是ad_video
    if (aricle.videoAdExtra&&[aricle.videoAdExtra.card_type isEqualToString:@"ad_textlink"]) {
        return YES;
    }
    return NO;
}

- (TTAdVideoRelateRightImageView*)relateRigthImageView:(Article *)article top:(CGFloat)top width:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block
{
    TTAdVideoRelateRightImageView* view = [[TTAdVideoRelateRightImageView alloc] initWithWidth:width successBlock:block];
    view.top = top;
    
    [self relatedViewConfigure:view article:article];
    
    return view;
}

- (TTAdVideoRelateLeftImageView*)relateLeftImageView:(Article *)article top:(CGFloat)top width:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block
{
    TTAdVideoRelateLeftImageView* view = [[TTAdVideoRelateLeftImageView alloc] initWithWidth:width successBlock:block];
    view.top = top;
    
    [self relatedViewConfigure:view article:article];
    
    return view;
}

- (TTAdVideoRelateTopImageView*)relateTopImageView:(Article *)article top:(CGFloat)top width:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block
{
    TTAdVideoRelateTopImageView* view = [[TTAdVideoRelateTopImageView alloc] initWithWidth:width successBlock:block];
    view.top = top;
    
    [self relatedViewConfigure:view article:article];
    
    return view;
}

- (void)relatedViewConfigure:(TTDetailNatantRelateReadView *)view article:(Article *)article {
    
    TTDetailNatantRelateReadRightImgViewModel* viewModel = [[TTDetailNatantRelateReadRightImgViewModel alloc] init];
    view.viewModel = viewModel;
    view.viewModel.pushAnimation = YES;
    view.viewModel.useForVideoDetail = YES;
    [view refreshArticle:article];
    
    //click事件监听
    //TTDetailNatantRelateReadPureTitleViewModel中响应didSelectVideoAlbumBlock即return
    WeakSelf;
    view.viewModel.didSelectVideoAlbum = ^(Article *article){
        StrongSelf;
        TTAdVideoRelateAdModel* adModel = article.videoAdExtra;
        if (adModel.actionType == TTAdActionTypeApp) {
            BOOL canOpen = [TTAdAppDownloadManager downloadApp:adModel];
            [self trackRelateAdWithTag:@"detail_ad_list" label:@"click" article:article];
            if (canOpen) {
                [self trackRelateAdWithTag:@"detail_ad_list" label:@"open" article:article];
            } else {
                [self trackRelateAdWithTag:@"detail_ad_list" label:@"click_start" article:article];
            }
        }
        else if (adModel.actionType == TTAdActionTypePhone){
            [self handleAction:adModel];
            [self trackRelateAdWithTag:@"detail_ad_list" label:@"click" article:article];
        }
        else{
            [self handleWeb:adModel];
            [self trackRelateAdClick:article];
        }
        TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:adModel.ad_id logExtra:adModel.log_extra];
        ttTrackURLsModel(adModel.click_track_url_list, trackModel);
        [self videoTrack];
    };
}

- (void)relateHandleAction:(Article*)article
{
    TTAdVideoRelateAdModel* adModel = article.videoAdExtra;
    if ([adModel.creative_type isEqualToString:@"app"]) {
        BOOL canOpen = [TTAdAppDownloadManager downloadApp:adModel];
        [self trackRelateAdWithTag:@"detail_ad_list" label:@"click" article:article];
        if (canOpen) {
            [self trackRelateAdWithTag:@"detail_ad_list" label:@"open" article:article];
        } else {
            [self trackRelateAdWithTag:@"detail_ad_list" label:@"click_start" article:article];
        }
    }
    else if ([adModel.creative_type isEqualToString:@"action"])
    {
        [self handleAction:adModel];
        [self trackRelateAdWithTag:@"detail_ad_list" label:@"click" article:article];
        [self trackRelateAdWithTag:@"detail_ad_list" label:@"click_call" article:article];
    }
    else if ([adModel.creative_type isEqualToString:@"form"])
    {
        [self handleForm:adModel article:article];
        [self trackRelateAdWithTag:@"detail_ad_list" label:@"click" article:article];
        [self trackRelateAdWithTag:@"detail_ad_list" label:@"click_button" article:article];
    }
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:adModel.ad_id logExtra:adModel.log_extra];
    ttTrackURLsModel(adModel.click_track_url_list, trackModel);
    [self videoTrack];
}



- (void)handleWeb:(TTAdVideoRelateAdModel*)adModel
{
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionaryWithCapacity:3];
    [extraDic setValue:adModel.log_extra forKey:@"log_extra"];
    BOOL canOpen = [TTAppLinkManager dealWithWebURL:adModel.web_url openURL:adModel.open_url sourceTag:@"detail_ad_list" value:adModel.ad_id extraDic:extraDic];
    
    if (!canOpen) {
        NSURL *openURL = [TTURLUtils URLWithString:adModel.open_url];
        canOpen = [[TTRoute sharedRoute] canOpenURL:openURL];
        if (canOpen) {
            [[TTRoute sharedRoute] openURLByPushViewController:openURL userInfo:TTRouteUserInfoWithDict(extraDic)];
        }
    }
    
    //点击广告图片跳转到广告详情页
    if (!canOpen && !isEmptyString(adModel.web_url)) {
        [extraDic setValue: adModel.web_url forKey:@"url"];
        [extraDic setValue:adModel.ad_id forKey:@"ad_id"];
        NSURL *url = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:extraDic];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(@{@"supportRotate":@1})];
    }
}

- (void)handleForm:(TTAdVideoRelateAdModel *)adModel article:(Article*)article
{
    TTAdAppointAlertModel* model = [[TTAdAppointAlertModel alloc] initWithAdId:adModel.ad_id logExtra:adModel.log_extra formUrl:adModel.form_url width:adModel.form_width  height:adModel.form_height sizeValid:adModel.use_size_validation];
    
    [TTAdAction handleFormActionModel:model fromSource:TTAdApointFromSourceFeed completeBlock:^(TTAdApointCompleteType type) {
        if (type == TTAdApointCompleteTypeCloseForm) {
            [self trackRelateAdWithTag:@"detail_ad_list" label:@"click_cancel" article:article];
        }
        else if (type == TTAdApointCompleteTypeLoadFail){
            [self trackRelateAdWithTag:@"detail_ad_list" label:@"load_fail" article:article];
        }
    }];
}

- (void)handleAction:(TTAdVideoRelateAdModel*)adModel
{
    NSString *phoneNumber = adModel.phone_number;
    if (phoneNumber.length > 0) {
        
        NSURL *URL = [TTStringHelper URLWithURLString:[NSString stringWithFormat:@"tel://%@", phoneNumber]];
        if ([TTDeviceHelper OSVersionNumber] < 8) {
            [self listenCall:adModel];
            UIWebView * callWebview = [[UIWebView alloc] init];
            [callWebview loadRequest:[NSURLRequest requestWithURL:URL]];
            [[UIApplication sharedApplication].keyWindow addSubview:callWebview];
            // 这里delay1s之后把callWebView干掉，不能直接干掉，否则不能打电话。
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [callWebview removeFromSuperview];
            });
            return;
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            [self listenCall:adModel];
            [[UIApplication sharedApplication] openURL:URL];
        }
    }
}

//监听电话状态
- (void)listenCall:(TTAdVideoRelateAdModel*)adModel
{
    TTAdCallListenModel* callModel = [[TTAdCallListenModel alloc] init];
    callModel.ad_id = adModel.ad_id;
    callModel.log_extra = adModel.log_extra;
    callModel.position = @"detail_ad_list";
    callModel.dailTime = [NSDate date];
    callModel.dailActionType = adModel.dial_action_type;
    [TTAdManageInstance call_callAdModel:callModel];
}

//补充视频业务中广告跳转引发的视频统计
- (void)videoTrack
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kTTAdVideoManagerDidRelateAdClick" object:nil];
    });
}

- (void)trackRelateAdShow:(Article*)article
{
    [self trackRelateAdWithTag:@"detail_ad_list" label:@"show" article:article];
    //发送track_url请求
    TTAdVideoRelateAdModel* adModel = article.videoAdExtra;
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:adModel.ad_id logExtra:adModel.log_extra];
    ttTrackURLsModel(adModel.track_url_list, trackModel);
}


- (void)trackRelateAdClick:(Article*)article
{
    [self trackRelateAdWithTag:@"detail_ad_list" label:@"click" article:article];
    TTAdVideoRelateAdModel* adModel = article.videoAdExtra;
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:adModel.ad_id logExtra:adModel.log_extra];
    ttTrackURLsModel(adModel.click_track_url_list, trackModel);
}

-(void)trackRelateAdWithTag:(NSString*)tag
                label:(NSString*)label
              article:(Article*)article
{
    TTAdVideoRelateAdModel* adModel = article.videoAdExtra;

    if (!isEmptyString(adModel.ad_id)) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:adModel.log_extra forKey:@"log_extra"];
        [dict setValue:@(article.uniqueID) forKey:@"ext_value"];
        [dict setValue:@([[TTTrackerProxy sharedProxy]  connectionType]) forKey:@"nt"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        [TTAdTrackManager trackWithTag:tag label:label value:adModel.ad_id extraDic:dict];

    }
    
}

-(void)trackWithTag:(NSString *)tag
              label:(NSString *)label
              value:(NSString *)value
           extraDic:(NSDictionary *)dic
{
    wrapperTrackEventWithCustomKeys(tag, label, value, nil, dic);
}

#pragma mark 视频详情页Banner位广告

-(void)enteredVideoDetailPage:(BOOL)enter
{
    self.inVideoDetailPage = enter;
}

- (BOOL)isInVideoDetailPage
{
    return self.inVideoDetailPage;
}

- (UIView*)detailBannerPaddingView:(CGFloat)width topLineShow:(BOOL)topShow bottomLineShow:(BOOL)bottomShow
{
    return [TTAdVideoViewFactory detailBannerPaddingView:width topLineShow:topShow bottomLineShow:bottomShow];
}

@end
