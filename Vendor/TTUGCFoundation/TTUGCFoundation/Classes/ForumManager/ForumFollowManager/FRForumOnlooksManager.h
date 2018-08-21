//
//  FRForumOnlooksManager.h
//  Article
//
//  Created by ZhangLeonardo on 15/7/17.
//
//

#import <Foundation/Foundation.h>
#import "FRRequestManager.h"
@class FRForumEntity;

extern NSString *const kForumLikeStatusChangeNotification;
extern NSString *const kForumLikeStatusChangeForumIDKey;
extern NSString *const kForumLikeStatusChangeForumLikeKey;


@interface FRForumOnlooksManager : NSObject

+ (void)switchFollowStatus:(FRForumEntity *)entity;
+ (void)unonlooksForForumID:(int64_t)fid callback:(TTNetworkResponseModelFinishBlock)callback;
+ (void)onlooksForForumID:(int64_t)fid callback:(TTNetworkResponseModelFinishBlock)callback;

@end
