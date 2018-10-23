//
//  ArticleInviteFriendViewController.h
//  Article
//
//  Created by Zhang Leonardo on 13-12-30.
//
//

#import <UIKit/UIKit.h>
#import "SSViewControllerBase.h"
#import "ArticleInviteFriendView.h"

@interface ArticleInviteFriendViewController : SSViewControllerBase
@property(nonatomic, retain)ArticleInviteFriendView * inviteFriendView;

- (id)initWithStyle:(ArticleInviteFriendViewStyle)style;
@end
