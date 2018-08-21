//
//  SettingPushCell.m
//  Article
//
//  Created by Chen Hong on 16/1/6.
//
//

#import "SettingPushCell.h"
#import "SSThemed.h"

#define kPushCellFontSize 12
#define kPushCellLeftPadding [TTDeviceUIUtils tt_padding:30.f/2]
#define kPushCellRightPadding 80
#define kPushCellDetailLabelTopPadding 5

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
        self.pushDetailLabel.textColorThemeKey = kColorText4;
        self.pushDetailLabel.numberOfLines = 0;
        self.pushDetailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:self.pushDetailLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.pushTitleLabel sizeToFit];
    if (isEmptyString(self.pushDetailLabel.text)) {
        self.pushTitleLabel.origin = CGPointMake(kPushCellLeftPadding, (self.contentView.height - self.pushTitleLabel.height) / 2);
    } else {
        CGFloat width = self.width - 85.f;
        CGSize size = [self.pushDetailLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
        self.pushDetailLabel.size = size;
        CGFloat totalHeight = self.pushTitleLabel.height + kPushCellDetailLabelTopPadding + self.pushDetailLabel.height;
        self.pushTitleLabel.origin = CGPointMake(kPushCellLeftPadding, (self.contentView.height - totalHeight) / 2);
        self.pushDetailLabel.origin = CGPointMake(kPushCellLeftPadding, self.pushTitleLabel.bottom + kPushCellDetailLabelTopPadding);
    }
}

@end
