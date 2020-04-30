//
//  FHVRPreloadManager.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/30.
//

#import <Foundation/Foundation.h>

static NSString * _Nonnull kFHVrImagePreLoadChannel = @"img";

NS_ASSUME_NONNULL_BEGIN

@interface FHVRPreloadManager : NSObject

+(instancetype)sharedInstance;

- (void)requestForSimilarHouseId:(NSString *)houseId;

@end

NS_ASSUME_NONNULL_END
