//
//  TTArticleDetailViewController+Share.m
//  Article
//
//  Created by muhuai on 2017/7/30.
//
//

#import "TTArticleDetailViewController+Share.h"
#import "TTArticleDetailViewController+Report.h"
#import "NewsDetailLogicManager.h"
//#import "TTRepostViewController.h"
#import "TTAdManager.h"
#import "TTAdPromotionManager.h"
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <objc/runtime.h>
//#import "TTShareToRepostManager.h"
#import "TTActivityShareSequenceManager.h"
#import <TTKitchen/TTKitchenHeader.h>
//#import "TTKitchenHeader.h"
#import "TTWebImageManager.h"
#import "TTShareConstants.h"

#import <TTActivityContentItemProtocol.h>
#import <TTWechatTimelineContentItem.h>
#import <TTWechatContentItem.h>
#import <TTQQFriendContentItem.h>
#import <TTQQZoneContentItem.h>
//#import <TTDingTalkContentItem.h>
//#import "TTRepostViewController.h"
//#import <TTRepostServiceProtocol.h>
//#import "TTRepostService.h"
//#import "TTRepostOriginModels.h"
#import "TTForwardWeitoutiaoContentItem.h"
#import "TTDirectForwardWeitoutiaoContentItem.h"
//#import "TTCopyContentItem.h"
//#import <TTSystemContentItem.h>
#import "TTShareMethodUtil.h"
#import <TTForwardWeitoutiaoActivity.h>
#import <TTDirectForwardWeitoutiaoActivity.h>
#import "AKAwardCoinManager.h"
#import "FHTraceEventUtils.h"

extern BOOL ttvs_isShareIndividuatioEnable(void);

@implementation TTArticleDetailViewController (Share)

@dynamic navMoreShareView, toolbarShareView, activityActionManager, curShareSourceType;

- (void)p_showMorePanel {
    if ([self.detailView.detailViewModel tt_articleDetailType] != TTDetailArchTypeSimple) {
        [self.activityActionManager clearCondition];
        if (!self.activityActionManager) {
            self.activityActionManager = [[TTActivityShareManager alloc] init];
            self.activityActionManager.clickSource = self.detailModel.clickLabel;
            self.activityActionManager.miniProgramEnable = self.detailModel.article.articleType == ArticleTypeNativeContent;
            self.activityActionManager.delegate = self;
        }
        
        
        NSMutableArray * activityItems = @[].mutableCopy;
        if ([self.articleInfoManager needShowAdShare]) {
            NSMutableDictionary *shareInfo = [self.articleInfoManager makeADShareInfo];
            activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager shareInfo:shareInfo showReport:NO];
        } else {
            activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager setArticleCondition:self.detailModel.article adID:self.detailModel.adID showReport:NO];
        }
        
        if (self.articleInfoManager.promotionModel) {
            TTActivity *promtionActivity = [TTActivity activityWithModel:self.articleInfoManager.promotionModel];
            [activityItems addObject:promtionActivity];
            wrapperTrackEventWithCustomKeys(@"setting_btn", @"show",self.detailModel.article.groupModel.groupID, nil, nil);
        }
        
        if ([self.detailView.detailViewModel tt_articleDetailType] == TTDetailArchTypeNoComment ||
            [self.detailView.detailViewModel tt_articleDetailType] == TTDetailArchTypeNoToolBar) {
            TTActivity * favorite = [TTActivity activityOfFavorite];
            favorite.selected = self.detailModel.article.userRepined;
            [activityItems addObject:favorite];
        }
        TTActivity * nightMode = [TTActivity activityOfNightMode];
        [activityItems addObject:nightMode];
        
        // add by zjing 去掉问答字体设置
//        TTActivity * fontSetting = [TTActivity activityOfFontSetting];
//        [activityItems addObject:fontSetting];
        
        TTActivity * reportActivity = [TTActivity activityOfReport];
        [activityItems addObject:reportActivity];
        
        
        if (self.navMoreShareView) {
            self.navMoreShareView = nil;
        }
        
        self.navMoreShareView = [[SSActivityView alloc] init];
        [self.navMoreShareView refreshCancelButtonTitle:@"取消"];
        self.navMoreShareView.delegate = self;
        [self.navMoreShareView setActivityItemsWithFakeLayout:activityItems];
        [TTAdManageInstance share_showInAdPage:self.detailModel.adID.stringValue groupId:self.detailModel.article.groupModel.groupID];
        [self.navMoreShareView show];
        self.curShareSourceType = TTShareSourceObjectTypeArticleTop;
    }
    else if ([self.detailView.detailViewModel tt_articleDetailType] == TTDetailArchTypeSimple) {
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"用Safari打开", nil), NSLocalizedString(@"复制链接", nil), nil];
        actionSheet.delegate = self;
        [actionSheet showInView:self.view];
    }
    wrapperTrackEvent(@"detail", @"preferences");
    TLS_LOG(@"click_preference");
}

- (void)p_willShowSharePannel
{
    
    [self.activityActionManager clearCondition];
    if (!self.activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
        self.activityActionManager.clickSource = self.detailModel.clickLabel;
        self.activityActionManager.miniProgramEnable = self.detailModel.article.articleType == ArticleTypeNativeContent;
        self.activityActionManager.delegate = self;
    }
    
    NSMutableArray * activityItems = @[].mutableCopy;
    if ([self.articleInfoManager needShowAdShare]) {
        NSMutableDictionary *shareInfo = [self.articleInfoManager makeADShareInfo];
        activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager shareInfo:shareInfo showReport:NO];
    } else {
        activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager setArticleCondition:self.detailModel.article adID:self.detailModel.adID showReport:NO];
    }
    
    if (self.articleInfoManager.promotionModel) {
        TTActivity *proActivity = [TTActivity activityWithModel:self.articleInfoManager.promotionModel];
        [activityItems insertObject:proActivity atIndex:0];
        wrapperTrackEventWithCustomKeys(@"share_btn", @"show", self.detailModel.article.groupModel.groupID, nil, nil);
    }
    
//    if ([[TTKitchenMgr sharedInstance] getBOOL:kKCShareBoardDisplayRepost]) {
//        if (!self.shareManager) {
//            self.shareManager = [[TTShareManager alloc] init];
//            self.shareManager.delegate = self;
//        }
//        NSArray *contentItems = [self forwardSharePanelContentItemsWithTTActivities:activityItems];
//        [self.shareManager  displayForwardSharePanelWithContent:contentItems];
//
//    } else {
        self.toolbarShareView = [[SSActivityView alloc] init];
        self.toolbarShareView.delegate = self;
        self.toolbarShareView.activityItems = activityItems;
        [TTAdManageInstance share_showInAdPage:self.detailModel.adID.stringValue groupId:self.detailModel.article.groupModel.groupID];
        [self.toolbarShareView showOnViewController:self useShareGroupOnly:NO];
//    }
    
    
    self.curShareSourceType = TTShareSourceObjectTypeArticle;
    
//    [self.detailModel sendDetailTrackEventWithTag:@"detail" label:@"share_button"];
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark - SharePannel inner actions

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    TLS_LOG(@"didCompleteByItemType=%d", itemType);
    //分享数量统计
    if (itemType > TTActivityTypeNone && itemType <= TTActivityTypeShareButton){
        [Answers logCustomEventWithName:@"share" customAttributes:@{@"article": [NSString stringWithFormat:@"%d",itemType]}];
        [[TTMonitor shareManager] trackService:@"shareboard_success" status:itemType extra:@{@"source": @"article"}];
    }
    if (view == self.toolbarShareView) {
//        if (itemType == TTActivityTypeWeitoutiao) {
//            NSDictionary * extraDic = nil;
//            if (!isEmptyString(self.detailModel.article.groupModel.itemID)) {
//                extraDic = @{@"item_id":self.detailModel.article.groupModel.itemID};
//            }
//            wrapperTrackEventWithCustomKeys(@"detail_share", @"share_weitoutiao", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extraDic);
//            [self p_forwardToWeitoutiao];
//            if (ttvs_isShareIndividuatioEnable()){
//                [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:itemType];
//            }
//        }
        if (itemType == TTActivityTypeReport) {
            self.toolbarShareView = nil;
            [self report_showReportOnSharePannel];
            
        }
        else if (itemType == TTActivityTypePromotion) {
            [TTAdPromotionManager handleModel:self.articleInfoManager.promotionModel  condition:nil];
            wrapperTrackEventWithCustomKeys(@"share_btn", @"click", self.detailModel.article.groupModel.groupID, nil, nil);
        }
        else {
            if ([AKAwardCoinManager isShareTypeWithActivityType:itemType]) {
                [AKAwardCoinManager requestShareBounsWithGroup:self.detailModel.article.groupModel.groupID fromPush:self.detailModel.fromSource == NewsGoDetailFromSourceAPNS || self.detailModel.fromSource == NewsGoDetailFromSourceAPNSInAppAlert completion:nil];
            }
            
            NSString *adID = nil;
            if (self.detailModel.adID.longLongValue > 0) {
                adID = [NSString stringWithFormat:@"%@", self.detailModel.adID];
            }
            
            [self prepareShareImageIfNeeded];
            [self.activityActionManager performActivityActionByType:itemType inViewController:self sourceObjectType:self.curShareSourceType uniqueId:self.detailModel.article.groupModel.groupID adID:adID platform:TTSharePlatformTypeOfMain groupFlags:self.detailModel.article.groupFlags];
            NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:self.curShareSourceType];
            if (itemType == TTActivityTypeNone) {
                tag = @"detail";
            }
            NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
            [self.detailModel sendDetailTrackEventWithTag:tag label:label];
            
            self.toolbarShareView = nil;
        }
    } else if (view == self.navMoreShareView) {
//        if (itemType == TTActivityTypeWeitoutiao) {
//            [self p_forwardToWeitoutiao];
//            if (ttvs_isShareIndividuatioEnable()){
//                [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:itemType];
//            }
//
//        }
        if (itemType == TTActivityTypePGC) {
            NSString *mediaID = [self.detailModel.article.mediaInfo[@"media_id"] stringValue];
            NSString *enterItemId = self.detailModel.article.groupModel.itemID;
            
            NSMutableString *linkURLString = [NSMutableString stringWithFormat:@"sslocal://media_account?media_id=%@&source=%@&itemt_id=%@", mediaID, @"article_more", enterItemId];
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:linkURLString]];
            
            [self.navMoreShareView cancelButtonClicked];
            
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
            wrapperTrackEventWithCustomKeys(@"detail", @"pgc_button", mediaID, nil, extra);
        }
        else if (itemType == TTActivityTypeNightMode){
            BOOL isDayMode = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay);
            NSString * eventID = nil;
            if (isDayMode){
                [[TTThemeManager sharedInstance_tt] switchThemeModeto:TTThemeModeNight];
                eventID = @"click_to_night";
            }
            else{
                [[TTThemeManager sharedInstance_tt] switchThemeModeto:TTThemeModeDay];
                eventID = @"click_to_day";
            }
            wrapperTrackEvent(@"detail", eventID);
            //做一个假的动画效果 让夜间渐变
            UIView * imageScreenshot = [self.view.window snapshotViewAfterScreenUpdates:NO];
            [self.view.window addSubview:imageScreenshot];
            [UIView animateWithDuration:0.5f animations:^{
                imageScreenshot.alpha = 0;
            } completion:^(BOOL finished) {
                [imageScreenshot removeFromSuperview];
            }];
        }
        else if (itemType == TTActivityTypeFontSetting){
            [self.navMoreShareView fontSettingPressed];
        }
        else if (itemType == TTActivityTypeReport){
            [self.navMoreShareView cancelButtonClicked];
            
            [self report_showReportOnTopSharePannel];
            wrapperTrackEvent(@"detail", @"report_button");
        }
        else if (itemType == TTActivityTypeFavorite) {
            [self p_willChangeArticleFavoriteState];
        }
        else if (itemType == TTActivityTypePromotion) {
            [TTAdPromotionManager handleModel:self.articleInfoManager.promotionModel condition:nil];
            wrapperTrackEventWithCustomKeys(@"setting_btn", @"click", self.detailModel.article.groupModel.groupID, nil, nil);
        }
        else { // Share
            NSString *adId = nil;
            if ([self.detailModel.adID longLongValue] > 0) {
                adId = [NSString stringWithFormat:@"%@", self.detailModel.adID];
            }
            
            [self prepareShareImageIfNeeded];
            
            [self.activityActionManager performActivityActionByType:itemType inViewController:self sourceObjectType:self.curShareSourceType uniqueId:self.detailModel.article.groupModel.groupID adID:adId platform:TTSharePlatformTypeOfMain groupFlags:self.detailModel.article.groupFlags];
            NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:self.curShareSourceType];
            NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
            if (itemType == TTActivityTypeNone) {
                tag = @"detail";
                self.navMoreShareView = nil;
            }
            [self.detailModel sendDetailTrackEventWithTag:tag label:label];
        }
    }
}

- (void)prepareShareImageIfNeeded
{
    NSString *adID = nil;
    if (self.detailModel.adID.longLongValue > 0) {
        adID = [NSString stringWithFormat:@"%@", self.detailModel.adID];
    }
    
    NSInteger feedDetailShareImageStyle = [SSCommonLogic feedDetailShareImageStyle];
    if (feedDetailShareImageStyle < 1) {
        self.activityActionManager.shareToWeixinMomentScreenQRCodeImage = nil;
        return;
    }
    
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
        
        NSInteger feedDetailShareImageStyle = [SSCommonLogic feedDetailShareImageStyle];
        if (feedDetailShareImageStyle == 1 || feedDetailShareImageStyle == 3 || feedDetailShareImageStyle == 4) {
            UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, NO, [UIScreen mainScreen].scale);
            
            CGPoint savedContentOffset = self.detailView.detailWebView.containerScrollView.contentOffset;
            CGRect savedFrame = self.detailView.detailWebView.containerScrollView.frame;
            self.detailView.detailWebView.containerScrollView.contentOffset = CGPointZero;
            self.detailView.detailWebView.containerScrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            [self.detailView.detailWebView.containerScrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            CGImageRef imageRef = nil;
            CGRect rect = CGRectZero;
            CGImageRef imageRefRect = nil;
            self.detailView.detailWebView.containerScrollView.contentOffset = savedContentOffset;
            self.detailView.detailWebView.containerScrollView.frame= savedFrame;
            
            UIGraphicsEndImageContext();
            
            UIImageView *shareView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            shareView.backgroundColor = [UIColor whiteColor];
            
            UIView *gradientView = [[UIView alloc] initWithFrame:shareView.bounds];
            // 渐变图层
            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.frame = gradientView.bounds;
            // 设置颜色
            gradientLayer.colors = @[(id)[[UIColor whiteColor] colorWithAlphaComponent:0.0f].CGColor,
                                     (id)[[UIColor whiteColor] colorWithAlphaComponent:1.0f].CGColor];
            gradientLayer.locations = @[[NSNumber numberWithFloat:(shareView.bounds.size.height - 158.0f) / shareView.bounds.size.height],
                                        [NSNumber numberWithFloat:(shareView.bounds.size.height - 138.0f) / shareView.bounds.size.height]];
            // 添加渐变图层
            [gradientView.layer addSublayer:gradientLayer];
            [shareView addSubview:gradientView];
            
            UIImageView *coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, shareView.bounds.size.height - 158, shareView.bounds.size.width, 158)];
            coverView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5];
            [shareView addSubview:coverView];
            
            UIImageView *qView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
            iconView.image = [UIImage themedImageNamed:@"share_app_icon"];
            
            // 实例化二维码滤镜
            CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
            // 恢复滤镜的默认属性
            [filter setDefaults];
            
            NSString *phoneNum = self.detailModel.article.displayURL;
            if (feedDetailShareImageStyle == 1) {
                phoneNum = @"https://d.toutiao.com/YKJo/";
            }
            if (feedDetailShareImageStyle == 3) {
                phoneNum = self.detailModel.article.displayURL;
            }
            if (feedDetailShareImageStyle == 4) {
                phoneNum = self.detailModel.article.shareURL;
                
                NSString *questionMarkOrAmpersand = nil;
                if ([phoneNum rangeOfString:@"?"].location == NSNotFound) {
                    questionMarkOrAmpersand = @"?";
                }else {
                    questionMarkOrAmpersand = @"&";
                }
                NSString *para = [NSString stringWithFormat:@"%@=weixin_moments_image&%@=weixin_moments_image&%@", kShareChannelFrom, kUTMSource, kUTMOther];
                NSString *weixinMomentShareURL = [NSString stringWithFormat:@"%@%@%@", phoneNum, questionMarkOrAmpersand, para];
                
                phoneNum = weixinMomentShareURL;
            }
            // 将字符串转换成NSData
            NSData *data = [phoneNum dataUsingEncoding:NSUTF8StringEncoding];
            // 通过KVO设置滤镜, 传入data, 将来滤镜就知道要通过传入的数据生成二维码
            [filter setValue:data forKey:@"inputMessage"];
            // 设置二维码 filter 容错等级
            [filter setValue:@"Q" forKey:@"inputCorrectionLevel"];
            // 生成二维码
            CIImage *outputImage = [filter outputImage];
            qView.image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:80.0];
            qView.center = CGPointMake(shareView.bounds.size.width / 2, shareView.bounds.size.height - 60);
            iconView.center = qView.center;
            
            [shareView addSubview:qView];
            [shareView addSubview:iconView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, shareView.bounds.size.height - 132, shareView.bounds.size.width, 20)];
            label.textColor = [UIColor colorWithHexString:@"f85959"];
            label.text = @"长按识别二维码，打开app阅读全文";
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:14.];
            [shareView addSubview:label];
            
            UIImageView *tipView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 12)];
            tipView.image = [UIImage themedImageNamed:@"share_detail_tip_arrow"];
            tipView.center = CGPointMake(label.center.x + 122, label.center.y);
            [shareView addSubview:tipView];
            
            shareView.image = newImage;
            //[self.view addSubview:shareView];
            
            UIGraphicsBeginImageContextWithOptions(shareView.frame.size, NO, [UIScreen mainScreen].scale);
            
            [shareView.layer renderInContext:UIGraphicsGetCurrentContext()];
            newImage = UIGraphicsGetImageFromCurrentImageContext();
            imageRef = newImage.CGImage;
            rect = CGRectMake(0, 0, shareView.bounds.size.width * [UIScreen mainScreen].scale, shareView.bounds.size.height * [UIScreen mainScreen].scale);
            imageRefRect = CGImageCreateWithImageInRect(imageRef, rect);
            newImage =[ [UIImage alloc] initWithCGImage:imageRefRect];
            
            UIGraphicsEndImageContext();
            
            gradientView.hidden = YES;
            coverView.hidden = YES;
            qView.hidden = YES;
            label.hidden = YES;
            shareView.image = nil;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //shareView.image = newImage;
            });
            
            if (!adID && [TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay && [[UIDevice currentDevice].systemVersion doubleValue] >= 9.0 && ![TTDeviceHelper isPadDevice]) {
                self.activityActionManager.shareToWeixinMomentScreenQRCodeImage = newImage;
            } else {
                self.activityActionManager.shareToWeixinMomentScreenQRCodeImage = nil;
            }
        } else if (feedDetailShareImageStyle == 2) {
            
            UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, NO, [UIScreen mainScreen].scale);
            
            CGPoint savedContentOffset = self.detailView.detailWebView.containerScrollView.contentOffset;
            CGRect savedFrame = self.detailView.detailWebView.containerScrollView.frame;
            self.detailView.detailWebView.containerScrollView.contentOffset = CGPointZero;
            self.detailView.detailWebView.containerScrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            [self.detailView.detailWebView.containerScrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            CGImageRef imageRef = nil;
            CGRect rect = CGRectZero;
            CGImageRef imageRefRect = nil;
            self.detailView.detailWebView.containerScrollView.contentOffset= savedContentOffset;
            self.detailView.detailWebView.containerScrollView.frame= savedFrame;
            
            UIGraphicsEndImageContext();
            
            UIImageView *shareView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            shareView.backgroundColor = [UIColor whiteColor];
            
            UIView *gradientView = [[UIView alloc] initWithFrame:shareView.bounds];
            // 渐变图层
            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.frame = gradientView.bounds;
            // 设置颜色
            gradientLayer.colors = @[(id)[[UIColor whiteColor]  colorWithAlphaComponent:0.0f].CGColor,
                                     (id)[[UIColor colorWithHexString:@"0xf8f8f8"] colorWithAlphaComponent:1.0f].CGColor];
            gradientLayer.locations = @[[NSNumber numberWithFloat:(shareView.bounds.size.height - 120.0f) / shareView.bounds.size.height],
                                        [NSNumber numberWithFloat:(shareView.bounds.size.height - 100.0f) / shareView.bounds.size.height]];
            // 添加渐变图层
            [gradientView.layer addSublayer:gradientLayer];
            [shareView addSubview:gradientView];
            
            UIImageView *coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, shareView.bounds.size.height - 100, shareView.bounds.size.width, 100)];
            coverView.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
            [shareView addSubview:coverView];
            
            UIImageView *qView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            iconView.image = [UIImage themedImageNamed:@"share_app_icon_bigger"];
            
            // 实例化二维码滤镜
            CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
            // 恢复滤镜的默认属性
            [filter setDefaults];
            NSString *phoneNum = @"https://d.toutiao.com/kMq1/";
            // 将字符串转换成NSData
            NSData *data = [phoneNum dataUsingEncoding:NSUTF8StringEncoding];
            // 通过KVO设置滤镜, 传入data, 将来滤镜就知道要通过传入的数据生成二维码
            [filter setValue:data forKey:@"inputMessage"];
            // 设置二维码 filter 容错等级
            [filter setValue:@"Q" forKey:@"inputCorrectionLevel"];
            // 生成二维码
            CIImage *outputImage = [filter outputImage];
            qView.image=[self createNonInterpolatedUIImageFormCIImage:outputImage withSize:64.0];
            qView.center = CGPointMake(shareView.bounds.size.width - 47, shareView.bounds.size.height - 50);
            iconView.center = CGPointMake(40, shareView.bounds.size.height - 50);
            [shareView addSubview:qView];
            [shareView addSubview:iconView];
            
            UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, shareView.bounds.size.height - 101, shareView.bounds.size.width, 1)];
            lineView.backgroundColor = [UIColor colorWithHexString:@"e8e8e8"];
            [shareView addSubview:lineView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(73, shareView.bounds.size.height - 73, shareView.bounds.size.width - 73 - 64 - 15, 25)];
            label.textColor = [UIColor colorWithHexString:@"0x1a1a1a"];
            label.text = @"长按识别二维码阅读全文";
            label.font = [UIFont systemFontOfSize:18.];
            label.textAlignment = NSTextAlignmentLeft;
            [shareView addSubview:label];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(73, shareView.bounds.size.height - 46, shareView.bounds.size.width - 73 - 64 - 15, 20)];
            label1.textColor = [UIColor colorWithHexString:@"0x999999"];
            label1.text = @"更多精彩内容值得关注";
            label1.font = [UIFont systemFontOfSize:14.];
            label1.textAlignment = NSTextAlignmentLeft;
            [shareView addSubview:label1];
            
            shareView.image = newImage;
            //[self.view addSubview:shareView];
            
            UIGraphicsBeginImageContextWithOptions(shareView.frame.size, NO, [UIScreen mainScreen].scale);
            
            [shareView.layer renderInContext:UIGraphicsGetCurrentContext()];
            newImage = UIGraphicsGetImageFromCurrentImageContext();
            imageRef = newImage.CGImage;
            rect = CGRectMake(0, 0, shareView.bounds.size.width * [UIScreen mainScreen].scale, shareView.bounds.size.height * [UIScreen mainScreen].scale);
            imageRefRect = CGImageCreateWithImageInRect(imageRef, rect);
            newImage = [ [UIImage alloc] initWithCGImage:imageRefRect];
            
            UIGraphicsEndImageContext();
            
            coverView.hidden = YES;
            qView.hidden = YES;
            label.hidden = YES;
            label1.hidden = YES;
            shareView.image = nil;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //shareView.image = newImage;
            });
            
            if (!adID && [TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay && [[UIDevice currentDevice].systemVersion doubleValue] >= 9.0 && ![TTDeviceHelper isPadDevice]) {
                self.activityActionManager.shareToWeixinMomentScreenQRCodeImage = newImage;
            } else {
                self.activityActionManager.shareToWeixinMomentScreenQRCodeImage = nil;
            }
        } else {
            self.activityActionManager.shareToWeixinMomentScreenQRCodeImage = nil;
        }
    } else {
        self.activityActionManager.shareToWeixinMomentScreenQRCodeImage = nil;
    }
}



- (void)p_willChangeArticleFavoriteState {
    if (!TTNetworkConnected()){
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return;
    }
    //    [self p_didChangeArticleFavoriteState];
    // 调用新的方法，在点击收藏时吊起强制&非强制的登录弹窗
    [self didChangeArticleFavoriteState];
}

// 新增方法 文章详情页的收藏 强制&非强制登录弹窗
- (void)didChangeArticleFavoriteState {
    if (!self.itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    
    if ([SSCommonLogic accountABVersionEnabled]) {
        NSString *label;
        if (!self.detailModel.article.userRepined) {
//            label = @"favorite_button";
//
//            [self report_p_sendDetailLogicTrackWithLabel:label];
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:@"house_app2c_v2" forKey:@"event_type"];
            [params setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
            [params setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
            //        [params setValue:model.userID.stringValue forKey:@"user_id"];
            [params setValue:self.detailModel.orderedData.logPb forKey:@"log_pb"];
            [params setValue:self.detailModel.orderedData.categoryID forKey:@"category_name"];
            [params setValue:[FHTraceEventUtils generateEnterfrom:self.detailModel.orderedData.categoryID] forKey:@"enter_from"];
            [params setValue:@"detail" forKey:@"position"];
            [TTTrackerWrapper eventV3:@"rt_favourite" params:params];
            // 加入收藏吊起登录弹窗的代码
            TTAccountLoginAlertTitleType type = TTAccountLoginAlertTitleTypeFavor;
            NSString *source = @"article_detail_favor";
            NSInteger favorCount = [SSCommonLogic favorCount];
            
            if ([SSCommonLogic favorDetailActionType] == 0) {
                // 策略0: 不需要登录
                // 收藏操作都会正常进行,进行原来的收藏操作
//                 add by zjing 去掉登录同步收藏功能
                [self didFavorWithDismissHandler:nil];

                if ([SSCommonLogic needShowLoginTipsForFavor]) {
//                    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:@"登录后云端同步保存收藏，建议先登录" preferredStyle:UIAlertControllerStyleAlert];
//                    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                        [self didFavorWithDismissHandler:nil];
//                    }]];
////                    [ac addAction:[UIAlertAction actionWithTitle:@"同步收藏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                        [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
//                            if (type == TTAccountAlertCompletionEventTypeDone) {
//                                // 如果登录成功，后续功能会照常进行
//                                // 进行收藏操作
//                                if ([TTAccountManager isLogin]) {
//                                    [self didFavorWithDismissHandler:nil];
//                                }
//                            } else if (type == TTAccountAlertCompletionEventTypeCancel) {
//                                // 如果退出登录，登录不成功，则后续功能不会进行
//                                // 添加收藏失败的统计埋点
//                                // 收藏成功后，统计打点 favorite_fail
//                                //                            [self p_sendDetailLogicTrackWithLabel:@"favorite_fail"];
//                            } else if (type == TTAccountAlertCompletionEventTypeTip) {
//                                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:source subscribeCompletion:^(TTAccountLoginState state) {
//                                    if (state == TTAccountLoginStateLogin) {
//                                        // 如果登录成功，则进行收藏过程
//                                        //                                    [self didFavorWithDismissHandler:nil];
//                                    } else if (state == TTAccountLoginStateCancelled) {
//                                        // 添加收藏失败的统计埋点
//                                        // 收藏成功后，统计打点 favorite_fail
//                                        //                                    [self p_sendDetailLogicTrackWithLabel:@"favorite_fail"];
//                                    }
//                                }];
//                            }
//                        }];
//                    }]];
//                    [self presentViewController:ac animated:YES completion:nil];
                } else {
                    [self didFavorWithDismissHandler:nil];
                }
            } else if ([SSCommonLogic favorDetailActionType] == 1) {
                // 策略1: 强制登录，需要客户端判断用户的登录状态
                if ([TTAccountManager isLogin]) {
                    // 如果用户已经登录，不出现弹窗，收藏操作会正常进行
                    [self didFavorWithDismissHandler:nil];
                } else if (![TTAccountManager isLogin]) {
                    // 用户处于未登录状态，需要进行强制登录，用户不登录的话无法使用后续功能
                    [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                        if (type == TTAccountAlertCompletionEventTypeDone) {
                            // 如果登录成功，后续功能会照常进行
                            // 进行收藏操作
                            if ([TTAccountManager isLogin]) {
                                [self didFavorWithDismissHandler:nil];
                            }
                        } else if (type == TTAccountAlertCompletionEventTypeCancel) {
                            // 如果退出登录，登录不成功，则后续功能不会进行
                            // 添加收藏失败的统计埋点
                            // 收藏成功后，统计打点 favorite_fail
                            //                            [self p_sendDetailLogicTrackWithLabel:@"favorite_fail"];
                        } else if (type == TTAccountAlertCompletionEventTypeTip) {
                            [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:source subscribeCompletion:^(TTAccountLoginState state) {
                                if (state == TTAccountLoginStateLogin) {
                                    // 如果登录成功，则进行收藏过程
                                    //                                    [self didFavorWithDismissHandler:nil];
                                } else if (state == TTAccountLoginStateCancelled) {
                                    // 添加收藏失败的统计埋点
                                    // 收藏成功后，统计打点 favorite_fail
                                    //                                    [self p_sendDetailLogicTrackWithLabel:@"favorite_fail"];
                                }
                            }];
                        }
                    }];
                }
            } else if ([SSCommonLogic favorDetailActionType] == 2) {
                // 策略2: 非强制登录，需要客户端判断用户的登录状态
                if ([TTAccountManager isLogin]) {
                    // 如果用户已登录，不出现弹窗，收藏操作会正常进行
                    [self didFavorWithDismissHandler:nil];
                } else if (![TTAccountManager isLogin]) {
                    // 用户处于未登录状态，进行非强制登录弹窗
                    // 非强制登录的逻辑，根据当前文章详情页的点击收藏的次数进行弹窗判断的逻辑
                    // 得到当前文章详情页的点击收藏的次数，进行判断
                    favorCount++;
                    BOOL countEqual = NO;
                    for (NSNumber *tmp in [SSCommonLogic favorDetailActionTick]) {
                        if (favorCount == tmp.integerValue) {
                            countEqual = YES;
                            // 如果等于某次非强制登录弹窗的次数，则进行弹窗
                            
                            // 受弹窗顺序影响，0是动作生效前；1：动作生效后
                            if([SSCommonLogic favorDetailDialogOrder] == 0){
                                [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                                    if (type == TTAccountAlertCompletionEventTypeDone) {
                                        // 显示弹窗后，才进行收藏过程
                                        [self didFavorWithDismissHandler:nil];
                                    } else if (type == TTAccountAlertCompletionEventTypeCancel) {
                                        // 显示弹窗后，才进行收藏过程
                                        [self didFavorWithDismissHandler:nil];
                                    } else if (type == TTAccountAlertCompletionEventTypeTip) {
                                        [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:source subscribeCompletion:^(TTAccountLoginState state) {
                                            if (state == TTAccountLoginStateLogin) {
                                                // 如果登录成功，则进行收藏过程
                                                //                                                [self didFavorWithDismissHandler:nil];
                                            } else if (state == TTAccountLoginStateCancelled) {
                                                // 显示弹窗后，才进行收藏过程
                                            }
                                        }];
                                    }
                                }];
                            }
                            else if([SSCommonLogic favorDetailDialogOrder] == 1){
                                WeakSelf;
                                [self didFavorWithDismissHandler:^(BOOL isUserDismiss) {
                                    [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                                        StrongSelf;
                                        if (type == TTAccountAlertCompletionEventTypeTip) {
                                            [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:source subscribeCompletion:^(TTAccountLoginState state) {
                                                
                                            }];
                                        }
                                    }];
                                }];
                            }
                            // 找到相等次数时，break跳出循环
                            break;
                        }
                    }
                    if (!countEqual) {
                        // 如果不是符合的次数，则直接进行收藏操作过程
                        [self didFavorWithDismissHandler:nil];
                    }
                }
                
                // 将点击订阅数持久化进NSUSerDefaults
                [SSCommonLogic setFavorCount:favorCount];
            }
        } else {
            label = @"unfavorite_button";
            // 原来的打点方法
            [self report_p_sendDetailLogicTrackWithLabel:label];
            [self.itemActionManager unfavoriteForOriginalData:self.detailModel.article adID:self.detailModel.adID finishBlock:nil];
            if (!self.detailModel.article.userRepined) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                          indicatorText:NSLocalizedString(@"取消收藏", nil)
                                         indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"]
                                            autoDismiss:YES
                                         dismissHandler:nil];
            }
        }
    }
}

//非强制登录策略下，先出收藏成功提醒，再出登录弹窗
- (void)didFavorWithDismissHandler:(DismissHandler)handler{
    [self.itemActionManager favoriteForOriginalData:self.detailModel.article adID:self.detailModel.adID finishBlock:nil];
    if(self.detailModel.article.userRepined) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"收藏成功", nil)
                                 indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"]
                                    autoDismiss:YES
                                 dismissHandler:handler];
    }
    // 收藏成功后，统计打点 favor_success
    [self report_p_sendDetailLogicTrackWithLabel:@"favorite_success"];
    [Answers logCustomEventWithName:@"favorite" customAttributes:@{@"source": @"article"}];
    [[TTMonitor shareManager] trackService:@"favorite_success" status:1 extra:@{@"source": @"article"}];
}


- (void)report_p_sendDetailLogicTrackWithLabel:(NSString *)label
{
    [NewsDetailLogicManager trackEventTag:[self.detailView.detailWebView isCommentVisible]? @"comment": @"detail" label:label value:@(self.detailModel.article.uniqueID) extValue:self.detailModel.adID fromID:nil params:self.detailModel.gdExtJsonDict groupModel:self.detailModel.article.groupModel];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == 0) {
            NSURL *url = [TTStringHelper URLWithURLString:self.detailModel.article.shareURL];
            [[UIApplication sharedApplication] openURL:url];
        }
        else if (buttonIndex == 1) {
            [TTActivityShareManager copyText:self.detailModel.article.shareURL];
        }
    }
}

static char kCurShareSourceTypeKey;
- (void)setCurShareSourceType:(TTShareSourceObjectType)curShareSourceType {
    objc_setAssociatedObject(self, &kCurShareSourceTypeKey, @(curShareSourceType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTShareSourceObjectType)curShareSourceType {
    return [objc_getAssociatedObject(self, &kCurShareSourceTypeKey) integerValue];
}

#pragma mark - TTActivityShareManagerDelegate

//- (void)activityShareManager:(TTActivityShareManager *)activityShareManager
//    completeWithActivityType:(TTActivityType)activityType
//                       error:(NSError *)error {
//    if (!error) {
//        [[TTShareToRepostManager sharedManager] shareToRepostWithActivityType:activityType
//                                                                   repostType:TTThreadRepostTypeArticle
//                                                            operationItemType:TTRepostOperationItemTypeArticle
//                                                              operationItemID:self.detailModel.article.itemID
//                                                                originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.detailModel.article]
//                                                                 originThread:nil
//                                                               originShortVideoOriginalData:nil
//                                                            originWendaAnswer:nil
//                                                               repostSegments:nil];
//    }
//}

#pragma mark - ForwardSharePanel
- (nullable NSArray<id<TTActivityContentItemProtocol>> *)forwardSharePanelContentItemsWithTTActivities:(NSArray<TTActivity *> *)activities
{
    [self prepareShareImageIfNeeded];//耗时大约0.02～0.08s，iPhone6s，iOS10
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:7];
    NSString * questionMarkOrAmpersand = nil;
    if ([self.activityActionManager.shareURL rangeOfString:@"?"].location == NSNotFound) {
        questionMarkOrAmpersand = @"?";
    }else {
        questionMarkOrAmpersand = @"&";
    }
    NSString *shareBaseURL = [NSString stringWithFormat:@"%@%@", self.activityActionManager.shareURL, questionMarkOrAmpersand ];
    for (TTActivity *activity in activities) {
        switch (activity.activityType) {
            case TTActivityTypeWeixinShare:
            {
                NSString *weixinShareURL = [shareBaseURL stringByAppendingString:kShareChannelFromWeixin];
                TTWechatContentItem *wcContentItem  = [[TTWechatContentItem alloc] initWithTitle:self.activityActionManager.weixinTitleText desc:self.activityActionManager.weixinText webPageUrl:weixinShareURL thumbImage:self.activityActionManager.shareImage shareType:TTShareWebPage];
                [mutableArray addObject:wcContentItem];
            }
                break;
            case TTActivityTypeWeixinMoment:
            {
                if (self.activityActionManager.shareToWeixinMomentScreenQRCodeImage) {
                    TTWechatTimelineContentItem *wcMomentContentItem = [[TTWechatTimelineContentItem alloc] init];
                    wcMomentContentItem.shareType = TTShareImage;
                    wcMomentContentItem.image = self.activityActionManager.shareToWeixinMomentScreenQRCodeImage;
                    [mutableArray addObject:wcMomentContentItem];

                } else {
                    NSString *weixinMomentShareURL = [shareBaseURL stringByAppendingString:kShareChannelFromWeixinMoment] ;
                    TTWechatTimelineContentItem *wcMomentContentItem = [[TTWechatTimelineContentItem alloc] initWithTitle:self.activityActionManager.weixinMomentText
                                                                                                                     desc:self.activityActionManager.weixinMomentText
                                                                                                               webPageUrl:weixinMomentShareURL
                                                                                                               thumbImage:self.activityActionManager.shareImage
                                                                                                                shareType:TTShareWebPage];
                    [mutableArray addObject:wcMomentContentItem];
                }
            }
                break;
            case TTActivityTypeQQShare:
            {
                NSString *qqShareURL = [shareBaseURL stringByAppendingString:kShareChannelFromQQ];
                
                TTQQFriendContentItem *qqFriendContentItem = [[TTQQFriendContentItem alloc] initWithTitle:self.activityActionManager.qqShareTitleText
                                                                                                     desc:self.activityActionManager.qqShareText
                                                                                               webPageUrl:qqShareURL
                                                                                               thumbImage:self.activityActionManager.shareImage
                                                                                                 imageUrl:self.activityActionManager.shareImageURL
                                                                                                 shareTye:TTShareWebPage];
                [mutableArray addObject:qqFriendContentItem];
            }
                break;
            case TTActivityTypeQQZone:
            {
                NSString *qqZoneShareURL = [shareBaseURL stringByAppendingString:kShareChannelFromQQZone];
                NSString * qqZoneText = self.activityActionManager.qqZoneText;
                if (isEmptyString(qqZoneText)) {
                    qqZoneText = self.activityActionManager.qqShareText;
                }
                NSString *title = self.activityActionManager.qqZoneTitleText;
                if (isEmptyString(title)) {
                    title = self.activityActionManager.qqShareTitleText;
                }
                if (isEmptyString(title)) {
                    title = NSLocalizedString(@"幸福里", nil);
                }
                UIImage *shareImage = self.activityActionManager.shareToWeixinMomentOrQZoneImage ? self.activityActionManager.shareToWeixinMomentOrQZoneImage : self.activityActionManager.shareImage;
                TTQQZoneContentItem *qqZoneContentItem = [[TTQQZoneContentItem alloc] initWithTitle:title desc:qqZoneText webPageUrl:qqZoneShareURL thumbImage:shareImage imageUrl:self.activityActionManager.shareImageURL shareTye:TTShareWebPage];
                [mutableArray addObject:qqZoneContentItem];
            }
                break;
//            case TTActivityTypeDingTalk:
//            {
//                NSString *dingTalkShareURL = [shareBaseURL stringByAppendingString:kShareChannelFromDingTalk];
//                TTDingTalkContentItem *dingTalkContentItem = [[TTDingTalkContentItem alloc] initWithTitle:self.activityActionManager.dingtalkTitleText
//                                                                                                     desc:self.activityActionManager.dingtalkText
//                                                                                               webPageUrl:dingTalkShareURL
//                                                                                               thumbImage:self.activityActionManager.shareImage
//                                                                                                shareType:TTShareWebPage];
//                [mutableArray addObject:dingTalkContentItem];
//            }
//                break;
//            case TTActivityTypeSystem:
//            {
//                TTSystemContentItem *systemContentItem = [[TTSystemContentItem alloc] initWithDesc:self.activityActionManager.systemShareText webPageUrl:self.activityActionManager.systemShareUrl image:self.activityActionManager.systemShareImage];
//                [mutableArray addObject:systemContentItem];
//            }
//                break;
//            case TTActivityTypeCopy:
//            {
//                NSString *copyText = @"";
//                if (!isEmptyString(self.activityActionManager.copyText)) {
//                    copyText = self.activityActionManager.copyText;
//                } else if (!isEmptyString(self.activityActionManager.copyContent)) {
//                    copyText = self.activityActionManager.copyText;
//                }
//                TTCopyContentItem *copyContentItem = [[TTCopyContentItem alloc] initWithDesc:copyText];
//                [mutableArray addObject:copyContentItem];
//
//            }
//                break;

            default:
                break;
        }
        
    }
    
//    //再添加微头条的两个activity
//    TTForwardWeitoutiaoContentItem *forwardWeitoutiaoContentItem = [[TTForwardWeitoutiaoContentItem alloc] init];
//    forwardWeitoutiaoContentItem.repostParams = [self repostParams];
//    WeakSelf;
//    forwardWeitoutiaoContentItem.customAction = ^{
//        StrongSelf;
//        [self p_forwardToWeitoutiao];
//    };
//
//    [mutableArray addObject:forwardWeitoutiaoContentItem];
//
//    TTDirectForwardWeitoutiaoContentItem *directForwardContentItem = [[TTDirectForwardWeitoutiaoContentItem alloc] init];
//    directForwardContentItem.repostParams = [self repostParams];
//    directForwardContentItem.customAction = nil;
//    [mutableArray addObject:directForwardContentItem];
    
    return mutableArray.copy;
}

//- (NSDictionary *)repostParams
//{
//    NSDictionary *repostParams = [TTRepostService repostParamsWithRepostType:TTThreadRepostTypeArticle
//                                                               originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.detailModel.article]
//                                                                originThread:nil
//                                                originShortVideoOriginalData:nil
//                                                           originWendaAnswer:nil
//                                                           operationItemType:TTRepostOperationItemTypeArticle
//                                                             operationItemID:self.detailModel.article.itemID
//                                                              repostSegments:nil];
//    return repostParams;
//}

//- (void)p_forwardToWeitoutiao {
//    // 文章详情页的转发，实际转发对象为文章，操作对象为文章
//    [[TTRoute sharedRoute] openURLByPresentViewController:[NSURL URLWithString:@"sslocal://repost_page"] userInfo:TTRouteUserInfoWithDict([self repostParams])];
//}

#pragma mark TTShareManagerDelegate
- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController {
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    [extraDic setValue:self.detailModel.article.itemID forKey:@"item_id"];
    [extraDic setValue:self.detailModel.article.aggrType forKey:@"aggr_type"];
    [extraDic setValue:@"detail_bottom_bar" forKey:@"section"];
    NSString *tag = @"detail_share";
    if (activity == nil) {
        wrapperTrackEventWithCustomKeys(@"detail", [TTShareMethodUtil labelNameForShareActivity:activity], self.detailModel.article.itemID, self.detailModel.clickLabel, extraDic);
    } else if ([activity.activityType isEqualToString:TTActivityTypeForwardWeitoutiao]) {
        wrapperTrackEventWithCustomKeys(@"detail_share", @"share_weitoutiao", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extraDic);
    } else if ([activity.activityType isEqualToString:TTActivityTypeDirectForwardWeitoutiao]) {
        return;
    } else {
        wrapperTrackEventWithCustomKeys(tag, [TTShareMethodUtil labelNameForShareActivity:activity], self.detailModel.article.itemID, self.detailModel.clickLabel, extraDic);
    }
    
}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc
{
    if ([activity.activityType isEqualToString:TTActivityTypeForwardWeitoutiao]
        || [activity.activityType isEqualToString:TTActivityTypeDirectForwardWeitoutiao]) {
        return;
    }
    NSString *label = [TTShareMethodUtil labelNameForShareActivity:activity shareState:(error ? NO : YES)];
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    [extraDic setValue:self.detailModel.article.itemID forKey:@"item_id"];
    [extraDic setValue:self.detailModel.article.aggrType forKey:@"aggr_type"];
    wrapperTrackEventWithCustomKeys(@"detail_share", label, self.detailModel.article.itemID, self.detailModel.clickLabel, extraDic);
    
    //分享成功或失败，触发分享item排序
    if(error) {
        TTVActivityShareErrorCode errorCode = [TTActivityShareSequenceManager shareErrorCodeFromItemErrorCode:error WithActivity:activity];
        switch (errorCode) {
            case TTVActivityShareErrorFailed:
                [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareServiceSequenceFirstActivity:activity.contentItemType];
                break;
            case TTVActivityShareErrorUnavaliable:
            case TTVActivityShareErrorNotInstalled:
            default:
                break;
        }
    }else{
        [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareServiceSequenceFirstActivity:activity.contentItemType];
    }
}
#pragma mark - 关联变量

SYNTHESE_CATEGORY_PROPERTY_STRONG(navMoreShareView, setNavMoreShareView, SSActivityView *)
SYNTHESE_CATEGORY_PROPERTY_STRONG(toolbarShareView, setToolbarShareView, SSActivityView *)
SYNTHESE_CATEGORY_PROPERTY_STRONG(activityActionManager, setActivityActionManager, TTActivityShareManager *)

SYNTHESE_CATEGORY_PROPERTY_STRONG(shareManager, setShareManager, TTShareManager *)

@end
