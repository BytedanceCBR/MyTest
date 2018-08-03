//
//  TTNewFollowingManager.h
//  Article
//
//  Created by lizhuoli on 17/1/8.
//
//

#import <Foundation/Foundation.h>
#import "TTNewFollowingResponseModel.h"

#define kTTNewFollowingErrorDomain @"kTTNewFollowingErrorDomain"

typedef void(^TTNewFollowingResponseBlock)(NSError *error, TTNewFollowingResponseModel *model);

@interface TTNewFollowingManager : NSObject

- (void)fetchFollowingListWithUserID:(NSString *)userID cursor:(NSString *)cursor completion:(TTNewFollowingResponseBlock)completion;

+ (instancetype)sharedInstance;

@end
