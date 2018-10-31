//
//  TTActionSheetWriteCommentCell.m
//  Article
//
//  Created by zhaoqin on 09/10/2016.
//
//

#import "AWEActionSheetWriteCommentCell.h"
#import "UIColor+TTThemeExtension.h"
#import "UIViewAdditions.h"
#import "TTThemeConst.h"
#import "TTThemeManager.h"
#import "TTDeviceHelper.h"
#import "TTUIResponderHelper.h"
#import "UIColor+TTThemeExtension.h"

@interface AWEActionSheetWriteCommentCell ()
@property (nonatomic, strong) UIImageView *arrowImageView;
@end

@implementation AWEActionSheetWriteCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.centerY = self.contentView.centerY;
        _contentLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        _arrowImageView = [[UIImageView alloc] init];
        
        [self.contentView addSubview:_contentLabel];
        [self.contentView addSubview:_arrowImageView];
        
        [self setBackgroundColor:[UIColor colorWithDayColorName:@"ffffff" nightColorName:@"252525"]];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat temp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = temp;
    }
    
    CGFloat padding = [TTUIResponderHelper paddingForViewWidth:screenWidth];
    CGFloat width = screenWidth - 2 * padding;
    self.contentLabel.frame = CGRectMake(32 + padding, 0, width - 32 * 2 - 15, self.contentView.height);
    self.contentLabel.font = [UIFont systemFontOfSize:16];
    self.contentLabel.centerY = self.contentView.centerY;
    [self.contentLabel setFont:[UIFont systemFontOfSize:16]];
    
    self.arrowImageView.frame = CGRectMake(0, 0, 15, 15);
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        _arrowImageView.image = [UIImage imageNamed:@"all_arrow_unlike"];
    }
    else {
        _arrowImageView.image = [UIImage imageNamed:@"all_arrow_unlike_night"];
    }
    self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
    self.arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.arrowImageView.centerY = self.contentLabel.centerY;
    self.arrowImageView.bottom = self.arrowImageView.bottom + [TTDeviceHelper ssOnePixel];
    self.arrowImageView.left = self.contentLabel.right + 1;
}

@end
