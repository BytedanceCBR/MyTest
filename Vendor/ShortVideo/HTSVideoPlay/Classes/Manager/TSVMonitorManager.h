//
//  TSVMonitorManager.h
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/9/21.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TSVMonitorNetworkService)
{
    TSVMonitorNetworkServiceCommentList,
    TSVMonitorNetworkServicePostComment,
    TSVMonitorNetworkServiceDeleteComment,
    TSVMonitorNetworkServiceReportComment,
    TSVMonitorNetworkServiceDiggComment,
    TSVMonitorNetworkServiceProfile,
    TSVMonitorNetworkServiceFollow,
    TSVMonitorNetworkServiceUnfollow
};

typedef NS_ENUM(NSInteger, TSVMonitorVideoPlayStatus)
{
    TSVMonitorVideoPlaySucceed,
    TSVMonitorVideoPlayFailed
};

@class TTShortVideoModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSVMonitorManager : NSObject

+ (instancetype)sharedManager;

- (NSString *)startMonitorNetworkService:(TSVMonitorNetworkService)service key:(nullable id<NSCopying>)key;

- (void)endMonitorNetworkService:(TSVMonitorNetworkService)service identifier:(NSString *)identifier error:(nullable NSError *)error;

- (void)trackVideoPlayStatus:(TSVMonitorVideoPlayStatus)status model:(TTShortVideoModel *)model error:(nullable NSError *)error;

- (void)didEnterShortVideoTab;

- (void)didLeaveShortVideoTab;

- (void)recordCurrentMemoryUsage;

- (void)trackDetailLoadingCellShowWithExtraInfo:(NSDictionary *)extraInfo;

- (void)trackCategoryResponseWithCategoryID:(NSString *)categoryID listEntrance:(NSString *)listEntrance count:(NSInteger)count error:(NSError *)error;

- (void)trackPictureServiceWithDuration:(CFTimeInterval)duration
                                  error:(nullable NSError *)error
                                 cached:(BOOL)cached
                        isAnimatedImage:(BOOL)isAnimatedImage;

@end

NS_ASSUME_NONNULL_END
