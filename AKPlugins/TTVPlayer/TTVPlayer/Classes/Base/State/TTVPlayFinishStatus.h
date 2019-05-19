//
//  TTVPlayFinishStatus.h
//  TTVPlayer
//
//  Created by lisa on 2019/1/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TTVPlayFinishStatusType) {
    TTVPlayFinishStatusType_SystemFinish,    // 系统正常播放结束 或者 出错结束（数据源出错，播放过程中出错）
    TTVPlayFinishStatusType_UserFinish       // 用户手动调用 stop 或者 closeAnsync
};

/**
 结束状态主要分为三种：1、用户手动(异步，非异步)  2、播放结束（错误导致、正常无错误）
 */
@interface TTVPlayFinishStatus : NSObject<NSCopying>

@property (nonatomic, assign) TTVPlayFinishStatusType type; // 2种
@property (nonatomic, strong) NSError * _Nullable playError; // 当 type 是系统结束时，播放过程中结束，会有错误
@property (nonatomic, assign) NSInteger sourceErrorStatus;   // 当 type 是系统结束时，播放之前，获取视频源会有的错误，其实两个都可以合并。。。只是不好特殊标出

@end

NS_ASSUME_NONNULL_END
