//
//  TTProfileBaseFunctionCell.h
//  Article
//
//  Created by lizhuoli on 2017/3/28.
//
//

#import "SSThemed.h"
#import "TTBadgeNumberView.h"
#import "SSAvatarView.h"
#import "TTSettingMineTabEntry.h"

@protocol TTProfileBaseFunctionCellProtocol <NSObject>

@optional
- (void)setupExtraConfig;
@required
- (void)configWithModel:(id)model;

@end

@interface TTProfileBaseFunctionCell : SSThemedTableViewCell <TTProfileBaseFunctionCellProtocol>

@property (nonatomic, strong) SSThemedLabel *titleLb;
@property (nonatomic, strong) SSThemedImageView *cellImageView;
@property (nonatomic, strong) SSThemedLabel *accessoryLb;
@property (nonatomic, strong) TTBadgeNumberView *badgeView;
@property (nonatomic, strong) SSThemedImageView *rightImageView;

/** 右侧下标头像 */
@property (nonatomic, strong) SSAvatarView *accessoryAvatarView;

- (void)setHintStyle:(TTSettingHintStyle)hintStyle number:(long long)number;
- (void)setCellImageName:(NSString*)imageName;
- (void)configWithEntry:(TTSettingMineTabEntry *)entry;
- (void)setupSubviews;

@end
