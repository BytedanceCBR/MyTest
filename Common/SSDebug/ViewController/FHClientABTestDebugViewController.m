//
//  FHClientABTestDebugViewController.m
//  Article
//
//  Created by 张静 on 2019/3/20.
//
#if INHOUSE

#import "FHClientABTestDebugViewController.h"
#import "TTSettingsManager+SaveSettings.h"
#import <BDABTestSDK/BDABTestManager.h>
#import <BDABTestSDK/BDABKeychainStorage.h>
#import <TTThemedAlertController.h>
#import <FHCommonUI/ToastManager.h>

@interface FHClientABTestDebugViewController ()

@end

@implementation FHClientABTestDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *dataSource = [NSMutableArray array];
    
    NSMutableArray *itemArray = [NSMutableArray array];
    STTableViewCellItem *item_39 = [[STTableViewCellItem alloc] initWithTitle:@"查看命中的实验组和配置参数,vid不对请忽略" target:self action:@selector(_showABTestInfo)];
    item_39.switchStyle = NO;
    item_39.checked = [SSCommonLogic isThirdTabHTSEnabled];
    [itemArray addObject:item_39];
    
    STTableViewCellItem *item_40 = [[STTableViewCellItem alloc] initWithTitle:@"清空该设备的实验数据" target:self action:@selector(_showResetABStorage)];
    item_40.switchStyle = NO;
    item_40.checked = [SSCommonLogic isForthTabHTSEnabled];
    [itemArray addObject:item_40];
    STTableViewSectionItem *section = [[STTableViewSectionItem alloc] initWithSectionTitle:@"AB实验-vid暂时需要对比Libra和app_log核对" items:itemArray];
    [dataSource addObject:section];

    self.dataSource = dataSource;
}

- (void)_showABTestInfo
{
    UIViewController *clientABVC = [BDABTestManager panelViewController];
    [self presentViewController:clientABVC animated:YES completion:nil];
}

- (void)_showResetABStorage
{
    TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"清空确认", nil) message:@"确认要清空该设备的实验数据么？清空后重启APP时会按照新设备重新命中实验组" preferredType:TTThemedAlertControllerTypeAlert];
    WeakSelf;
    [alertVC addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
    }];
    [alertVC addActionWithTitle:NSLocalizedString(@"确认", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        StrongSelf;
        [self _resetABStorage];
    }];
    [alertVC showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
}

- (void)_resetABStorage
{
    if ([self removeAll]) {
        [[ToastManager manager]showToast:@"清空成功，请重启APP"];
    }else{
        [[ToastManager manager]showToast:@"清空失败"];
    }
}
- (BOOL)removeAll {
    
    BDABKeychainStorage *keychainManager = [[BDABKeychainStorage alloc] initWithServiceName:@"ByteDanceClientABTestKeychain" useUserDefaultCache:YES];
    [keychainManager setObject:nil forKey:@"kBDClientABStorageManagerFeatureUserDefaultKey"];
    [keychainManager setObject:nil forKey:@"kBDClientABStorageManagerServerSettingFeatureUserDefaultKey"];
    [keychainManager setObject:nil forKey:@"kBDClientABManagerAppVersionUserDefaultKey"];
    [keychainManager setObject:nil forKey:@"kBDClientABTestRandomNumbersKey"];

    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:6];
    [query setObject:(__bridge id)(kSecClassGenericPassword) forKey:(__bridge id<NSCopying>)(kSecClass)];
    [query setObject:@"ByteDanceClientABTestKeychain" forKey:(__bridge id<NSCopying>)(kSecAttrService)];
    //    [query setObject:(__bridge id)(kSecMatchLimitAll) forKey:(__bridge id<NSCopying>)(kSecMatchLimit)];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    BOOL result = (status == errSecSuccess || status == errSecItemNotFound);
    return result;
}
@end

#endif
