//
//  FHMessageManager.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/2/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMessageManager : NSObject

- (void)startSyncMessage;

- (void)stopSyncMessage;

-(void)reduceSystemMessageTabBarBadgeNumber:(NSInteger)reduce;
@end

NS_ASSUME_NONNULL_END
