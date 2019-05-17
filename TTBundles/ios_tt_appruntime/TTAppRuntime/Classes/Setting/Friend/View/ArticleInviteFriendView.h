//
//  ArticleInviteFriendView.h
//  Article
//
//  Created by Zhang Leonardo on 13-12-30.
//
//

#import "SSViewBase.h"
#import "SSNavigationBar.h"

typedef enum ArticleInviteFriendViewStyle{
    ArticleInviteFriendViewStyleNormal,
    ArticleInviteFriendViewStyleExplore
}ArticleInviteFriendViewStyle;

@class FriendListView;
@class ArticleTitleImageView;
@interface ArticleInviteFriendView : SSViewBase
@property(nonatomic, retain)ArticleTitleImageView * titleBarView;
@property (nonatomic, retain) SSNavigationBar     * navigationBar;
@property(nonatomic, retain)FriendListView * inviteFriendListView;
- (id)initWithFrame:(CGRect)frame style:(ArticleInviteFriendViewStyle)style;

@end
