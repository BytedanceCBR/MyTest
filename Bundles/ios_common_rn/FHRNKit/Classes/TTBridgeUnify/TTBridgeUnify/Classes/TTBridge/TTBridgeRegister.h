//
//  BridgeRegister.h
//  Pods
//
//  Created by renpeng on 2018/10/9.
//

#import <Foundation/Foundation.h>
#import "TTBridgeDefines.h"
#import "TTBridgePlugin.h"

extern TTBridgeName const TTDeviceSetClipboardDataBridgeName;

extern TTBridgeName const TTViewOpenBridgeName;
extern TTBridgeName const TTViewCloseBridgeName;
extern TTBridgeName const TTViewShowLoadingBridgeName;
extern TTBridgeName const TTViewHideLoadingBridgeName;
extern TTBridgeName const TTViewSetBackButtonStyleBridgeName;
extern TTBridgeName const TTViewSetStatusBarStyleBridgeName;
extern TTBridgeName const TTViewSetTitleBridgeName;
extern TTBridgeName const TTViewOnPageVisibleBridgeName;
extern TTBridgeName const TTViewOnPageInvisibleBridgeName;

extern TTBridgeName const TTMediaPlayVideoBridgeName;
extern TTBridgeName const TTMediaPlayNativeVideoBridgeName;

extern TTBridgeName const TTAppLoginBridgeName;
extern TTBridgeName const TTAppGetAppInfoBridgeName;
extern TTBridgeName const TTAppCheckLoginStatusBridgeName;
extern TTBridgeName const TTAppPayBridgeName;
extern TTBridgeName const TTAppShareBridgeName;
extern TTBridgeName const TTAppSetShareInfoBridgeName;
extern TTBridgeName const TTAppShowSharePanelBridgeName;
extern TTBridgeName const TTAppCommentBridgeName;
extern TTBridgeName const TTAppOnCommentPublishBridgeName;
extern TTBridgeName const TTAppGalleryBridgeName;
extern TTBridgeName const TTAppConfigBridgeName;
extern TTBridgeName const TTAppToastBridgeName;
extern TTBridgeName const TTAppAlertBridgeName;
extern TTBridgeName const TTAppSendLogV3BridgeName;
extern TTBridgeName const TTAppFetchBridgeName;
extern TTBridgeName const TTAppSendALogBridgeName;

extern void TTRegisterBridge(TTBridgeRegisterEngineType engineType,
                             NSString *nativeName,
                             TTBridgeName bridgeName,
                             TTBridgeAuthType authType,
                             NSArray<NSString *> *domains);

extern void TTRegisterWebViewBridge(NSString *nativeName, TTBridgeName bridgeName);

extern void TTRegisterRNBridge(NSString *nativeName, TTBridgeName bridgeName);

extern void TTRegisterAllBridge(NSString *nativeName, TTBridgeName bridgeName);

@interface TTBridgeMethodInfo : NSObject

@property (nonatomic, copy, readonly) NSDictionary<NSNumber*, NSNumber*> *authTypes;

@end

@interface TTBridgeRegister : NSObject

+ (instancetype)sharedRegister;

- (void)registerMethod:(NSString *)method
            engineType:(TTBridgeRegisterEngineType)engineType
              authType:(TTBridgeAuthType)authType
               domains:(NSArray<NSString *> *)domains;

@property (nonatomic, copy, readonly) NSDictionary<NSString*, TTBridgeMethodInfo*> *registedMethods;
@property (nonatomic, copy, readonly) NSDictionary<NSString*, NSMutableArray*> *domain2PrivateMethods;

@end


