//
//  TTPostUGCEntranceIconDownloadManager.h
//  Article
//
//  Created by xushuangqing on 17/11/2017.
//

#import <Foundation/Foundation.h>
#import "TTPostUGCEntrance.h"

@interface TTPostUGCEntranceIconDownloadManager : NSObject

+ (nullable instancetype)sharedManager;

- (nullable UIImage *)getEntranceIconForType:(TTPostUGCEntranceButtonType)type withURL:(nullable NSString *)url;

@end
