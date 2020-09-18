//
//  SettingNormalCell.m
//  Article
//
//  Created by Chen Hong on 16/1/6.
//
//

#import "SettingNormalCell.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTDeviceUIUtils.h>

#define kPushCellLeftPadding [TTDeviceUIUtils tt_padding:30.f/2]

@implementation SettingNormalCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //iPad下 留白
        self.needMargin = YES;
        _topLine = [[UIView alloc]init];
        _topLine.backgroundColor = [UIColor colorWithHexString:@"#e7e7e7"];
        [self.contentView addSubview:_topLine];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.textLabel sizeToFit];
    self.textLabel.frame = CGRectIntegral(self.textLabel.frame);
    self.textLabel.centerY = self.height / 2;
    self.textLabel.left = kPushCellLeftPadding;
    self.topLine.frame = CGRectMake(kPushCellLeftPadding, 0, self.width - kPushCellLeftPadding, [TTDeviceHelper ssOnePixel]);
}

@end
