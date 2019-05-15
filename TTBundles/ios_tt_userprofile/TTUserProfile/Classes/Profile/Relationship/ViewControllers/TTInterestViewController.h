//
//  TTInterestViewController.h
//  Article
//
//  Created by liuzuopeng on 8/10/16.
//
//

#import "TTTableViewController.h"


@class ArticleFriend;
/**
 * 关心实体词列表即兴趣列表
 */
@interface TTInterestViewController : TTTableViewController
- (instancetype)initWithUID:(NSString *)uid;
- (instancetype)initWithArticleFriend:(ArticleFriend *)aFriend;
@end
