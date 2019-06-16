//
//  FHUGCFollowManager.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/16.
//

#import <Foundation/Foundation.h>
#import "FHUGCModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCFollowManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong)   FHUGCModel       *followData;

@end

NS_ASSUME_NONNULL_END
