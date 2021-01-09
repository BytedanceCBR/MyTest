//
//  FHNewHouseDetailMapResultCollectionCell.m
//  Pods
//
//  Created by bytedance on 2020/9/11.
//

#import "FHNewHouseDetailMapResultCollectionCell.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>

@implementation FHNewHouseDetailMapResultCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    return CGSizeMake(width, 36);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont themeFontRegular:14];
    self.titleLabel.textColor = [UIColor themeGray1];
    self.subTitleLabel.font = [UIFont themeFontRegular:12];
    self.subTitleLabel.textColor = [UIColor themeGray3];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont themeFontRegular:14];
        self.titleLabel.textColor = [UIColor themeGray1];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.centerY.mas_equalTo(self);
        }];
        
        self.subTitleLabel = [[UILabel alloc] init];
        self.subTitleLabel.font = [UIFont themeFontRegular:12];
        self.subTitleLabel.textColor = [UIColor themeGray3];
        self.subTitleLabel.textAlignment = NSTextAlignmentRight;
        self.subTitleLabel.hidden = YES;
        [self addSubview:self.subTitleLabel];
        [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.titleLabel.mas_right).mas_offset(5);
            make.centerY.mas_equalTo(self.titleLabel);
            make.right.mas_equalTo(-12);
        }];
        
        [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.subTitleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return self;
}

- (void)bindViewModel:(id)viewModel {
    
}

@end
