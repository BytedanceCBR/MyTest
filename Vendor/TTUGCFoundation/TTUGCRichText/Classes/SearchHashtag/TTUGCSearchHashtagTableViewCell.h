//
//  TTUGCSearchHashtagTableViewCell.h
//  Article
//
//  Created by Jiyee Sheng on 25/09/2017.
//
//


#import "SSThemed.h"
#import "FRApiModel.h"

@class SSAvatarView;

@interface TTUGCSearchHashtagTableViewCell : SSThemedTableViewCell

@property (nonatomic, strong) SSAvatarView *avatarView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *descLabel;
@property (nonatomic, strong) SSThemedImageView *cornerImageView;
@property (nonatomic, strong) SSThemedView *bottomLineView;

- (void)configWithHashtagModel:(FRPublishPostSearchHashtagStructModel *)hashtagModel row:(NSInteger)row;

@end
