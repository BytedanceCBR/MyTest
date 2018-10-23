//
//  TTVideoDetailADContainerView.m
//  Article
//
//  Created by yin on 16/9/29.
//
//

#import "SSADActionManager.h"
#import "SSRobust.h"
#import "SSWebViewController.h"
#import "TTAdDetailViewHelper.h"
#import "TTAdManager.h"
#import "TTAppLinkManager.h"
#import "TTRoute.h"
#import "TTStringHelper.h"
#import "TTUIResponderHelper.h"
#import "TTURLUtils.h"
#import "TTVideoDetailADContainerView.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "TTTrackerProxy.h"
#import "ExploreDetailMixedVideoADView.h"

@interface TTVideoDetailADContainerView ()

@property(nonatomic, strong) NSMutableArray *adViews;
@property(nonatomic, strong) NSMutableDictionary *adViewFrames;

/// /*<ADID, hasSent>*/
@property(nonatomic, strong) NSMutableDictionary *showEvents;

@end

static NSMutableDictionary *_adClasses;

@implementation TTVideoDetailADContainerView

- (void)dealloc {
}

- (instancetype)initWithWidth:(CGFloat)width {
    return [self initWithFrame:CGRectMake(0, 0, width, 0)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.adViews = [NSMutableArray arrayWithCapacity:2];
        self.adViewFrames = [NSMutableDictionary dictionaryWithCapacity:2];
        self.showEvents = [NSMutableDictionary dictionaryWithCapacity:2];
        [self reloadThemeUI];
    }
    return self;
}

//旋转后重新布局

- (void)refreshWithWidth:(CGFloat)width
{
    [super refreshWithWidth: width];
    [self reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self reloadData];
}
- (void)setAdModels:(NSArray *)adModels {
    _adModels = [adModels copy];
    [self reloadData];
}

- (void)sendShowTrackIfNeededForGroup:(NSString *)groupID withLabel:(NSString *)label
{
    if (!self.hasShow) {
        [super sendShowTrackIfNeededForGroup:groupID withLabel:label];
    }
}

- (NSString *)eventLabel{
    return @"show_ad";
}

- (void)trackEventIfNeeded {
    [self enumerateValidModelsInArray:self.adModels usingBlock:^(ArticleDetailADModel *obj, NSUInteger idx, BOOL *stop) {
        NSString *ad_id = obj.ad_id;
        if (![[self.showEvents valueForKey:ad_id] boolValue]) {
            if (obj.detailADType == ArticleDetailADModelTypePhone) {
                [obj sendTrackEventWithLabel:@"show" eventName:@"detail_call"];
            }
            else if (obj.detailADType == ArticleDetailADModelTypeAppoint) {
                [obj sendTrackEventWithLabel:@"show" eventName:@"detail_form"];
            }
            else if (obj.detailADType == ArticleDetailADModelTypeMedia) {
                NSString *mediaID = self.viewModel.article.mediaID;
                NSString *itemID = self.viewModel.article.groupModel.itemID;
                NSMutableDictionary *events = [NSMutableDictionary dictionary];
                [events setValue:mediaID forKey:@"media_id"];
                [events setValue:itemID forKey:@"item_id"];
                [events setValue:obj.log_extra forKey:@"log_extra"];
                [events setValue:@"1" forKey:@"is_ad_event"];
                TTInstallNetworkConnection nt = [[TTTrackerProxy sharedProxy] connectionType];
                [events setValue:@(nt) forKey:@"nt"];
                wrapperTrackEventWithCustomKeys(@"detail_ad", @"show", obj.mediaID, nil, events);
            }
            else if (obj.detailADType == ArticleDetailADModelTypeCounsel) {
                [obj sendTrackEventWithLabel:@"show" eventName:@"detail_counsel"];
            }
            else {
                [obj sendTrackEventWithLabel:@"show" eventName:@"detail_ad"];
            }

            if (idx < self.adViews.count) {
                ExploreDetailBaseADView *adView = [self.adViews objectAtIndex:idx];
                [adView didSendShowEvent];
            }
            [self.showEvents setValue:@(YES) forKey:ad_id];
        }
    }];
    [self sendShowTrackIfNeededForGroup:self.viewModel.article.groupModel.groupID withLabel:[self eventLabel]];
}

/*
 ad_data 早期是 dictionary
 6.2.5 后改为 string 再次做兼容半年 小心
 */
-(void)reloadData:(nullable id<TTAdNatantDataModel>)object {
    if (![object respondsToSelector:@selector(adNatantDataModel:)]) {
        NSAssert(TRUE, @"没有实现协议 TTAdNatantDataModel");
        return;
    }
    NSDictionary * adData = [object adNatantDataModel:@"kDetailNatantAdsKey"];
    if ([adData isKindOfClass:[NSString class]]) {
        NSData *jsonData = [(NSString *)adData dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;
        adData = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
    }
    NSArray *adModels = [TTVideoDetailADContainerView newADModelsWithJSONData:adData];
    self.adModels = adModels;
}

- (void)reloadData {
    
    __block ExploreDetailMixedVideoADView *videoADView = nil;
    
    [self.adViews enumerateObjectsUsingBlock:^(ExploreDetailBaseADView  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ExploreDetailMixedVideoADView class]]) {
            videoADView = (ExploreDetailMixedVideoADView *)obj;
        }
    }];

    [self.adViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.adViews removeAllObjects];
    [self.adViewFrames removeAllObjects];
    while (self.subviews.count >= 1) {
        UIView *subview = self.subviews.lastObject;
        [subview removeFromSuperview];
    }
    [self sizeToFit];
    
    [self enumerateValidModelsInArray:self.adModels usingBlock:^(ArticleDetailADModel *obj, NSUInteger idx, BOOL *stop) {
        Class cls = [TTAdDetailViewHelper classForKey:obj.key forArea:TTAdDetailViewAreaVideo];
        if (TTClassIsSubClassOfClass(cls, ExploreDetailBaseADView.class)) {
            ExploreDetailBaseADView *adView;
            if (cls == [ExploreDetailMixedVideoADView class] && videoADView) {
                adView = videoADView;
                videoADView = nil;
            } else {
                adView = [[cls alloc] initWithWidth:self.width];
            }
            adView.viewModel = self.viewModel;
            CGRect frame = CGRectFromString(self.adViewFrames[@(obj.hash).stringValue]);
            adView.frame = frame;
            if ([adView respondsToSelector:@selector(setAdModel:)]) {
                adView.adModel = obj;
            }
            if ([adView respondsToSelector:@selector(setDelegate:)]) {
                adView.delegate = self;
            }
            ///...
            adView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self.adViews addObject:adView];
            [self addSubview:adView];
        } else {
            LOGE(@"视频详情页下发不支持的广告类型 %@", obj.key);
        }
    }];
    [self sizeToFit];
    
    __weak typeof(self) wself = self;
    [self setScrollInOrOutBlock:^(BOOL isVisible){
        for(UIView *subview in wself.subviews) {
            if([subview isKindOfClass:[ExploreDetailBaseADView class]]) {
                ExploreDetailBaseADView *adView = (ExploreDetailBaseADView *)subview;
                [adView scrollInOrOutBlock:isVisible];
            }
        }
    }];
    
    if (self.relayOutBlock) {
        self.relayOutBlock(NO);
    }
}


- (CGSize)recalculateFrames {
    [self.adViewFrames removeAllObjects];
    
    __block CGFloat top = 0;
    
    const NSUInteger count = self.adModels.count;
    const CGFloat width = self.width;
    [self enumerateValidModelsInArray:self.adModels usingBlock:^(ArticleDetailADModel *obj, NSUInteger idx, BOOL *stop) {
        CGRect frame = CGRectZero;
        Class cls = [TTAdDetailViewHelper classForKey:obj.key forArea:TTAdDetailViewAreaVideo];
        if ([cls respondsToSelector:@selector(heightForADModel:constrainedToWidth:)]) {
            CGFloat (* heightForADModelIMP)(id, SEL, id, CGFloat) = (CGFloat (*)(id, SEL, id, CGFloat))objc_msgSend;
            const CGFloat height = heightForADModelIMP(cls, @selector(heightForADModel:constrainedToWidth:), obj, width);
            frame = CGRectMake(0, top, width, height);
        }
        [self.adViewFrames setValue:NSStringFromCGRect(frame) forKey:@(obj.hash).stringValue];
        top += CGRectGetHeight(frame);
        if (CGRectGetHeight(frame) > 0 && idx < (count - 1)) {
            top += kTTAdDetailADContainerLineSpacing;
        }
    }];
    return CGSizeMake(self.width, top);
}

- (void)enumerateValidModelsInArray:(NSArray *)adModels
                         usingBlock:(void(^)(ArticleDetailADModel *obj, NSUInteger idx, BOOL *stop))block {
    [self.adModels enumerateObjectsUsingBlock:^(ArticleDetailADModel *obj, NSUInteger idx, BOOL *stop1) {
        if ([obj isKindOfClass:[ArticleDetailADModel class]] && [obj isModelAvailable] && !isEmptyString(obj.key)) {
            if (block) {
                block(obj, idx, stop1);
            }
        }
    }];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize contentSize = [self recalculateFrames];
    size.width = self.frame.size.width;
    size.height = contentSize.height;
    return size;
}

+ (NSArray *)newADModelsWithJSONData:(NSDictionary *)JSONData {
    if (SSIsEmptyDictionary(JSONData)) {
        return nil;
    }
    //判断是否是视频详情页
    NSMutableArray *adModels = [NSMutableArray arrayWithCapacity:JSONData.count];
    [JSONData enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if (!SSIsEmptyDictionary(obj)) {
            NSInteger type = [TTAdDetailViewHelper typeWithADKey:key];
            if (type != NSNotFound) {
                ArticleDetailADModel *adModel = [[ArticleDetailADModel alloc] initWithDictionary:obj detailADType:(ArticleDetailADModelType)type];
                
                if(type == ArticleDetailADModelTypeMixed) {
                    switch (adModel.displaySubtype) {
                        case 1:
                            adModel.key = @"video_mixed_leftPic";
                            break;
                        case 2:
                            adModel.key = @"mixed_video";
                            break;
                        case 3:
                            adModel.key = adModel.isTongTouAd ? @"video_mixed_largePic" : @"video_mixed_ununify_largePic";
                            break;
                        case 4:
                            adModel.key = @"video_mixed_groupPic";
                            break;
                        default:
                            adModel.key = key;
                            break;
                    }
                } else if (type == ArticleDetailADModelTypeApp) {
                    switch (adModel.displaySubtype) {
                        case 1:
                            adModel.key = @"video_app_leftPic";
                            break;
                        case 2:
                            adModel.key = @"app_video";
                            break;
                        case 3:
                            adModel.key = @"video_app_largePic";
                            break;
                        case 4:
                            adModel.key = @"video_app_groupPic";
                            break;
                        default:
                            adModel.key = key;
                            break;
                    }
                } else if (type == ArticleDetailADModelTypePhone) {
                    switch (adModel.displaySubtype) {
                        case 1:
                            adModel.key = @"video_phone_leftPic";
                            break;
                        case 2:
                            adModel.key = @"phone_video";
                            break;
                        case 3:
                            adModel.key = @"video_phone_largePic";
                            break;
                        case 4:
                            adModel.key = @"video_phone_groupPic";
                            break;
                        default:
                            adModel.key = key;
                            break;
                    }
                }else if (type == ArticleDetailADModelTypeAppoint) {
                    switch (adModel.displaySubtype) {
                            case 1:
                            adModel.key = @"video_appoint_leftPic";
                            break;
                            case 2:
                            adModel.key = @"phone_video";
                            break;
                            case 3:
                            adModel.key = @"video_appoint_largePic";
                            break;
                            case 4:
                            adModel.key = @"video_appoint_groupPic";
                            break;
                        default:
                            adModel.key = key;
                            break;
                    }
                }
                else if (type == ArticleDetailADModelTypeCounsel) {
                    NSArray *diplayTypes = @[@"leftPic", @"video", @"largePic", @"groupPic"];
                    if (adModel.displaySubtype <= diplayTypes.count && adModel.displaySubtype >= 1) {
                        adModel.key = [NSString stringWithFormat:@"video_unify_%@", diplayTypes[adModel.displaySubtype - 1]];
                    }
                }
                else {
                    adModel.key = key;
                }
                
                if ([adModel isModelAvailable]) {
                    [adModels addObject:adModel];
                }
            }
            else{
                if (obj[@"id"]) {
                    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                    [dict setValue:@"video" forKey:@"detail_location"];
                    [dict setValue:[NSString stringWithFormat:@"%@", key] forKey:@"type"];
                    [dict setValue:obj[@"log_extra"] forKey:@"log_extra"];
                    [dict setValue:obj[@"id"] forKey:@"ad_id"];
                    [TTAdManager monitor_trackService:@"ad_detail_unkowntype" status:1 extra:dict];
                }
            }
        }
    }];
    return [adModels copy];
}

- (void)detailBaseADView:(ExploreDetailBaseADView *)adView didClickWithModel:(ArticleDetailADModel *)adModel {
    switch (adModel.actionType) {
        case SSADModelActionTypeApp: {
            [adModel trackRealTimeDownload];
            [[SSADActionManager sharedManager] handleAppActionForADBaseModel:adModel forTrackEvent:@"detail_download_ad" needAlert:YES]; // 内部有 click 事件
        }
            break;
        case SSADModelActionTypeWeb: {
            if (isEmptyString(adModel.webURL) && isEmptyString(adModel.open_url)) {
                break;
            }
            NSMutableString *urlString = [NSMutableString stringWithString:adModel.webURL];
            NSURL *url = [NSURL URLWithString:adModel.webURL];
            
            if ([[TTRoute sharedRoute] canOpenURL:url]) {
                NSMutableDictionary* paramDict = [NSMutableDictionary dictionary];
                [paramDict setValue:adModel.log_extra forKey:@"log_extra"];
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(paramDict)];
            } else {
                NSMutableDictionary *applinkTrackDic = [NSMutableDictionary dictionary];
                [applinkTrackDic setValue:adModel.log_extra forKey:@"log_extra"];
                //尝试唤起外部app @by zengruihuan
                BOOL canOpenApp = [TTAppLinkManager dealWithWebURL:adModel.webURL openURL:adModel.open_url sourceTag:@"detail_ad" value:adModel.ad_id extraDic:applinkTrackDic];
                if (!canOpenApp) {
                    NSMutableDictionary *params = [NSMutableDictionary dictionary];
                    [params setValue:urlString forKey:@"url"];
                    [params setValue:adModel.webTitle forKey:@"title"];
                    [params setValue:adModel.ad_id forKey:@"ad_id"];
                    [params setValue:adModel.log_extra forKey:@"log_extra"];
                    NSURL *schema = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:params];
                    if ([[TTRoute sharedRoute] canOpenURL:schema]) {
                        [[TTRoute sharedRoute] openURLByPushViewController:schema];
                    }
                    [adModel trackWithTag:@"detail_ad" label:@"open_url_h5" extra:applinkTrackDic];
                }
            }
            
            [self trackBackgroundClick:adModel];
        }
            break;
        default:
            break;
    }
}

- (void)trackBackgroundClick:(ArticleDetailADModel *)adModel {
    if (adModel.detailADType == ArticleDetailADModelTypePhone) {
        [adModel sendTrackEventWithLabel:@"click" eventName:@"detail_call"];
    } else if (adModel.detailADType == ArticleDetailADModelTypeMixed) {
        [adModel sendTrackEventWithLabel:@"click" eventName:@"detail_ad"];
        [adModel sendTrackEventWithLabel:@"detail_show" eventName:@"detail_ad"];
    }  else if (adModel.detailADType == ArticleDetailADModelTypeAppoint) {
        [adModel sendTrackEventWithLabel:@"click" eventName:@"detail_form"];
    }else if (adModel.detailADType == ArticleDetailADModelTypeCounsel) {
        [adModel sendTrackEventWithLabel:@"click" eventName:@"detail_counsel"];
    } else if (adModel.detailADType == ArticleDetailADModelTypeMedia) {
        NSString *mediaID = self.viewModel.article.mediaID;
        NSString *itemID = self.viewModel.article.groupModel.itemID;
        NSMutableDictionary *events = [NSMutableDictionary dictionary];
        [events setValue:mediaID forKey:@"media_id"];
        [events setValue:itemID forKey:@"item_id"];
        [events setValue:adModel.log_extra forKey:@"log_extra"];
        [events setValue:@"1" forKey:@"is_ad_event"];
        TTInstallNetworkConnection nt = [[TTTrackerProxy sharedProxy] connectionType];
        [events setValue:@(nt) forKey:@"nt"];
        wrapperTrackEventWithCustomKeys(@"detail_ad", @"click", adModel.mediaID, nil, events);
        [adModel sendTrackEventWithLabel:@"detail_show" eventName:@"detail_ad"];
    } else {
        [adModel sendTrackEventWithLabel:@"click" eventName:@"detail_ad"];
    }

    if (self.isVideoAd) {
        NSString *uniqueID = [NSString stringWithFormat:@"%lld",self.viewModel.article.uniqueID];
        wrapperTrackEventWithCustomKeys(@"video", @"detail_selfad", uniqueID, nil, nil);
    }
}

- (void)dislikeClick:(ArticleDetailADModel *)adModel
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:self.adModels];
    __block NSInteger index = 0;
    [self.adModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ArticleDetailADModel * model = (ArticleDetailADModel *)obj;
        if (model.ad_id.integerValue == adModel.ad_id.integerValue) {
            index = idx;
            [array removeObjectAtIndex:index];
            *stop = YES;
        }
    }];
    self.adModels = array;
    if (self.adModels.count == 0) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(removeNatantView:animated:)]) {
            [self.delegate removeNatantView:self animated:NO];
        }
    }
}

//将父视图的点击传递给dislikeView,增大dislike的响应区域
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *responseView = [super hitTest:point withEvent:event];
    if (responseView == nil) {
        for (UIView *baseAdView in self.subviews) {
            CGPoint tp = [baseAdView convertPoint:point fromView:self];
            if ([baseAdView isKindOfClass:[ExploreDetailBaseADView class]]) {
                UIView* dislikeView = ((ExploreDetailBaseADView*)baseAdView).dislikeView;
                if (CGRectContainsPoint(dislikeView.frame, tp)) {
                    responseView = dislikeView;
                }
            }
        }
    }
    return responseView;
}

@end
