//
//  TTSocialBaseViewController.h
//  Article
//
//  Created by liuzuopeng on 8/9/16.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "SSMyUserModel.h"
#import "TTTableViewController.h"
#import "FriendDataManager.h"
#import "TTFriendModel.h"




@class TTSocialBaseViewController;
@protocol TTSocialBaseViewControllerDelegate <NSObject>
@end


/**
 * 个人或者好友关系圈base viewController
 */
@interface TTSocialBaseViewController <ModelType : TTFriendModel *> : TTTableViewController
<
FriendDataManagerDelegate
>
// 从服务端开始读取的数据偏移量
@property (nonatomic, assign) NSUInteger offset; // default is 0

@property (nonatomic, strong) ArticleFriend *currentFriend;
@property (nonatomic, strong, readonly) FriendDataManager *friendDataManager;
@property (nonatomic, strong, readonly) NSMutableArray<ModelType> *friendModels;


/**
 * FriendDataListTypeSuggestUser type default is add_friends, other is friends
 */
@property (nonatomic, strong) NSString *umengEventName; // default is 'add_friends'
@property (nonatomic, assign) FriendDataListType relationType; // default is FriendDataListTypeNone

- (instancetype)initWithUserID:(NSString *)userID;
- (instancetype)initWithArticleFriend:(ArticleFriend *)aFriend;
@end
