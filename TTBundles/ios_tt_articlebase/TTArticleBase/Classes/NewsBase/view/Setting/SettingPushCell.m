//
//  SettingPushCell.m
//  Article
//
//  Created by Chen Hong on 16/1/6.
//
//

#import "SettingPushCell.h"
#import "SSThemed.h"
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/UIViewAdditions.h>

#define kPushCellFontSize 14
#define kPushCellLeftPadding [TTDeviceUIUtils tt_padding:30.f/2]
#define kPushCellRightPadding 80
#define kPushCellDetailLabelTopPadding 5
#define kPushCellTopPadding [TTDeviceUIUtils tt_padding:17.f]

@implementation SettingPushCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //iPad下 留白
        self.needMargin = YES;
        
        self.pushTitleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(15, 12, 80, 20)];
        self.pushTitleLabel.backgroundColor = [UIColor clearColor];
        self.pushTitleLabel.textColorThemeKey = kColorText1;
        [self.contentView addSubview:self.pushTitleLabel];
        
        self.pushDetailLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        self.pushDetailLabel.backgroundColor = [UIColor clearColor];
        self.pushDetailLabel.font = [UIFont systemFontOfSize:kPushCellFontSize];
        self.pushDetailLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        self.pushDetailLabel.numberOfLines = 0;
        self.pushDetailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:self.pushDetailLabel];
        
        _topLine = [[UIView alloc]init];
        _topLine.backgroundColor = [UIColor colorWithHexString:@"#e7e7e7"];
        [self.contentView addSubview:_topLine];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.pushTitleLabel sizeToFit];
    if (isEmptyString(self.pushDetailLabel.text)) {
        self.pushTitleLabel.origin = CGPointMake(kPushCellLeftPadding, (self.contentView.height - self.pushTitleLabel.height) / 2);
    } else {
        CGFloat width = self.width - kPushCellLeftPadding * 2;
        CGSize size = [self.pushDetailLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
        self.pushDetailLabel.size = size;
        CGFloat totalHeight = self.pushTitleLabel.height + kPushCellDetailLabelTopPadding + self.pushDetailLabel.height;
        self.pushTitleLabel.origin = CGPointMake(kPushCellLeftPadding, kPushCellTopPadding);
        self.pushDetailLabel.origin = CGPointMake(kPushCellLeftPadding, self.pushTitleLabel.bottom + [TTDeviceUIUtils tt_padding:11]);
        self.accessoryView.origin = CGPointMake([TTDeviceUIUtils tt_padding:313.f], self.pushTitleLabel.top - 7);
    }
    self.topLine.frame = CGRectMake(kPushCellLeftPadding, 0, self.width - kPushCellLeftPadding, [TTDeviceHelper ssOnePixel]);
}

@end
