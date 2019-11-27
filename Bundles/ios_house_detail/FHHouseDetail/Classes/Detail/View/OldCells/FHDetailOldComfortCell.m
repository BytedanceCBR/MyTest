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
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHDetailOldComfortCell ()

@property(nonatomic, strong) FHDetailStarHeaderView *headerView;
@property(nonatomic, strong) UIView *bgView;
@property(weak, nonatomic) UIImageView *shadowImage;

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
    
    UIView *firstView = nil;
    for (NSInteger index = 0; index < 4; index++) {
        FHDetailComfortItemView *itemView = [[FHDetailComfortItemView alloc]initWithFrame:CGRectZero];
        [self.bgView addSubview:itemView];
        switch (index) {
            case 0:
                itemView.titleLabel.text = model.comfortInfo.buildingAge ? : @"楼龄 -年";
                itemView.subtitleLabel.text = @"建议在0-5年";
                itemView.icon.image = ICON_FONT_IMG(20, @"\U0000e676", nil);//@"detail_comfort_1"
                break;
            case 1:
                itemView.titleLabel.text = model.comfortInfo.houseCount ? : @"规模 -户";
                itemView.subtitleLabel.text = @"建议在3000-5000户";
                itemView.icon.image = ICON_FONT_IMG(20, @"\U0000e662", nil);//@"detail_comfort_2"
                break;
            case 2:
                itemView.titleLabel.text = model.comfortInfo.plotRatio ? : @"容积率 -";
                itemView.subtitleLabel.text = @"越低越好，最高不超过5";
                itemView.icon.image = ICON_FONT_IMG(20, @"\U0000e663", nil);//@"detail_comfort_3"
                break;
            case 3:
                itemView.titleLabel.text = model.comfortInfo.propertyFee ? : @"物业费 -元/平/月";
                itemView.icon.image = ICON_FONT_IMG(20, @"\U0000e664", nil);//@"detail_comfort_4"
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
                make.top.mas_equalTo(firstView.mas_bottom).mas_offset(20);
                make.bottom.mas_equalTo(-20);
            }
            // first line
            if (index % 2 == 0) {
                make.left.mas_equalTo(0);
            } else {
                make.left.mas_equalTo(firstView.mas_right);
                make.right.mas_equalTo(0);
            }
            if (firstView) {
                make.width.height.mas_equalTo(firstView);
            }
        }];
        if (!firstView) {
            firstView = itemView;
        }        
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

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        shadowImage.image = [[UIImage imageNamed:@"left_right"]resizableImageWithCapInsets:UIEdgeInsetsMake(30,30,30,30) resizingMode:UIImageResizingModeStretch];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (void)setupUI
{
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(-20);
        make.right.mas_equalTo(self.contentView).offset(20);
        make.top.equalTo(self.contentView);
        make.height.equalTo(self.contentView);
    }];
     [self.contentView addSubview:self.shadowImage];
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
