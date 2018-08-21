//
//  RelationUserCell.h
//  Article
//
//  Created by Yu Tianhang on 12-11-2.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "FriendDataManager.h"
#import "ArticleFriend.h"
#import "SSAvatarView.h"
#import "FriendListCellUnit.h"

#define FriendListCellHeight FriendListCellUnitHeight

@interface FriendListCell : SSThemedTableViewCell <FriendDataManagerDelegate> {
    
    FriendDataListType _type;

    ArticleFriend *currentFriend;
    FriendDataManager *friendDataManager;
}
@property(nonatomic, retain)NSString * umengEventName;
@property (nonatomic, retain) ArticleFriend *currentFriend;

@property (nonatomic, retain) FriendDataManager *friendDataManager;
@property (nonatomic, retain) FriendListCellUnit * listCellUnit;

@property(nonatomic,assign) BOOL isMyList; //我的关注、粉丝列表

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(FriendDataListType)type;
- (void)loadView;
- (void)refreshUI;

@end
