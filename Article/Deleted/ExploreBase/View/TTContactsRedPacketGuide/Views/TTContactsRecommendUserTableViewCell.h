//
//  TTContactsRecommendUserTableViewCell.h
//  Article
//
//  Created by Jiyee Sheng on 8/3/17.
//
//


#import "SSThemed.h"


@class TTContactsRecommendUserTableViewCell;
@class SSAvatarView;
@class TTAlphaThemedButton;

@interface TTRecommendUserModel : NSObject

@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *screen_name;
@property (strong, nonatomic) NSString *mobile_name;
@property (strong, nonatomic) NSString *avatar_url;
@property (strong, nonatomic) NSString *user_auth_info;
@property (strong, nonatomic) NSString *user_decoration;
@property (strong, nonatomic) NSString *recommend_reason;
@property (assign, nonatomic) BOOL selected;
@property (assign, nonatomic) BOOL selectable;
@property (assign, nonatomic) BOOL userProfileEnabled; // 是否允许进入个人主页

- (instancetype)initWithFRUserRelationContactFriendsUserStructModel:(FRUserRelationContactFriendsUserStructModel *)model;

@end

@protocol TTContactsRecommendUserTableViewCellDelegate <NSObject>

- (void)addFriendsTableViewCell:(TTContactsRecommendUserTableViewCell *)cell didSelectedUser:(BOOL)selected;
- (void)addFriendsTableViewCell:(TTContactsRecommendUserTableViewCell *)cell didUserProfile:(NSString *)userId;

@end

@interface TTContactsRecommendUserTableViewCell : SSThemedTableViewCell

@property (nonatomic, weak) id <TTContactsRecommendUserTableViewCellDelegate> delegate;

@property (nonatomic, strong) SSAvatarView *avatarView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *descLabel;
@property (nonatomic, strong) TTAlphaThemedButton *selectButton;
@property (nonatomic, strong) SSThemedView *bottomLineView;

- (void)configWithUserModel:(TTRecommendUserModel *)userModel;
- (void)onChange:(id)sender;
@end
