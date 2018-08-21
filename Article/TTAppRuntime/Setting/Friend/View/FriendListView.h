//
//  FriendListView.h
//  Article
//
//  Created by Yu Tianhang on 12-11-5.
//
//

#import "SSViewBase.h"
#import <TTWeChatShare.h>

@interface FriendListView : SSViewBase <TTWeChatShareDelegate>
@property(nonatomic, retain)NSString * umengEventName;//FriendDataListTypeSuggestUser type default is add_friends, other is friends
@property (nonatomic, retain, readonly) UITableView *friendView;

- (id)initWithFrame:(CGRect)frame;
@end
