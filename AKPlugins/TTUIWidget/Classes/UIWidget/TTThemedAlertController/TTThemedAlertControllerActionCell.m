//
//  TTThemedAlertControllerActionCell.m
//  TTScrollViewController
//
//  Created by 冯靖君 on 15/4/12.
//  Copyright (c) 2015年 冯靖君. All rights reserved.
//

#import "TTThemedAlertControllerActionCell.h"
#import "TTThemedAlertControllerCommon.h"
#import "SSThemed.h"
#import "UIColor+TTThemeExtension.h"
#import "TTDeviceHelper.h"

@interface TTThemedAlertControllerActionCell ()

//for vertical layout
@property (nonatomic, strong) UILabel *actionTitleLabel;
@property (nonatomic, strong) CALayer *bottomLine;
//for horizental layout
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) CALayer *verticalLine;

@property (nonatomic, assign) TTThemedAlertControllerActionCellType cellType;
@property (nonatomic, assign) BOOL isPopoverCell;

@end

@implementation TTThemedAlertControllerActionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _actionTitleLabel = [[UILabel alloc] init];
        _actionTitleLabel.backgroundColor = [UIColor clearColor];
        _actionTitleLabel.textAlignment = NSTextAlignmentCenter;
        
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.backgroundColor = [UIColor clearColor];
        _leftButton.titleLabel.textAlignment = NSTextAlignmentCenter;

        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.backgroundColor = [UIColor clearColor];
        _rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.contentView addSubview:_actionTitleLabel];
        [self.contentView addSubview:_leftButton];
        [self.contentView addSubview:_rightButton];
        
        [self configSubViewsWithType:TTThemedAlertControllerActionCellTypeHidden];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.selectedBackgroundView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4Highlighted];
        self.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.cellType == TTThemedAlertControllerActionCellTypeVertical) {
        self.actionTitleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    }
    else if (self.cellType == TTThemedAlertControllerActionCellTypeHorizental) {
        self.leftButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds) / 2 - 1, CGRectGetHeight(self.bounds));
        self.rightButton.frame = CGRectMake(CGRectGetWidth(self.bounds) / 2 + 1, 0, CGRectGetWidth(self.bounds) / 2 - 1, CGRectGetHeight(self.bounds));
        
        self.verticalLine = [CALayer layer];
        self.verticalLine.frame = CGRectMake(CGRectGetWidth(self.bounds) / 2, 0, [TTDeviceHelper ssOnePixel], CGRectGetHeight(self.bounds));
        self.verticalLine.backgroundColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
        [self.layer addSublayer:self.verticalLine];
    }
    
    if (self.isPopoverCell) {
        self.bottomLine = [CALayer layer];
        self.bottomLine.frame = CGRectMake(0, CGRectGetHeight(self.frame) - [TTDeviceHelper ssOnePixel], CGRectGetWidth(self.frame), [TTDeviceHelper ssOnePixel]);
        self.bottomLine.backgroundColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
        [self.layer addSublayer:self.bottomLine];
    }
}

- (void)configCellWithActionModel:(TTThemedAlertActionModel *)actionModel isPopover:(BOOL)isPopover
{
    self.actionTitleLabel.text = actionModel.actionTitle;
    self.actionTitleLabel.font = actionModel.actionElementModel.elementFont;
    self.actionTitleLabel.textColor = actionModel.actionElementModel.elementColor;
    self.isPopoverCell = isPopover;
    
    self.cellType = TTThemedAlertControllerActionCellTypeVertical;
    [self configSubViewsWithType:TTThemedAlertControllerActionCellTypeVertical];
}

- (void)configHorizentalCellWithLeftModel:(TTThemedAlertActionModel *)leftModel leftAction:(SEL)leftAction rightModel:(TTThemedAlertActionModel *)rightModel rightAction:(SEL)rightAction target:(id)target
{
    [self.leftButton setTitle:leftModel.actionTitle forState:UIControlStateNormal];
    [self.leftButton setTitleColor:leftModel.actionElementModel.elementColor forState:UIControlStateNormal];
    self.leftButton.titleLabel.font = leftModel.actionElementModel.elementFont;
    [self.leftButton addTarget:target
                        action:leftAction
              forControlEvents:UIControlEventTouchUpInside];
    
    [self.rightButton setTitle:rightModel.actionTitle forState:UIControlStateNormal];
    [self.rightButton setTitleColor:rightModel.actionElementModel.elementColor forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = rightModel.actionElementModel.elementFont;
    [self.rightButton addTarget:target
                        action:rightAction
              forControlEvents:UIControlEventTouchUpInside];
    
    self.cellType = TTThemedAlertControllerActionCellTypeHorizental;
    [self configSubViewsWithType:TTThemedAlertControllerActionCellTypeHorizental];
}

- (void)configSubViewsWithType:(TTThemedAlertControllerActionCellType)type
{
    if (type == TTThemedAlertControllerActionCellTypeVertical) {
        _actionTitleLabel.hidden = NO;
        _leftButton.hidden = YES;
        _rightButton.hidden = YES;
        _bottomLine.hidden = NO;
        _verticalLine.hidden = YES;
    }
    else if (type == TTThemedAlertControllerActionCellTypeHorizental) {
        _actionTitleLabel.hidden = YES;
        _leftButton.hidden = NO;
        _rightButton.hidden = NO;
        _bottomLine.hidden = YES;
        _verticalLine.hidden = NO;
    }
    else {
        _actionTitleLabel.hidden = YES;
        _leftButton.hidden = YES;
        _rightButton.hidden = YES;
        _bottomLine.hidden = YES;
        _verticalLine.hidden = YES;
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self configSubViewsWithType:TTThemedAlertControllerActionCellTypeHidden];
}

@end
