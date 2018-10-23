/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.0 Edition
 BSD License, Use at your own risk
 */

// Thanks to Emanuele Vulcano, Kevin Ballard/Eridius, Ryandjohnson, Matt Brown, etc.

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "UIDevice+TTAdditions.h"

@implementation UIDevice (Hardware)
/*
 Platforms
 
 iFPGA ->        ??

 iPhone1,1 ->    iPhone 1G, M68
 iPhone1,2 ->    iPhone 3G, N82
 iPhone2,1 ->    iPhone 3GS, N88
 iPhone3,1 ->    iPhone 4/AT&T, N89
 iPhone3,2 ->    iPhone 4/Other Carrier?, ??
 iPhone3,3 ->    iPhone 4/Verizon, TBD
 iPhone4,1 ->    (iPhone 5/AT&T), TBD
 iPhone4,2 ->    (iPhone 5/Verizon), TBD
 iPhone5,1 ->    iPhone 5 GSM
 iPhone5,2 ->    iPhone 5 CDMA
 iPhone6,1 ->    iPhone 5S
 iPhone6,2 ->    iPhone 5S
 iPhone7,1 ->    iPhone 6 Plus
 iPhone7,2 ->    iPhone 6
 iPhone8,1 ->    iPhone 6S
 iPhone8,2 ->    iPhone 6S Plus
 iPhone8,4 ->    iPhone SE
 iPhone9,1,iPhone9,3 ->    iPhone 7
 iPhone9,2,iPhone9,4 ->    iPhone 7 Plus
 iPhone10,1,iPhone10,4 ->    iPhone 8
 iPhone10,2,iPhone10,5 ->    iPhone 8 Plus
 iPhone10,3,iPhone10,6 ->    iPhone X

 iPod1,1   ->    iPod touch 1G, N45
 iPod2,1   ->    iPod touch 2G, N72
 iPod2,2   ->    Unknown, ??
 iPod3,1   ->    iPod touch 3G, N18
 iPod4,1   ->    iPod touch 4G, N80
 iPod5,1   ->    iPod 5
 
 // Thanks NSForge
 iPad1,1   ->    iPad 1G, WiFi and 3G, K48
 iPad2,1   ->    iPad 2G, WiFi, K93
 iPad2,2   ->    iPad 2G, GSM 3G, K94
 iPad2,3   ->    iPad 2G, CDMA 3G, K95
 iPad3,1   ->    (iPad 3G, GSM)
 iPad3,2   ->    (iPad 3G, CDMA)
 

 AppleTV2,1 ->   AppleTV 2, K66

 i386, x86_64 -> iPhone Simulator
*/


#pragma mark sysctlbyname utils
- (NSString *) getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];

    free(answer);
    return results;
}

- (NSString *) platform
{
    return [self getSysInfoByName:"hw.machine"];
}

- (NSNumber *) freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

#pragma mark platform type and name utils
- (NSUInteger) platformType
{
    NSString *platform = [self platform];

    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"])        return UIDeviceIFPGA;

    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return UIDevice1GiPhone;
    if ([platform isEqualToString:@"iPhone1,2"])    return UIDevice3GiPhone;
    if ([platform hasPrefix:@"iPhone2"])            return UIDevice3GSiPhone;
    if ([platform hasPrefix:@"iPhone3"])            return UIDevice4iPhone;
    if ([platform hasPrefix:@"iPhone4"])            return UIDevice4siPhone;
    if ([platform isEqualToString:@"iPhone5,1"])    return UIDevice5GSMiPhone;
    if ([platform isEqualToString:@"iPhone5,2"])    return UIDevice5GlobaliPhone;
    if ([platform isEqualToString:@"iPhone5,3"] || [platform isEqualToString:@"iPhone5,4"])    return UIDevice5CiPhone;
    if ([platform isEqualToString:@"iPhone6,1"] || [platform isEqualToString:@"iPhone6,2"])    return UIDevice5SiPhone;
    if ([platform isEqualToString:@"iPhone7,1"])    return UIDevice6PlusiPhone;
    if ([platform isEqualToString:@"iPhone7,2"])    return UIDevice6iPhone;
    if ([platform isEqualToString:@"iPhone8,1"])    return UIDevice6SiPhone;
    if ([platform isEqualToString:@"iPhone8,2"])    return UIDevice6SPlusiPhone;
    if ([platform isEqualToString:@"iPhone8,4"])    return UIDeviceSEiPhone;
    if ([platform isEqualToString:@"iPhone9,1"])    return UIDevice7_1iPhone;
    if ([platform isEqualToString:@"iPhone9,3"])    return UIDevice7_3iPhone;
    if ([platform isEqualToString:@"iPhone9,2"])    return UIDevice7_2PlusiPhone;
    if ([platform isEqualToString:@"iPhone9,4"])    return UIDevice7_4PlusiPhone;
    if ([platform isEqualToString:@"iPhone10,1"])   return UIDevice8iPhone;
    if ([platform isEqualToString:@"iPhone10,4"])   return UIDevice8iPhone;
    if ([platform isEqualToString:@"iPhone10,2"])   return UIDevice8PlusiPhone;
    if ([platform isEqualToString:@"iPhone10,5"])   return UIDevice8PlusiPhone;
    if ([platform isEqualToString:@"iPhone10,3"])   return UIDeviceXiPhone;
    if ([platform isEqualToString:@"iPhone10,6"])   return UIDeviceXiPhone;
    
    // iPod
    if ([platform hasPrefix:@"iPod1"])              return UIDevice1GiPod;
    if ([platform hasPrefix:@"iPod2"])              return UIDevice2GiPod;
    if ([platform hasPrefix:@"iPod3"])              return UIDevice3GiPod;
    if ([platform hasPrefix:@"iPod4"])              return UIDevice4GiPod;
    if ([platform hasPrefix:@"iPod5"])              return UIDevice5GiPod;

    // iPad
    if ([platform hasPrefix:@"iPad1"])              return UIDevice1GiPad;
    if ([platform hasPrefix:@"iPad2,5"] || [platform hasPrefix:@"iPad2,6"] || [platform hasPrefix:@"iPad2,7"])            return UIDeviceiPadMini;
    if ([platform hasPrefix:@"iPad2,1"] || [platform hasPrefix:@"iPad2,2"] || [platform hasPrefix:@"iPad2,3"] || [platform hasPrefix:@"iPad2,4"])              return UIDevice2GiPad;
    if ([platform isEqualToString:@"iPad3,1"] || [platform isEqualToString:@"iPad3,2"] || [platform isEqualToString:@"iPad3,3"])    return UIDevice3GiPad;
    if ([platform isEqualToString:@"iPad3,4"] || [platform isEqualToString:@"iPad3,5"] || [platform isEqualToString:@"iPad3,6"])    return UIDevice4GiPad;
    if ([platform isEqualToString:@"iPad4,1"] || [platform isEqualToString:@"iPad4,2"] || [platform isEqualToString:@"iPad4,3"])    return UIDeviceAiriPad;
    if ([platform isEqualToString:@"iPad4,4"] || [platform isEqualToString:@"iPad4,5"])    return UIDeviceiPadMiniRetina;
    if ([platform isEqualToString:@"iPad6,7"] || [platform isEqualToString:@"iPad6,8"]) {
        return UIDeviceiPadPro;
    }
    
    // Apple TV
    if ([platform hasPrefix:@"AppleTV2"])           return UIDeviceAppleTV2;

    if ([platform hasPrefix:@"iPhone"])             return UIDeviceUnknowniPhone;
    if ([platform hasPrefix:@"iPod"])               return UIDeviceUnknowniPod;
    if ([platform hasPrefix:@"iPad"])               return UIDeviceUnknowniPad;
    
     // Simulator thanks Jordan Breeding
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? UIDeviceiPhoneSimulatoriPhone : UIDeviceiPhoneSimulatoriPad;
    }

    return UIDeviceUnknown;
}

- (NSString *) platformString
{
    switch ([self platformType])
    {
        case UIDevice1GiPhone: return IPHONE_1G_NAMESTRING;
        case UIDevice3GiPhone: return IPHONE_3G_NAMESTRING;
        case UIDevice3GSiPhone: return IPHONE_3GS_NAMESTRING;
        case UIDevice4iPhone: return IPHONE_4_NAMESTRING;
        case UIDevice4siPhone: return IPHONE_4S_NAMESTRING;
        case UIDevice5GSMiPhone: return IPHONE_5GSM_NAMESTRING;
        case UIDevice5GlobaliPhone: return IPHONE_5Global_NAMESTRING;
        case UIDevice5CiPhone:  return IPHONE_5C_NAMESTRING;
        case UIDevice5SiPhone: return IPHONE_5S_NAMESTRING;
        case UIDevice6iPhone: return IPHONE_6_NAMESTRING;
        case UIDevice6PlusiPhone: return IPHONE_6_PLUS_NAMESTRING;
        case UIDevice6SiPhone: return IPHONE_6S_NAMESTRING;
        case UIDevice6SPlusiPhone: return IPHONE_6S_PLUS_NAMESTRING;
        case UIDeviceSEiPhone: return IPHONE_SE;
        case UIDevice7_1iPhone: return IPHONE_7_NAMESTRING;
        case UIDevice7_3iPhone: return IPHONE_7_NAMESTRING;
        case UIDevice7_2PlusiPhone: return IPHONE_7_PLUS_NAMESTRING;
        case UIDevice7_4PlusiPhone: return IPHONE_7_PLUS_NAMESTRING;
        case UIDevice8iPhone: return  IPHONE_8_NAMESTRING;
        case UIDevice8PlusiPhone: return  IPHONE_8_PLUS_NAMESTRING;
        case UIDeviceXiPhone: return  IPHONE_X_NAMESTRING;
        
        case UIDeviceUnknowniPhone: return [self platform];
        
        case UIDevice1GiPod: return IPOD_1G_NAMESTRING;
        case UIDevice2GiPod: return IPOD_2G_NAMESTRING;
        case UIDevice3GiPod: return IPOD_3G_NAMESTRING;
        case UIDevice4GiPod: return IPOD_4G_NAMESTRING;
        case UIDevice5GiPod: return IPOD_5G_NAMESTRING;
        case UIDeviceUnknowniPod: return [self platform];
            
        case UIDevice1GiPad : return IPAD_1G_NAMESTRING;
        case UIDevice2GiPad : return IPAD_2G_NAMESTRING;
        case UIDevice3GiPad : return IPAD_3G_NAMESTRING;
        case UIDevice4GiPad : return IPAD_4G_NAMESTRING;
        case UIDeviceAiriPad : return IPAD_AIR_NAMESTRING;
        case UIDeviceiPadMini: return IPAD_MINI_NAMESTRING;
        case UIDeviceiPadMiniRetina: return IPAD_MINI_Retina_NAMESTRING;
        case UIDeviceiPadPro: return IPAD_PRO_NAMESTRING;
        case UIDeviceUnknowniPad : return [self platform];
            
        case UIDeviceAppleTV2 : return APPLETV_2G_NAMESTRING;
        case UIDeviceUnknownAppleTV: return APPLETV_UNKNOWN_NAMESTRING;
            
        case UIDeviceiPhoneSimulator: return IPHONE_SIMULATOR_NAMESTRING;
        case UIDeviceiPhoneSimulatoriPhone: return IPHONE_SIMULATOR_IPHONE_NAMESTRING;
        case UIDeviceiPhoneSimulatoriPad: return IPHONE_SIMULATOR_IPAD_NAMESTRING;
            
        case UIDeviceIFPGA: return IFPGA_NAMESTRING;
            
        default: return IOS_FAMILY_UNKNOWN_DEVICE;
    }
}

- (BOOL)isPoorPerformanceDevice {
    
    switch ([self platformType]) {
        case UIDevice1GiPhone:
        case UIDevice3GiPhone:
        case UIDevice3GSiPhone:
        case UIDevice4iPhone:
        case UIDevice4siPhone:
        case UIDevice5GSMiPhone:
        case UIDevice5GlobaliPhone:
        case UIDevice5CiPhone:
        case UIDevice1GiPad:
        case UIDevice2GiPad:
        case UIDevice3GiPad:
        case UIDevice4GiPad:
        case UIDeviceiPadMini:
            return YES;
        default:
            return NO;
    }
}

@end

@implementation UIDevice (ProcessesAdditions)

- (NSArray *)runningProcesses {
    static int maxArgumentSize = 0;
    if (maxArgumentSize == 0) {
        size_t size = sizeof(maxArgumentSize);
        if (sysctl((int[]){ CTL_KERN, KERN_ARGMAX }, 2, &maxArgumentSize, &size, NULL, 0) == -1) {
            perror("sysctl argument size");
            maxArgumentSize = 4096; // Default
        }
    }
    NSMutableArray *processes = [NSMutableArray array];
    int mib[3] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL};
    struct kinfo_proc *info;
    size_t length;
    NSInteger count;
    
    if (sysctl(mib, 3, NULL, &length, NULL, 0) < 0)
        return nil;
    if (!(info = malloc(length)))
        return nil;
    if (sysctl(mib, 3, info, &length, NULL, 0) < 0) {
        free(info);
        return nil;
    }
    count = length / sizeof(struct kinfo_proc);
    for (int i = 0; i < count; i++) {
        pid_t pid = info[i].kp_proc.p_pid;
        if (pid == 0) {
            continue;
        }
        size_t size = maxArgumentSize;
        char* buffer = (char *)malloc(length);
        if (sysctl((int[]){ CTL_KERN, KERN_PROCARGS2, pid }, 3, buffer, &size, NULL, 0) == 0) {
            NSString* executable = [NSString stringWithCString:(buffer+sizeof(int)) encoding:NSUTF8StringEncoding];
            NSURL * executableURL = [NSURL fileURLWithPath:executable isDirectory:NO];
            NSString * processName = [executableURL lastPathComponent];

            if (processName && processName.length)
            {
                [processes addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:pid], @"ProcessID",
                                      processName, @"ProcessName",
                                      nil]];
            }
        }
        free(buffer);
    }
    
    free(info);
    
    return processes;
}

@end
