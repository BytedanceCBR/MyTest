//
//  FHHouseSaleFlowView.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2020/9/6.
//

#import "FHHouseSaleFlowView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "UIViewAdditions.h"

@interface FHHouseSaleFlowView ()

@property(nonatomic, strong) UILabel *titleLabel;

@end

@implementation FHHouseSaleFlowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        [self initViews];
    }
    return self;
}

- (void)initViews {
    self.titleLabel = [self LabelWithFont:[UIFont themeFontSemibold:18] textColor:[UIColor themeGray1]];
    _titleLabel.text = @"卖房流程";
    _titleLabel.frame = CGRectMake(15, 12, self.width - 30, 25);
    [self addSubview:_titleLabel];
    
    NSArray *textArray = @[@"发布房源",@"电话核实",@"经纪人实勘",@"房源展示"];
    
    CGFloat width = ceil((self.width - 8)/4);
    CGFloat padding = ceil((width - 18 - 32)/2);
    
    for (NSInteger i = 0; i < 4; i++) {
        NSInteger j = i + 1;
        if(j < 4){
            UIImageView *arror = [[UIImageView alloc] initWithFrame:CGRectMake(4 + width * j - 9, self.titleLabel.bottom + 20, 18, 12)];
            arror.image = [UIImage imageNamed:@"house_sale_flow_arror"];
            [self addSubview:arror];
        }
//        house_sale_flow_1
        NSString *imageName = [NSString stringWithFormat:@"house_sale_flow_%li",(long)i];
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(4 + width * (i + 1) - 9 - 32 - padding, self.titleLabel.bottom + 10, 32, 32)];
        icon.image = [UIImage imageNamed:imageName];
        [self addSubview:icon];
        
        UILabel *textLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray1]];
        textLabel.text = textArray[i];
        textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:textLabel];
        textLabel.top = icon.bottom + 2;
        textLabel.height = 17;
        textLabel.width = width;
        textLabel.centerX = icon.centerX;

    }
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
