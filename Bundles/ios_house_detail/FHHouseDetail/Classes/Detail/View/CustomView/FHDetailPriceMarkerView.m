//
//  FHDetailPriceMarkerView.m
//  PNChartDemo
//
//  Created by 张静 on 2019/2/19.
//  Copyright © 2019年 kevinzhow. All rights reserved.
//

#import "FHDetailPriceMarkerView.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import <Masonry/Masonry.h>
#import "UIView+House.h"

@interface FHDetailPriceMarkerView ()

@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *firstLabel;
@property(nonatomic , strong) UILabel *secondLabel;
@property(nonatomic , strong) UILabel *thirdLabel;

@property(nonatomic, assign) NSInteger selectIndex;
@property(nonatomic, assign) double unitPerSquare;

@end

@implementation FHDetailPriceMarkerView

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
    [self addSubview:self.titleLabel];
    [self addSubview:self.firstLabel];
    [self addSubview:self.secondLabel];
    [self addSubview:self.thirdLabel];

    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
    
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
    
    if (self.markData.selectPoint.x + self.width > [UIScreen mainScreen].bounds.size.width / 2) {
        self.left = self.markData.selectPoint.x - self.width - 10;
    }else {
        self.left = self.markData.selectPoint.x + 10;
    }
    self.centerY = self.superview.height / 2;
}

- (void)refreshContent:(FHDetailPriceMarkerData *)markData
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
        
        FHDetailPriceMarkerItem *item = items.firstObject;
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
        
        FHDetailPriceMarkerItem *item = items[1];
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
        
        FHDetailPriceMarkerItem *item = items[1];
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
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UILabel *)firstLabel
{
    if (!_firstLabel) {
        _firstLabel = [[UILabel alloc]init];
        _firstLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _firstLabel.font = [UIFont themeFontRegular:12];
        _firstLabel.textColor = [UIColor whiteColor];
    }
    return _firstLabel;
}

- (UILabel *)secondLabel
{
    if (!_secondLabel) {
        _secondLabel = [[UILabel alloc]init];
        _secondLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _secondLabel.font = [UIFont themeFontRegular:12];
        _secondLabel.textColor = [UIColor whiteColor];
    }
    return _secondLabel;
}

- (UILabel *)thirdLabel
{
    if (!_thirdLabel) {
        _thirdLabel = [[UILabel alloc]init];
        _thirdLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _thirdLabel.font = [UIFont themeFontRegular:12];
        _thirdLabel.textColor = [UIColor whiteColor];
    }
    return _thirdLabel;
}

@end

@implementation FHDetailPriceMarkerData



@end

@implementation FHDetailPriceMarkerItem



@end

