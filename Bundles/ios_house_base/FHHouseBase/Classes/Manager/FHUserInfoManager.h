//
//  FHUserInfoManager.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/10/16.
//

#import <Foundation/Foundation.h>
#import "FHUserInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUserInfoManager : NSObject

@property(nonatomic, strong) FHUserInfoModel *userInfo;

+(instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
