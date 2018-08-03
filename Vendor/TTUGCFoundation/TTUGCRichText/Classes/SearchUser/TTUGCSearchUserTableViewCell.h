//
//  TTUGCSearchUserTableViewCell.h
//  Article
//
//  Created by Jiyee Sheng on 05/09/2017.
//
//


#import "SSThemed.h"
#import "FRApiModel.h"

@class SSAvatarView;
@class TTIconLabel;

@interface TTUGCSearchUserTableViewCell : SSThemedTableViewCell

@property (nonatomic, strong) SSAvatarView *avatarView;
@property (nonatomic, strong) TTIconLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *descLabel;
@property (nonatomic, strong) SSThemedView *bottomLineView;

- (void)configWithUserModel:(FRPublishPostSearchUserStructModel *)userModel;

@end
