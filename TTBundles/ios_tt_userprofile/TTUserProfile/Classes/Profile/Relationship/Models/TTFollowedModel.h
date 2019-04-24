//
//  TTFollowedModel.h
//  Article
//
//  Created by it-test on 8/10/16.
//
//

#import <Foundation/Foundation.h>
#import "TTFriendModel.h"

@interface TTFollowedModel : TTFriendModel
@property (nonatomic, assign) NSUInteger totalNumber;
@property (nonatomic, assign) BOOL hasMore;
@end
