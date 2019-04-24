//
//  TTFriendModel.h
//  Article
//
//  Created by it-test on 8/22/16.
//
//

#import "ArticleFriendModel.h"

@interface TTFriendModel : ArticleFriendModel
/**
 * 当前访问者的用户id
 * 若从个人profile进来，则是用户uid；否则从他人主页进来则是他人uid
 */
@property (nonatomic, copy) NSString *visitorUID;

/**
 * 当前访客是否为账户用户
 * 若当前访客是账户用户，在关注页时，不显示关注按钮
 */
- (BOOL)isAccountUserOfVisitor;
@end
