//
//  WDDetailViewModel.m
//  Article
//
//  Created by 冯靖君 on 16/4/8.
//
//  详情页正文部分VM

#import "WDDetailViewModel.h"
#import "WDAnswerEntity.h"
#import "WDDetailModel.h"
#import "WDDefines.h"
#import "WDParseHelper.h"
#import "WDNetWorkPluginManager.h"
#import "WDSettingHelper.h"
#import "WDPersonModel.h"
#import "WDCommonLogic.h"

#import "ArticleJSManager.h"
#import <TTUserSettingsManager+FontSettings.h>
#import "YSWebView.h"
#import "TTDeviceHelper.h"
#import "ArticleJSManager.h"
#import "NetworkUtilities.h"
#import "TTThemeManager.h"
#import "TTStringHelper.h"
#import "TTUserSettings/TTUserSettingsManager+NetworkTraffic.h"
#import <TTAccountBusiness.h>
#import <TTBaseLib/JSONAdditions.h>
#import <TTDetailWebviewGIFManager.h>

#define kJsMetaImageOriginKey       @"origin"
#define kJsMetaImageThumbKey        @"thumb"
#define kJsMetaImageNoneKey         @"none"
#define kJsMetaImageAllKey          @"all"
#define kShowOriginImageHost        @"origin_image"         //单张显示大图
#define kShowFullImageHost          @"full_image"           //进入图片浏览页面
#define kCacheSizeForAllTypeThumb   @"thumb"

@interface WDDetailViewModel ()

@property (nonatomic, strong) WDDetailModel *detailModel;

@end

@implementation WDDetailViewModel

#if INHOUSE
+ (void)load {
    NSString *feArticleTestHost = [[NSUserDefaults standardUserDefaults] valueForKey:@"FEArticleTestHost"];
    if (!feArticleTestHost) {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"FEArticleTestHost"];
    }
}
#endif

- (void)dealloc
{
}

- (instancetype)initWithDetailModel:(WDDetailModel *)detailModel
{
    self = [super init];
    if (self) {
        _detailModel = detailModel;
        [self p_updateModelWithData:detailModel.answerEntity.detailWendaExtra];
    }
    return self;
}


- (void)p_updateModelWithData:(NSDictionary *)wendaExtDict
{
    [self.detailModel.answerEntity updateWithAnsid:self.detailModel.answerEntity.ansid Content:self.detailModel.answerEntity.content];
    if (wendaExtDict) {
        [self.detailModel updateDetailModelWithExtraData:wendaExtDict];
    }
}

#pragma mark - public

- (void)tt_setArticleHasRead
{
    if (self.detailModel.answerEntity.hasRead) {
        return;
    }
    self.detailModel.answerEntity.hasRead = YES;
    [self.detailModel.answerEntity save];
}

- (BOOL)isAuthor
{
    return [[self.person userID] isEqualToString:[TTAccountManager userID]];
}

- (WDPersonModel *)person
{
    return self.detailModel.answerEntity.user;
}


- (CGFloat)tt_getLastContentOffsetY
{
    return [self.detailModel.answerEntity.articlePosition floatValue];
}

- (void)tt_setContentOffsetY:(CGFloat)offsetY
{
    if (offsetY < 0) {
        return;
    }
    
    self.detailModel.answerEntity.articlePosition = @(offsetY);
    [self.detailModel.answerEntity save];
}
@end

@implementation WDDetailViewModel(WDDetailNativeContentCategory)

- (NSString *)tt_nativeContentHTMLForWebView:(UIView *)webView
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
    int gifPlayInNative = 2;
    int showLargeGifIcon = 0;
    
    NSMutableString *head = [NSMutableString stringWithFormat:
                             @"<html><head>"
                             @"<style type=\"text/css\">"
                             @".i-holder{background:url(%@) #ccc no-repeat center center;}"
                             @"</style>"
                             @"<meta name=\"apple-mobile-web-app-capable\" content=\"yes\" />"
                             @"<meta name=\"network_available\" content=\"\" />"
                             @"<meta name=\"show_video\" content=\"%d\" />"
                             @"<meta name=\"show_avatar\" content=\"%d\"/>"
                             @"<meta name=\"offset_height\" content=\"%d\"/>"
                             @"<meta name=\"lazy_load\" content=\"%d\"/>"
                             @"<meta name=\"gif_play_in_native\" content=\"%d\"/>"
                             @"<meta name=\"show_large_gif_icon\" content=\"%d\"/>"
                             @"<meta charset=\"utf-8\">",
                             @"loading.png",
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
        NSMutableString *widthStyle = [NSMutableString stringWithFormat:@"<style>html,body{ width:%ipx;  overflow: hidden}</style>", (int)(webView.width)];
        [head appendString:widthStyle];
    }
    [head appendString:@"</head>"];
    
    NSMutableString *content = [NSMutableString stringWithString:head];
    NSString *articleContent = isEmptyString(self.detailModel.answerEntity.content) ? @"" : self.detailModel.answerEntity.content;
    
    NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
    
    //为了让加载html的时候就可以直接显示夜间模式， 防止刚进入详情页会白一下
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        [content appendFormat:@"<body class=\"font_%@\">%@", fontSizeType, articleContent];
    }
    else {
        [content appendFormat:@"<body class=\"night font_%@\">%@", fontSizeType, articleContent];
    }
    
    //服务端控制详情页ui设置参数
    NSDictionary *detailUICustomStyleDictionary = [self savedDetailViewUISettingInfoDict];
    if ([detailUICustomStyleDictionary isKindOfClass:[NSDictionary class]] && [detailUICustomStyleDictionary count] > 0) {
        NSString* json = [detailUICustomStyleDictionary tt_JSONRepresentation];
        [content appendFormat:@"<script>window.custom_style = %@</script>", json];
    }
    
    //h5_extra
    NSMutableDictionary *h5Extra;
    if (!SSIsEmptyDictionary(self.detailModel.answerEntity.h5Extra)) {
        h5Extra = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.answerEntity.h5Extra];
    } else {
        h5Extra = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    
    
    NSMutableDictionary *h5SettingsDict = @{}.mutableCopy;
    //先读取本地settings下发的透传字段h5_settings
    NSDictionary* localSettings = [WDCommonLogic fetchH5SettingsForAuthor];
    if (localSettings.count > 0) {
        [h5SettingsDict setValuesForKeysWithDictionary:localSettings];
    }
    //再读区info接口回来的数据
    NSDictionary *h5Settings = [h5Extra tt_dictionaryValueForKey:@"h5_settings"];
    if (h5Settings) {
        [h5SettingsDict setValuesForKeysWithDictionary:h5Settings];
    }
    //头条认证展现需要透传
    NSDictionary* verifyInfoSettings = [WDCommonLogic userVerifyConfigs];
    if (verifyInfoSettings) {
        [h5SettingsDict setValue:[WDCommonLogic userVerifyConfigs] forKey:@"user_verify_info_conf"];
    }
    
    //详情页gif是否使用native方式播放
    [h5SettingsDict setValue:@([TTDetailWebviewGIFManager isDetailViewGifNativeEnabled]) forKey:@"is_use_native_play_gif"];
    if (h5SettingsDict.count > 0) { // 无字段，添加
        [h5Extra setValue:[h5SettingsDict copy] forKey:@"h5_settings"];
    }
    
    [h5Extra setValue:@YES forKey:@"is_lite"];
    
    NSString *json = [h5Extra tt_JSONRepresentation];
    [content appendFormat:@"<script>window.h5_extra = %@</script>", json];
    
    // wenda_extra
    if ([self.detailModel.answerEntity.detailWendaExtra isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *wendaExtra = [self.detailModel.answerEntity.detailWendaExtra mutableCopy];
        
        [wendaExtra setValue:self.detailModel.enterFrom
                      forKey:kWDEnterFromKey];
        [wendaExtra setValue:self.detailModel.parentEnterFrom
                      forKey:kWDParentEnterFromKey];
        if (![[WDSettingHelper sharedInstance_tt] isQuestionRewardUserViewShow]) {
            // 红包分成把开关透传给前端
            [wendaExtra setValue:@(1) forKey:@"disable_profit"];
        }
        
        [wendaExtra setValue:self.detailModel.answerTips forKey:@"answer_tips"];
        
        [wendaExtra setValue:[self.detailModel listSchema] forKey:@"list_schema"];
        wendaExtra[kWDApiVersion] = WD_API_VERSION;
        wendaExtra[@"showMode"] = @([[WDSettingHelper sharedInstance_tt] wdDetailShowMode]);
        wendaExtra[kWDDetailNeedReturnKey] = @([self.detailModel needReturn]);
        wendaExtra[@"answer_detail_type"] = @(1); // 干掉了Web的详情页头部，都是Native的
        wendaExtra[kWDDetailShowReport] = @(self.detailModel.relatedReportStyle);
        [wendaExtra setValue:@(self.detailModel.answerEntity.userLike) forKey:@"is_following"];
        NSString *json = [wendaExtra tt_JSONRepresentation];
        [content appendFormat:@"<script>window.wenda_extra = %@</script>", json];
    }
    
    // lib.js & iphone.js
    [content appendFormat:@"<script src=\"%@/js/lib.js\"></script>", subRoot];
    [content appendFormat:@"<script src=\"%@/js/iphone.js\"></script>", subRoot];
    
    [content appendString:@"</body></html>"];
    return content;
}

- (NSURL *)tt_nativeContentFilePath
{
    JSWDMetaInsertImageType insertImageType = [self tt_loadImageTypeWithImageMode:self.detailModel.answerEntity.imageMode forseShowOriginImg:NO];
    NSString *autoLoad = [self tt_loadImageJSStringKeyForType:insertImageType];
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

- (JSWDMetaInsertImageType)tt_loadImageTypeWithImageMode:(NSNumber *)imageMode
                                    forseShowOriginImg:(BOOL)forseShowOriginImg
{
    TTNetworkTrafficSetting settingType = [TTUserSettingsManager networkTrafficSetting];
    BOOL showOriginForce = forseShowOriginImg || TTNetworkWifiConnected() || (settingType == TTNetworkTrafficOptimum) || [imageMode integerValue] == 1;
    if (showOriginForce) {
        return JSWDMetaInsertImageTypeOrigin;
    }
    else if (settingType == TTNetworkTrafficMedium) {
        return JSWDMetaInsertImageTypeThumb;
    }
    else {
        return JSWDMetaInsertImageTypeNone;
    }
}

- (NSString *)tt_loadImageJSStringKeyForType:(JSWDMetaInsertImageType)type
{
    NSString * keyString = nil;
    switch (type) {
        case JSWDMetaInsertImageTypeThumb:
            keyString = kJsMetaImageThumbKey;
            break;
        case JSWDMetaInsertImageTypeOrigin:
            keyString = kJsMetaImageOriginKey;
            break;
        default:
            keyString = kJsMetaImageNoneKey;
            break;
    }
    return keyString;
}

- (NSDictionary *)savedDetailViewUISettingInfoDict
{
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"kDetailViewUserDefaultKey"];
    return dict;
}

@end

