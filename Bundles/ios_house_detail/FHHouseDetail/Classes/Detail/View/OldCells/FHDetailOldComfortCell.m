//
//  FHDetailOldComfortCell.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/5/21.
//

#import "FHDetailOldComfortCell.h"
#import "FHDetailStarHeaderView.h"
#import <FHHouseBase/FHUtils.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "FHDetailComfortItemView.h"

@interface FHDetailOldComfortCell ()

@property(nonatomic, strong) FHDetailStarHeaderView *headerView;
@property(nonatomic, strong) UIView *bgView;

@end

@implementation FHDetailOldComfortCell

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailOldComfortModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailOldComfortModel *model = (FHDetailOldComfortModel *)data;
    [self.headerView updateTitle:model.comfortInfo.title ? : @"舒适指数"];
    [self.headerView updateStarsCount:model.comfortInfo.score.integerValue];
    
    for (UIView *subview in self.bgView.subviews) {
        [subview removeFromSuperview];
    }
    
    UIView *lastView = nil;
    for (NSInteger index = 0; index < 4; index++) {
        FHDetailComfortItemView *itemView = [[FHDetailComfortItemView alloc]initWithFrame:CGRectZero];
        [self.bgView addSubview:itemView];
        switch (index) {
            case 0:
                itemView.titleLabel.text = model.comfortInfo.buildingAge;
                itemView.subtitleLabel.text = @"建议在 0-5年";
                itemView.icon.image = [UIImage imageNamed:@"detail_comfort_1"];
                break;
            case 1:
                itemView.titleLabel.text = model.comfortInfo.houseCount;
                itemView.subtitleLabel.text = @"建议在 3000-5000户";
                itemView.icon.image = [UIImage imageNamed:@"detail_comfort_2"];
                break;
            case 2:
                itemView.titleLabel.text = model.comfortInfo.plotRatio;
                itemView.subtitleLabel.text = @"越低越好,最高不超过5";
                itemView.icon.image = [UIImage imageNamed:@"detail_comfort_3"];
                break;
            case 3:
                itemView.titleLabel.text = model.comfortInfo.propertyFee;
                itemView.icon.image = [UIImage imageNamed:@"detail_comfort_4"];
                itemView.subtitleLabel.text = @"越贵服务等级越高";
                break;
            default:
                break;
        }
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            // first column
            if (index / 2 == 0) {
                make.top.mas_equalTo(20);
            }else {
                make.top.mas_equalTo(lastView.mas_bottom).mas_offset(20);
                make.bottom.mas_equalTo(-20);
            }
            // first line
            if (index % 2 == 0) {
                make.left.mas_equalTo(0);
            } else {
                make.left.mas_equalTo(lastView.mas_right);
                make.right.mas_equalTo(0);
            }
            if (lastView) {
                make.width.height.mas_equalTo(lastView);
            }
        }];
        lastView = itemView;
    }
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

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"neighborhood_surroundings";
}

- (void)setupUI
{
    _headerView = [[FHDetailStarHeaderView alloc] init];
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(110);
        make.bottom.mas_equalTo(-(178 - 43 + 30));
    }];
    
    [self.contentView addSubview:self.bgView];
    self.bgView.frame = CGRectMake(20, 110 - 43, [UIScreen mainScreen].bounds.size.width - 40, 178);
    [FHUtils addShadowToView:self.bgView withOpacity:0.1 shadowColor:[UIColor blackColor] shadowOffset:CGSizeMake(0, 2) shadowRadius:6 andCornerRadius:4];
}

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end


@implementation FHDetailOldComfortModel

@end
