//
//  FHTrackingManager.m
//  FHHouseBase
//
//  Created by wangxinyu on 2020/12/3.
//

#import "FHTrackingManager.h"
#import "UIColor+Theme.h"
#import <BDInstall/BDInstall.h>
#import <BDInstallPopup/BDInstallPopup.h>
#import <BDInstallPopup/BDInstallPopupURLChina.h>
#import <BDTrackerProtocol/BDTrackerProtocol.h>

@interface FHTrackingManager ()

@property (nonatomic, assign) BOOL hasTriedInHomePage;  ///是否已经在首页尝试过弹窗

@end

@implementation FHTrackingManager

+ (instancetype)sharedInstance {
    static FHTrackingManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FHTrackingManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self registerNotification];
    }
    
    return self;
}

/**
 iOS 14 IDFA授权弹窗
 */
- (void)showTrackingServicePopupInHomePage:(BOOL)isInHomePage {
    self.hasTriedInHomePage = isInHomePage;
    NSString *deviceID = BDTrackerProtocol.deviceID;
    NSString *installID = BDTrackerProtocol.installID;
    if (!deviceID || !installID || !deviceID.length || !installID.length) {
        return;
    }
    
    BDInstallPopupConfig *config = [BDInstallPopupConfig new];
    config.confirmBtnColor = [UIColor themeOrange1];
    config.useCoverView = NO;
    config.confirmBtnText = @"确认";
    config.cancelBtnText = @"取消";
    config.title = @"优化信息服务";
    config.appID = 1370;
    config.appName = @"幸福里";
    config.service = [BDInstallPopupURLChina class];
    config.iid = ^NSString * _Nonnull{
        return installID;
    };
    config.did = ^NSString * _Nonnull{
        return deviceID;
    };
    [[BDInstallPopup sharedInstance] popupIfNeedWithConfig:config completion:nil];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceDidregistered:)
                                                 name:BDInstallDeviceDidRegisteredNotification
                                               object:nil];
}

- (void)deviceDidregistered:(NSNotification *)notification {
    /**
     这个通知是异步的，如果已经尝试在首页弹出过还能运行到这里，说明在
     首页没能弹出成功（可能是因为did没准备好），那么在这里再次尝试弹窗
     */
    if (!self.hasTriedInHomePage) {
        return;
    }
    
    [self showTrackingServicePopupInHomePage:NO];
}

@end
