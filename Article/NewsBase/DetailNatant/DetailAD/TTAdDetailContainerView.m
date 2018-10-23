//
//  ExploreDetailADContainerView.m
//  Article
//
//  Created by SunJiangting on 15/7/21.
//
//

#import "TTAdDetailContainerView.h"

#import "ExploreArticleMovieViewDelegate.h"
#import "ExploreDetailMixedVideoADView.h"
#import "SSRobust.h"
#import "SSWebViewController.h"
#import "TTAdDetailViewDefine.h"
#import "TTAdDetailViewHelper.h"
#import "TTAdDetailViewModel.h"
#import "TTAdMonitorManager.h"
#import "TTAppLinkManager.h"
#import "TTRoute.h"
#import "TTStringHelper.h"
#import "TTUIResponderHelper.h"
#import "TTURLUtils.h"
#import <objc/message.h>
#import "TTAdAppDownloadManager.h"

@interface TTAdDetailContainerView ()
@property (nonatomic, strong) NSMutableArray<ExploreDetailBaseADView *> *adViews;
@property (nonatomic, strong) NSMutableDictionary *adViewFrames;
@property (nonatomic, strong) NSMutableSet<NSString *> *showEvents;
@property (nonatomic, copy, nullable) NSArray<ArticleDetailADModel *> *adModels;
@end

@implementation TTAdDetailContainerView

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        self.adViews = [NSMutableArray array];
        self.adViewFrames = [NSMutableDictionary dictionary];
        self.showEvents = [NSMutableSet set];
        [self reloadThemeUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithWidth:0];
}

-(void)reloadData:(id<TTAdNatantDataModel>) object  {
    if (![object conformsToProtocol:@protocol(TTAdNatantDataModel)]) {
        return;
    }
    NSString *ad_data_jsonString = [object adNatantDataModel:@"kDetailNatantAdsKey"];
    if (![ad_data_jsonString isKindOfClass:[NSString class]] || !ad_data_jsonString) {
        NSAssert([ad_data_jsonString isKindOfClass:[NSString class]], @"详情页 浮层广告传入参数错误");
        return;
    }
    NSData *jsonData = [ad_data_jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError;
    NSDictionary *ad_datas = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
    if (!ad_datas) {
        return;
    }
    NSError *modelError;
    NSArray<ArticleDetailADModel *> *adModels = [TTAdDetailViewHelper detailAdModelsWithDictionary:ad_datas error:&modelError];
    if (modelError) {
        [TTAdMonitorManager trackService:@"ad_detail" status:0 extra:modelError.userInfo];
    }
    self.adModels = adModels;
}

- (void)setAdModels:(NSArray<ArticleDetailADModel *> *)adModels {
    _adModels = [adModels copy];
    [self reloadSubViews];
}

//旋转后重新布局
- (void)refreshWithWidth:(CGFloat)width {
    [super refreshWithWidth: width];
    [self reloadSubViews];
}

- (void)layoutSubviews {
    [self reloadSubViews];
    [super layoutSubviews];
}

- (void)reloadSubViews {
    
    // 修复视频全屏后，退出全屏时，exploreMovieView.movieFatherView被重置的问题
    __block ExploreDetailMixedVideoADView *videoADView = nil;
    
    [self.adViews enumerateObjectsUsingBlock:^(ExploreDetailBaseADView  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ExploreDetailMixedVideoADView class]]) {
            videoADView = (ExploreDetailMixedVideoADView *)obj;
        }
    }];
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.adViews removeAllObjects];
    [self.adViewFrames removeAllObjects];
    
    [self sizeToFit]; // calcurate subview layout
    
    [self.adModels enumerateObjectsUsingBlock:^(ArticleDetailADModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Class cls = [TTAdDetailViewHelper classForKey:obj.key forArea:TTAdDetailViewAreaGloabl];
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
        
            adView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self.adViews addObject:adView];
            [self addSubview:adView];
            
        } else {
            LOGE(@"文章详情页下发了不支持的广告类型");
        }
    }];

    __weak typeof(self) wself = self;
    [self setScrollInOrOutBlock:^(BOOL isVisible) {
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

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize contentSize = [self recalculateFrames];
    size.width = self.frame.size.width;
    size.height = contentSize.height;
    return size;
}

- (CGSize)recalculateFrames {
    [self.adViewFrames removeAllObjects];
    
    __block CGFloat top = 0;
    const NSUInteger count = self.adModels.count;
    const CGFloat width = self.width;
    [self.adModels enumerateObjectsUsingBlock:^(ArticleDetailADModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect frame = CGRectZero;
        Class cls = [TTAdDetailViewHelper classForKey:obj.key forArea:TTAdDetailViewAreaGloabl];
        if ([cls respondsToSelector:@selector(heightForADModel:constrainedToWidth:)]) {
            CGFloat (* heightForADModelIMP)(id, SEL, id, CGFloat) = (CGFloat (*)(id, SEL, id, CGFloat))objc_msgSend;
            const CGFloat height = heightForADModelIMP(cls, @selector(heightForADModel:constrainedToWidth:), obj, width);
            frame = CGRectMake(0, top, width, height);
        } else {
            NSAssert(NO, @"some semll bad");
        }
        [self.adViewFrames setValue:NSStringFromCGRect(frame) forKey:@(obj.hash).stringValue];
        top += CGRectGetHeight(frame);
        if (CGRectGetHeight(frame) > 0 && idx < (count - 1)) {
            top += kTTAdDetailADContainerLineSpacing;
        }
    }];
    return CGSizeMake(self.width, top);
}

#pragma mark - delegate for ad View

- (void)detailBaseADView:(ExploreDetailBaseADView *)adView didClickWithModel:(ArticleDetailADModel *)adModel {
    switch (adModel.actionType) {
        case SSADModelActionTypeApp: { //内部有点击打点
            BOOL canOpenApp = [TTAdAppDownloadManager downloadApp:adModel];
            [adModel trackRealTimeDownload];
            [adModel sendTrackEventWithLabel:@"click" eventName:@"detail_download_ad" extra:@{@"has_v3": @"1"}];
            if (canOpenApp) {
                [adModel sendTrackEventWithLabel:@"open" eventName:@"detail_download_ad"]; // click_start 和  open 同时存在
            }
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
        default: {
            [TTAdMonitorManager trackService:@"ad_detail_backgroundaction" status:1 extra:adModel.monitorInfo];
        }
            break;
    }
}

#pragma mark - dislike

- (void)dislikeClick:(ArticleDetailADModel *)adModel {
    NSMutableArray<ArticleDetailADModel *> *array = [NSMutableArray arrayWithArray:self.adModels];
    __block NSInteger index = 0;
    [self.adModels enumerateObjectsUsingBlock:^(ArticleDetailADModel  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ArticleDetailADModel * model = (ArticleDetailADModel *)obj;
        if ([model.ad_id isEqualToString:adModel.ad_id]) {
            index = idx;
            [array removeObjectAtIndex:index];
            *stop = YES;
        }
    }];
    self.adModels = array;
    if (self.adModels.count <= 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(removeNatantView:animated:)]) {
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

#pragma mark - track

- (void)sendShowTrackIfNeededForGroup:(NSString *)groupID withLabel:(NSString *)label {
    if (!self.hasShow) {
        [super sendShowTrackIfNeededForGroup:groupID withLabel:label];
    }
}

- (NSString *)eventLabel{
    return @"show_ad";
}

- (void)trackEventIfNeeded {
    [self.adModels enumerateObjectsUsingBlock:^(ArticleDetailADModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *ad_id = obj.ad_id;
        if (![self.showEvents containsObject:ad_id]) {
            if (obj.detailADType == ArticleDetailADModelTypePhone) {
                [obj trackWithTag:@"detail_call" label:@"show" extra:nil];
            } else if (obj.detailADType == ArticleDetailADModelTypeAppoint) {
                [obj trackWithTag:@"detail_form" label:@"show" extra:nil];
            } else if (obj.detailADType == ArticleDetailADModelTypeCounsel) {
                [obj trackWithTag:@"detail_counsel" label:@"show" extra:nil];
            } else if (obj.detailADType == ArticleDetailADModelTypeMedia) {
                NSMutableDictionary *extra = [NSMutableDictionary dictionary];
                NSString *mediaID = self.viewModel.article.mediaID;
                NSString *itemID = self.viewModel.article.groupModel.itemID;
                [extra setValue:mediaID forKey:@"media_id"];
                [extra setValue:itemID forKey:@"item_id"];
                [obj trackWithTag:@"detail_ad" label:@"show" extra:extra];
            } else {
                [obj trackWithTag:@"datail_ad" label:@"show" extra:nil];
            }
            [obj sendTrackURLs:obj.track_urls];
            if (idx < self.adViews.count) {
                ExploreDetailBaseADView *adView = [self.adViews objectAtIndex:idx];
                [adView didSendShowEvent];
            }
            [self.showEvents addObject:ad_id];

        }
    }];
    [self sendShowTrackIfNeededForGroup:self.viewModel.article.groupModel.groupID withLabel:[self eventLabel]];
}

- (void)trackBackgroundClick:(ArticleDetailADModel *)adModel {
    if (adModel.detailADType == ArticleDetailADModelTypePhone) {
        [adModel trackWithTag:@"detail_call" label:@"click" extra:nil];
    } else if (adModel.detailADType == ArticleDetailADModelTypeMixed) {
        [adModel trackWithTag:@"detail_ad" label:@"click" extra:nil];
        [adModel trackWithTag:@"detail_ad" label:@"detail_show" extra:nil];
    } else if (adModel.detailADType == ArticleDetailADModelTypeAppoint) {
        [adModel trackWithTag:@"detail_form" label:@"click" extra:nil];
    } else if (adModel.detailADType == ArticleDetailADModelTypeCounsel) {
        [adModel trackWithTag:@"detail_counsel" label:@"click" extra:nil];
    } else if (adModel.detailADType == ArticleDetailADModelTypeMedia) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        NSString *mediaID = self.viewModel.article.mediaID;
        NSString *itemID = self.viewModel.article.groupModel.itemID;
        [extra setValue:mediaID forKey:@"media_id"];
        [extra setValue:itemID forKey:@"item_id"];
        [adModel trackWithTag:@"detail_ad" label:@"click" extra:extra];
        [adModel trackWithTag:@"detail_ad" label:@"detail_show" extra:extra];
    } else {
        [adModel trackWithTag:@"detail_ad" label:@"click" extra:nil];
    }
    [adModel sendTrackURLs:adModel.click_track_urls];
}

@end

