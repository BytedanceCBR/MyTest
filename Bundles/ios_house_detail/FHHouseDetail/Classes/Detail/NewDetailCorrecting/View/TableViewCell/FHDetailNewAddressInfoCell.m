//
//  FHDetailNewAddressInfoCell.m
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/9.
//

#import "FHDetailNewAddressInfoCell.h"
#import <ByteDanceKit/UIDevice+BTDAdditions.h>
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHDetailNewAddressInfoCell ()

@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *mapBtn;
@property (nonatomic, strong) UIImageView *rightArrow;

@end

@implementation FHDetailNewAddressInfoCell

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
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNewAddressInfoCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailNewAddressInfoCellModel *model = (FHDetailNewAddressInfoCellModel *)data;
    adjustImageScopeType(model)

    self.titleLabel.text = @"zjing江宁-秣陵南京市江宁区云台河路地铁站向北约500米江宁-秣陵南京市江宁区云台河路地铁站向北约500米";
}

- (void)setupUI
{
    [self.contentView addSubview:self.shadowImage];
    [self.contentView addSubview:self.containerView];
    [self.containerView addSubview:self.topLine];
    [self.containerView addSubview:self.mapBtn];
    [self.containerView addSubview:self.titleLabel];
    [self.containerView addSubview:self.rightArrow];

    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    self.containerView.backgroundColor = [UIColor whiteColor];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(15);
        make.right.mas_equalTo(self.contentView).mas_offset(-15);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.containerView).mas_offset(15);
        make.right.mas_equalTo(self.containerView).mas_offset(-15);
        make.height.mas_equalTo([UIDevice btd_onePixel]);
        make.top.mas_equalTo(0);
    }];
    [self.mapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.width.height.mas_equalTo(44);
        make.top.equalTo(self.titleLabel);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topLine.mas_bottom).mas_offset(25);
        make.left.mas_equalTo(self.mapBtn.mas_right).mas_offset(15);
        make.right.mas_equalTo(self.rightArrow.mas_left).mas_offset(-15);
        make.bottom.mas_equalTo(-30);
    }];
    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.containerView).mas_offset(-15);
        make.width.height.mas_equalTo(18);
        make.centerY.equalTo(self.containerView);
    }];
    
    [self.mapBtn addTarget:self action:@selector(clickMapAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickMapAction:(UIButton *)btn {
//if (self.model.mapImageClick) {
//    self.model.mapImageClick();
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"house_info";
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
        containerView.clipsToBounds = YES;
        containerView.layer.cornerRadius = 10;
        [self.contentView addSubview:containerView];
        _containerView = containerView;
    }
    return _containerView;
}

- (UIButton *)mapBtn {
    if (!_mapBtn) {
        _mapBtn = [[UIButton alloc]init];
        [_mapBtn setImage:[UIImage imageNamed:@"plot_mapbtn"] forState:UIControlStateNormal];
    }
    return _mapBtn;
}

- (UIView *)topLine
{
    if (!_topLine) {
        _topLine = [[UIView alloc]init];
        _topLine.backgroundColor = [UIColor colorWithHexString:@"#e7e7e7"];
    }
    return _topLine;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont themeFontMedium:16];
        _titleLabel.textColor = [UIColor themeGray2];
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleLabel;
}

- (UIImageView *)rightArrow
{
    if (!_rightArrow) {
        UIImage *img = ICON_FONT_IMG(16, @"\U0000e670", [UIColor themeGray3]); //@"detail_entrance_arrow"
        _rightArrow = [[UIImageView alloc]initWithImage:img];
    }
    return _rightArrow;
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

@implementation FHDetailNewAddressInfoCellModel


@end
