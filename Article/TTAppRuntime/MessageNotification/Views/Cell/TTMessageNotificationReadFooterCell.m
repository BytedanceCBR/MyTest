//
//  TTMessageNotificationReadFooterCell.m
//  Article
//
//  Created by lizhuoli on 2017/4/1.
//
//

#import "TTMessageNotificationReadFooterCell.h"
#import "TTMessageNotificationCellHelper.h"

@interface TTMessageNotificationReadFooterCell ()

@property (nonatomic, strong) SSThemedLabel *readLabel;

@end

@implementation TTMessageNotificationReadFooterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.separatorAtBottom = YES;
        self.separatorColorThemeKey = kColorLine1;
        self.needMargin = YES;
        self.readLabel = [[SSThemedLabel alloc] init];
        
        self.backgroundColorThemeKey = kColorBackground4;
        [self addSubview:self.readLabel];
        
        [self setupSubViews];
    }
    
    return self;
}

- (void)setupSubViews
{
    self.readLabel.textColorThemeKey = kColorText3;
    self.readLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.readLabel.font = [UIFont systemFontOfSize:[TTMessageNotificationCellHelper tt_newFontSize:16.f]];
    self.readLabel.textAlignment = NSTextAlignmentCenter;
    self.readLabel.text = @"查看更早的消息…";
    [self.readLabel sizeToFit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.readLabel.center = CGPointMake(self.width / 2.f, self.height / 2.f);
}

+ (CGFloat)cellHeight
{
    return [TTMessageNotificationCellHelper tt_newPadding:62.5f];
}

@end
