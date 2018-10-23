//
//  SSCheckbox.m
//  Article
//
//  Created by SunJiangting on 15-1-14.
//
//

#import "SSCheckbox.h"

#import "SSCheckbox.h"
#import "SSThemed.h"
#import "TTDeviceHelper.h"

//#define SSCheckboxDefaultImageViewSize CGSizeMake(20, 20)
#define SSCheckboxMargin 5

@interface SSCheckbox ()
@property(nonatomic) SSThemedImageView *imageView;
@property(nonatomic) SSThemedLabel *titleLabel;

@property(nonatomic) UIButton *eventButton;


@property (nonatomic, copy) NSString    *imageName;
@property (nonatomic, copy) NSString    *checkedImageName;
@end

@implementation SSCheckbox

- (instancetype)initWithTitle:(NSString *)title {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.titleLabel.text = title;
        [self sizeToFit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.horizontalSpacing = SSCheckboxMargin;
        self.imageName = @"select_reviewbar_all";
        self.checkedImageName = @"select_reviewbar_all_press";
        self.imageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imageView];
        
        self.titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        CGFloat fontSize = 12;
        if ([TTDeviceHelper is736Screen] || [TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
            fontSize = 13;
        }
        self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColorThemeKey = kColorText3;
        [self addSubview:self.titleLabel];
        
        self.eventButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.eventButton.frame = self.bounds;
        self.eventButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.eventButton addTarget:self action:@selector(eventButtonActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.eventButton];
        self.checked = NO;
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)eventButtonActionFired:(UIButton *)button {
    self.checked = !(self.checked);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setChecked:(BOOL)checked {
    NSString *imageName = checked ? self.checkedImageName : self.imageName;
    if (imageName) {
        self.imageView.imageName = imageName;
    } else {
        self.imageView.image = checked ? self.checkedImage : self.image;
    }
    [_imageView sizeToFit];
    _checked = checked;
}

- (void)sizeToFit {
    CGSize imageSize = _imageView.frame.size;
    [self.titleLabel sizeToFit];
    CGFloat width = imageSize.width + self.horizontalSpacing + CGRectGetWidth(self.titleLabel.frame);
    CGFloat height = MAX(imageSize.height, CGRectGetHeight(self.titleLabel.frame));
    CGPoint origin = self.frame.origin;
    self.frame = CGRectMake(origin.x, origin.y, width, height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    CGFloat imageTop = (CGRectGetHeight(bounds) - _imageView.frame.size.height) / 2;
    self.imageView.frame = CGRectMake(0, imageTop, _imageView.frame.size.width, _imageView.frame.size.height);
    
    CGFloat left = CGRectGetMaxX(self.imageView.frame) + self.horizontalSpacing;
    self.titleLabel.frame = CGRectMake(left, 0, CGRectGetWidth(bounds) - left, CGRectGetHeight(bounds));
}

@end
