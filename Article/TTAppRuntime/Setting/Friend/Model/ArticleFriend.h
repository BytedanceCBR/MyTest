//
//  ArticleFriend.h
//  Article
//
//  Created by Dianwei on 12-11-2.
//
//

#import "FriendModel.h"

@interface ArticleFriend : FriendModel

+ (ArticleFriend *)accountUser;

- (BOOL)isAccountUser;

+ (ArticleFriend *)initWithFriendModel:(FriendModel *)model;

@end
