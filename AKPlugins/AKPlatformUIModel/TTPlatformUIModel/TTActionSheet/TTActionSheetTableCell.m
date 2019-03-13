//
//  TTActionSheetTableCell.m
//  Article
//
//  Created by zhaoqin on 8/28/16.
//
//

#import "TTActionSheetTableCell.h"
#import "TTActionSheetConst.h"
#import "TTActionSheetCellModel.h"
#import "TTActionSheetModel.h"

#import "TTDeviceUIUtils.h"
#import "TTDeviceHelper.h"
#import "UIViewAdditions.h"
#import "TTThemeConst.h"
#import "TTUIResponderHelper.h"
#import "UIColor+TTThemeExtension.h"

@implementation TTActionSheetTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.centerY = self.contentView.centerY;
        _contentLabel.textColor = [UIColor tt_themedColorForKey:kFHColorCharcoalGrey];
        _revokeLabel = [[UILabel alloc] init];
        _revokeLabel.text = @"撤销";
        _revokeLabel.textColor = [UIColor tt_themedColorForKey:kFHColorRed3];
        _revokeLabel.hidden = YES;
        _seperatorView = [[UIView alloc] init];
        [_seperatorView setBackgroundColor:[UIColor tt_themedColorForKey:kColorLine1]];
        
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.revokeLabel];
        [self.contentView addSubview:self.seperatorView];

        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = backgroundView;
        
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
    self.contentLabel.frame = CGRectMake([TTDeviceUIUtils tt_padding:32] + padding, 0, (width - 32 * 2) * 3 / 4, self.contentView.height);
    self.contentLabel.centerY = self.contentView.centerY;
    [self.contentLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16.0f]]];
    
    self.seperatorView.frame = CGRectMake(self.contentLabel.left, self.contentView.height - 0.5, width - 32 * 2, 0.5);
    
    self.revokeLabel.frame = CGRectMake(self.contentLabel.right, 0, (width - 32 * 2) / 4, self.contentView.height);
    [self.revokeLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16.0f]]];
    self.revokeLabel.right = self.seperatorView.right;
    self.revokeLabel.centerY = self.contentView.centerY;
    self.revokeLabel.textAlignment = NSTextAlignmentRight;
}

- (void)configCellWithModel:(TTActionSheetCellModel *)model {
    if (model.isSelected) {
        switch (model.source) {
            case TTActionSheetTypeReport:
                self.contentLabel.text = [NSString stringWithFormat:@"已举报 %@", model.text];
                break;
            case TTActionSheetTypeDislike:
                self.contentLabel.text = [NSString stringWithFormat:@"%@ 的内容", model.text];
                break;
        }
        self.revokeLabel.hidden = NO;
        self.contentLabel.textColor = [UIColor colorWithDayColorName:@"999999" nightColorName:@"505050"];
    }
    else {
        switch (model.source) {
            case TTActionSheetTypeReport:
                self.contentLabel.text = model.text;
                break;
            case TTActionSheetTypeDislike:
                self.contentLabel.text = [NSString stringWithFormat:@"%@ 的内容", model.text];
                break;
        }
        self.revokeLabel.hidden = YES;
        self.contentLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    }
}


@end
