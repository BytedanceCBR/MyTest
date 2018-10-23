//
//  TTDiskSpaceHelper.h
//  Article
//
//  Created by 徐霜晴 on 16/11/18.
//
//

#import <Foundation/Foundation.h>

@interface TTDiskSpaceHelper : NSObject

//获取硬盘大小，单位Byte
+ (long long)getTotalDiskSpace;

//获取可用空间大小，单位Byte
+ (long long)getFreeDiskSpace;

@end
