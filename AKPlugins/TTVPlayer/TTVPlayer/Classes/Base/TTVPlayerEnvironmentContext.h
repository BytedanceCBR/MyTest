//
//  TTVPlayerInfoContext.h
//  TTVPlayer
//
//  Created by lisa on 2018/12/15.
//

#import <Foundation/Foundation.h>
#import "TTVReduxKit.h"

NS_ASSUME_NONNULL_BEGIN

/**
 这个类存放当前播放器的一些环境变量，播放器销毁后，这个变量跟着一起销毁，播放器更新后，此数据跟着更新，比如 host等
 此类Pod 外可以读取，Pod 内可以修改？？？TODO
 */
@interface TTVPlayerEnvironmentContext : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, copy) NSString * _Nullable host; // 播放地址的host
@property (nonatomic, weak) NSDictionary * _Nullable commonParameters; // 公共参数


/**
 重新设置到初始值，由于播放器切换或者重新设置，退出播放等
 */
+ (void)reset;

@end

NS_ASSUME_NONNULL_END
