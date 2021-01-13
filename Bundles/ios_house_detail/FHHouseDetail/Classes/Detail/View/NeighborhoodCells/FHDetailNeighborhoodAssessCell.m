//
//  FHDetailNeighborhoodAssessCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/3/6.
//

#import "FHDetailNeighborhoodAssessCell.h"
#import "FHDetailNeighborhoodModel.h"
#import "TTDeviceHelper.h"
#import "UIView+House.h"
#import <FHHouseBase/FHUserTracker.h>
#import "TTAccountManager.h"
#import "TTStringHelper.h"
#import "FHCardSliderView.h"
#import "FHDetailAccessCellModel.h"

@interface FHDetailNeighborhoodAssessCell ()

@property(nonatomic , strong) NSMutableArray *dataList;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, weak) UIImageView *shadowImage;
@property(nonatomic , strong) FHCardSliderView *cardSliderView;
@property(nonatomic , strong) UILabel *titleLabel;

@end

@implementation FHDetailNeighborhoodAssessCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        [self initConstaints];
    }
    return self;
}

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(-4.5, 0, -4.5, 0));
    }];
    
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontSemibold:16] textColor:[UIColor themeGray1]];
    _titleLabel.text = @"小区攻略";
    [self.containerView addSubview:_titleLabel];

    self.cardSliderView = [[FHCardSliderView alloc] initWithFrame:CGRectZero type:FHCardSliderViewTypeHorizontal];
    _cardSliderView.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:_cardSliderView];
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (void)initConstaints {
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(0, 9, 4.5, 9));
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView).offset(12);
        make.left.mas_equalTo(self.containerView).offset(12);
        make.right.mas_equalTo(self.containerView).offset(-12);
        make.height.mas_equalTo(22);
    }];
    
    [_cardSliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
        make.left.mas_equalTo(self.containerView).offset(12);
        make.right.mas_equalTo(self.containerView).offset(-12);
        make.height.mas_equalTo([FHCardSliderView getViewHeight]);
        make.bottom.mas_equalTo(self.containerView).offset(-12);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailAccessCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailAccessCellModel *cellModel = (FHDetailAccessCellModel *)data;
    self.shadowImage.image = cellModel.shadowImage;
    if (cellModel.shdowImageScopeType != FHHouseShdowImageScopeTypeAll && cellModel.shdowImageScopeType != FHHouseShdowImageScopeTypeBottomAll) {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
        }];
        [self.cardSliderView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
        }];
    }
    FHDetailNeighborhoodDataStrategyModel *strategy = cellModel.strategy;
    _titleLabel.text = strategy.title.length > 0 ? strategy.title : @"小区攻略";
    
    _cardSliderView.tracerDic = cellModel.tracerDic;
    [_cardSliderView setCardListData:cellModel.cards];
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    [self.cardSliderView trackCardShow];
    return @"guide";
}

@end
