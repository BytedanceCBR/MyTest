//
//  ArticleFriend.m
//  Article
//
//  Created by Dianwei on 12-11-2.
//
//

#import "ArticleFriend.h"
#import <TTAccountBusiness.h>

@implementation ArticleFriend

+ (ArticleFriend *)initWithFriendModel:(FriendModel *)model
{
    if (model == nil) {
        return nil;
    }
    ArticleFriend * friend = [[ArticleFriend alloc] initWithDictionary:[model dictionaryInfo]];
    return friend;
}

+ (ArticleFriend *)accountUser
{
    ArticleFriend *ret = [[ArticleFriend alloc] init];
    ret.userID = [TTAccountManager userID];
    ret.screenName = [TTAccountManager userName];
    ret.userDescription = [TTAccountManager currentUser].userDescription;
    ret.avatarURLString = [TTAccountManager avatarURLString];
    return ret;
}

//[self.userID isEqualToString:@"0"] 为了兼容老版本
- (BOOL)isAccountUser
{
    return [self.userID isEqualToString:[TTAccountManager userID]] || [self.userID isEqualToString:@"0"];
}

@end
