//
//  FHCommuteManager.h
//  FHHouseList
//
//  Created by 春晖 on 2019/4/1.
//

#import <Foundation/Foundation.h>
#import "FHCommuteType.h"

NS_ASSUME_NONNULL_BEGIN
//通勤找房manager
@interface FHCommuteManager : NSObject

@property(nonatomic , strong) NSString *destLocation;//通勤目的地
@property(nonatomic , assign) FHCommuteType commuteType;
@property(nonatomic , copy)   NSString * duration;

+(instancetype)sharedInstance;

-(NSString *)commuteTypeName;

-(void)sync;

@end

NS_ASSUME_NONNULL_END
