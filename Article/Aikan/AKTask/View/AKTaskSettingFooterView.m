//
//  AKTaskSettingFootView.m
//  Article
//
//  Created by chenjiesheng on 2018/3/2.
//
#import "AKTaskSettingDefine.h"
#import "AKTaskSettingFooterView.h"

#import <UIColor+TTThemeExtension.h>
@interface AKTaskSettingFooterView ()

@property (nonatomic, strong)UILabel            *desLabel;

@end

@implementation AKTaskSettingFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createComponent];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.desLabel.centerX = self.width / 2;
    self.desLabel.top = kAKPaddingTopFooterViewDesLabel;
}

- (void)createComponent
{
    self.backgroundColor = [UIColor colorWithHexString:@"F4F5F6"];
    [self createDesLabel];
}

- (void)createDesLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:kAKFontFootView];
    label.textColor = [UIColor colorWithHexString:@"999999"];
    label.text = @"后续如需再次开启，可在我的-任务中的设置打开";
    [label sizeToFit];
    [self addSubview:label];
    self.desLabel = label;
}

@end
