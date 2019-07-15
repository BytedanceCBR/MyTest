//
//  TTUGCSearchHashtagTableViewCell.h
//  Article
//
//  Created by Jiyee Sheng on 25/09/2017.
//
//


#import "SSThemed.h"
#import "FRApiModel.h"
#import "TTUGCHashtagModel.h"
#import <TTAvatar/SSAvatarView.h>

@interface TTUGCSearchHashtagTableHeaderViewCell : SSThemedTableViewCell

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedView *separatorView;

- (void)configWithHashtagHeaderModel:(TTUGCHashtagHeaderModel *)hashtagHeaderModel;

@end

@interface TTUGCSearchHashtagTableViewCell : SSThemedTableViewCell

@property (nonatomic, strong) SSAvatarView *avatarView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *descLabel;
@property (nonatomic, strong) SSThemedLabel *discussLabel;
@property (nonatomic, strong) SSThemedImageView *cornerImageView;
@property (nonatomic, strong) SSThemedView *bottomLineView;

- (void)configWithHashtagModel:(TTUGCHashtagModel *)hashtagModel row:(NSInteger)row longSeparatorLine:(BOOL)longSeparatorLine;

@end
