//
//  FHDetailPriceToastView.m
//  PNChartDemo
//
//  Created by 张静 on 2019/2/19.
//  Copyright © 2019年 kevinzhow. All rights reserved.
//

#import "FHDetailPriceToastView.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import <Masonry/Masonry.h>
#import "UIView+House.h"
#import <FHHouseBase/FHUtils.h>

@interface FHDetailPriceToastView ()
@property(nonatomic, assign) double unitPerSquare;
@property(nonatomic, weak) UIImageView *shadowImage;

@end

@implementation FHDetailPriceToastView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.unitPerSquare = 100 * 10000.0;
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(-15);
        make.right.equalTo(self).offset(15);
        make.top.equalTo(self).offset(-20);
        make.bottom.equalTo(self).offset(20);
    }];
    [self addSubview:self.titleLabel];
    [self addSubview:self.firstLabel];
    [self addSubview:self.secondLabel];
    [self addSubview:self.thirdLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(10);
    }];
    [self.firstLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(10);
    }];
    [self.secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.firstLabel.mas_bottom).mas_offset(2);
        make.left.mas_equalTo(10);
    }];
    [self.thirdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.secondLabel.mas_bottom).mas_offset(2);
        make.left.mas_equalTo(10);
    }];

}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        shadowImage.image = [[UIImage imageNamed:@"top_left_right_bottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,25,20,25)resizingMode:UIImageResizingModeStretch];
        [self addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat maxWidth = MAX(MAX(self.titleLabel.width, self.firstLabel.width), MAX(self.secondLabel.width, self.thirdLabel.width)) + 20;
    self.width = maxWidth;
    
    self.titleLabel.width = self.width - 20;
    self.firstLabel.width = self.width - 20;
    self.secondLabel.width = self.width - 20;
    self.thirdLabel.width = self.width - 20;
    self.height = self.thirdLabel.bottom + 20;
}

- (void)refreshContent:(FHDetailPriceToastData *)markData
{
    self.firstLabel.text = nil;
    self.secondLabel.text = nil;
    self.thirdLabel.text = nil;
    
    self.unitPerSquare = markData.unitPerSquare;
    NSArray *items = markData.trendItems;
    if (items.count < 1) {
        return;
    }
    if (items.count > 0) {
        
        FHDetailPriceToastItem *item = items.firstObject;
        NSString *name = item.name;
        self.titleLabel.text = item.priceModel.timeStr;
        if (name.length > 7) {
            name = [NSString stringWithFormat:@"%@...",[name substringToIndex:7]];
        }
        double unitPerSquare = self.unitPerSquare != 0 ? self.unitPerSquare : 1000000.00;
        if (unitPerSquare >= 1000000.00) {
            double price = item.priceModel.price.doubleValue / unitPerSquare;
            self.firstLabel.text = unitPerSquare >= 1000000.00 ? [NSString stringWithFormat:@"%@：%.2f万元/平",name,price] : [NSString stringWithFormat:@"%@：%.2f元/平",name,price];
        }else {
            NSInteger price = item.priceModel.price.doubleValue / unitPerSquare;
            self.firstLabel.text = [NSString stringWithFormat:@"%@：%ld元/平",name,(long)price];
        }
    }
    if (items.count > 1) {
        
        FHDetailPriceToastItem *item = items[1];
        NSString *name = item.name;
        self.titleLabel.text = item.priceModel.timeStr;
        if (name.length > 7) {
            name = [NSString stringWithFormat:@"%@...",[name substringToIndex:7]];
        }
        double unitPerSquare = self.unitPerSquare != 0 ? self.unitPerSquare : 1000000.00;
        if (unitPerSquare >= 1000000.00) {
            double price = item.priceModel.price.doubleValue / unitPerSquare;
            self.secondLabel.text = unitPerSquare >= 1000000.00 ? [NSString stringWithFormat:@"%@：%.2f万元/平",name,price] : [NSString stringWithFormat:@"%@：%.2f元/平",name,price];
        }else {
            NSInteger price = item.priceModel.price.doubleValue / unitPerSquare;
            self.secondLabel.text = [NSString stringWithFormat:@"%@：%ld元/平",name,(long)price];
        }
    }
    if (items.count > 2) {
        
        FHDetailPriceToastItem *item = items[2];
        NSString *name = item.name;
        self.titleLabel.text = item.priceModel.timeStr;
        if (name.length > 7) {
            name = [NSString stringWithFormat:@"%@...",[name substringToIndex:7]];
        }
        double unitPerSquare = self.unitPerSquare != 0 ? self.unitPerSquare : 1000000.00;
        if (unitPerSquare >= 1000000.00) {
            double price = item.priceModel.price.doubleValue / unitPerSquare;
            self.thirdLabel.text = unitPerSquare >= 1000000.00 ? [NSString stringWithFormat:@"%@：%.2f万元/平",name,price] : [NSString stringWithFormat:@"%@：%.2f元/平",name,price];
        }else {
            NSInteger price = item.priceModel.price.doubleValue / unitPerSquare;
            self.thirdLabel.text = [NSString stringWithFormat:@"%@：%ld元/平",name,(long)price];
        }
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = [UIFont themeFontRegular:14];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (UILabel *)firstLabel
{
    if (!_firstLabel) {
        _firstLabel = [[UILabel alloc]init];
        _firstLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _firstLabel.font = [UIFont themeFontRegular:12];
        _firstLabel.textColor = [UIColor blackColor];
    }
    return _firstLabel;
}

- (UILabel *)secondLabel
{
    if (!_secondLabel) {
        _secondLabel = [[UILabel alloc]init];
        _secondLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _secondLabel.font = [UIFont themeFontRegular:12];
        _secondLabel.textColor = [UIColor blackColor];
    }
    return _secondLabel;
}

- (UILabel *)thirdLabel
{
    if (!_thirdLabel) {
        _thirdLabel = [[UILabel alloc]init];
        _thirdLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _thirdLabel.font = [UIFont themeFontRegular:12];
        _thirdLabel.textColor = [UIColor blackColor];
    }
    return _thirdLabel;
}

@end

@implementation FHDetailPriceToastData



@end

@implementation FHDetailPriceToastItem



@end

