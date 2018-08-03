//
//  BlockUsersListCell.h
//  Article
//
//  Created by Huaqing Luo on 9/3/15.
//
//

#import "SSThemed.h"
#import "NewFriendListCellUnit.h"
#import "TTBlockManager.h"
#import "ArticleFriendModel.h"

@class BlockUsersListCell;

@protocol BlockUsersListCellDelegate <NSObject>

- (void)blockUsersListCell:(BlockUsersListCell *)cell didBlockUser:(BOOL)blocking;

@end

@interface BlockUsersListCell : SSThemedTableViewCell

@property (nonatomic, strong          ) ArticleFriendModel    * blockUser;
@property (nonatomic, strong, readonly) NewFriendListCellUnit * listCellUnit;

@property (nonatomic, weak) id<BlockUsersListCellDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width;
- (void)refreshUI;

@end
