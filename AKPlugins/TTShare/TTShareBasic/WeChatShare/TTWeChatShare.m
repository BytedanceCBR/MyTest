//
//  TTWeChatShare.m
//  Article
//
//  Created by 王霖 on 15/9/21.
//
//

#import "TTWeChatShare.h"
#import "TTShareImageUtil.h"
//#define kWeixinExtShareLocalUrlKey  @"localUrl"

NSString * const TTWeChatShareErrorDomain = @"TTWeChatShareErrorDomain";

static NSString * const kTTWeChatShareErrorDescriptionWeChatNotInstall = @"WeChat is not installed.";
static NSString * const kTTWeChatShareErrorDescriptionWeChatNotSupportAPI = @"WeChat do not support api.";
static NSString * const kTTWeChatShareErrorDescriptionExceedMaxImageSize = @"(Image/Preview image) excced max size.";
static NSString * const kTTWeChatShareErrorDescriptionExceedMaxTextSize = @"Text excced max length.";
static NSString * const kTTWeChatShareErrorDescriptionContentInvalid = @"Content is invalid.";
static NSString * const kTTWeChatShareErrorDescriptionCancel = @"User cancel.";
static NSString * const kTTWeChatShareErrorDescriptionOther = @"Some error occurs.";

#define kTTWeChatShareMaxPreviewImageSize    (1024 * 32)
#define kTTWeChatShareMaxImageSize   (1024 * 1024 * 10)
#define kTTWeChatShareMaxTextSize    (1024 * 10)

@interface TTWeChatShare()<WXApiDelegate>

@property (nonatomic, strong)NSDictionary *callbackUserInfo;

@end

@implementation TTWeChatShare

static TTWeChatShare *shareInstance;
static NSString *wechatShareAppID = nil;

+ (instancetype)sharedWeChatShare {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[TTWeChatShare alloc] init];
    });
    return shareInstance;
}

+ (void)registerWithID:(NSString*)appID {
    wechatShareAppID = appID;
}

+ (void)registerWechatShareIDIfNeeded {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [WXApi registerApp:wechatShareAppID universalLink:@" https://i.haoduofangs.com/"];
    });
}

- (BOOL)isAvailable {
    return [self isAvailableWithNotifyError:NO];
}

- (NSString *)currentVersion {
    [[self class] registerWechatShareIDIfNeeded];
    return [WXApi getApiVersion];
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    [[self class] registerWechatShareIDIfNeeded];
    return [WXApi handleOpenURL:url delegate:[TTWeChatShare sharedWeChatShare]];
}

- (void)sendTextToScene:(enum WXScene)scene withText:(NSString *)text customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
    [[self class] registerWechatShareIDIfNeeded];
    
    self.callbackUserInfo = customCallbackUserInfo;
    
    if(![self isAvailableWithNotifyError:YES]) {
        return;
    }
    
    if (text.length == 0) {
        NSError * error = [NSError errorWithDomain:TTWeChatShareErrorDomain
                                              code:kTTWeChatShareErrorTypeInvalidContent
                                          userInfo:@{NSLocalizedDescriptionKey: kTTWeChatShareErrorDescriptionContentInvalid}];
        [self callbackError:error];
        return;
    }
    
    while([text dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > kTTWeChatShareMaxTextSize) {
        NSUInteger toIndex = text.length / 2;
        if (toIndex > 0 && toIndex < text.length) {
            text = [text substringToIndex:toIndex];
        }else {
            break;
        }
    }
    
    if ([text dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > kTTWeChatShareMaxTextSize) {
        NSError * error = [NSError errorWithDomain:TTWeChatShareErrorDomain
                                              code:kTTWeChatShareErrorTypeExceedMaxTextSize
                                          userInfo:@{NSLocalizedDescriptionKey: kTTWeChatShareErrorDescriptionExceedMaxTextSize}];
        [self callbackError:error];
        return;
    }
    
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
    req.bText = YES;
    req.text = text;
    req.scene = scene;
    
    [WXApi sendReq:req completion:nil];
}

- (void)sendImageToScene:(enum WXScene)scene withImage:(UIImage *)image customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
    [[self class] registerWechatShareIDIfNeeded];
    
    self.callbackUserInfo = customCallbackUserInfo;
    
    if(![self isAvailableWithNotifyError:YES]) {
        return;
    }
    
    WXMediaMessage * message = [WXMediaMessage message];
    message.thumbData = [TTShareImageUtil compressImage:image withLimitLength:kTTWeChatShareMaxPreviewImageSize];
    
    WXImageObject * ext = [WXImageObject object];
    ext.imageData = [TTShareImageUtil compressImage:image withLimitLength:kTTWeChatShareMaxImageSize];

    message.mediaObject = ext;
    
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    [WXApi sendReq:req completion:nil];
}

- (void)sendWebpageToScene:(enum WXScene)scene withWebpageURL:(NSString *)webpageURL thumbnailImage:(UIImage *)thumbnailImage title:(NSString *)title description:(NSString *)description customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
    [[self class] registerWechatShareIDIfNeeded];
    
    self.callbackUserInfo = customCallbackUserInfo;
    
    if(![self isAvailableWithNotifyError:YES]) {
        return;
    }
    
    // 微信朋友圈发送链接时如果image为空将会导致发送失败，并且不提示回调信息给我们，因此在发送链接的时候强制要求外部判断image不为空
    if ((scene == WXSceneTimeline && !thumbnailImage)) {
        NSError * error = [NSError errorWithDomain:TTWeChatShareErrorDomain
                                              code:kTTWeChatShareErrorTypeInvalidContent
                                          userInfo:@{NSLocalizedDescriptionKey: kTTWeChatShareErrorDescriptionContentInvalid}];
        [self callbackError:error];
        return;
    }
    
    while ([title dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > 512) {
        NSUInteger toIndex = title.length / 2;
        if (toIndex > 0 && toIndex < title.length) {
            title = [title substringToIndex:toIndex];
        }else {
            break;
        }
    }
    
    while ([description dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > 1024) {
        NSUInteger toIndex = description.length / 2;
        if (toIndex > 0 && toIndex < description.length) {
            description = [description substringToIndex:toIndex];
        }else {
            break;
        }
    }
    
    if ([title dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > 512 || [description dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > 1024 || [webpageURL dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > kTTWeChatShareMaxTextSize) {
        NSError * error = [NSError errorWithDomain:TTWeChatShareErrorDomain
                                              code:kTTWeChatShareErrorTypeInvalidContent
                                          userInfo:@{NSLocalizedDescriptionKey: kTTWeChatShareErrorDescriptionContentInvalid}];
        [self callbackError:error];
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.thumbData = [TTShareImageUtil compressImage:thumbnailImage withLimitLength:kTTWeChatShareMaxPreviewImageSize];
    
    WXWebpageObject *webPageObject = [WXWebpageObject object];
    webPageObject.webpageUrl = webpageURL;
    message.mediaObject = webPageObject;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req completion:nil];
}

- (void)sendWebpageWithMiniProgramShareInScene:(enum WXScene)scene withParameterDict:(NSDictionary *)dict WebpageURL:(NSString *)webpageURL thumbnailImage:(UIImage *)thumbnailImage title:(NSString *)title description:(NSString *)description customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo{
    [[self class] registerWechatShareIDIfNeeded];
    
    self.callbackUserInfo = customCallbackUserInfo;
    
    if(![self isAvailableWithNotifyError:YES]) {
        return;
    }
    
    // 微信朋友圈发送链接时如果image为空将会导致发送失败，并且不提示回调信息给我们，因此在发送链接的时候强制要求外部判断image不为空
    if (scene == WXSceneTimeline || scene == WXSceneFavorite) {
        NSError * error = [NSError errorWithDomain:TTWeChatShareErrorDomain
                                              code:kTTWeChatShareErrorTypeNotSupportAPI
                                          userInfo:@{NSLocalizedDescriptionKey: kTTWeChatShareErrorDescriptionContentInvalid}];
        [self callbackError:error];
        return;
    }
    
    while ([title dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > 512) {
        NSUInteger toIndex = title.length / 2;
        if (toIndex > 0 && toIndex < title.length) {
            title = [title substringToIndex:toIndex];
        }else {
            break;
        }
    }
    
    while ([description dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > 1024) {
        NSUInteger toIndex = description.length / 2;
        if (toIndex > 0 && toIndex < description.length) {
            description = [description substringToIndex:toIndex];
        }else {
            break;
        }
    }
    
    if ([title dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > 512 || [description dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > 1024 || [webpageURL dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > kTTWeChatShareMaxTextSize) {
        NSError * error = [NSError errorWithDomain:TTWeChatShareErrorDomain
                                              code:kTTWeChatShareErrorTypeInvalidContent
                                          userInfo:@{NSLocalizedDescriptionKey: kTTWeChatShareErrorDescriptionContentInvalid}];
        [self callbackError:error];
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.thumbData = [TTShareImageUtil compressImage:thumbnailImage withLimitLength:kTTWeChatShareMaxPreviewImageSize];
    
    NSString *defaultPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"SSCommonMiniProgramPathTemplate"];
    NSMutableString *path = [[NSMutableString alloc] initWithString:defaultPath];
    NSString *miniID = [[NSUserDefaults standardUserDefaults] stringForKey:@"SSCommonMiniProgramID"];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSString class]]){
            [path appendString:[NSString stringWithFormat:@"&%@=%@",key,obj]];
        }
    }];
    
    WXMiniProgramObject *object = [WXMiniProgramObject object];
    object.userName = miniID;
    object.webpageUrl = webpageURL;
    object.path = path;
    
    message.mediaObject = object;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req completion:nil];
}

- (void)sendVideoToScene:(enum WXScene)scene withVideoURL:(NSString *)videoURL thumbnailImage:(UIImage*)thumbnailImage title:(NSString*)title description:(NSString*)description customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
    [[self class] registerWechatShareIDIfNeeded];
    
    self.callbackUserInfo = customCallbackUserInfo;
    
    if(![self isAvailableWithNotifyError:YES]) {
        return;
    }
    
    while ([title dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > 512) {
        NSUInteger toIndex = title.length / 2;
        if (toIndex > 0 && toIndex < title.length) {
            title = [title substringToIndex:toIndex];
        }else {
            break;
        }
    }
    
    while ([description dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > 1024) {
        NSUInteger toIndex = description.length / 2;
        if (toIndex > 0 && toIndex < description.length) {
            description = [description substringToIndex:toIndex];
        }else {
            break;
        }
    }
    
    if ([title dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > 512 || [description dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > 1024 || [videoURL dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length > kTTWeChatShareMaxTextSize) {
        NSError * error = [NSError errorWithDomain:TTWeChatShareErrorDomain
                                              code:kTTWeChatShareErrorTypeInvalidContent
                                          userInfo:@{NSLocalizedDescriptionKey: kTTWeChatShareErrorDescriptionContentInvalid}];
        [self callbackError:error];
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.thumbData = [TTShareImageUtil compressImage:thumbnailImage withLimitLength:kTTWeChatShareMaxPreviewImageSize];
    
    WXVideoObject *ext = [WXVideoObject object];
    ext.videoUrl = videoURL;
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req completion:nil];
}

-(void)onResp:(BaseResp*)resp {
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if(resp.errCode != 0) {
            if(resp.errCode == WXErrCodeUserCancel) {
                NSError * error = [NSError errorWithDomain:TTWeChatShareErrorDomain
                                                      code:kTTWeChatShareErrorTypeCancel
                                                  userInfo:@{NSLocalizedDescriptionKey: kTTWeChatShareErrorDescriptionCancel}];
                [self callbackError:error];
            }else {
                NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
                if (resp.errStr.length > 0) {
                    [userInfo setValue:resp.errStr forKey:NSLocalizedDescriptionKey];
                }else {
                    [userInfo setValue:kTTWeChatShareErrorDescriptionOther forKey:NSLocalizedDescriptionKey];
                }
                NSError * error = [NSError errorWithDomain:TTWeChatShareErrorDomain
                                                      code:kTTWeChatShareErrorTypeOther
                                                  userInfo:userInfo.copy];
                [self callbackError:error];
            }
        }else {
            if(_delegate && [_delegate respondsToSelector:@selector(weChatShare:sharedWithError:customCallbackUserInfo:)]) {
                [_delegate weChatShare:self sharedWithError:nil customCallbackUserInfo:_callbackUserInfo];
            }
        }
    }else if ([resp isKindOfClass:[PayResp class]]) {
        if (_payDelegate && [_payDelegate respondsToSelector:@selector(weChatShare:payResponse:)]) {
            [_payDelegate weChatShare:self payResponse:(PayResp *)resp];
        }
    }
}

-(void)onReq:(BaseReq*)req {
    if (_requestDelegate && [_requestDelegate respondsToSelector:@selector(weChatShare:receiveRequest:)]) {
        [_requestDelegate weChatShare:self receiveRequest:req];
    }
}

#pragma mark - Error

- (BOOL)isAvailableWithNotifyError:(BOOL)notifyError {
    [[self class] registerWechatShareIDIfNeeded];
    
    if(![WXApi isWXAppInstalled]) {
        if (notifyError) {
            NSError * error = [NSError errorWithDomain:TTWeChatShareErrorDomain
                                                  code:kTTWeChatShareErrorTypeNotInstalled
                                              userInfo:@{NSLocalizedDescriptionKey: kTTWeChatShareErrorDescriptionWeChatNotInstall}];
            [self callbackError:error];
        }
        return NO;
    }
    else if(![WXApi isWXAppSupportApi]){
        if (notifyError) {
            NSError * error = [NSError errorWithDomain:TTWeChatShareErrorDomain
                                                  code:kTTWeChatShareErrorTypeNotSupportAPI
                                              userInfo:@{NSLocalizedDescriptionKey: kTTWeChatShareErrorDescriptionWeChatNotSupportAPI}];
            [self callbackError:error];
        }
        return NO;
    }
    return YES;
}

- (void)callbackError:(NSError *)error {
    if (_delegate && [_delegate respondsToSelector:@selector(weChatShare:sharedWithError:customCallbackUserInfo:)]) {
        [_delegate weChatShare:self sharedWithError:error customCallbackUserInfo:_callbackUserInfo];
    }
}

#pragma mark - Util

@end
