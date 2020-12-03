//
//  FHTrackingManager.m
//  FHHouseBase
//
//  Created by wangxinyu on 2020/12/3.
//

#import "FHTrackingManager.h"
#import <BDInstall/BDInstall.h>
#import <BDInstallPopup/BDInstallPopup.h>
#import <BDInstallPopup/BDInstallPopupURLChina.h>
#import <BDTrackerProtocol/BDTrackerProtocol.h>

@interface FHTrackingManager ()

@property (nonatomic, assign) BOOL hasShown;

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
- (void)showTrackingServicePopup {
    NSString *deviceID = BDTrackerProtocol.deviceID;
    NSString *installID = BDTrackerProtocol.installID;
    if (!deviceID || !installID || !deviceID.length || !installID.length) {
        return;
    }
    
    BDInstallPopupConfig *config = [BDInstallPopupConfig new];
    config.confirmBtnText = @"确认";
    config.cancelBtnText = @"取消";
    config.title = @"权限申请";
    config.appID = 1370;
    config.service = [BDInstallPopupURLChina class];
    config.iid = ^NSString * _Nonnull{
        return installID;
    };
    config.did = ^NSString * _Nonnull{
        return deviceID;
    };
    [[BDInstallPopup sharedInstance] popupIfNeedWithConfig:config completion:nil];
    self.hasShown = YES;
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceDidregistered:)
                                                 name:BDInstallDeviceDidRegisteredNotification
                                               object:nil];
}

- (void)deviceDidregistered:(NSNotification *)notification {
    /**
     这个通知是异步的，如果已经弹出过一次弹窗了就不要重复展示了
     */
    if (self.hasShown) {
        return;
    }
    
    [self showTrackingServicePopup];
}

@end
