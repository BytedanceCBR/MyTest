//
//  FRForumLocationDoubleLineCell.m
//  Article
//
//  Created by 王霖 on 15/7/14.
//
//

#import "FRForumLocationDoubleLineCell.h"
#import "FRLocationEntity.h"
#import "TTDeviceHelper.h"

@interface FRForumLocationDoubleLineCell ()

@property (nonatomic, strong)SSThemedLabel *titleLabel;
@property (nonatomic, strong)SSThemedLabel *describeLabel;
@property (nonatomic, strong)SSThemedImageView *selectedImageView;

@end

@implementation FRForumLocationDoubleLineCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorColorThemeKey = kColorLine1;
        self.backgroundColorThemeKey = kColorBackground4;
        self.separatorThemeInsetLeft = 15;
        self.separatorAtTOP = YES;
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
    NSArray *labelHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_titleLabel]-42-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_titleLabel)];
    [self.contentView addConstraints:labelHorizontalConstraints];
    
    
    self.describeLabel = [[SSThemedLabel alloc] init];
    _describeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        _describeLabel.font = [UIFont systemFontOfSize:14];
    }else {
        _describeLabel.font = [UIFont systemFontOfSize:13];
    }
    _describeLabel.textColorThemeKey = kColorText3;
    [self.contentView addSubview:_describeLabel];
    NSLayoutConstraint *describeAlignRightConstraint = [NSLayoutConstraint constraintWithItem:_describeLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-42];
    [self.contentView addConstraint:describeAlignRightConstraint];

    CGFloat topPadding = 5;
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        topPadding = 6.5;
    }
    NSArray *labelsVerticleConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topPadding-[_titleLabel]-2-[_describeLabel]" options:NSLayoutFormatAlignAllLeft metrics:@{@"topPadding":[NSNumber numberWithDouble:topPadding]} views:NSDictionaryOfVariableBindings(_titleLabel, _describeLabel)];
    [self.contentView addConstraints:labelsVerticleConstraints];
    
    
    
    self.selectedImageView = [[SSThemedImageView alloc] init];
    _selectedImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _selectedImageView.imageName = @"hookicon_location";
    [self.contentView addSubview:_selectedImageView];
    _selectedImageView.hidden = YES;
    
    NSLayoutConstraint *imageCenterYConstraint = [NSLayoutConstraint constraintWithItem:_selectedImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *imageRightIntervalConstraint = [NSLayoutConstraint constraintWithItem:_selectedImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-15];
    [self.contentView addConstraints:@[imageCenterYConstraint, imageRightIntervalConstraint]];
}

- (void)setLocation:(FRLocationEntity *)location {
    _location = location;
    _titleLabel.text = _location.locationName;
    _describeLabel.text = _location.locationAddress;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    _selectedImageView.hidden = !selected;
}

@end
