//
//  TTDeviceHelper.m
//  Pods
//
//  Created by zhaoqin on 8/11/16.
//
//

#import "TTDeviceHelper.h"
#import "OpenUDID.h"
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <sys/xattr.h>
#include <net/if.h>
#include <net/if_dl.h>

static TTDeviceMode tt_deviceMode;

@import AdSupport;

@implementation TTDeviceHelper

+ (NSString*)platformName {
    NSString *result = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"ipad" : @"iphone";
    return result;
}

+ (BOOL)is480Screen {
    return [TTDeviceHelper getDeviceType] == TTDeviceMode480;
}

+ (BOOL)is568Screen {
    return [TTDeviceHelper getDeviceType] == TTDeviceMode568;
}

+ (BOOL)is667Screen {
    return [TTDeviceHelper getDeviceType] == TTDeviceMode667;
}

+ (BOOL)is736Screen {
    return [TTDeviceHelper getDeviceType] == TTDeviceMode736;
}

+ (BOOL)isIPhoneXDevice{
    return [TTDeviceHelper getDeviceType] == TTDeviceMode812 || [TTDeviceHelper getDeviceType] == TTDeviceMode896;
}

+ (BOOL)isPadDevice {
    return [TTDeviceHelper getDeviceType] == TTDeviceModePad;
}

+ (Boolean)is812Screen {
    return [TTDeviceHelper getDeviceType] == TTDeviceMode812;
}

+ (Boolean)is896Screen2X {
    CGFloat scale = [UIScreen mainScreen].scale;
    return [TTDeviceHelper getDeviceType] == TTDeviceMode896 && scale == 2.f;
}

+ (Boolean)is896Screen3X {
    CGFloat scale = [UIScreen mainScreen].scale;
    return [TTDeviceHelper getDeviceType] == TTDeviceMode896 && scale == 3.f;
}

+ (BOOL)isScreenWidthLarge320 {
    CGFloat shortSide = MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    return shortSide > 320;
}

+ (CGFloat)scaleToScreen375
{
    return [UIScreen mainScreen].bounds.size.width / 375.0f;
}

+ (BOOL)isIpadProDevice {
    CGFloat height = [UIScreen mainScreen].currentMode.size.height;
    CGFloat width = [UIScreen mainScreen].currentMode.size.width;
    BOOL isPro = (height == 2732 || width == 2732);
    return [TTDeviceHelper isPadDevice] && isPro;
}

+ (BOOL)isJailBroken {
    static BOOL s_is_jailBroken = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *filePath = @"/Applications/Cydia.app";
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            s_is_jailBroken = YES;
        }
        
        filePath = @"/private/var/lib/apt";
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            s_is_jailBroken = YES;
        }
    });
    return s_is_jailBroken;
}

+ (TTDeviceMode)getDeviceType {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([TTDeviceHelper judgePadDevice]) {
            tt_deviceMode = TTDeviceModePad;
        }
        else if ([TTDeviceHelper judge812Screen]) {
            tt_deviceMode = TTDeviceMode812;
        }else if ([TTDeviceHelper judge896Screen]) {
            tt_deviceMode = TTDeviceMode896;
        }else if ([TTDeviceHelper judge736Screen]) {
            tt_deviceMode = TTDeviceMode736;
        }
        else if ([TTDeviceHelper judge667Screen]) {
            tt_deviceMode = TTDeviceMode667;
        }
        else if ([TTDeviceHelper judge568Screen]) {
            tt_deviceMode = TTDeviceMode568;
        }
        else if ([TTDeviceHelper judge480Screen]){
            tt_deviceMode = TTDeviceMode480;
        }
        else{
            tt_deviceMode = TTDeviceMode667;
        }
    });
    return tt_deviceMode;
}

+ (BOOL)judgePadDevice {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (BOOL)judge812Screen {
    CGFloat longSide = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    return longSide == 812;
}

+ (BOOL)judge896Screen {
    CGFloat longSide = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    return longSide == 896;
}

+ (BOOL)judge736Screen {
    CGFloat longSide = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    return longSide == 736;
}

+ (BOOL)judge667Screen {
    //added 5.4:iPhone图集支持横屏，修改判断方式
    CGFloat longSide = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    return longSide == 667;
}

+ (BOOL)judge568Screen {
    CGFloat longSide = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    return longSide == 568;
}

+ (BOOL)judge480Screen {
    CGFloat longSide = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    return longSide == 480;
}

+ (NSString*)idfaString {
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

+ (NSString *)idfvString {
    if([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return @"";
}

+ (float)OSVersionNumber {
    static float currentOsVersionNumber = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentOsVersionNumber = [[[UIDevice currentDevice] systemVersion] floatValue];
    });
    return currentOsVersionNumber;
}

+ (NSString *)MACAddress {
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0) {
        errorFlag = @"if_nametoindex failure";
    }
    else {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0) {
            errorFlag = @"sysctl mgmtInfoBase failure";
        }
        else {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL) {
                errorFlag = @"buffer allocation failure";
            }
            else {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0){
                    errorFlag = @"sysctl msgBuffer failure";
                }
            }
        }
    }
    // Befor going any further...
    if (errorFlag != NULL) {
        free(msgBuffer);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    NSString *macAddressString = @"00:00:00:00:00:00";
    
    if (socketStruct != nil) {
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                            macAddress[0], macAddress[1], macAddress[2],
                            macAddress[3], macAddress[4], macAddress[5]];
    }
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

+ (NSString *)currentLanguage {
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+ (NSString *)fetchOpenUDIDFromKeychain {
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:6];
    [query setObject:(__bridge id)(kSecClassGenericPassword) forKey:(__bridge id<NSCopying>)(kSecClass)];
    [query setObject:@"openUDID" forKey:(__bridge id<NSCopying>)(kSecAttrAccount)];
    [query setObject:@"ttKeyChainService" forKey:(__bridge id<NSCopying>)(kSecAttrService)];
    [query setObject:@"openUDID" forKey:(__bridge id<NSCopying>)(kSecAttrGeneric)];
    [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id<NSCopying>)(kSecReturnData)];
    [query setObject:(__bridge id)(kSecMatchLimitOne) forKey:(__bridge id<NSCopying>)(kSecMatchLimit)];
    CFTypeRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess) {
        if (result) {
            CFRelease(result);
        }
        return nil;
    }
    NSData *data = [NSData dataWithData:(__bridge NSData *)(result)];
    if (result) {
        CFRelease(result);
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (void)saveOpenUDIDToKeychain:(NSString *)openUDID {
    NSData *openUDIDData = [openUDID dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:4];
    [query setObject:(__bridge id)(kSecClassGenericPassword) forKey:(__bridge id<NSCopying>)(kSecClass)];
    [query setObject:@"ttKeyChainService" forKey:(__bridge id<NSCopying>)(kSecAttrService)];
    [query setObject:@"openUDID" forKey:(__bridge id<NSCopying>)(kSecAttrAccount)];
    [query setObject:@"openUDID" forKey:(__bridge id<NSCopying>)(kSecAttrGeneric)];
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    if (status == errSecSuccess) {
        if (openUDIDData) {
            NSMutableDictionary *updateDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [updateDict setObject:openUDIDData forKey:(__bridge id<NSCopying>)(kSecValueData)];
            status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updateDict);
        }
    }
    else if(status == errSecItemNotFound) {
        if (openUDIDData) {
            NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithCapacity:5];
            [attrs setObject:(__bridge id)(kSecClassGenericPassword) forKey:(__bridge id<NSCopying>)(kSecClass)];
            [attrs setObject:@"ttKeyChainService" forKey:(__bridge id<NSCopying>)(kSecAttrService)];
            [attrs setObject:@"openUDID" forKey:(__bridge id<NSCopying>)(kSecAttrAccount)];
            [attrs setObject:@"openUDID" forKey:(__bridge id<NSCopying>)(kSecAttrGeneric)];
            [attrs setObject:openUDIDData forKey:(__bridge id<NSCopying>)(kSecValueData)];
            status = SecItemAdd((__bridge CFDictionaryRef)attrs, NULL);
        }
    }
}

+ (NSString*)openUDID {
    static NSString * openUDID = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        openUDID = [self fetchOpenUDIDFromKeychain];
        if (!openUDID || openUDID.length == 0) {
            openUDID = [OpenUDID value];
            [self saveOpenUDIDToKeychain:openUDID];
        }
    });
    return openUDID;
}

+ (CGFloat)ssOnePixel {
    return 1.0f / [[UIScreen mainScreen] scale];
}

+ (CGFloat)screenScale {
    return [[UIScreen mainScreen] scale];
}

+ (CGSize)resolution {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float scale = [[UIScreen mainScreen] scale];
    CGSize resolution = CGSizeMake(screenBounds.size.width * scale, screenBounds.size.height * scale);
    return resolution;
}


+ (NSString *)resolutionString {
    CGSize resolution = [self resolution];
    return [NSString stringWithFormat:@"%d*%d", (int)resolution.width, (int)resolution.height];
}

@end

@implementation TTDeviceHelper (TTDiskSpace)

+ (long long)getTotalDiskSpace {
    float totalSpace;
    NSError * error;
    NSDictionary * infoDic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (infoDic) {
        NSNumber * fileSystemSizeInBytes = [infoDic objectForKey:NSFileSystemSize];
        totalSpace = [fileSystemSizeInBytes longLongValue];
        return totalSpace;
    } else {
        return 0;
    }
}

+ (long long)getFreeDiskSpace {
    float totalFreeSpace;
    NSError * error;
    NSDictionary * infoDic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (infoDic) {
        NSNumber * fileSystemSizeInBytes = [infoDic objectForKey:NSFileSystemFreeSize];
        totalFreeSpace = [fileSystemSizeInBytes longLongValue];
        return totalFreeSpace;
    } else {
        return 0;
    }
}

@end
