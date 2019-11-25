//
//  FHDetailNewUGCSocialCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/11/25.
//

#import "FHDetailNewUGCSocialCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHExtendHotAreaButton.h"
#import "UILabel+House.h"
#import "FHEnvContext.h"
#import "TTAccountManager.h"
#import <TTSandBoxHelper.h>

@interface FHDetailNewUGCSocialCell()

@property (nonatomic, strong)   UIControl       *bgControl; // 底部按钮

@end

@implementation FHDetailNewUGCSocialCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
//    if (self.currentData == data || ![data isKindOfClass:[FHDetailHouseOutlineInfoModel class]]) {
//        return;
//    }
    self.currentData = data;
  
    [self layoutIfNeeded];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor themeWhite];
    self.bgControl = [[UIControl alloc] initWithFrame:CGRectZero];
    self.bgControl.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.bgControl];
    [self.bgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(113);
    }];
}

// add by zyk
- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"ugc_social_info";
}

@end
