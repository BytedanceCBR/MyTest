//
//  FHNewHouseDetailAddressInfoCollectionCell.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailAddressInfoCollectionCell.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHNewHouseDetailAddressInfoCollectionCell ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *nameLablel;
@property (nonatomic, strong) UIImageView *rightArrow;
@property (nonatomic, strong) UIControl *actionBtn;
@property (nonatomic, strong) UIButton *detailBtn;
@end

@implementation FHNewHouseDetailAddressInfoCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    return CGSizeMake(width, 54 + 20);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.containerView = [[UIView alloc] init];
        [self.contentView addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(20);
        }];
        
        self.nameLablel = [[UILabel alloc] init];
        self.nameLablel.font = [UIFont themeFontRegular:16];
        self.nameLablel.textColor = [UIColor colorWithHexStr:@"#aeadad"];
        [self.containerView addSubview:self.nameLablel];
        [self.nameLablel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.containerView);
            make.left.mas_equalTo(12);
            make.width.mas_equalTo(32);
        }];
        
//        UIImage *img = ICON_FONT_IMG(16, @"\U0000e670", [UIColor themeGray3]); //@"detail_entrance_arrow"
        self.rightArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"neighborhood_detail_v3_arrow_icon"]];
        [self.containerView addSubview:self.rightArrow];
        [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.containerView).mas_offset(-12);
            make.centerY.equalTo(self.containerView);
        }];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont themeFontRegular:16];
        self.titleLabel.textColor = [UIColor themeGray1];
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.containerView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12 + 42);
            make.right.mas_equalTo(self.rightArrow.mas_left).mas_offset(-4);
            make.centerY.mas_equalTo(self.containerView);
        }];

        self.actionBtn = [[UIControl alloc]init];
        [self.actionBtn addTarget:self action:@selector(clickMapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.actionBtn];
        [self.actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.rightArrow);
            make.left.mas_equalTo(self.nameLablel);
            make.top.bottom.equalTo(self.titleLabel);
        }];
        self.detailBtn = [[UIButton alloc] init];
        self.detailBtn.backgroundColor = [UIColor colorWithHexString:@"#f7f7f7"];
        self.detailBtn.layer.cornerRadius = 1;
        self.detailBtn.layer.masksToBounds = YES;
        [self.detailBtn setTitle:@"更多详细信息" forState:UIControlStateNormal];
        self.detailBtn.titleLabel.numberOfLines = 0;
        [self.detailBtn setTitleColor:[UIColor themeGray2] forState:UIControlStateNormal];
                self.detailBtn.titleLabel.font = [UIFont themeFontRegular:12];
        [self.contentView addSubview:self.detailBtn];
        [self.detailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.containerView.mas_bottom).offset(12);
            make.height.mas_equalTo(30);
            make.left.mas_equalTo(12);
            make.right.mas_equalTo(-12);
        }];
        [self.detailBtn addTarget:self action:@selector(clickMoreDetailAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailAddressInfoCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHNewHouseDetailAddressInfoCellModel *model = (FHNewHouseDetailAddressInfoCellModel *)data;
    self.titleLabel.text = model.courtAddress;
    self.nameLablel.text = @"地址";
}

- (void)clickMoreDetailAction:(UIButton *)btn {
    if (self.propertyDetailActionBlock) {
        self.propertyDetailActionBlock();
    }
}

- (void)clickMapAction:(UIButton *)btn
{
    if (self.mapDetailActionBlock) {
        self.mapDetailActionBlock();
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"";
}

@end

@implementation FHNewHouseDetailAddressInfoCellModel

@end
