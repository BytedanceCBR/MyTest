//
//  TTFollowingModel.h
//  Article
//
//  Created by it-test on 8/10/16.
//
//

#import <Foundation/Foundation.h>
#import "TTFriendModel.h"


@interface TTFollowingModel : TTFriendModel
@property (nonatomic, assign) NSUInteger totalNumber;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, copy) NSString *tipsCount;
@end
