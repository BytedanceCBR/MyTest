//
//  FHDetailNewPriceNotifyCell.m
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/9.
//

#import "FHDetailNewPriceNotifyCell.h"
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHDetailNewPriceNotifyCell ()

@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, strong) UIView *priceBgView;
@property (nonatomic, strong) UIButton *priceChangedNotify;
@property (nonatomic, strong) UIView *verticalLineView;
@property (nonatomic, strong) UIButton *openNotify;

@end

@implementation FHDetailNewPriceNotifyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNewPriceNotifyCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailNewPriceNotifyCellModel *model = (FHDetailNewPriceNotifyCellModel *)data;
    
    adjustImageScopeType(model)
}

- (void)setupUI
{
    [self.contentView addSubview:self.shadowImage];
    [self.contentView addSubview:self.containerView];
    [self.containerView addSubview:self.priceBgView];

    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(15);
        make.right.mas_equalTo(self.contentView).mas_offset(-15);
        make.top.equalTo(self.shadowImage).offset(12);
        make.bottom.equalTo(self.shadowImage).offset(-20);
    }];
    [self.priceBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(45);
        make.top.equalTo(0);
        make.bottom.mas_equalTo(-30);
    }];
    _priceChangedNotify = [UIButton buttonWithType:UIButtonTypeCustom];
    _priceChangedNotify.titleLabel.font = [UIFont themeFontRegular:16];
    
    UIImage *priceImg = ICON_FONT_IMG(16, @"\U0000e67e", [UIColor colorWithHexString:@"#9c6d43"]);
    UIImage *openImage = ICON_FONT_IMG(16, @"\U0000e68e", [UIColor colorWithHexString:@"#9c6d43"]);

    [_priceChangedNotify setImage:priceImg forState:UIControlStateNormal];
    [_priceChangedNotify setImage:priceImg forState:UIControlStateHighlighted];
    
    [_priceChangedNotify setTitle:@"变价通知" forState:UIControlStateNormal];
    [_priceChangedNotify setTitleColor:[UIColor colorWithHexString:@"#9c6d43"] forState:UIControlStateNormal];
    _priceChangedNotify.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [self.containerView addSubview:_priceChangedNotify];
    [_priceChangedNotify addTarget:self action:@selector(priceChangedNotifyActionClick) forControlEvents:UIControlEventTouchUpInside];
    [_priceChangedNotify mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.priceBgView);
        make.left.equalTo(self.priceBgView);
        make.right.equalTo(self.priceBgView.mas_centerX);
    }];
    
    
    _verticalLineView = [UIView new];
    _verticalLineView.backgroundColor = [UIColor colorWithHexString:@"#ffe7d2"];
    [self.containerView addSubview:_verticalLineView];
    [_verticalLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.priceChangedNotify);
        make.bottom.equalTo(self.priceChangedNotify);
        make.left.equalTo(self.priceChangedNotify.mas_right);
        make.width.mas_equalTo(1);
    }];
    
    _openNotify = [UIButton buttonWithType:UIButtonTypeCustom];
    _openNotify.titleLabel.font = [UIFont themeFontRegular:16];
    [_openNotify setImage:openImage forState:UIControlStateNormal];
    [_openNotify setImage:openImage forState:UIControlStateHighlighted];
                                                
    [_openNotify setTitle:@"开盘通知" forState:UIControlStateNormal];
    [_openNotify setTitleColor:[UIColor colorWithHexString:@"#9c6d43"] forState:UIControlStateNormal];
    _openNotify.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [_openNotify addTarget:self action:@selector(openNotifyActionClick) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:_openNotify];
    [_openNotify mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.priceChangedNotify);
        make.left.equalTo(self.priceBgView.mas_centerX);
        make.right.equalTo(self.priceBgView);
    }];
}

- (void)openNotifyActionClick
{
    FHDetailNewPriceNotifyCellModel *model = (FHDetailNewPriceNotifyCellModel *)self.currentData;
    if ([model.contactModel isKindOfClass:[FHHouseDetailContactViewModel class]]) {
        FHHouseDetailContactViewModel *contactViewModel = (FHHouseDetailContactViewModel *)model.contactModel;
        if ([model.contactModel respondsToSelector:@selector(fillFormActionWithActionType:)]) {
            [contactViewModel fillFormActionWithActionType:FHFollowActionTypeFloorPan];
        }
    }
}
- (void)priceChangedNotifyActionClick
{
    FHDetailNewPriceNotifyCellModel *model = (FHDetailNewPriceNotifyCellModel *)self.currentData;
    if ([model.contactModel isKindOfClass:[FHHouseDetailContactViewModel class]]) {
        FHHouseDetailContactViewModel *contactViewModel = (FHHouseDetailContactViewModel *)model.contactModel;
        if ([model.contactModel respondsToSelector:@selector(fillFormActionWithActionType:)]) {
            [contactViewModel fillFormActionWithActionType:FHFollowActionTypePriceChanged];
        }
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"";
}

- (NSArray *)elementTypeStringArray:(FHHouseType)houseType
{
    return @[@"price_notice",@"openning_notice"];
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (UIView *)containerView {
    if (!_containerView) {
        UIView *containerView = [[UIView alloc]init];
        [self.contentView addSubview:containerView];
        _containerView = containerView;
    }
    return _containerView;
}

- (UIView *)priceBgView
{
    if (!_priceBgView) {
        _priceBgView = [[UIView alloc]init];
        _priceBgView.backgroundColor = [UIColor colorWithHexString:@"#fffaf0"];
        _priceBgView.layer.cornerRadius = 25;
        _priceBgView.layer.masksToBounds = YES;
    }
    return _priceBgView;
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


@implementation FHDetailNewPriceNotifyCellModel


@end
