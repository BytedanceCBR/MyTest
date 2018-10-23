//
//  ArticleShareManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-3-15.
//
//

#import "ArticleShareManager.h"
#import "TTImageInfosModel.h"
#import "SSSimpleCache.h"
#import "NetworkUtilities.h"
#import "UIDevice+TTAdditions.h"
#import "TTInstallIDManager.h"
#import "TTReportManager.h"
#import <TTImage/TTWebImageManager.h>
#import "ExploreEntryHelper.h"
#import "SSUserModel.h"
#import "ExploreCellHelper.h"
#import "TTShareConstants.h"
//#import "TTLiveOverallInfoModel.h"
#import "TTModuleBridge.h"
#import "TTImageInfosModel+Extention.h"
#import "TTVFeedItem+Extension.h"
#import <TTAccountBusiness.h>
#import "TTShareMethodUtil.h"
#import "TTWebImageManager.h"
#import "TTKitchenHeader.h"
#import "Article+TTADComputedProperties.h"
#import <BDWebImage/SDWebImageAdapter.h>

extern NSInteger ttvs_isShareTimelineOptimize(void);

@implementation TTShareModel
+ (TTShareModel *_Nullable)shareModelWithFeedItem:(TTVFeedItem *_Nullable)item
{
    TTVVideoArticle *article = item.article;
    TTShareModel *model = [[TTShareModel alloc] init];
    if ([item isAd]) {
        model.adID = @(item.adCell.article.adId.longLongValue);
    }
    if (article.largeImageList.URLListArray.count > 0) {
        model.infosModel = [[TTImageInfosModel alloc] initWithImageUrlList:article.largeImageList];
    }
    if (!model.infosModel && article.middleImageList.URLListArray.count > 0) {
        model.infosModel = [[TTImageInfosModel alloc] initWithImageUrlList:article.middleImageList];
    }
    model.shareURL = article.shareURL;
    model.downloadURL = item.adCell.app.downloadURL;
    model.groupModel = [[TTGroupModel alloc] initWithGroupID:@(article.groupId).stringValue itemID:@(article.itemId).stringValue impressionID:nil aggrType:article.aggrType];
    model.mediaName = item.videoUserInfo.name;
    model.title = article.title;
    model.abstract = article.abstract;
    model.commentCount = @(article.commentCount);
    return model;
}

@end
static ArticleShareManager * manager;

@implementation ArticleShareManager

+ (ArticleShareManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ArticleShareManager alloc] init];
    });
    return manager;
}

//+ (void)load
//{
//    [[TTModuleBridge sharedInstance_tt] registerAction:@"getShareItems" withBlock:^id _Nullable(id  _Nullable object, NSDictionary *_Nullable params) {
//        TTActivityShareManager *manager = [params objectForKey:@"manager"];
//        TTLiveOverallInfoModel *model = [params objectForKey:@"model"];
//
//        return [self shareActivityManager:manager setLiveModel:model];
//    }];
//}



+ (nonnull NSMutableArray *)shareActivityManager:(nonnull TTActivityShareManager *)manager setHuoshanCondition:(nonnull HuoShan *)huoshan
{
    [manager clearCondition];
    
    
    NSString *shareUrl = [NSString stringWithFormat:@"%@?share_ht_uid=%@&did=%@",
                          [huoshan.shareInfo objectForKey:@"source_url"],
                          [TTAccountManager userID],
                          [[TTInstallIDManager sharedInstance] deviceID]
                          ];
    NSString *shareImageUrl = [huoshan.shareInfo objectForKey:@"pic_url"];
    NSString *shareTitle = [huoshan.shareInfo objectForKey:@"title"];
    NSString *shareDesc = [huoshan.shareInfo objectForKey:@"description"];
    
    UIImage *image = [TTWebImageManager imageForURLString:shareImageUrl];
    if (image == nil) {
        image = [UIImage imageNamed:@"share_icon.png"];
    }
    if (image) {
        UIImage * videoImage = [UIImage imageNamed:@"huoshanlive"];
        videoImage = [videoImage imageScaleAspectToMaxSize:image.size.height / 1.5];
        image = [UIImage drawImage:videoImage inImage:image atPoint:CGPointMake(image.size.width / 2, image.size.height / 2)];
    }
    
    manager.shareImage = image;
    manager.shareImageURL = shareImageUrl;
    manager.shareToWeixinMomentOrQZoneImage = manager.shareImage;
    manager.shareURL = shareUrl;
    manager.hasImg = (manager.shareImage == nil ? NO : YES);
    
    TTGroupModel *model = [[TTGroupModel alloc] initWithGroupID:huoshan.liveId.stringValue];
    manager.groupModel = model;
    
    manager.weixinTitleText = shareTitle;
    NSString *detail = isEmptyString(shareDesc)?NSLocalizedString(@"真房源，好中介，快流通", nil):shareDesc;
    manager.weixinText = detail;
    manager.weixinMomentText = isEmptyString(shareTitle)?NSLocalizedString(@"真房源，好中介，快流通", nil):shareDesc;
    manager.qqShareTitleText = shareTitle;
    manager.qqShareText = detail;
    
    
    NSDictionary * templatesDict = [SSCommonLogic getShareTemplate];
    NSString * sinaWeiboTemplate = [templatesDict objectForKey:@"sina_weibo"];
    NSString * sinaWeiboMessage = [SSCommonLogic parseShareContentWithTemplate:sinaWeiboTemplate title:shareDesc shareURLString:shareUrl];
    
    manager.sinaWeiboText = sinaWeiboMessage;
    
    NSString * qqZoneTemplate = [templatesDict objectForKey:@"qzone_sns"];
    NSString * qqZoneMessage = [SSCommonLogic parseShareContentWithTemplate:qqZoneTemplate title:shareDesc shareURLString:shareUrl];
    
    manager.qqZoneText = qqZoneMessage;
    manager.qqZoneTitleText = shareTitle;

    manager.dingtalkTitleText = manager.weixinTitleText;
    manager.dingtalkText = manager.weixinText;
    
    NSString * questionMarkOrAmpersand = nil;
    if ([shareUrl rangeOfString:@"?"].location == NSNotFound) {
        questionMarkOrAmpersand = @"?";
    }else {
        questionMarkOrAmpersand = @"&";
    }

    NSString * systemTemplate = [templatesDict objectForKey:@"system"];
    NSString * copyShareText = [SSCommonLogic parseShareContentWithTemplate:systemTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@%@",shareUrl, questionMarkOrAmpersand, kShareChannelFromCopy]];
    manager.copyText = copyShareText;
    
    //视频列表页和详情页在分享面板显示举报选项
    [manager refreshActivitysWithReport:NO];
    
    NSMutableArray * activityItems = [manager defaultShareItems];
    
    return activityItems;
}

//+ (NSMutableArray *)shareActivityManager:(TTActivityShareManager *)manager setLiveModel:(TTLiveOverallInfoModel *)model {
//
//    [manager clearCondition];
//
//    manager.shareImage = model.liveShareImage;
//    manager.shareImageURL = model.liveShareImageURL;
//    manager.shareToWeixinMomentOrQZoneImage = manager.shareImage;
//    manager.shareURL = model.liveShareURL;
//    manager.hasImg = (manager.shareImage == nil ? NO : YES);
//
//    NSString *shareTitle = model.liveTitle;
//
//    manager.weixinTitleText = shareTitle;
//    NSString *detail = isEmptyString(model.liveAbstract)?NSLocalizedString(@"爱看", nil):model.liveAbstract;
//    manager.weixinText = detail;
//    manager.weixinMomentText = isEmptyString(shareTitle)?NSLocalizedString(@"爱看", nil):shareTitle;
//    manager.qqShareTitleText = shareTitle;
//    manager.qqShareText = detail;
//
//
//    NSDictionary * templatesDict = [SSCommonLogic getShareTemplate];
//    NSString * sinaWeiboTemplate = [templatesDict objectForKey:@"sina_weibo"];
//    NSString * sinaWeiboMessage = [SSCommonLogic parseShareContentWithTemplate:sinaWeiboTemplate title:shareTitle shareURLString:model.liveShareURL];
//
//    manager.sinaWeiboText = sinaWeiboMessage;
//
//    NSString * qqZoneTemplate = [templatesDict objectForKey:@"qzone_sns"];
//    NSString * qqZoneMessage = [SSCommonLogic parseShareContentWithTemplate:qqZoneTemplate title:shareTitle shareURLString:model.liveShareURL];
//
//    manager.qqZoneText = qqZoneMessage;
//    //        王大可说分享到空间 标题为 爱看
//    manager.qqZoneTitleText = NSLocalizedString(@"爱看", nil);
//
//    NSString * qqWeiboTemplate = [templatesDict objectForKey:@"qq_weibo"];
//    NSString * qqWeiboMessage = [SSCommonLogic parseShareContentWithTemplate:qqWeiboTemplate title:shareTitle shareURLString:model.liveShareURL];
//
//    manager.dingtalkTitleText = manager.weixinTitleText;
//    manager.dingtalkText = manager.weixinText;
//
//    //视频列表页和详情页在分享面板显示举报选项
//    [manager refreshActivitysWithReport:NO];
//
//    NSMutableArray * activityItems = [manager defaultShareItems];
//
//    return activityItems;
//}


+ (NSMutableArray *)shareActivityManager:(TTActivityShareManager *)manager setArticleCondition:(Article *)article adID:(NSNumber *)adID
{
    return [self shareActivityManager:manager setArticleCondition:article adID:adID showReport:NO];
}

+ (NSMutableArray *)shareActivityManager:(TTActivityShareManager *)manager setArticleCondition:(Article *)article adID:(NSNumber *)adID showReport:(BOOL)showReport
{
    return [self shareActivityManager:manager setArticleCondition:article adID:adID showReport:showReport withQQ:NO];
}

+ (nonnull NSMutableArray *)shareActivityManager:(nonnull TTActivityShareManager *)manager setArticleCondition:(nonnull Article *)article adID:(nullable NSNumber *)adID showReport:(BOOL)showReport withQQ:(BOOL)qq{
    
    [manager clearCondition];
    if (![TTDeviceHelper isPadDevice] && 0 == adID.longLongValue) {
        manager.forwardToWeitoutiao = YES;
    }
    UIImage *shareImage = [TTShareMethodUtil weixinSharedImageForArticle:article];
    
    if (!shareImage) {
        shareImage = [self defaultWeixinImage];
        manager.useDefaultImage = YES;
    }

    manager.shareImage = shareImage;
    manager.shareImageURL = [TTShareMethodUtil weixinSharedImageURLForArticle:article];
    manager.shareToWeixinMomentOrQZoneImage = manager.shareImage;
    manager.shareURL = article.shareURL;
    if (!isEmptyString(article.adModel.download_url) && isEmptyString(article.shareURL)) {
        manager.shareURL = article.adModel.download_url;
    }
    manager.hasImg = (manager.shareImage == nil ? NO : YES);
    /// 此处是为了兼容4.0 4.0 中tag不是必传参数
    //    if ([article respondsToSelector:@selector(tag)]) {
    //         manager.itemTag = article.tag;
    //    }
    manager.groupModel = article.groupModel;
    
    NSString *shareTitle = @"";
    NSString *weixinShareTitle = @"";
    if (!isEmptyString(article.mediaName)) {
        shareTitle = [NSString stringWithFormat:@"【%@】%@", article.mediaName, article.title];
        if ([SSCommonLogic shouldArticleShareWithPGCName]) {
            weixinShareTitle = shareTitle;
        }
        else {
            weixinShareTitle = article.title;
        }
    } else {
        shareTitle = article.title;
        weixinShareTitle = shareTitle;
    }

    manager.weixinTitleText = weixinShareTitle;
    NSString *detail = isEmptyString(article.abstract) ? NSLocalizedString(@"真房源，好中介，快流通", nil) : article.abstract;
    manager.weixinText = detail;
    manager.weixinMomentText = isEmptyString(weixinShareTitle) ? NSLocalizedString(@"真房源，好中介，快流通", nil) : weixinShareTitle;
    manager.qqShareTitleText = shareTitle;
    manager.qqShareText = detail;
    
    if (manager.isVideoSubject && ttvs_isShareTimelineOptimize() > 2) {
        NSString *weixinMomentText = isEmptyString(article.title) ? NSLocalizedString(@"真房源，好中介，快流通", nil) : article.title;
        manager.weixinMomentText = weixinMomentText;
    }
    
    if ([adID longLongValue] > 0) {
        manager.adID = [NSString stringWithFormat:@"%@", adID];
    }
    else {
        manager.adID = nil;
    }
    
    if (manager.isVideoSubject && ttvs_isShareTimelineOptimize() > 2 && isEmptyString(manager.adID)) {
        NSString *weixinMomentText = isEmptyString(article.title) ? NSLocalizedString(@"真房源，好中介，快流通", nil) : article.title;
        manager.weixinMomentText = weixinMomentText;
    }
    
    NSDictionary * templatesDict = [SSCommonLogic getShareTemplate];
    NSString * sinaWeiboTemplate = [templatesDict objectForKey:@"sina_weibo"];
    NSString * sinaWeiboMessage = [SSCommonLogic parseShareContentWithTemplate:sinaWeiboTemplate title:shareTitle shareURLString:article.shareURL];
    
    manager.sinaWeiboText = sinaWeiboMessage;
    
    NSString * qqZoneTemplate = [templatesDict objectForKey:@"qzone_sns"];
    NSString * qqZoneMessage = [SSCommonLogic parseShareContentWithTemplate:qqZoneTemplate title:shareTitle shareURLString:article.shareURL];
    
    manager.qqZoneText = qqZoneMessage;
    //        王大可说分享到空间 标题为 爱看
    manager.qqZoneTitleText = NSLocalizedString(@"好多房", nil);
    
    NSString * questionMarkOrAmpersand = nil;
    if ([article.shareURL rangeOfString:@"?"].location == NSNotFound) {
        questionMarkOrAmpersand = @"?";
    }else {
        questionMarkOrAmpersand = @"&";
    }
    
    NSString * webContentQuestionMarkOrAmpersand = nil;
    if (article.articleType == ArticleTypeWebContent) {
        if ([article.articleURLString rangeOfString:@"?"].location == NSNotFound) {
            webContentQuestionMarkOrAmpersand = @"?";
        }else {
            webContentQuestionMarkOrAmpersand = @"&";
        }
    }
    
    NSString * systemTemplate = [templatesDict objectForKey:@"system"];
    NSString * smsText = nil;
    if (article.articleType == ArticleTypeWebContent) {
        smsText = [SSCommonLogic parseShareContentWithTemplate:systemTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@%@", article.articleURLString, webContentQuestionMarkOrAmpersand, kShareChannelFromSMS]];
    }else {
        smsText = [SSCommonLogic parseShareContentWithTemplate:systemTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@%@", article.shareURL, questionMarkOrAmpersand, kShareChannelFromSMS]];
    }
    manager.messageText = smsText;
    
    NSString * mailSubject = [NSString stringWithFormat:@"%@ 【%@】", [TTSandBoxHelper appDisplayName], shareTitle];
    
    NSString * mailContent = nil;
    NSString * originMailContent = [NSString stringWithFormat:@"%@", article.detail.content];
    
    if ([originMailContent length] < 10) {//正文没有下载完成时候的分享, 防止article.content为(null)
        
        //添加下载连接
        NSString * downloadStr = [NSString stringWithFormat:@"(%@ <a href=\"http://app.toutiao.com/news_article/\">%@</a>)<br></br>", NSLocalizedString(@"想看更多合你口味的内容，马上下载", nil), [TTSandBoxHelper appDisplayName]];
        if (article.articleType == ArticleTypeWebContent) {
            //导流页邮件分享url使用article url
            mailContent = [NSString stringWithFormat:@"%@ <br></br>%@%@%@, <br></br>%@", shareTitle, article.articleURLString, webContentQuestionMarkOrAmpersand, kShareChannelFromMail, downloadStr];
        }else {
            mailContent = [NSString stringWithFormat:@"%@ <br></br>%@%@%@, <br></br>%@", shareTitle, article.shareURL, questionMarkOrAmpersand, kShareChannelFromMail, downloadStr];
        }
        
    }
    else {
        if (article.articleType == ArticleTypeWebContent) {
            //导流页邮件分享url使用article url
            mailContent = [ArticleShareManager conversionMailContentToPureHTML:originMailContent shareURL:article.articleURLString commentCount:article.commentCount];
        }else {
            mailContent = [ArticleShareManager conversionMailContentToPureHTML:originMailContent shareURL:article.shareURL commentCount:article.commentCount];
        }
    }
    
    manager.mailBody = mailContent;
    manager.mailSubject = mailSubject;
    manager.mailData = nil;
    manager.mailBodyIsHTML = YES;
    
    //系统分享
    manager.systemShareText = shareTitle;
    if (article.articleType == ArticleTypeWebContent) {
        //导流页系统分享url使用article url
        manager.systemShareUrl = article.articleURLString;
    }else {
        manager.systemShareUrl = article.shareURL;
    }
    manager.systemShareImage = manager.shareImage;
    
    NSString * facebookTemplate = [templatesDict objectForKey:@"facebook"];
    NSString * facebookShareText = [SSCommonLogic parseShareContentWithTemplate:facebookTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@%@", article.shareURL, questionMarkOrAmpersand, kShareChannelFromFacebook]];
    
    manager.facebookText = facebookShareText;
    
    NSString * twitterTemplate = [templatesDict objectForKey:@"twitter"];
    NSString * twitterShareText = [SSCommonLogic parseShareContentWithTemplate:twitterTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@%@", article.shareURL, questionMarkOrAmpersand, kShareChannelFromTwitter]];
    
    manager.twitterText = twitterShareText;
    
    NSString * copyShareText = nil;
    if (article.articleType == ArticleTypeWebContent) {
        //导流页复制链接使用article url
        copyShareText = [SSCommonLogic parseShareContentWithTemplate:systemTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@%@", article.articleURLString, webContentQuestionMarkOrAmpersand, kShareChannelFromCopy]];
    }else {
        copyShareText = [SSCommonLogic parseShareContentWithTemplate:systemTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@%@", article.shareURL, questionMarkOrAmpersand, kShareChannelFromCopy]];
    }
    manager.copyText = copyShareText;
    
    
    manager.dingtalkTitleText = manager.weixinTitleText;
    manager.dingtalkText = manager.weixinText;
    
    //视频列表页和详情页在分享面板显示举报选项
    [manager refreshActivitysWithReport:showReport withQQ:qq];
    
    NSMutableArray * activityItems = [manager defaultShareItems];
    
    return activityItems;
}

+ (nonnull NSMutableArray *)shareActivityManager:(nullable TTActivityShareManager *)manager shareModel:(nullable TTShareModel *)shareModel showReport:(BOOL)showReport
{
    [manager clearCondition];
    NSNumber *adID = shareModel.adID;
    NSString *shareImageURL = nil;
    UIImage *shareImage = nil;
    TTImageInfosModel *infosModel = shareModel.infosModel;
    if (isEmptyString(shareImageURL)) {
        shareImage = [TTWebImageManager imageForModel:infosModel];
        shareImageURL = [infosModel urlStringAtIndex:0];
    }

    NSString *shareURL = shareModel.shareURL;
    NSString *downloadURL = shareModel.downloadURL;
    NSString *mediaName = shareModel.mediaName;
    NSString *title = shareModel.title;
    NSString *abstract = shareModel.abstract;
    NSString *content = shareModel.content;
    NSNumber *commentCount = shareModel.commentCount;
    TTGroupModel *groupModel = shareModel.groupModel;

    if (![TTDeviceHelper isPadDevice] && 0 == adID.longLongValue) {
        manager.forwardToWeitoutiao = YES;
    }

    if (!shareImage) {
        shareImage = [self defaultWeixinImage];
        manager.useDefaultImage = YES;
    }

    if (!shareImage) {
        shareImage = [self defaultWeixinImage];
        manager.useDefaultImage = YES;
    }
    manager.shareImage = shareImage;
    manager.shareImageURL = shareImageURL;
    manager.shareToWeixinMomentOrQZoneImage = shareImage;
    manager.shareURL = shareURL;
    if (!isEmptyString(downloadURL) && isEmptyString(shareURL)) {
        manager.shareURL = downloadURL;
    }
    manager.hasImg = (manager.shareImage == nil ? NO : YES);

    manager.groupModel = groupModel;

    NSString *shareTitle;
    if (!isEmptyString(mediaName)) {
        shareTitle = [NSString stringWithFormat:@"【%@】%@", mediaName, title];
    }
    else {
        shareTitle = title;
    }

    manager.weixinTitleText = shareTitle;
    NSString *detail = isEmptyString(abstract)?NSLocalizedString(@"真房源，好中介，快流通", nil):abstract;
    manager.weixinText = detail;
    manager.weixinMomentText = isEmptyString(shareTitle)?NSLocalizedString(@"真房源，好中介，快流通", nil):shareTitle;
    manager.qqShareTitleText = shareTitle;
    manager.qqShareText = detail;
    
    if (manager.isVideoSubject && ttvs_isShareTimelineOptimize() > 2) {
        NSString *weixinMomentText = isEmptyString(title) ? NSLocalizedString(@"真房源，好中介，快流通", nil) : title;
        manager.weixinMomentText = weixinMomentText;
    }

    if ([adID longLongValue] > 0) {
        manager.adID = [NSString stringWithFormat:@"%@", adID];
    }
    else {
        manager.adID = nil;
    }
    
    if (manager.isVideoSubject && ttvs_isShareTimelineOptimize() > 2 && isEmptyString(manager.adID)) {
        NSString *weixinMomentText = isEmptyString(title) ? NSLocalizedString(@"真房源，好中介，快流通", nil) : title;
        manager.weixinMomentText = weixinMomentText;
    }

    NSDictionary * templatesDict = [SSCommonLogic getShareTemplate];
    NSString * sinaWeiboTemplate = [templatesDict objectForKey:@"sina_weibo"];
    NSString * sinaWeiboMessage = [SSCommonLogic parseShareContentWithTemplate:sinaWeiboTemplate title:shareTitle shareURLString:shareURL];

    manager.sinaWeiboText = sinaWeiboMessage;

    NSString * qqZoneTemplate = [templatesDict objectForKey:@"qzone_sns"];
    NSString * qqZoneMessage = [SSCommonLogic parseShareContentWithTemplate:qqZoneTemplate title:shareTitle shareURLString:shareURL];

    manager.qqZoneText = qqZoneMessage;
    //        王大可说分享到空间 标题为 爱看
    manager.qqZoneTitleText = NSLocalizedString(@"好多房", nil);

    NSString * questionMarkOrAmpersand = nil;
    if ([shareURL rangeOfString:@"?"].location == NSNotFound) {
        questionMarkOrAmpersand = @"?";
    }else {
        questionMarkOrAmpersand = @"&";
    }

    NSString * systemTemplate = [templatesDict objectForKey:@"system"];
    NSString * smsText = [SSCommonLogic parseShareContentWithTemplate:systemTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@%@", shareURL, questionMarkOrAmpersand, kShareChannelFromSMS]];
    manager.messageText = smsText;

    NSString * mailSubject = [NSString stringWithFormat:@"%@ 【%@】", [TTSandBoxHelper appDisplayName], shareTitle];

    NSString * mailContent = nil;
    NSString * originMailContent = [NSString stringWithFormat:@"%@", content];

    if ([originMailContent length] < 10) {//正文没有下载完成时候的分享, 防止content为(null)

        //添加下载连接
        NSString * downloadStr = [NSString stringWithFormat:@"(%@ <a href=\"http://app.toutiao.com/news_article/\">%@</a>)<br></br>", NSLocalizedString(@"想看更多合你口味的内容，马上下载", nil), [TTSandBoxHelper appDisplayName]];
        mailContent = [NSString stringWithFormat:@"%@ <br></br>%@%@%@, <br></br>%@", shareTitle, shareURL, questionMarkOrAmpersand, kShareChannelFromMail, downloadStr];

    }
    else {
        mailContent = [ArticleShareManager conversionMailContentToPureHTML:originMailContent shareURL:shareURL commentCount:[commentCount integerValue]];
    }

    manager.mailBody = mailContent;
    manager.mailSubject = mailSubject;
    manager.mailData = nil;
    manager.mailBodyIsHTML = YES;

    //系统分享
    manager.systemShareText = shareTitle;
    manager.systemShareUrl = shareURL;
    manager.systemShareImage = manager.shareImage;

    NSString * facebookTemplate = [templatesDict objectForKey:@"facebook"];
    NSString * facebookShareText = [SSCommonLogic parseShareContentWithTemplate:facebookTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@%@", shareURL, questionMarkOrAmpersand, kShareChannelFromFacebook]];

    manager.facebookText = facebookShareText;

    NSString * twitterTemplate = [templatesDict objectForKey:@"twitter"];
    NSString * twitterShareText = [SSCommonLogic parseShareContentWithTemplate:twitterTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@%@", shareURL, questionMarkOrAmpersand, kShareChannelFromTwitter]];

    manager.twitterText = twitterShareText;

    NSString * copyShareText = [SSCommonLogic parseShareContentWithTemplate:systemTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@%@", shareURL, questionMarkOrAmpersand, kShareChannelFromCopy]];

    manager.copyText = copyShareText;

    manager.dingtalkTitleText = manager.weixinTitleText;
    manager.dingtalkText = manager.weixinText;

    //视频列表页和详情页在分享面板显示举报选项
    [manager refreshActivitysWithReport:showReport];

    NSMutableArray * activityItems = [manager defaultShareItems];

    return activityItems;
}

+ (NSMutableArray *)shareActivityManager:(TTActivityShareManager *)manager setNativeGalleryImage:(UIImage *)image webGalleryURL:(NSString *)galleryURL
{
    [manager clearCondition];
    manager.shareImageStyleImage = image;
    manager.shareImageStyleImageURL = galleryURL;
    [manager refreshActivitysForSingleGallery];
    return [manager defaultShareItems];
}

+ (UIImage *)defaultWeixinImage
{
    UIImage * weixinImg = nil;
    //优先使用share_icon.png分享
    if (!weixinImg) {
        weixinImg = [UIImage imageNamed:@"share_icon.png"];
    }
    
    //无图时使用icon
    if(!weixinImg)
    {
        weixinImg = [UIImage imageNamed:@"Icon.png"];
    }
    return weixinImg;
}

+ (UIImage *)weixinSharedImageForImageUrl:(NSString *)imageUrl {
    UIImage * weixinImg = nil;
    
    weixinImg = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:imageUrl];
    
    //优先使用share_icon.png分享
    if (!weixinImg) {
        weixinImg = [UIImage imageNamed:@"default_web_share_icon.png"];
    }
    //否则使用icon
    if(!weixinImg)
    {
        weixinImg = [UIImage imageNamed:@"Icon.png"];
    }
    
    return weixinImg;
}

#pragma mark - download avatarImage


#pragma mark -- mail content Util

+ (NSString *)conversionMailContentToPureHTML:(NSString *)originMailContent shareURL:(NSString *)shareURL commentCount:(NSInteger)commentCount
{
    if (isEmptyString(originMailContent)) {
        return @"";
    }

    NSMutableString * resultContent = [NSMutableString stringWithString:originMailContent];
    NSString * questionMarkOrAmpersand = nil;
    if ([shareURL rangeOfString:@"?"].location == NSNotFound) {
        questionMarkOrAmpersand = @"?";
    }else {
        questionMarkOrAmpersand = @"&";
    }
    NSString * sURL = [NSString stringWithFormat:@"%@%@%@", shareURL, questionMarkOrAmpersand, kShareChannelFromMail];
    NSString * sepLineStr = @"---------------------------------";
    NSString * downloadAppURL = @"http://app.toutiao.com/news_article/";

    @try {//防止服务器修改返回值造成的不可预期后果
        //去掉 显示大图一行
        NSString * showOriginImgTagStr = [NSString stringWithFormat:@"<div id=\"toggle_img\"> <a href=\"#\" onclick=\"toggle_images(); return false;\">%@</a></div>", NSLocalizedString(@"显示大图", nil)];
        
        NSRange showOriginImgTagRange = [originMailContent rangeOfString:showOriginImgTagStr];
        
        if (showOriginImgTagRange.location != NSNotFound && showOriginImgTagRange.length > 0) {
            [resultContent replaceCharactersInRange:showOriginImgTagRange withString:@""];
        }
        
        NSError *tError = nil;
        NSString * imgPattern = @"<a class=\"image\"[\\s\\S]*?<\\/a>";
        NSRegularExpression *imgRegex = [NSRegularExpression regularExpressionWithPattern:imgPattern options:NSRegularExpressionCaseInsensitive error:&tError];
        
        
        NSRange imgPartMatch = [imgRegex rangeOfFirstMatchInString:resultContent options:0 range:NSMakeRange(0, [resultContent length])];
        
        int maxWhile = 0; //防止服务器修改返回值造成的不可预期后果
        
        while (imgPartMatch.location != NSNotFound && imgPartMatch.length > 0) {
            
            maxWhile ++;
            
            if (maxWhile > 100) {
                break;
            }
            
            NSString * imgURLPart = [resultContent substringWithRange:imgPartMatch];
            
            NSString * imgURLPattern = @"origin_src=\".*?\"";
            NSError * imgURLError = nil;
            NSRegularExpression * imgURLRegex = [NSRegularExpression regularExpressionWithPattern:imgURLPattern options:NSRegularExpressionCaseInsensitive error:&imgURLError];
            NSRange imgURLMatchRange = [imgURLRegex rangeOfFirstMatchInString:imgURLPart options:0 range:NSMakeRange(0, [imgURLPart length])];
            
            if (imgURLMatchRange.location != NSNotFound) {
                NSString * tempOriginURL = [imgURLPart substringWithRange:imgURLMatchRange];
                NSString * originURL = nil;
                if ([tempOriginURL length] > [@"origin_src=\"\"" length]) {
                    originURL = [tempOriginURL substringWithRange:NSMakeRange([@"origin_src=\"" length], [tempOriginURL length] - [@"origin_src=\"\"" length])];
                }
                if (!isEmptyString(originURL)) {
                    [resultContent replaceCharactersInRange:imgPartMatch withString:[NSString stringWithFormat:@"<img src=\"%@\"></img>", originURL]];
                }
            }
            
            imgPartMatch = [imgRegex rangeOfFirstMatchInString:resultContent options:0 range:NSMakeRange(0, [resultContent length])];
        }
        
        //去掉HTML中的查看原文， 使用ShareURL替换
        NSString * watchOriginPagePattern = @"<div id=\"src\"><a href=\".*?\">.*?</a></div>";
        NSRegularExpression * watchOriginRegex = [NSRegularExpression regularExpressionWithPattern:watchOriginPagePattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSRange watchOriginRange = [watchOriginRegex rangeOfFirstMatchInString:resultContent options:0 range:NSMakeRange(0, [resultContent length])];
        if (watchOriginRange.location != NSNotFound) {
            NSString * replaceStr = [NSString stringWithFormat:@"<p><a href=\"%@\">%@</a></p>", sURL, NSLocalizedString(@"查看原文", nil)];
            [resultContent replaceCharactersInRange:watchOriginRange withString:replaceStr];
        }
        
        //添加下载连接
        NSString * downloadStr = [NSString stringWithFormat:@"(%@ <a href=\"%@\">%@</a>)<br></br>", NSLocalizedString(@"想看更多合你口味的内容，马上下载", nil), downloadAppURL, [TTSandBoxHelper appDisplayName]];
        if ([resultContent length] > 0) {
            [resultContent insertString:downloadStr atIndex:0];
        }
        else {
            [resultContent appendString:downloadStr];
        }
        
        
        //来源，时间和正文，多空一行
        NSString * timeLabelPattern = @"<span class=\"time\">.*?</span>";
        NSRegularExpression * timeLabelRegex = [NSRegularExpression regularExpressionWithPattern:timeLabelPattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSRange timeLabelRange = [timeLabelRegex rangeOfFirstMatchInString:resultContent options:0 range:NSMakeRange(0, [resultContent length])];
        if (timeLabelRange.location != NSNotFound) {
            [resultContent insertString:[NSString stringWithFormat:@"<br></br>%@<br></br>", sepLineStr] atIndex:(timeLabelRange.location + timeLabelRange.length)];
        }
        
        //添加评论数字一行
        NSString * tmpstr = NSLocalizedString(@"查看", nil);
        NSString * tmpStr2 = NSLocalizedString(@"条)网友精彩评论", nil);
        NSString * commentCountStr = [NSString stringWithFormat:@"<p><a href=\"%@\">%@(%ld%@...</a></p>", sURL, tmpstr, (long)commentCount, tmpStr2];
        [resultContent appendString:commentCountStr];

        
        //分割线， 签名
        NSString * signStr = [NSString stringWithFormat:@"<br></br>%@<p>%@</p><p></p><p></p>%@<br></br>%@ <a href=\"%@\">%@</a><br></br><img src=\"http://s.pstatp.com/r2/image/code/news_article.png?ver=201305241510\"/><br></br>%@<br></br>", NSLocalizedString(@"好多房 - 真房源，好中介，快流通", nil), sepLineStr, NSLocalizedString(@"《好多房》是一款会自动学习的资讯软件，它会聪明地分析你的兴趣爱好，自动为你推荐喜欢的内容，并且越用越懂你。", nil), NSLocalizedString(@"点击下载", nil), downloadAppURL, NSLocalizedString(@"好多房", nil), NSLocalizedString(@"扫描二维码", nil)];
        
        [resultContent appendString:signStr];
        
        //title加粗
        NSString * titlePattern = @"<div class=\"title\">.*?</div>";
        NSRegularExpression * titlePatternRegex  = [NSRegularExpression regularExpressionWithPattern:titlePattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSRange titleLabelRange = [titlePatternRegex rangeOfFirstMatchInString:resultContent options:0 range:NSMakeRange(0, [resultContent length])];
        if (titleLabelRange.location != NSNotFound) {
            NSString * originTitleStr = [resultContent substringWithRange:titleLabelRange];
            NSString * replaceTitleStr = [NSString stringWithFormat:@"<strong>%@</strong>", originTitleStr];
            [resultContent replaceCharactersInRange:titleLabelRange withString:replaceTitleStr];
        }
        
    }
    @catch (NSException *exception) {
        SSLog(@"article mail share body exception %@", exception);
        resultContent = [NSMutableString stringWithString:originMailContent];
    }
    @finally {
        
    }
    
    return [NSString stringWithString:resultContent];
}

+ (NSMutableArray *)shareActivityManager:(TTActivityShareManager *)manager exploreEntry:(ExploreEntry *)entry
{
    return [self shareActivityManager:manager mediaID:[NSString stringWithFormat:@"%@", @([entry.mediaID longLongValue])] avatarString:entry.imageURLString shareURL:entry.shareURL isLoginUser:[ExploreEntryHelper isLoginUserEntry:entry] screenName:entry.name desc:entry.desc];
}

+ (NSArray *)shareActivityManager:(TTActivityShareManager *)manager profileShareObject:(NSDictionary *)data isAccountUser:(BOOL)loginUser {
    if (!data || !manager) return nil;
    
    [manager clearCondition];
    
    NSString *userId        = [data valueForKey:@"user_id"];
    NSString *shareName     = [data valueForKey:@"name"];
    NSString *shareImageUrl = [data valueForKey:@"avatar_url"];
    NSString *shareDesp __unused = [data valueForKey:@"description"];
    NSString *shareUrl      = [data valueForKey:@"share_url"];
    NSString *shareTitle    = [TTSandBoxHelper appDisplayName];
    BOOL      isBlocking    = [[data valueForKey:@"is_blocking"] boolValue];
    UIImage *shareImage = nil;
    
    NSData *imgData = [[SSSimpleCache sharedCache] dataForUrl:shareImageUrl];
    if (imgData != nil) {
        shareImage = [UIImage imageWithData:imgData];
    } else {
        shareImage = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:shareImageUrl];
    }
    
    NSString *shareMsg = [NSString stringWithFormat:@"推荐《%@》的主页", shareName];
//    if ([shareMsg length] > 140) {
//        NSInteger overLength = [shareMsg length] - 140;
//        NSInteger overIndex = [shareDesp length] - overLength;
//        NSString *fixDesc = @"";
//        if (overIndex > 0) {
//            fixDesc = [shareDesp substringToIndex:overIndex];
//        }
//        shareMsg = [NSString stringWithFormat:formatString, shareName, fixDesc, shareUrl];
//    }
    NSString *shareMsgWithUrl = shareMsg;
    if (shareUrl) {
        shareMsgWithUrl = [NSString stringWithFormat:@"%@ %@", shareMsg, shareUrl];
    }
    
    manager.shareImage = shareImage;
    manager.shareImageURL = shareImageUrl;
    manager.shareToWeixinMomentOrQZoneImage = manager.shareImage;
    manager.hasImg = (manager.shareImage == nil ? NO : YES);
    manager.mediaID = [NSString stringWithFormat:@"%@", userId]; // userID and mediaID融合
    manager.shareURL = shareUrl;
    manager.itemTag = nil;
    
    
    manager.weixinText = shareMsg;
    manager.weixinTitleText = shareTitle;
    manager.weixinMomentText = shareMsg;
    manager.qqShareTitleText = shareTitle;
    manager.qqShareText = shareMsg;
    
    NSString *mailSubject = [NSString stringWithFormat:NSLocalizedString(@"推荐好多房中的\"%@\"", nil), shareName];
    manager.mailBody = shareMsgWithUrl;
    manager.mailSubject = mailSubject;
    manager.mailBodyIsHTML = NO;
    manager.mailData = nil;
    manager.messageText = shareMsgWithUrl;
    
    //系统分享
    manager.systemShareText = shareMsg;
    manager.systemShareUrl = shareUrl;
    manager.systemShareImage = shareImage;
    
    
    manager.facebookText = shareMsg;
    
    manager.twitterText = shareMsg;
    
    manager.copyText = shareUrl;
    
    manager.sinaWeiboText = shareMsg;
    
    manager.dingtalkTitleText = manager.weixinTitleText;
    manager.dingtalkText = manager.weixinText;
    
    [manager refreshActivitysForProfileWithAccountUser:loginUser isBlocking:isBlocking];
    
    return [manager defaultShareItems];
}

+ (NSMutableArray *)shareActivityManager:(TTActivityShareManager *)manager pgcAccount:(PGCAccount *)account
{
    return [self shareActivityManager:manager mediaID:account.mediaID avatarString:account.avatarURLString shareURL:account.shareURL isLoginUser:account.isLoginUser screenName:account.screenName desc:account.userDesc];
}

+ (NSMutableArray *)shareActivityManager:(TTActivityShareManager *)manager
                                 mediaID:(NSString *)mediaID
                            avatarString:(NSString *)avatarStr
                                shareURL:(NSString *)shareURL
                             isLoginUser:(BOOL)loginUser
                              screenName:(NSString *)screenName
                                    desc:(NSString *)desc
{
    [manager clearCondition];
    UIImage * shareImg = nil;
    NSData * imgData = [[SSSimpleCache sharedCache] dataForUrl:avatarStr];
    
    if (imgData != nil) {
        shareImg = [UIImage imageWithData:imgData];
    }
    else
    {
        shareImg = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:avatarStr];
    }
    
    manager.shareImage = shareImg;
    manager.shareImageURL = avatarStr;
    manager.shareToWeixinMomentOrQZoneImage = manager.shareImage;
    manager.hasImg = (manager.shareImage == nil ? NO : YES);
    manager.mediaID = [NSString stringWithFormat:@"%@", mediaID];
    manager.shareURL = shareURL;
    manager.itemTag = nil;
    
    NSString * tempStr = loginUser ? NSLocalizedString(@"欢迎访问我的头条号《%@》：%@ %@", nil) : NSLocalizedString(@"推荐《%@》：%@ %@", nil);
    
    NSString * shareMsg = [NSString stringWithFormat:tempStr, screenName, desc, shareURL];
    if ([shareMsg length] > 140) {
        NSInteger overLength = [shareMsg length] - 140;
        NSInteger overIndex = [desc length] - overLength;
        NSString * fixDesc = @"";
        if (overIndex > 0) {
            fixDesc = [desc substringToIndex:overIndex];
        }
        shareMsg = [NSString stringWithFormat:tempStr, screenName, fixDesc, shareURL];
    }
    
    NSString * shareTitle = [TTSandBoxHelper appDisplayName];
    
    
    manager.weixinText = shareMsg;
    manager.weixinTitleText = shareTitle;
    
    manager.weixinMomentText = shareMsg;
    
    manager.qqShareTitleText = shareTitle;
    manager.qqShareText = shareMsg;

    NSString * mailSubject = [NSString stringWithFormat:NSLocalizedString(@"推荐好多房中的\"%@\"", nil), screenName];
    
    manager.mailBody = shareMsg;
    manager.mailSubject = mailSubject;
    manager.mailBodyIsHTML = NO;
    manager.mailData = nil;
    manager.messageText = shareMsg;
    
    //系统分享
    manager.systemShareText = shareMsg;
    manager.systemShareUrl = shareURL;
    manager.systemShareImage = shareImg;

    
    manager.facebookText = shareMsg;
    
    manager.twitterText = shareMsg;
    
    manager.copyText = shareMsg;
    
    manager.sinaWeiboText = shareMsg;
    
    manager.dingtalkTitleText = manager.weixinTitleText;
    manager.dingtalkText = manager.weixinText;

    //fix pgc订阅号主页，不显示举报
    [manager refreshActivitysWithReport:NO];
    //[manager refreshActivitys];
    
    return [manager defaultShareItems];
    
}

+ (NSMutableArray *)shareActivityManager:(TTActivityShareManager *)manager shareInfo:(NSDictionary *)shareInfo showReport:(BOOL)report
{
    return [self shareActivityManager:manager shareInfo:shareInfo showReport:report withQQ:NO];
}


+ (NSMutableArray *)shareActivityManager:(TTActivityShareManager *)manager shareInfo:(NSDictionary *)shareInfo showReport:(BOOL)report withQQ:(BOOL)qq{
    [manager clearCondition];
    NSString * const defaultText = NSLocalizedString(@"真房源，好中介，快流通", nil);
    NSString *shareTitle = [shareInfo tt_stringValueForKey:@"share_title"];
    if (isEmptyString(shareTitle)) {
        shareTitle = defaultText;
    }
    NSString *detail = [shareInfo tt_stringValueForKey:@"share_desc"];
    if (isEmptyString(detail)) {
        detail = defaultText;
    }
    NSString *shareURL = [shareInfo tt_stringValueForKey:@"share_url"] ?: @"https://m.toutiao.com";
    NSString *adID = [shareInfo tt_stringValueForKey:@"ad_id"];
    TTGroupModel *groupModel = [shareInfo tt_objectForKey:@"groupModel"];
    
    NSDictionary *imageInfo = [shareInfo tt_dictionaryValueForKey:@"share_icon"];
    TTImageInfosModel *imageInfoModel = [[TTImageInfosModel alloc] initWithDictionary:imageInfo];
    UIImage *shareImage = [TTWebImageManager imageForModel:imageInfoModel];
    
    if (!shareImage) {
        shareImage = (UIImage *)[shareInfo objectForKey:@"share_image"];
    }
    
    if (!shareImage) {
        shareImage = [self defaultWeixinImage];
        manager.useDefaultImage = YES;
    }
    
    manager.shareImage = shareImage;
    manager.shareImageURL = [imageInfoModel urlStringAtIndex:0];
    manager.shareToWeixinMomentOrQZoneImage = manager.shareImage;
    manager.shareURL = shareURL;
    manager.hasImg = (manager.shareImage == nil ? NO : YES);
    manager.adID = adID;
    manager.groupModel = groupModel;
    
    manager.weixinTitleText = shareTitle;
    manager.weixinText = detail;
    manager.weixinMomentText = isEmptyString(shareTitle)?NSLocalizedString(@"真房源，好中介，快流通", nil):shareTitle;
    manager.qqShareTitleText = shareTitle;
    manager.qqShareText = detail;
    
    if (manager.isVideoSubject && ttvs_isShareTimelineOptimize() > 2 && isEmptyString(manager.adID)) {
        NSString *weixinMomentText = isEmptyString(shareTitle) ? NSLocalizedString(@"真房源，好中介，快流通", nil) : shareTitle;
        manager.weixinMomentText = weixinMomentText;
    }

    NSDictionary * templatesDict = [SSCommonLogic getShareTemplate];
    NSString * sinaWeiboTemplate = [templatesDict objectForKey:@"sina_weibo"];
    NSString * sinaWeiboMessage = [SSCommonLogic parseShareContentWithTemplate:sinaWeiboTemplate title:shareTitle shareURLString:shareURL];
    
    manager.sinaWeiboText = sinaWeiboMessage;
    
    NSString * qqZoneTemplate = [templatesDict objectForKey:@"qzone_sns"];
    NSString * qqZoneMessage = [SSCommonLogic parseShareContentWithTemplate:qqZoneTemplate title:shareTitle shareURLString:shareURL];
    
    manager.qqZoneText = qqZoneMessage;
    //        王大可说分享到空间 标题为 爱看
    manager.qqZoneTitleText = NSLocalizedString(@"好多房", nil);
    
    NSString * systemTemplate = [templatesDict objectForKey:@"system"];
    NSString * smsText = [SSCommonLogic parseShareContentWithTemplate:systemTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@", shareURL, kShareChannelFromSMS]];
    manager.messageText = smsText;
    
    NSString * mailSubject = [NSString stringWithFormat:@"%@ 【%@】", [TTSandBoxHelper appDisplayName], shareTitle];
    
    NSString * mailContent = nil;
    NSString * originMailContent = [NSString stringWithFormat:@"%@", detail];
    
    if ([originMailContent length] < 10) {//正文没有下载完成时候的分享, 防止article.content为(null)
        
        //添加下载连接
        NSString * downloadStr = [NSString stringWithFormat:@"(%@ <a href=\"http://app.toutiao.com/news_article/\">%@</a>)<br></br>", NSLocalizedString(@"想看更多合你口味的内容，马上下载", nil), [TTSandBoxHelper appDisplayName]];
        mailContent = [NSString stringWithFormat:@"%@ <br></br>%@%@, <br></br>%@", shareTitle, shareURL, kShareChannelFromMail, downloadStr];
        
    }
    manager.mailBody = mailContent;
    manager.mailSubject = mailSubject;
    manager.mailData = nil;
    manager.mailBodyIsHTML = YES;
    
    //系统分享
    manager.systemShareText = shareTitle;
    manager.systemShareUrl = shareURL;
    manager.systemShareImage = manager.shareImage;
    
    NSString * facebookTemplate = [templatesDict objectForKey:@"facebook"];
    NSString * facebookShareText = [SSCommonLogic parseShareContentWithTemplate:facebookTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@", shareURL, kShareChannelFromFacebook]];
    
    manager.facebookText = facebookShareText;
    
    NSString * twitterTemplate = [templatesDict objectForKey:@"twitter"];
    NSString * twitterShareText = [SSCommonLogic parseShareContentWithTemplate:twitterTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@", shareURL, kShareChannelFromTwitter]];
    
    manager.twitterText = twitterShareText;
    
    NSString * copyShareText = [SSCommonLogic parseShareContentWithTemplate:systemTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@", shareURL, kShareChannelFromCopy]];
    
    manager.copyText = copyShareText;
    
    manager.dingtalkTitleText = manager.weixinTitleText;
    manager.dingtalkText = manager.weixinText;
    
    //视频列表页和详情页在分享面板显示举报选项
    [manager refreshActivitysWithReport:report withQQ:qq];
    NSMutableArray * activityItems = [manager defaultShareItems];
    
    return activityItems;
}

+ (nonnull NSMutableArray *)shareActivityManager:(nonnull TTActivityShareManager *)manager setWapConditionWithTitle:(nullable NSString *)title desc:(nullable NSString *)desc url:(nullable NSString *)url imageUrl:(nullable NSString *)imageUrl
{
    [manager clearCondition];
    UIImage *shareImage = [self weixinSharedImageForImageUrl:imageUrl];
    if (!shareImage) {
        shareImage = [self defaultWeixinImage];
        manager.useDefaultImage = YES;
    }
    manager.shareImage = shareImage;
    manager.shareImageURL = imageUrl;
    manager.shareToWeixinMomentOrQZoneImage = manager.shareImage;
    manager.shareURL = url;
    manager.hasImg = (manager.shareImage == nil ? NO : YES);
    
    NSString *shareTitle = nil;

    shareTitle = title;
    if (isEmptyString(shareTitle)) {
        shareTitle = NSLocalizedString(@"网页分享", nil);
    }
    
    manager.weixinTitleText = shareTitle;
    NSString *detail = desc;
    
    if (isEmptyString(detail)) {
        detail = url;
    }
    
    if (isEmptyString(detail)) {
        detail = NSLocalizedString(@"链接", nil);

    }
    manager.weixinText = detail;
    manager.weixinMomentText = isEmptyString(shareTitle)?NSLocalizedString(@"真房源，好中介，快流通", nil):shareTitle;
    manager.qqShareTitleText = shareTitle;
    manager.qqShareText = detail;
    
    NSDictionary * templatesDict = [SSCommonLogic getShareTemplate];
    NSString * sinaWeiboTemplate = [templatesDict objectForKey:@"sina_weibo"];
    NSString * sinaWeiboMessage = [SSCommonLogic parseShareContentWithTemplate:sinaWeiboTemplate title:shareTitle shareURLString:url];
    
    manager.sinaWeiboText = sinaWeiboMessage;
    
    NSString * qqZoneTemplate = [templatesDict objectForKey:@"qzone_sns"];
    NSString * qqZoneMessage = [SSCommonLogic parseShareContentWithTemplate:qqZoneTemplate title:shareTitle shareURLString:url];
    
    manager.qqZoneText = qqZoneMessage;
    //        王大可说分享到空间 标题为 爱看
    manager.qqZoneTitleText = NSLocalizedString(@"好多房", nil);
    
    NSString * questionMarkOrAmpersand = nil;
    if ([url rangeOfString:@"?"].location == NSNotFound) {
        questionMarkOrAmpersand = @"?";
    }else {
        questionMarkOrAmpersand = @"&";
    }
    
    NSString * systemTemplate = [templatesDict objectForKey:@"system"];
    NSString * smsText = [SSCommonLogic parseShareContentWithTemplate:systemTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@%@", url, questionMarkOrAmpersand, kShareChannelFromSMS]];
    manager.messageText = smsText;
    
    NSString * mailSubject = [NSString stringWithFormat:@"%@ 【%@】", [TTSandBoxHelper appDisplayName], shareTitle];
    
    NSString * mailContent = nil;
    NSString * originMailContent = [NSString stringWithFormat:@"%@", desc];
    
    if ([originMailContent length] < 10) {//正文没有下载完成时候的分享, 防止article.content为(null)
        //添加下载连接
        NSString * downloadStr = [NSString stringWithFormat:@"(%@ <a href=\"http://app.toutiao.com/news_article/\">%@</a>)<br></br>", NSLocalizedString(@"想看更多合你口味的内容，马上下载", nil), [TTSandBoxHelper appDisplayName]];
        mailContent = [NSString stringWithFormat:@"%@ <br></br>%@%@%@, <br></br>%@", shareTitle, url, questionMarkOrAmpersand, kShareChannelFromMail, downloadStr];
    }
    else {
        mailContent = [ArticleShareManager conversionMailContentToPureHTML:originMailContent shareURL:url commentCount:0];
    }
    
    manager.mailBody = mailContent;
    manager.mailSubject = mailSubject;
    manager.mailData = nil;
    manager.mailBodyIsHTML = YES;
    
    //系统分享
    manager.systemShareText = shareTitle;
    manager.systemShareUrl = url;
    manager.systemShareImage = manager.shareImage;
    
    NSString * facebookTemplate = [templatesDict objectForKey:@"facebook"];
    NSString * facebookShareText = [SSCommonLogic parseShareContentWithTemplate:facebookTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@%@", url, questionMarkOrAmpersand, kShareChannelFromFacebook]];
    
    manager.facebookText = facebookShareText;
    
    NSString * twitterTemplate = [templatesDict objectForKey:@"twitter"];
    NSString * twitterShareText = [SSCommonLogic parseShareContentWithTemplate:twitterTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@%@", url, questionMarkOrAmpersand, kShareChannelFromTwitter]];
    
    manager.twitterText = twitterShareText;
    
    NSString * copyShareText = [SSCommonLogic parseShareContentWithTemplate:systemTemplate title:shareTitle shareURLString:[NSString stringWithFormat:@"%@%@%@", url, questionMarkOrAmpersand, kShareChannelFromCopy]];
    
    manager.copyText = copyShareText;
    
    manager.dingtalkTitleText = manager.weixinTitleText;
    manager.dingtalkText = manager.weixinText;
    
//    //视频列表页和详情页在分享面板显示举报选项
    [manager refreshActivitysWithReport:NO];
    
    NSMutableArray * activityItems = [manager defaultShareItems];
    
    return activityItems;
}

@end
