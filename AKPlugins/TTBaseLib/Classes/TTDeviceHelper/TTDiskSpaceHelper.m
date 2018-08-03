//
//  TTDiskSpaceHelper.m
//  Article
//
//  Created by 徐霜晴 on 16/11/18.
//
//

#import "TTDiskSpaceHelper.h"

@implementation TTDiskSpaceHelper

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
