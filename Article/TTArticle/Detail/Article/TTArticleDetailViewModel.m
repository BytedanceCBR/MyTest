//
//  TTArticleDetailViewModel.m
//  Article
//
//  Created by 冯靖君 on 16/4/8.
//
//  详情页正文部分VM

#import "TTArticleDetailViewModel.h"
#import "Article.h"
#import "ArticleJSManager.h"
#import "SSUserSettingManager.h"
#import "NewsDetailLogicManager.h"
#import "PGCAccountManager.h"
#import "YSWebView.h"
#import <TTUserSettingsManager+FontSettings.h>
#import "ExploreEntryManager.h"
#import "SSWebViewUtil.h"

#import "TTUISettingHelper.h"
#import "CommonURLSetting.h"
#import "SSWebViewUtil.h"
#import "TTNovelRecordManager.h"
#import "TTDeviceHelper.h"
#import "TTThemeManager.h"
#import "TTStringHelper.h"
#import "TTUserSettings/TTUserSettingsManager+NetworkTraffic.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/UIDevice+TTAdditions.h>
#import <TTBaseLib/JSONAdditions.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import <TTABManagerUtil.h>
#import <AKWebViewBundlePlugin/TTDetailWebviewGIFManager.h>

@interface TTArticleDetailViewModel ()

@property(nonatomic, strong)TTDetailModel *detailModel;
@property(nonatomic, assign)BOOL webTransformed;

@end

@implementation TTArticleDetailViewModel

#if INHOUSE
+ (void)load {
    NSString *feArticleTestHost = [[NSUserDefaults standardUserDefaults] valueForKey:@"FEArticleTestHost"];
    if (!feArticleTestHost) {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"FEArticleTestHost"];
    }
}
#endif

- (instancetype)initWithDetailModel:(TTDetailModel *)detailModel
{
    self = [super init];
    if (self) {
        _detailModel = detailModel;
        _webTransformed = NO;
    }
    return self;
}

#pragma mark - public

- (TTDetailArchType)tt_articleDetailType
{
    if (([self.detailModel.fitArticle.groupFlags longLongValue] & kArticleGroupFlagsDetailTypeSimple) > 0) {
        return TTDetailArchTypeSimple;
    }
    else if (([self.detailModel.fitArticle.groupFlags longLongValue] & kArticleGroupFlagsDetailTypeNoToolBar) > 0) {
        if ([TTDeviceHelper isPadDevice]) {
            return TTDetailArchTypeNoComment;
        }
        else {
            return TTDetailArchTypeNoToolBar;
        }
    }
    else if (([self.detailModel.fitArticle.groupFlags longLongValue] & kArticleGroupFlagsDetailTypeNoComment) > 0) {
        return TTDetailArchTypeNoComment;
    }
    else {
        return TTDetailArchTypeNormal;
    }
}

/**
 *  added 5.4:当前文章是否展示位转码页。因为增加了导流页超时保护机制，增加articleLoadedTimeoutNative的判断
 */
- (void)tt_setWebHasBeenTransformed:(BOOL)transformed
{
    _webTransformed = transformed;
}

- (BOOL)tt_webHasBeenTransformed
{
    return _webTransformed;
}

- (TTArticleDetailLoadedContentType)tt_articleDetailLoadedContentType
{
    if ([self p_currentArticleType] == ArticleTypeNativeContent) {
        return TTArticleDetailLoadedContentTypeNative;
    }
    else {
        if (self.webTransformed) {
            return TTArticleDetailLoadedContentTypeNative;
        }
    }
    return TTArticleDetailLoadedContentTypeWeb;
}

//判断是否为非合作导流页
- (BOOL)tt_isArticleNonCooperationWebContent
{
    if ([self p_currentArticleType] == ArticleTypeWebContent && self.detailModel.article.articleSubType != ArticleSubTypeCooperationWap) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)tt_setArticleHasRead
{
    if ([self.detailModel.article.hasRead boolValue]) {
        return;
    }
    self.detailModel.article.hasRead = @(YES);
    [self.detailModel.article save];
    //[[SSModelManager sharedManager] save:nil];
}

- (BOOL)tt_detailNeedLoadJS
{
    return ![self tt_isArticleNonCooperationWebContent];
}

- (TTDetailNatantStyle)tt_natantStyleFromNatantLevel
{
    if (!self.detailModel.article) {
        return TTDetailNatantStyleDisabled;
    }
    
    //无评论,无toolbar,精简模式下 不显示浮层 @zengruihuan
    if (self.tt_articleDetailType == TTDetailArchTypeNoComment || self.tt_articleDetailType == TTDetailArchTypeNoToolBar || self.tt_articleDetailType == TTDetailArchTypeSimple) {
        return TTDetailNatantStyleDisabled;
    }
    
    switch ([self.detailModel.article.natantLevel integerValue]) {
        case ArticleNatantLevelDefault:
        {
            if ([self.detailModel.adID longLongValue] != 0 || ([self.detailModel.article.groupFlags longLongValue] & kArticleGroupFlagsClientEscape) > 0) {
                return TTDetailNatantStyleOnlyClick;
            }
            else {
                return TTDetailNatantStyleAppend;
            }
        }
            break;
        case ArticleNatantLevelClose:
        {
            return TTDetailNatantStyleDisabled;
        }
            break;
        case ArticleNatantLevelOpen:
        {
            return TTDetailNatantStyleAppend;
        }
            break;
        case ArticleNatantLevelHalfOpen:
        {
            return TTDetailNatantStyleInsert;
        }
            break;
        case ArticleNatantLevelHalfClose:
        {
            return TTDetailNatantStyleOnlyClick;
        }
            break;
        default:
            break;
    }
    return TTDetailNatantStyleDisabled;
}

- (CGFloat)tt_getLastContentOffsetY {
    return [self.detailModel.article.articlePosition floatValue];
}

- (void)tt_setContentOffsetY:(CGFloat)offsetY {
    if (offsetY < 0) {
        return;
    }
    
    if (self.detailModel.article.novelData) {
        [TTNovelRecordManager setLastestReadChapter:self.detailModel.article.itemID inBook:self.detailModel.article.novelData[@"book_id"]];
    }
    self.detailModel.article.articlePosition = @(offsetY);
    [self.detailModel.article save];
    //[[SSModelManager sharedManager] save:nil];
}
#pragma mark - private

- (ArticleType)p_currentArticleType
{
    if (!self.detailModel.article.managedObjectContext) {
        return ArticleTypeNativeContent;
    }
    return self.detailModel.article.articleType;
}

- (NSString *)p_webContentArticleLoadURLString
{
    NSString * webURLString = self.detailModel.article.articleURLString;
    
    //处理web图集
    if ([self.detailModel.article isImageSubject] && !isEmptyString(webURLString)) {
        
        NSMutableString * tmpWebURLString = [NSMutableString stringWithString:webURLString];
        
        BOOL hasHash = YES;
        if ([tmpWebURLString rangeOfString:@"#"].location == NSNotFound) {
            hasHash = NO;
        }
        if (hasHash) {
            [tmpWebURLString appendString:@"&support_gallery=false"];
        }
        else {
            [tmpWebURLString appendString:@"#support_gallery=false"];
        }
        
        webURLString = tmpWebURLString;
    }
    
    //处理合作网站
    if (self.detailModel.article.articleSubType == ArticleSubTypeCooperationWap) {
        webURLString = [NewsDetailLogicManager changegCooperationWapURL:webURLString];
    }
    
    /**
     *  added 5.2.1
     *
     *  如果开屏广告透传了openUrl，则使用其作为落地页打开
     */
    if(!isEmptyString(self.detailModel.adOpenUrl) && !isEmptyString(self.detailModel.adID.stringValue)) {
        webURLString = self.detailModel.adOpenUrl;
    }
    
    //处理特卖的参数 5.6 add by nick yu
    if(!isEmptyString(webURLString) && [SSCommonLogic isTeMaiURL:webURLString])
    {
        NSString * query = [self.detailModel.originalSchema componentsSeparatedByString:@"?"].lastObject;
        if (query) {
            webURLString = [SSWebViewUtil jointQueryParams:query toURL:webURLString];
        }
    }
    return webURLString;
}

- (void)tt_uploadArticlePosition:(CGFloat)positionY finishBlock:(nullable TTNetworkJSONFinishBlock)finishBlock {
    NSString *itemId = self.detailModel.article.itemID;
    if (isEmptyString(itemId)) {
        return;
    }
    NSDictionary *param = @{@"item_id": itemId,
                            @"article_position": @(positionY)};
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting articlePositionUploadURLString] params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (finishBlock) {
            finishBlock(error, jsonObj);
        }
    }];
}

- (BOOL)tt_disableWKWebview {
    if ([self p_currentArticleType] == ArticleTypeWebContent) {
        return YES;
    }
    
    if ([TTDeviceHelper OSVersionNumber] < 9.f) {
        return YES;
    }
    
    return ![SSCommonLogic detailWKEnabled];
}

@end

@implementation TTArticleDetailViewModel(TTArticleDetailNativeContentCategory)

- (NSString *)tt_nativeContentHTMLForWebView:(YSWebView *)webView
{
    int showAvatarAuto = 1;
    if (!TTNetworkWifiConnected() && [TTUserSettingsManager networkTrafficSetting] == TTNetworkTrafficSave) {
        showAvatarAuto = 0;
    }
    
    int lazyLoadBufferOffset = webView.height;
    lazyLoadBufferOffset = MAX(320, lazyLoadBufferOffset);
    lazyLoadBufferOffset = MIN(768, lazyLoadBufferOffset);
    
    /*
     0 ： 点击无效
     1 ： 仅对大图生效
     2： 对大图，小图都生效
     */
    int gifPlayInNative = [TTDeviceHelper OSVersionNumber] >= 8 ? 2 : 0;
    int showLargeGifIcon = 0;
    
    NSMutableString *head = [NSMutableString stringWithFormat:
                             @"<html><head>"
                             @"<style type=\"text/css\">"
                             @".i-holder{background:url(%@) #ccc no-repeat center center;}"
                             @"</style>"
                             @"<meta id=\"viewport\" name=\"viewport\" content=\"initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0\">"
                             @"<meta name=\"apple-mobile-web-app-capable\" content=\"yes\" />"
                             @"<meta name=\"network_available\" content=\"\" />"
                             @"<meta name=\"digg_count\" content=\"%d\" />"
                             @"<meta name=\"bury_count\" content=\"%d\" />"
                             @"<meta name=\"user_digg\" content=\"%d\" />"
                             @"<meta name=\"user_bury\" content=\"%d\" />"
                             @"<meta name=\"show_video\" content=\"%d\" />"
                             @"<meta name=\"show_avatar\" content=\"%d\"/>"
                             @"<meta name=\"offset_height\" content=\"%d\"/>"
                             @"<meta name=\"lazy_load\" content=\"%d\"/>"
                             @"<meta name=\"gif_play_in_native\" content=\"%d\"/>"
                             @"<meta name=\"show_large_gif_icon\" content=\"%d\"/>"
                             @"<meta charset=\"utf-8\">",
                             @"loading.png",
                             self.detailModel.article.diggCount,
                             self.detailModel.article.buryCount,
                             self.detailModel.article.userDigg,
                             self.detailModel.article.userBury,
                             TTNetworkWifiConnected(),
                             showAvatarAuto,
                             lazyLoadBufferOffset,
                             !TTNetworkWifiConnected(),
                             gifPlayInNative,
                             showLargeGifIcon];
    
    
    NSString *subRoot = [NSString stringWithFormat:@"./%@", kV55Folder];
    
#if INHOUSE
    NSString *feArticleTestHost = [[NSUserDefaults standardUserDefaults] valueForKey:@"FEArticleTestHost"];
    if (!isEmptyString(feArticleTestHost)) {
        subRoot = [NSString stringWithFormat:@"%@/%@", feArticleTestHost, kV55Folder];
    }
#endif
    
    [head appendFormat:@"<link type=\"text/css\" rel=\"stylesheet\" href=\"%@/css/iphone.css\">", subRoot];
    
    if (![TTDeviceHelper isPadDevice]) {
        NSMutableString *widthStyle = [NSMutableString stringWithFormat:@"<style>html,body{ width:%ipx;  overflow: hidden} body{-webkit-transition: opacity %@s ease-out; transition: opacity %@s ease-out;}</style>", (int)SSWidth(webView), @(0.25), @(0.25)];
        [head appendString:widthStyle];
    }
    [head appendString:@"</head>"];
    
    NSMutableString *content = [NSMutableString stringWithString:head];
    NSString *articleContent = isEmptyString(self.detailModel.article.detail.content) ? @"" : self.detailModel.article.detail.content;
    
    NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
    //为了让加载html的时候就可以直接显示夜间模式， 防止刚进入详情页会白一下
    BOOL disableOpacityAnimation = [[UIDevice currentDevice] isPoorPerformanceDevice] || [SSCommonLogic detailSharedWebViewEnabled];
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        [content appendFormat:@"<body class=\"%@ font_%@\">%@", disableOpacityAnimation? @"": @"opacity", fontSizeType, articleContent];
    }
    else {
        [content appendFormat:@"<body class=\"%@ night font_%@\">%@", disableOpacityAnimation? @"": @"opacity", fontSizeType, articleContent];
    }
    
    [content appendFormat:@"<script>window.h5_extra = %@</script>", [[self tt_h5ExtraDictWithArticle:self.detailModel.article] tt_JSONRepresentation]];
    
    //服务端控制详情页ui设置参数
    NSDictionary *detailUICustomStyleDictionary = [[TTUISettingHelper sharedInstance_tt] detailViewUISettingsDictionary];
    if ([detailUICustomStyleDictionary isKindOfClass:[NSDictionary class]] && [detailUICustomStyleDictionary count] > 0) {
        NSString* json = [detailUICustomStyleDictionary tt_JSONRepresentation];
        [content appendFormat:@"<script>window.custom_style = %@</script>", json];
    }
    // 推荐/转载评论列表
    if ([self.detailModel.article.zzComments isKindOfClass:[NSArray class]]) {
        if (self.detailModel.article.zzComments.count > 0) {
            NSString *json = [self.detailModel.article.zzComments tt_JSONRepresentation];
            [content appendFormat:@"<script>window.zz_comments = %@</script>", json];
        }
    }

    // lib.js & iphone.js
    [content appendFormat:@"<script src=\"%@/js/lib.js\"></script>", subRoot];
    [content appendFormat:@"<script src=\"%@/js/iphone.js\"></script>", subRoot];
   
    [content appendString:@"</body></html>"];
    return content;
}

- (NSString *)tt_sharedHTMLContentWithArticle:(Article *)article {
    //  \"转成 \\"
    NSString *content = article.detail.content;
    if (isEmptyString(content)) {
        return nil;
    }
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@[content] options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if (jsonStr.length <= 4) {
        return nil;
    }
    
    content = [jsonStr substringWithRange:NSMakeRange(2, jsonStr.length - 4)];
    
    return content;
}

+ (NSString *)tt_sharedHTMLTemplate {
    NSString *subRoot = [NSString stringWithFormat:@"./%@", kV60Folder];
    
#if INHOUSE
    NSString *feArticleTestHost = [[NSUserDefaults standardUserDefaults] valueForKey:@"FEArticleTestHost"];
    if (!isEmptyString(feArticleTestHost)) {
        subRoot = [NSString stringWithFormat:@"%@/%@", feArticleTestHost, kV60Folder];
    }
#endif

    NSString *template = [NSString stringWithFormat:
    @"<!DOCTYPE html>"
    @"<html>"
      @"<head>"
        @"<meta charset=\"utf-8\">"
        @"<meta name=\"viewport\" content=\"initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no\">"
        @"<link type=\"text/css\" rel=\"stylesheet\" href=\"%@/css/iphone.css\">"
      @"</head>"
      @"<body class=\"font_m\">"
        @"<header></header>"
        @"<article></article>"
        @"<footer></footer>"
        @"<script src=\"%@/js/lib.js\"></script>"
        @"<script src=\"%@/js/iphone.js\"></script>"
      @"</body>"
    @"</html>",subRoot, subRoot, subRoot];
    return template;
}

+ (NSURL *)tt_sharedHTMLFilePath {
    NSString *filePath;
    if ([[ArticleJSManager shareInstance] shouldUseJSFromWebWithSubRootPath:kV60Folder]) {
        filePath = [[ArticleJSManager shareInstance] packageFolderPath];
        filePath = [filePath stringByAppendingString:@"/"];
        filePath = [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        filePath = [@"file://" stringByAppendingString:filePath];
    } else {
        filePath = [[[NSBundle mainBundle] bundleURL] absoluteString];
        filePath = [filePath stringByAppendingFormat:@"%@/",kIOSAssetFolderName];
    }

    NSURL * bURL = [TTStringHelper URLWithURLString:filePath];
    
    return bURL;
}

- (NSString *)tt_sharedWebViewExtraJSONString {
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    Article *article = self.detailModel.article;
    
    //服务端控制详情页ui设置参数
    [extra setValue:({
        NSDictionary *detailUICustomStyleDictionary = [[TTUISettingHelper sharedInstance_tt] detailViewUISettingsDictionary];
        SSIsEmptyDictionary(detailUICustomStyleDictionary)? nil: detailUICustomStyleDictionary;
    }) forKey:@"custom_style"];
    
    // 推荐/转载评论列表
    [extra setValue:({
        SSIsEmptyArray(article.zzComments)? nil: article.zzComments;
    }) forKey:@"zz_comments"];
    
    // h5_extra
    [extra setValue:[self tt_h5ExtraDictWithArticle:self.detailModel.article] forKey:@"h5_extra"];
    
    return [extra tt_JSONRepresentation];
}

- (NSURL *)tt_nativeContentFilePath
{
    JSMetaInsertImageType insertImageType = [TTDetailWebContainerDefine tt_loadImageTypeWithImageMode:self.detailModel.article.imageMode forseShowOriginImg:NO];
    NSString *autoLoad = [TTDetailWebContainerDefine tt_loadImageJSStringKeyForType:insertImageType];
    NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
    NSString *filePath;
    if ([[ArticleJSManager shareInstance] shouldUseJSFromWebWithSubRootPath:kV55Folder]) {
        filePath = [[ArticleJSManager shareInstance] packageFolderPath];
        filePath = [filePath stringByAppendingString:@"/"];
        filePath = [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        filePath = [@"file://" stringByAppendingString:filePath];
    } else {
        filePath = [[[NSBundle mainBundle] bundleURL] absoluteString];
        filePath = [filePath stringByAppendingFormat:@"%@/",kIOSAssetFolderName];
    }
    
    filePath = [NSString stringWithFormat:@"%@#tt_image=%@", filePath, autoLoad];
    
    filePath = [NSString stringWithFormat:@"%@&tt_font=%@", filePath, fontSizeType];
    
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    filePath = [NSString stringWithFormat:@"%@&tt_daymode=%i", filePath, isDayModel ? 1 : 0];
    
    NSURL * bURL = [TTStringHelper URLWithURLString:filePath];
    
    return bURL;
}

- (NSDictionary *)tt_h5ExtraDictWithArticle:(Article *)article {
    NSMutableDictionary *h5Extra = [[NSMutableDictionary alloc] init];
    
    if (!SSIsEmptyDictionary(article.h5Extra)) {
        [h5Extra addEntriesFromDictionary:article.h5Extra];
    }
        
        //图集
    if ([article isImageSubject]) {
        [h5Extra setValue:@(YES) forKey:@"is_gallery"];
        if (![h5Extra objectForKey:@"title"]) {
            [h5Extra setValue:article.title forKey:@"title"];
        }
    }
        
    NSString *mediaId = [article.mediaInfo tt_stringValueForKey:@"media_id"];
    if (isEmptyString(mediaId)) {
        mediaId = [[article.h5Extra tt_dictionaryValueForKey:@"media"] tt_stringValueForKey:@"id"];
    }
        
        // 订阅状态
    if (![h5Extra objectForKey:@"is_subscribed"]) {
        BOOL isSubscribed = [article.isSubscribe boolValue];
        if (!isEmptyString(mediaId)) {
            ExploreEntry *item = [[ExploreEntryManager sharedManager] fetchEntyWithMediaID:mediaId];
            if (item) {
                isSubscribed = [item.subscribed boolValue];
            }
        }
        [h5Extra setValue:@(isSubscribed) forKey:@"is_subscribed"];
    }
        
        // 作者
    if (![h5Extra objectForKey:@"is_author"]) {
        BOOL isAuthor = NO;
        if (!isEmptyString(mediaId)) {
            PGCAccount *account = [[PGCAccountManager shareManager] currentLoginPGCAccount];
            if ([account.mediaID isEqualToString:mediaId]) {
                isAuthor = YES;
            }
        }
        [h5Extra setValue:@(isAuthor) forKey:@"is_author"];
    }
        
        //小说
    if (!SSIsEmptyDictionary(article.novelData)) {
        [h5Extra setValue:article.novelData forKey:@"novel_data"];
    }
        
        //ab_client
    if (![h5Extra objectForKey:@"ab_client"]) {
        [h5Extra setValue:[TTABManagerUtil ABTestClient] forKey:@"ab_client"];
    }
        
        //头条号强化
    if (![h5Extra objectForKey:@"h5_settings"]) {
        NSDictionary *h5Settings = [SSCommonLogic fetchH5SettingsForAuthor];
        NSMutableDictionary *h5SettingsDict = [NSMutableDictionary dictionaryWithDictionary:h5Settings];
        [h5SettingsDict setValue:@NO forKey:@"is_liteapp"];

        //头条认证展现需要透传
        [h5SettingsDict setValue:[SSCommonLogic userVerifyConfigs] forKey:@"user_verify_info_conf"];
        
        //详情页gif是否使用native方式播放
        [h5SettingsDict setValue:@([TTDetailWebviewGIFManager isDetailViewGifNativeEnabled]) forKey:@"is_use_native_play_gif"];
        [h5Extra setValue:[h5SettingsDict copy] forKey:@"h5_settings"];
    }
        
    if (!h5Extra[@"font_size"]) {
        [h5Extra setValue:[TTUserSettingsManager settedFontShortString] forKey:@"font_size"];
    }
        
    if (!h5Extra[@"image_type"]) {
        JSMetaInsertImageType insertImageType = [TTDetailWebContainerDefine tt_loadImageTypeWithImageMode:self.detailModel.article.imageMode forseShowOriginImg:NO];
            
        [h5Extra setValue:[TTDetailWebContainerDefine tt_loadImageJSStringKeyForType:insertImageType] forKey:@"image_type"];
    }
        
    if (!h5Extra[@"is_daymode"]) {
        [h5Extra setValue:@([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) forKey:@"is_daymode"];
    }
        
    if (!h5Extra[@"use_lazyload"]) {
        [h5Extra setValue:@(!TTNetworkWifiConnected()) forKey:@"use_lazyload"];
    }
    
    if ([self tt_webHasBeenTransformed]) {
        //导流页增加订阅按钮
        [h5Extra setValue:@(self.tt_articleDetailLoadedContentType == TTArticleDetailLoadedContentTypeNative?YES:NO) forKey:@"hideFollowButton"];
    }
    
    if (!isEmptyString(self.detailModel.categoryID)) {
        [h5Extra setValue:self.detailModel.categoryID forKey:@"category_name"];
    }
    
    if (self.detailModel.logPb) {
        [h5Extra setValue:self.detailModel.logPb forKey:@"log_pb"];
        
    }
    
    if (article.payStatus.count) {
        [h5Extra setValue:article.payStatus forKey:@"pay_status"];
    } else {
        [h5Extra setValue:@{@"status": @"-1"} forKey:@"pay_status"];
    }
    // f100 去掉关注按钮
    [h5Extra setValue:@YES forKey:@"hideFollowButton"];

    [h5Extra setValue:@YES forKey:@"is_lite"];

    return h5Extra;
}

- (void)tt_nativeContentFilePathWithWebView:(YSWebView *)webview callback:(TTArticleDetailViewModelLoadHTMLFinishCallback)callback {
    JSMetaInsertImageType insertImageType = [TTDetailWebContainerDefine tt_loadImageTypeWithImageMode:self.detailModel.article.imageMode forseShowOriginImg:NO];
    NSString *autoLoad = [TTDetailWebContainerDefine tt_loadImageJSStringKeyForType:insertImageType];
    NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    
    NSString *htmlStr = [self tt_nativeContentHTMLForWebView:webview];
    NSString *htmlPathStr = [[[ArticleJSManager shareInstance] packageFolderPath] stringByAppendingPathComponent:@"article.html"];
    NSURL *htmlPath = [NSURL URLWithString:[@"file://" stringByAppendingFormat:@"%@#tt_image=%@&tt_font=%@&tt_daymode=%i", htmlPathStr, autoLoad, fontSizeType, isDayModel ? 1 : 0]];
    [[ArticleJSManager shareInstance] startLoadJSResourcesIfNeed:^(NSString *path, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSError *htmlError;
            [htmlStr writeToURL:htmlPath atomically:YES encoding:NSUTF8StringEncoding error:&htmlError];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(error? nil: htmlPath);
                }
            });
        });
    }];
}

@end

@implementation TTArticleDetailViewModel (TTArticleDetailWebContentCategory)

- (nullable NSURLRequest *)tt_requstForWebContentArticle
{
    return [self tt_requstForWebContentArticleForURLString:@""];
}

- (nullable NSURLRequest *)tt_requstForWebContentArticleForURLString:(NSString *)urlString
{
    if ([self p_currentArticleType] != ArticleTypeWebContent) {
        return nil;
    }
    NSString *webURLString = [self p_webContentArticleLoadURLString];
    NSURL *webURL = [TTStringHelper URLWithURLString:webURLString];
    NSDictionary *wapHeaders = self.detailModel.article.wapHeaders;
    
    NSMutableURLRequest * urlRequest = nil;
    if (TTNetworkConnected()) {
        urlRequest = (NSMutableURLRequest*)[SSWebViewUtil requestWithURL:webURL httpHeaderDict:wapHeaders];
    }
    else {
        urlRequest = (NSMutableURLRequest*)[SSWebViewUtil requestWithURL:webURL httpHeaderDict:wapHeaders cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    }
    
    return urlRequest;
}

@end
