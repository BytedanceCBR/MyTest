//
//  FRForumLocationSingleLineCell.m
//  Article
//
//  Created by 王霖 on 15/7/14.
//
//

#import "FRForumLocationSingleLineCell.h"
#import "SSThemed.h"
#import "TTDeviceHelper.h"

@interface FRForumLocationSingleLineCell ()

@property (nonatomic, strong)SSThemedLabel *titleLabel;
@property (nonatomic, strong)SSThemedImageView *selectedImageView;

@end

@implementation FRForumLocationSingleLineCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorThemeInsetLeft = 15;
        self.separatorAtTOP = YES;
        self.separatorColorThemeKey = kColorLine1;
        self.backgroundColorThemeKey = kColorBackground4;
        [self createSubView];
    }
    return self;
}

- (void)createSubView {
    
    self.titleLabel = [[SSThemedLabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        _titleLabel.font = [UIFont systemFontOfSize:17];
    }else {
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    _titleLabel.textColorThemeKey = kColorText1;
    [self.contentView addSubview:_titleLabel];
    
    NSLayoutConstraint *labelCenterYConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self.contentView addConstraint:labelCenterYConstraint];
    NSArray *labelHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_titleLabel]-42-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_titleLabel)];
    [self.contentView addConstraints:labelHorizontalConstraints];
    
    self.selectedImageView = [[SSThemedImageView alloc] init];
    _selectedImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _selectedImageView.imageName = @"hookicon_location";
    [self.contentView addSubview:_selectedImageView];
    _selectedImageView.hidden = YES;
    
    NSLayoutConstraint *imageCenterYConstraint = [NSLayoutConstraint constraintWithItem:_selectedImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *imageRightIntervalConstraint = [NSLayoutConstraint constraintWithItem:_selectedImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-15];
    [self.contentView addConstraints:@[imageCenterYConstraint, imageRightIntervalConstraint]];
    
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    _titleLabel.text = _title;
}

- (void)setCellStyle:(FRForumLocationSingleLineCellStyle)cellStyle {
    _cellStyle = cellStyle;
    switch (_cellStyle) {
        case FRForumLocationSingleLineCellStyleValue1:
            _titleLabel.textColorThemeKey = kColorText5;
            break;
        default:
            _titleLabel.textColorThemeKey = kColorText1;
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    _selectedImageView.hidden = !selected;
}

@end
