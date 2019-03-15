//
//  FHDetailRentFacilityCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/18.
//

#import "FHDetailRentFacilityCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "UILabel+House.h"
#import "FHRowsView.h"
#import "FHHouseRentFacilityItemView.h"
#import "FHDetailStrickoutLabel.h"
#import "FHDetailHeaderView.h"

@interface FHDetailRentFacilityCell ()

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, strong)   FHRowsView       *facilityItemView;
@property (nonatomic, strong)   UIView       *containerView;

@end

@implementation FHDetailRentFacilityCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailRentFacilityModel class]]) {
        return;
    }
    self.currentData = data;
    //
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    FHDetailRentFacilityModel *model = (FHDetailRentFacilityModel *)data;
    if (model.facilities.count > 0) {
        _facilityItemView = [[FHRowsView alloc] initWithRowCount:5];
        [self.containerView addSubview:_facilityItemView];
        [_facilityItemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(self.containerView);
            make.bottom.mas_equalTo(-10);
        }];
        NSMutableArray *tempArray = [NSMutableArray new];
        [model.facilities enumerateObjectsUsingBlock:^(FHRentDetailResponseDataFacilitiesModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UILabel *strickoutLable = [[UILabel alloc] init];
            strickoutLable.textColor = [UIColor colorWithHexString:@"#a0aab3"];
            strickoutLable.font = [UIFont themeFontRegular:14];
            FHHouseRentFacilityItemView *itemView = [[FHHouseRentFacilityItemView alloc] initWithStrickoutLabel:strickoutLable];
            if (obj.enabled) {
                itemView.label.text = obj.name;
                itemView.strickoutLabel.hidden = YES;
            } else {
                if (obj.name.length > 0) {
                    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:obj.name];
                    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, obj.name.length)];
                    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor colorWithHexString:@"#a0aab3"] range:NSMakeRange(0, obj.name.length)];
                    itemView.strickoutLabel.attributedText = attri;
                    itemView.strickoutLabel.hidden = NO;
                }
            }
            if (obj.iconUrl.length > 0) {
                [itemView.iconView bd_setImageWithURL:[NSURL URLWithString:obj.iconUrl] options:BDImageRequestSetAnimationFade];
            }
            [tempArray addObject:itemView];
        }];
        if (tempArray.count > 0) {
            [self.facilityItemView addItemViews:tempArray];
        }
    }
   
    [self layoutIfNeeded];
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"house_facility";
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
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"房屋配置";
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(46);
    }];

    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

@end

// FHDetailRentFacilityModel

@implementation FHDetailRentFacilityModel


@end
