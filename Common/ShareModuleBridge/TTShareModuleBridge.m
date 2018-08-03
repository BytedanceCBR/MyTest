//
//  TTShareModuleBridge.m
//  Article
//
//  Created by 王霖 on 6/13/16.
//
//

#import "TTShareModuleBridge.h"
#import "TTModuleBridge.h"
#import "TTActivityShareManager.h"
#import "SSActivityView.h"

#import <CommonCrypto/CommonDigest.h>
#import <TTAccountBusiness.h>
#import "TTGroupModel.h"
#import "TTShareConstants.h"
#import "HTSPanelControllerItem.h"
#import "HTSPanelController.h"
#import "TTInstallIDManager.h"


#import "UIImageAdditions.h"
#import "TTInstallIDManager.h"

@interface TTShareModuleBridge ()

@property (nonatomic, strong) TTActivityShareManager * shareManager;

@end

@implementation TTShareModuleBridge

#pragma mark - Life circle

+ (instancetype)shareInstance {
    static TTShareModuleBridge * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TTShareModuleBridge alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (TTActivityShareManager *)shareManager {
    if (_shareManager == nil) {
        _shareManager = [[TTActivityShareManager alloc] init];
    }
    return _shareManager;
}

#pragma mark - Share action

- (void)shareActionOfObject:(id)object withParams:(id)params {
    if (![params isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSDictionary * shareParams = params;
    NSString * itemID = shareParams[@"itemID"];
    NSString * title = shareParams[@"title"];
    NSString * content = shareParams[@"content"];
    NSString * originalShareUrl = nil;
    if ([shareParams[@"shareURL"] isKindOfClass:[NSString class]] && [(NSString *)shareParams[@"shareURL"] length] > 0) {
        originalShareUrl = [NSString stringWithString:shareParams[@"shareURL"]];
    }
    NSString * shareURL = [self appendCommonQueryStringForUrlString:originalShareUrl];
    UIImage * shareImage = shareParams[@"shareImage"];
    if (shareImage) {
        UIImage * videoImage = [UIImage imageNamed:@"huoshanlive"];
        CGFloat maxSize = MIN(shareImage.size.width, shareImage.size.height) / 1.5;
        videoImage = [videoImage imageScaleAspectToMaxSize:maxSize];
        shareImage = [UIImage drawImage:videoImage inImage:shareImage atPoint:CGPointMake(shareImage.size.width / 2, shareImage.size.height / 2)];
    }
//    NSString * sinaWeiboContent = shareParams[@"sinaWeiboContent"];
    NSString * copyContent = shareParams[@"copyContent"];
    UIViewController * viewController = shareParams[@"viewController"];
    if (viewController == nil) {
        viewController = [TTUIResponderHelper topmostViewController];
    }
    TTShareModuleBridgeShareType shareType = [(NSNumber *)shareParams[@"shareType"] integerValue];
    
    [self.shareManager clearCondition];
    
    self.shareManager.shareImage = shareImage;
    self.shareManager.shareToWeixinMomentOrQZoneImage = shareImage;
    self.shareManager.shareURL = shareURL;
    self.shareManager.hasImg = (self.shareManager.shareImage == nil ? NO : YES);
    self.shareManager.mediaID = itemID;
    self.shareManager.groupModel = [[TTGroupModel alloc] initWithGroupID:itemID];
    
    //微信
    self.shareManager.weixinTitleText = title;
    self.shareManager.weixinText = content;
    self.shareManager.weixinMomentText = content;
    //QQ
    self.shareManager.qqShareTitleText = title;
    self.shareManager.qqShareText = content;
    self.shareManager.qqZoneText = content;
    
    if (shareType != TTShareModuleBridgeShareTypeMore) {
        //系统分享
        self.shareManager.systemShareText = title;
        self.shareManager.systemShareUrl = shareURL;
        self.shareManager.systemShareImage = shareImage;
        //复制链接
        self.shareManager.copyText = copyContent;
    }
    
    BOOL allowReport = [shareParams[@"allowReport"] boolValue];
    BOOL isHTSVideoOrAWEMEVideo = [shareParams[@"contentType"] isEqualToString:@"shareHotsoonVideo"] || [shareParams[@"contentType"] isEqualToString:@"shareAWEMEVideo"];;
    [self.shareManager refreshActivitysWithReport:allowReport];
     //suruiqiang....
    TTActivityType activityType = TTActivityTypeNone;
    switch (shareType) {
        case TTShareModuleBridgeShareTypeDefault:
        {
            //调起头条分享面板
            NSMutableArray *items = [self.shareManager defaultShareItems];
            BOOL allowDislike = [shareParams[@"allowDislike"] boolValue];
            if (allowDislike) {
                TTActivity * dislikeActivity = [TTActivity activityOfDislike];
                [items addObject:dislikeActivity];
            }
            BOOL allowSave = [shareParams[@"allowSave"] boolValue];;
            if (allowSave) {
                TTActivity *saveVideoActivity = [TTActivity activityOfSaveVideo];
                [items addObject:saveVideoActivity];
            }
            NSArray <NSArray <HTSPanelControllerItem *> *> * panelItems =
            [self panelItemsWithActivitiesItems:items isHTSVideo:isHTSVideoOrAWEMEVideo];
            if (panelItems.count > 0) {
                HTSPanelController *panelController = [[HTSPanelController alloc] initWithItems:panelItems
                                                                                    cancelTitle:NSLocalizedString(@"取消分享", nil)
                                                                                    cancelBlock:^{
                                                                                        if (isHTSVideoOrAWEMEVideo) {
                                                                                            NSMutableDictionary *params = [NSMutableDictionary dictionary];
                                                                                            [params setValue:@(TTActivityTypeNone) forKey:@"type"];
                                                                                            [params setValue:NSLocalizedString(@"取消分享", nil) forKey:@"title"];
                                                                                            [[TTModuleBridge sharedInstance_tt] notifyListenerForKey:@"com.toutiao.shareItemAction" object:self withParams:params complete:nil];
                                                                                        }
                                                       }];
                [panelController show];
            }
        }
            return;
        case TTShareModuleBridgeShareTypeWeixinShare:
            //微信好友分享
            activityType = TTActivityTypeWeixinShare;
            break;
        case TTShareModuleBridgeShareTypeWeixinMoment:
            //微信朋友圈分享
            activityType = TTActivityTypeWeixinMoment;
            break;
        case TTShareModuleBridgeShareTypeSinaWeibo:
            //新浪微博分享
            activityType = TTActivityTypeSinaWeibo;
            break;
        case TTShareModuleBridgeShareTypeQQZone:
            //QQ空间分享
            activityType = TTActivityTypeQQZone;
            break;
        case TTShareModuleBridgeShareTypeQQShare:
            //QQ好友分享
            activityType = TTActivityTypeQQShare;
            break;
        case TTShareModuleBridgeShareTypeCopy:
            //拷贝
            activityType = TTActivityTypeCopy;
            break;
        case TTShareModuleBridgeShareTypeMore:{
            //调起头条分享面板
            NSMutableArray *items = [self.shareManager defaultShareItems];
            BOOL allowDislike = [shareParams[@"allowDislike"] boolValue];
            //dislike
            if (allowDislike) {
                TTActivity * dislikeActivity = [TTActivity activityOfDislike];
                [items addObject:dislikeActivity];
            }
            NSArray <NSArray <HTSPanelControllerItem *> *> * panelItems =
            [self panelItemsWithActivitiesItems:items isHTSVideo:isHTSVideoOrAWEMEVideo];
            if (panelItems.count > 0) {
                HTSPanelController *panelController = [[HTSPanelController alloc] initWithItems:panelItems
                                                                                    cancelTitle:NSLocalizedString(@"取消", nil)
                                                                                    cancelBlock:^{
                                                                                        if (isHTSVideoOrAWEMEVideo) {
                                                                                            NSMutableDictionary *params = [NSMutableDictionary dictionary];
                                                                                            [params setValue:@(TTActivityTypeNone) forKey:@"type"];
                                                                                            [params setValue:NSLocalizedString(@"取消", nil) forKey:@"title"];
                                                                                            [[TTModuleBridge sharedInstance_tt] notifyListenerForKey:@"com.toutiao.shareItemAction" object:self withParams:params complete:nil];
                                                                                        }
                                                                                    }];
                [panelController show];
            }
        }
        default:
            break;
    }
    if (activityType != TTActivityTypeNone) {
        [self shareByItemType:activityType withViewController:viewController isHTSVideo:NO];
    }
}

- (void)shareByItemType:(TTActivityType)itemType withViewController:(UIViewController *)viewCcontroller isHTSVideo:(BOOL)isHTSVideo {
    [self.shareManager performActivityActionByType:itemType
                                  inViewController:viewCcontroller
                                  sourceObjectType:(isHTSVideo ? TTShareSourceObjectTypeHTSVideo : TTShareSourceObjectTypeHTSLive)
                                          uniqueId:self.shareManager.mediaID
                                              adID:nil
                                          platform:(isHTSVideo ? TTSharePlatformTypeOfMain : TTSharePlatformTypeOfHTSLivePlugin)
                                        groupFlags:nil];
}

#pragma mark - Public

- (void)registerShareAction {
    __weak typeof(self) wSelf = self;
    [[TTModuleBridge sharedInstance_tt] registerAction:@"com.toutiao.shareAction"
                                             withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
                                                 [wSelf shareActionOfObject:object withParams:params];
                                                 return nil;
                                             }];
}

- (void)removeShareAction {
    [[TTModuleBridge sharedInstance_tt] removeAction:@"com.toutiao.shareAction"];
}

#pragma mark - Utils

- (NSString *)appendCommonQueryStringForUrlString:(NSString *)urlString{
    if (isEmptyString(urlString)) {
        return nil;
    }
    NSRange range = [urlString rangeOfString:@"?"];
    __block NSString * seperate = (range.location == NSNotFound) ? @"?" : @"&";
    NSMutableString * mutableUrlString = [NSMutableString stringWithString:urlString];
    
    NSMutableDictionary * queryDictionary = [NSMutableDictionary dictionary];
    [queryDictionary setValue:[TTAccountManager userID] forKey:@"share_ht_uid"];
    [queryDictionary setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"did"];
    
    [queryDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *stringKey = key;
        NSString *stringValue = obj;
        if (!isEmptyString(stringValue)) {
            [mutableUrlString appendFormat:@"%@%@=%@", seperate, stringKey, stringValue];
            seperate = @"&";
        }
    }];
    
    return mutableUrlString.copy;
}

- (NSArray <NSArray <HTSPanelControllerItem *> *> *)panelItemsWithActivitiesItems:(NSArray <TTActivity *> *)activiesItems isHTSVideo:(BOOL)isHTSVideo {
    NSMutableArray * sharePanelItems = @[].mutableCopy;
    NSMutableArray * toolPanelItems = @[].mutableCopy;
    for (TTActivity *activityItem in activiesItems) {
        __weak typeof(self) wSelf = self;
        HTSPanelButtonClick itemClickBlock = ^(void) {
            if (isHTSVideo) {
                //针对达人视频/火山小视频 拦截举报和dislike以及保存视频, 主端不处理
                if (activityItem.activityType != TTActivityTypeDislike &&
                    activityItem.activityType != TTActivityTypeReport &&
                    activityItem.activityType != TTActivityTypeSaveVideo) {
                    [wSelf shareByItemType:activityItem.activityType withViewController:[TTUIResponderHelper topmostViewController] isHTSVideo:isHTSVideo];
                }
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setValue:@(activityItem.activityType) forKey:@"type"];
                [params setValue:activityItem.activityTitle forKey:@"title"];
                [[TTModuleBridge sharedInstance_tt] notifyListenerForKey:@"com.toutiao.shareItemAction" object:self withParams:params complete:nil];
            }
            else {
                [wSelf shareByItemType:activityItem.activityType withViewController:[TTUIResponderHelper topmostViewController] isHTSVideo:isHTSVideo];
            }
        };
        HTSPanelControllerItem *panelItem = [[HTSPanelControllerItem alloc] initWithAvatar:nil
                                                                                     title:activityItem.activityTitle
                                                                                     block:itemClickBlock];
        panelItem.iconImage = [UIImage themedImageNamed:activityItem.activityImageName];
        panelItem.itemType = HTSPanelControllerItemTypeIcon;
        if (activityItem.activityType == TTActivityTypeCopy ||
            activityItem.activityType == TTActivityTypeDislike ||
            activityItem.activityType == TTActivityTypeReport ||
            activityItem.activityType == TTActivityTypeSystem ||
            activityItem.activityType == TTActivityTypeSaveVideo) {
            [toolPanelItems addObject:panelItem];
        }else {
            [sharePanelItems addObject:panelItem];
        }
    }
    NSMutableArray <NSArray <HTSPanelControllerItem *> *> * panelItems = [NSMutableArray array];
    if (sharePanelItems.count > 0) {
        [panelItems addObject:sharePanelItems.copy];
    }
    if (toolPanelItems.count > 0) {
        [panelItems addObject:toolPanelItems.copy];
    }
    return panelItems.copy;
}
@end
