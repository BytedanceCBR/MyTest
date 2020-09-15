//
//  FHNewHouseDetailSurroundingCollectionCell.m
//  Pods
//
//  Created by bytedance on 2020/9/11.
//

#import "FHNewHouseDetailSurroundingCollectionCell.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHNewHouseDetailSurroundingCollectionCell ()

@property (nonatomic, strong) UIView *locationContentView;
@property (nonatomic, strong) UILabel *locationTitleLabel;
@property (nonatomic, strong) UILabel *locationValueLabel;

@property (nonatomic, strong) UIView *consultContentView;
@property (nonatomic, strong) UILabel *consultTitleLabel;
@property (nonatomic, strong) UILabel *consultValueLabel;
@property (nonatomic, strong) UIImageView *consultImageView;
@property (nonatomic, strong) UIButton *actionBtn;

@end

@implementation FHNewHouseDetailSurroundingCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if ([data isKindOfClass:[FHNewHouseDetailSurroundingCellModel class]]) {
        FHNewHouseDetailSurroundingCellModel *cellModel = (FHNewHouseDetailSurroundingCellModel *)data;
        CGFloat height = 0;
        if (cellModel.surroundingInfo.location.length > 0) {
            height += 30;
        }
        if (cellModel.surroundingInfo.surrounding) {
            height += 35;
        }
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.locationContentView = [[UIView alloc] init];
        [self.contentView addSubview:self.locationContentView];
        [self.locationContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(20);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
        }];
        
        self.locationTitleLabel = [[UILabel alloc] init];
        self.locationTitleLabel.font = [UIFont themeFontRegular:16];
        self.locationTitleLabel.textColor = [UIColor themeGray3];
        self.locationTitleLabel.text = @"位置:";
        [self.locationContentView addSubview:self.locationTitleLabel];
        [self.locationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(42);
        }];
        
        self.locationValueLabel = [[UILabel alloc] init];
        self.locationValueLabel.font = self.locationTitleLabel.font;
        self.locationValueLabel.numberOfLines = 1;
        self.locationValueLabel.textColor = [UIColor themeGray1];
        self.locationValueLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.locationContentView addSubview:self.locationValueLabel];
        [self.locationValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.locationTitleLabel.mas_right);
            make.top.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        
        self.consultContentView = [[UIView alloc] init];
        [self.contentView addSubview:self.consultContentView];
        [self.consultContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(15);
            make.height.mas_equalTo(20);
            make.top.mas_equalTo(self.locationContentView.mas_bottom).mas_offset(10);
        }];
        self.consultTitleLabel = [[UILabel alloc] init];
        self.consultTitleLabel.font = [UIFont themeFontRegular:16];
        self.consultTitleLabel.textColor = [UIColor themeGray3];
        self.consultTitleLabel.text = @"位置:";
        [self.consultContentView addSubview:self.consultTitleLabel];
        [self.consultTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(42);
        }];
        
        self.consultValueLabel = [[UILabel alloc] init];
        self.consultValueLabel.font = self.consultValueLabel.font;
        self.consultValueLabel.numberOfLines = 1;
        self.consultValueLabel.textColor = [UIColor colorWithHexStr:@"#ff9629"];
        self.consultValueLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.consultContentView addSubview:self.consultValueLabel];
        [self.consultValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.consultTitleLabel.mas_right);
            make.top.bottom.mas_equalTo(0);
            make.right.mas_lessThanOrEqualTo(-30);;
        }];
        
        self.consultImageView = [[UIImageView alloc] init];
        self.consultImageView.image = [UIImage imageNamed:@"plot__message"];
        self.consultImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.consultContentView addSubview:self.consultImageView];
        [self.consultImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.consultValueLabel.mas_right).offset(3);
            make.centerY.mas_equalTo(self.consultContentView).offset(-1);
            make.height.mas_equalTo(15);
            make.width.mas_equalTo(16);
        }];
        
        __weak typeof(self) weakSelf = self;
        self.actionBtn = [[UIButton alloc]init];
        [self.locationContentView addSubview:self.actionBtn];
        [self.actionBtn btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
            if (weakSelf.imActionBlock) {
                weakSelf.imActionBlock();
            }
        }];
        [self.actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.mas_equalTo(self.consultValueLabel);
            make.right.mas_equalTo(self.consultContentView.mas_right);
        }];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailSurroundingCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHNewHouseDetailSurroundingCellModel *cellModel = (FHNewHouseDetailSurroundingCellModel *)data;
    
    

    if (cellModel.surroundingInfo.location.length > 0) {
        self.locationValueLabel.text = cellModel.surroundingInfo.location;
    } else {
        [self.locationValueLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    if (cellModel.surroundingInfo.surrounding) {
        self.consultContentView.hidden = NO;
        self.consultTitleLabel.text = @"配套:";
        self.consultValueLabel.text = cellModel.surroundingInfo.surrounding.text;
    }else {
        self.consultContentView.hidden = YES;
    }
}

@end

@implementation FHNewHouseDetailSurroundingCellModel

@end
