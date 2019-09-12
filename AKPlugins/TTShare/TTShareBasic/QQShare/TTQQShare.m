//
//  TTQQShare.m
//  Article
//
//  Created by 王霖 on 15/9/21.
//
//

#import "TTQQShare.h"
#import "TTShareImageUtil.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/sdkdef.h>

NSString * const TTQQShareErrorDomain = @"TTQQShareErrorDomain";

static NSString * const kTTQQShareErrorDescriptionQQNotInstall = @"QQ is not installed.";
static NSString * const kTTQQShareErrorDescriptionQQNotSupportAPI = @"QQ do not support api.";
static NSString * const kTTQQShareErrorDescriptionExceedMaxImageSize = @"(Image/Preview image) excced max size.";
static NSString * const kTTQQShareErrorDescriptionExceedMaxTextLength = @"Text excced max length.";
static NSString * const kTTQQShareErrorDescriptionContentInvalid = @"Content is invalid.";
static NSString * const kTTQQShareErrorDescriptionCancel = @"User cancel.";
static NSString * const kTTQQShareErrorDescriptionOther = @"Some error occurs.";

#define kTTQQShareMaxImageSize   (1024 * 1024 * 5)
#define kTTQQShareMaxPreviewImageSize   (1024 * 1024 * 1)

@interface TTQQShare()<QQApiInterfaceDelegate>

@property(nonatomic, strong)TencentOAuth *tencentOauth;
@property(nonatomic, strong)NSArray *permissions;
@property(nonatomic, copy)NSDictionary *callbackUserInfo;

@end

@implementation TTQQShare

static TTQQShare *shareInstance;
static NSString *qqShareAppID = nil;

+ (instancetype)sharedQQShare {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[TTQQShare alloc] init];
    });
    return shareInstance;
}

+ (void)registerWithID:(NSString *)appID {
    qqShareAppID = appID;
}

+ (void)registerQQShareIfNeeded {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TTQQShare *qqShare = [TTQQShare sharedQQShare];
        qqShare.tencentOauth = [[TencentOAuth alloc] initWithAppId:qqShareAppID andDelegate:nil];
    });
}

- (BOOL)isAvailable {
    [[self class] registerQQShareIfNeeded];
    return [self isAvailableWithNotifyError:NO];
}

- (NSString *)currentVersion {
    return [TencentOAuth sdkVersion];
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    [self registerQQShareIfNeeded];
    return [QQApiInterface handleOpenURL:url delegate:[TTQQShare sharedQQShare]];
}

#pragma mark - 分享到QQ好友

- (void)sendText:(NSString *)text withCustomCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
    [[self class] registerQQShareIfNeeded];
    
    self.callbackUserInfo = customCallbackUserInfo;
    if (![self isAvailableWithNotifyError:YES]) {
        return;
    }
    
    if (text.length == 0) {
        NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                              code:kTTQQShareErrorTypeInvalidContent
                                          userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionContentInvalid}];
        [self callbackError:error];
        return;
    }
    
    if (text.length > 1536) {
        text = [text substringToIndex:1536];
    }
    
    QQApiTextObject * textObject = [QQApiTextObject objectWithText:text];
    SendMessageToQQReq * req = [SendMessageToQQReq reqWithContent:textObject];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}

- (void)sendImageWithImageData:(NSData *)imageData
            thumbnailImageData:(NSData *)thumbnailImageData
                         title:(NSString *)title
                   description:(NSString *)description
        customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
    [[self class] registerQQShareIfNeeded];
    
    self.callbackUserInfo = customCallbackUserInfo;
    
    if (![self isAvailableWithNotifyError:YES]) {
        return;
    }
    
    if (imageData.length > kTTQQShareMaxImageSize || thumbnailImageData.length > kTTQQShareMaxPreviewImageSize) {
        NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                              code:kTTQQShareErrorTypeExceedMaxImageSize
                                          userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionExceedMaxImageSize}];
        [self callbackError:error];
        return;
    }
    
    if (title.length > 128) {
        title = [title substringToIndex:128];
    }
    
    if (description.length > 512) {
        description = [description substringToIndex:512];
    }
    
    if (imageData == nil) {
        NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                              code:kTTQQShareErrorTypeInvalidContent
                                          userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionContentInvalid}];
        [self callbackError:error];
        return;
    }
    
    QQApiImageObject *imageObject = [QQApiImageObject objectWithData:imageData
                                                    previewImageData:thumbnailImageData
                                                               title:title
                                                         description:description];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imageObject];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}

- (void)sendImage:(UIImage *)image
        withTitle:(NSString *)title
      description:(NSString *)description
customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
    NSData *imageData = [TTShareImageUtil compressImage:image withLimitLength:kTTQQShareMaxImageSize];
    NSData *previewImageData = [TTShareImageUtil compressImage:image withLimitLength:kTTQQShareMaxPreviewImageSize];
    [self sendImageWithImageData:imageData
              thumbnailImageData:previewImageData
                           title:title
                     description:description
          customCallbackUserInfo:customCallbackUserInfo];
    
}

- (void)sendNewsWithURL:(NSString *)url
         thumbnailImage:(UIImage *)thumbnailImage
      thumbnailImageURL:(NSString *)thumbnailImageURL
                  title:(NSString *)title
            description:(NSString *)description
 customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
    [[self class] registerQQShareIfNeeded];
    
    self.callbackUserInfo = customCallbackUserInfo;
    
    if (![self isAvailableWithNotifyError:YES]) {
        return;
    }
    
    if (url.length > 512 || thumbnailImageURL.length > 512) {
        NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                              code:kTTQQShareErrorTypeInvalidContent
                                          userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionContentInvalid}];
        [self callbackError:error];
        return;
    }
    
    if (title.length > 128) {
        title = [title substringToIndex:128];
    }
    
    if (description.length > 512) {
        description = [description substringToIndex:512];
    }
    
    NSURL * nUrl = [self URLWithURLString:url];
    NSURL * pImageUrl = [self URLWithURLString:thumbnailImageURL];
    
    if (nUrl == nil) {
        NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                              code:kTTQQShareErrorTypeInvalidContent
                                          userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionContentInvalid}];
        [self callbackError:error];
        return;
    }
    
   
    if (pImageUrl != nil) {
        [TTShareImageUtil downloadImageDataWithURL:pImageUrl limitLength:kTTQQShareMaxPreviewImageSize completion:^(NSData *imageData, NSError *error) {
            QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:nUrl
                                                                title:title
                                                          description:description
                                                     previewImageData:imageData];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
            QQApiSendResultCode sent = [QQApiInterface sendReq:req];
            [self handleSendResult:sent];
        }];
    }else {
         QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:nUrl
                                           title:title
                                     description:description
                                previewImageData:[TTShareImageUtil compressImage:thumbnailImage withLimitLength:kTTQQShareMaxPreviewImageSize]];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        [self handleSendResult:sent];
    }
}

#pragma mark - 分享到QQ空间

- (void)sendImageToQZoneWithImage:(UIImage *)image title:(NSString *)title customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
    [[self class] registerQQShareIfNeeded];
    
    NSData *imageData = [TTShareImageUtil compressImage:image withLimitLength:kTTQQShareMaxImageSize];
    NSData *previewImageData = [TTShareImageUtil compressImage:image withLimitLength:kTTQQShareMaxPreviewImageSize];
    [self sendImageToQZoneWithImageData:imageData thumbnailImageData:previewImageData title:title customCallbackUserInfo:customCallbackUserInfo];;
}

- (void)sendImageToQZoneWithImageData:(NSData *)imageData thumbnailImageData:(NSData *)thumbnailImageData title:(NSString *)title customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
    [[self class] registerQQShareIfNeeded];
    
    self.callbackUserInfo = customCallbackUserInfo;
    
    if (![self isAvailableWithNotifyError:YES]) {
        return;
    }
    
    if (imageData.length > kTTQQShareMaxImageSize || thumbnailImageData.length > kTTQQShareMaxPreviewImageSize) {
        NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                              code:kTTQQShareErrorTypeExceedMaxImageSize
                                          userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionExceedMaxImageSize}];
        [self callbackError:error];
        return;
    }
    
    if (title.length > 128) {
        title = [title substringToIndex:128];
    }
    
    if (imageData == nil) {
        NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                              code:kTTQQShareErrorTypeInvalidContent
                                          userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionContentInvalid}];
        [self callbackError:error];
        return;
    }
    
    QQApiImageArrayForQZoneObject *imgObj = [QQApiImageArrayForQZoneObject objectWithimageDataArray:@[imageData] title:title extMap:nil];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:imgObj];
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    [self handleSendResult:sent];
}

- (void)sendNewsToQZoneWithURL:(NSString *)url
                thumbnailImage:(UIImage *)thumbnailImage
             thumbnailImageURL:(NSString *)thumbnailImageURL
                         title:(NSString *)title
                   description:(NSString *)description
        customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
    [[self class] registerQQShareIfNeeded];
    
    self.callbackUserInfo = customCallbackUserInfo;
    
    if (![self isAvailableWithNotifyError:YES]) {
        return;
    }
    
    if (url.length > 512 || thumbnailImageURL.length > 512) {
        NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                              code:kTTQQShareErrorTypeInvalidContent
                                          userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionContentInvalid}];
        [self callbackError:error];
        return;
    }
    
    if (title.length > 128) {
        title = [title substringToIndex:128];
    }
    
    if (description.length > 512) {
        description = [description substringToIndex:512];
    }
    
    NSURL * nUrl = [self URLWithURLString:url];
    NSURL * pImageUrl = [self URLWithURLString:thumbnailImageURL];
    
    if (nUrl == nil) {
        NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                              code:kTTQQShareErrorTypeInvalidContent
                                          userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionContentInvalid}];
        [self callbackError:error];
        return;
    }
    
    if (pImageUrl != nil) {
        [TTShareImageUtil downloadImageDataWithURL:pImageUrl limitLength:kTTQQShareMaxPreviewImageSize completion:^(NSData *imageData, NSError *error) {
            QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:nUrl
                                                                title:title
                                                          description:description
                                                     previewImageData:imageData];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
            QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
            [self handleSendResult:sent];
        }];
    }else {
        QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:nUrl
                                           title:title
                                     description:description
                                previewImageData:[TTShareImageUtil compressImage:thumbnailImage withLimitLength:kTTQQShareMaxPreviewImageSize]];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
        [self handleSendResult:sent];
    }
    
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult {
    switch (sendResult) {
        case EQQAPISENDSUCESS:
        case EQQAPIAPPSHAREASYNC:
            //QQ请求发送成功
            break;
        case EQQAPIQQNOTINSTALLED: {
            NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                                  code:kTTQQShareErrorTypeNotInstalled
                                              userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionQQNotInstall}];
            [self callbackError:error];
        }
            break;
        case EQQAPIQQNOTSUPPORTAPI: {
            NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                                  code:kTTQQShareErrorTypeNotSupportAPI
                                              userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionQQNotSupportAPI}];
            [self callbackError:error];
        }
            break;
        case EQQAPIMESSAGETYPEINVALID: {
            NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                                  code:kTTQQShareErrorTypeInvalidContent
                                              userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionContentInvalid}];
            [self callbackError:error];
        }
            break;
        case EQQAPIMESSAGECONTENTNULL: {
            NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                                  code:kTTQQShareErrorTypeInvalidContent
                                              userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionContentInvalid}];
            [self callbackError:error];
        }
            break;
        case EQQAPIMESSAGECONTENTINVALID: {
            NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                                  code:kTTQQShareErrorTypeInvalidContent
                                              userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionContentInvalid}];
            [self callbackError:error];
        }
            break;
        case EQQAPIAPPNOTREGISTED:
        case EQQAPIQQNOTSUPPORTAPI_WITH_ERRORSHOW:
        case EQQAPISENDFAILD: {
            NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                                  code:kTTQQShareErrorTypeOther
                                              userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionContentInvalid}];
            [self callbackError:error];
        }
            break;
        case EQQAPIQZONENOTSUPPORTTEXT: {
            //qzone分享不支持text类型分享
            NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                                  code:kTTQQShareErrorTypeInvalidContent
                                              userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionOther}];
            [self callbackError:error];
        }
            break;
        case EQQAPIQZONENOTSUPPORTIMAGE: {
            //qzone分享不支持image类型分享
            NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                                  code:kTTQQShareErrorTypeInvalidContent
                                              userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionContentInvalid}];
            [self callbackError:error];
        }
            break;
        default:
            break;
    }
}

#pragma mark -- QQApiInterfaceDelegate

- (void)onReq:(QQBaseReq *)req {
    if (_requestDelegate && [_requestDelegate respondsToSelector:@selector(qqShare:receiveRequest:)]) {
        [_requestDelegate qqShare:self receiveRequest:req];
    }
}

- (void)onResp:(QQBaseResp *)resp {
    switch (resp.type) {
        case ESENDMESSAGETOQQRESPTYPE: {
            SendMessageToQQResp* sendResp = (SendMessageToQQResp*)resp;
            if ([_delegate respondsToSelector:@selector(qqShare:sharedWithError:customCallbackUserInfo:)]) {
                NSError * error = nil;
                if (![resp.result isEqualToString:@"0"]) {
                    NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
                    if (sendResp.errorDescription.length > 0) {
                        [userInfo setValue:[sendResp errorDescription] forKey:NSLocalizedDescriptionKey];
                    }else {
                        [userInfo setValue:kTTQQShareErrorDescriptionOther forKey:NSLocalizedDescriptionKey];
                    }
                    error = [NSError errorWithDomain:TTQQShareErrorDomain
                                                code:kTTQQShareErrorTypeOther
                                            userInfo:userInfo.copy];
                }
                [_delegate qqShare:self sharedWithError:error customCallbackUserInfo:_callbackUserInfo];
            }
        }
            break;
        default:
            break;
    }
}

- (void)isOnlineResponse:(NSDictionary *)response {}

#pragma mark - Error

- (BOOL)isAvailableWithNotifyError:(BOOL)notifyError {
    if(![QQApiInterface isQQInstalled]) {
        if (notifyError) {
            NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                                  code:kTTQQShareErrorTypeNotInstalled
                                              userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionQQNotInstall}];
            [self callbackError:error];
        }
        return NO;
    }
    
    if(![QQApiInterface isQQSupportApi]) {
        if (notifyError) {
            NSError * error = [NSError errorWithDomain:TTQQShareErrorDomain
                                                  code:kTTQQShareErrorTypeNotSupportAPI
                                              userInfo:@{NSLocalizedDescriptionKey: kTTQQShareErrorDescriptionQQNotSupportAPI}];
            [self callbackError:error];
        }
        return NO;
    }
    return YES;
}

- (void)callbackError:(NSError *)error {
    if (_delegate && [_delegate respondsToSelector:@selector(qqShare:sharedWithError:customCallbackUserInfo:)]) {
        [_delegate qqShare:self sharedWithError:error customCallbackUserInfo:_callbackUserInfo];
    }
}

#pragma mark - Utilities

- (NSURL *)URLWithURLString:(NSString *)str
{
    if (str.length == 0) {
        return nil;
    }
    NSString * fixStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL * u = [NSURL URLWithString:fixStr];
    if (!u) {
        u = [NSURL URLWithString:[fixStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return u;
}

@end
