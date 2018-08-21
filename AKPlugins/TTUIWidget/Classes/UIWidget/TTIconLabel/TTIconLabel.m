//
//  TTIconLabel.m
//  Article
//
//  Created by lizhuoli on 17/1/18.
//
//

#import "TTIconLabel.h"
#import "TTAsyncLabel.h"
#import "TTVerifyNightMaskView.h"
#import "TTDeviceUIUtils.h"
#import "UIViewAdditions.h"
#import "TTThemeManager.h"
#import "UIImage+TTThemeExtension.h"
#import "UIImage+TTImage.h"
#import <objc/runtime.h>

#import <SDWebImage/UIImageView+WebCache.h>

#define IsEqualOrNil(x, y) ((!x && !y) || (x && [y isEqual:x]))
#define IsEqualStringOrNil(x, y) ((!x && !y) || (x && [y isEqualToString:x]))

@class TTIconImageModel;
@interface UIImageView (TTIconLabel)

@property (nonatomic, strong) TTVerifyNightMaskView *tt_nightMask;
@property (nonatomic, strong) TTIconImageModel *tt_iconImageModel;

@end

@implementation UIImageView (TTIconLabel)

- (void)setTt_nightMask:(TTVerifyNightMaskView *)tt_nightMask {
    objc_setAssociatedObject(self, @selector(tt_nightMask), tt_nightMask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTVerifyNightMaskView *)tt_nightMask
{
    TTVerifyNightMaskView *nightMask = objc_getAssociatedObject(self, @selector(tt_nightMask));
    if (!nightMask) {
        nightMask = [[TTVerifyNightMaskView alloc] init];
        [self addSubview:nightMask];
        [self setTt_nightMask:nightMask];
    }
    
    return nightMask;
}

- (void)setTt_iconImageModel:(TTIconImageModel *)tt_iconImageModel
{
    objc_setAssociatedObject(self, @selector(tt_iconImageModel), tt_iconImageModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTIconImageModel *)tt_iconImageModel
{
    return objc_getAssociatedObject(self, @selector(tt_iconImageModel));
}

@end

@interface TTIconImageModel : NSObject<NSCopying>

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, strong) UIImage *dayIcon;
@property (nonatomic, strong) UIImage *nightIcon;
@property (nonatomic, strong) NSURL *dayIconURL;
@property (nonatomic, strong) NSURL *nightIconURL;
@property (nonatomic, assign) CGSize size;

- (instancetype)initWithImageName:(NSString *)imageName dayIcon:(UIImage *)dayIcon nightIcon:(UIImage *)nightIcon dayIconURL:(NSURL *)dayIconURL nightIconURL:(NSURL *)nightIconURL size:(CGSize)size;

+ (instancetype)modelWithImageName:(NSString *)imageName size:(CGSize)size;
+ (instancetype)modelWithDayIcon:(UIImage *)dayIcon nightIcon:(UIImage *)nightIcon size:(CGSize)size;
+ (instancetype)modelWithDayIconURL:(NSURL *)dayIconURL nightIconURL:(NSURL *)nightIconURL size:(CGSize)size;

@end

@implementation TTIconImageModel

- (instancetype)initWithImageName:(NSString *)imageName dayIcon:(UIImage *)dayIcon nightIcon:(UIImage *)nightIcon dayIconURL:(NSURL *)dayIconURL nightIconURL:(NSURL *)nightIconURL size:(CGSize)size
{
    self = [super init];
    if (self) {
        self.imageName = imageName;
        self.dayIcon = dayIcon;
        self.nightIcon = nightIcon;
        self.dayIconURL = dayIconURL;
        self.nightIconURL = nightIconURL;
        self.size = size;
    }
    
    return self;
}

+ (instancetype)modelWithImageName:(NSString *)imageName size:(CGSize)size
{
    return [[self alloc] initWithImageName:imageName dayIcon:nil nightIcon:nil dayIconURL:nil nightIconURL:nil size:size];
}

+ (instancetype)modelWithDayIcon:(UIImage *)dayIcon nightIcon:(UIImage *)nightIcon size:(CGSize)size
{
    return [[self alloc] initWithImageName:nil dayIcon:dayIcon nightIcon:nightIcon dayIconURL:nil nightIconURL:nil size:size];
}

+ (instancetype)modelWithDayIconURL:(NSURL *)dayIconURL nightIconURL:(NSURL *)nightIconURL size:(CGSize)size
{
    return [[self alloc] initWithImageName:nil dayIcon:nil nightIcon:nil dayIconURL:dayIconURL nightIconURL:nightIconURL size:size];
}

- (id)copyWithZone:(NSZone *)zone
{
    TTIconImageModel *another = [[TTIconImageModel alloc] init];
    another.imageName = [self.imageName copyWithZone:zone];
    another.dayIcon  = self.dayIcon; // UIImage不copy
    another.nightIcon = self.nightIcon; // UIImage不copy
    another.dayIconURL = [self.dayIconURL copyWithZone:zone];
    another.nightIconURL = [self.nightIconURL copyWithZone:zone];
    another.size = self.size;
    
    return another;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[TTIconImageModel class]]) {
        return NO;
    }
    
    TTIconImageModel *other = (TTIconImageModel *)object;
    BOOL equal = IsEqualStringOrNil(self.imageName, other.imageName)
    && self.dayIcon == other.dayIcon
    && self.nightIcon == other.nightIcon
    && IsEqualOrNil(self.dayIconURL, other.nightIconURL)
    && IsEqualOrNil(self.nightIconURL, other.nightIconURL);
    
    return equal;
}

@end

@interface TTIconLabel ()

@property (nonatomic, strong) SSThemedLabel *themedLabel;
@property (nonatomic, strong) TTAsyncLabel *asyncLabel;
@property (nonatomic, strong, readwrite) UIView *label;
@property (nonatomic, strong) UIView *iconContainerView;
@property (nonatomic, copy) NSArray<UIImageView *> *imageViews;
@property (nonatomic, copy) NSArray<TTIconImageModel *> *iconModels;

@end

@implementation TTIconLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _themedLabel = [[SSThemedLabel alloc] init];
        _asyncLabel = [[TTAsyncLabel alloc] init];
        _labelMaxWidth = 0;
        _iconRightPadding = 0;
        _iconLeftPadding = [TTDeviceUIUtils tt_padding:3];
        _iconSpacing = [TTDeviceUIUtils tt_padding:3];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _themedLabel = [[SSThemedLabel alloc] init];
        _asyncLabel = [[TTAsyncLabel alloc] init];
        _labelMaxWidth = 0;
        _iconRightPadding = 0;
        _iconLeftPadding = [TTDeviceUIUtils tt_padding:3];
        _iconSpacing = [TTDeviceUIUtils tt_padding:3];
    }
    return self;
}

#pragma mark - UILabel property
- (void)setText:(NSString *)text
{
    _text = text;
    [self.asyncLabel setText:text];
    [self.themedLabel setText:text];
}

- (void)setTextColorThemeKey:(NSString *)textColorThemeKey
{
    _textColorThemeKey = textColorThemeKey;
    [self setTextColor:[UIColor tt_themedColorForKey:textColorThemeKey]];
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    [self.asyncLabel setFont:font];
    [self.themedLabel setFont:font];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self.asyncLabel setTextColor:textColor];
    [self.themedLabel setTextColor:textColor];
}

- (void)setHighlightedTextColor:(UIColor *)highlightedTextColor
{
    _highlightedTextColor = highlightedTextColor;
    [self.themedLabel setHighlightedTextColor:highlightedTextColor];
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    [self.themedLabel setHighlighted:highlighted];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
    _numberOfLines = numberOfLines;
    [self.asyncLabel setNumberOfLines:numberOfLines];
    [self.themedLabel setNumberOfLines:numberOfLines];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _textAlignment = textAlignment;
    [self.asyncLabel setTextAlignment:textAlignment];
    [self.themedLabel setTextAlignment:textAlignment];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    _lineBreakMode = lineBreakMode;
    [self.asyncLabel setLineBreakMode:lineBreakMode];
    [self.themedLabel setLineBreakMode:lineBreakMode];
}

- (void)setLineSpacing:(CGFloat)lineSpacing
{
    _lineSpacing = lineSpacing;
}

- (void)setLineHeight:(CGFloat)lineHeight
{
    _lineHeight = lineHeight;
}

- (void)setVerticalAlignment:(ArticleVerticalAlignment)verticalAlignment
{
    _verticalAlignment = verticalAlignment;
    [self.themedLabel setVerticalAlignment:verticalAlignment];
}

#pragma mark - config
- (void)setEnableAsync:(BOOL)enableAsync
{
    if (_enableAsync != enableAsync) {
        _enableAsync = enableAsync;
        [self setupLabel];
    }
}

#pragma mark - iconView
- (NSUInteger)indexOfDayIcon:(UIImage *)icon
{
    if (![icon isKindOfClass:[UIImage class]]) {
        return NSNotFound;
    }
    __block NSUInteger index = NSNotFound;
    [self.iconModels enumerateObjectsUsingBlock:^(TTIconImageModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (icon == model.dayIcon) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

- (NSUInteger)indexOfDayIconURL:(NSURL *)iconURL
{
    if (![iconURL isKindOfClass:[NSURL class]]) {
        return NSNotFound;
    }
    __block NSUInteger index = NSNotFound;
    [self.iconModels enumerateObjectsUsingBlock:^(TTIconImageModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([iconURL isEqual:model.dayIconURL]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

- (NSUInteger)indexOfImageName:(NSString *)imageName
{
    if (isEmptyString(imageName)) {
        return NSNotFound;
    }
    __block NSUInteger index = NSNotFound;
    [self.iconModels enumerateObjectsUsingBlock:^(TTIconImageModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([imageName isEqualToString:model.imageName]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

#pragma mark - private method
- (UIView *)label
{
    if (!_label) {
        if (self.enableAsync) {
            _label = self.asyncLabel;
        } else {
            _label = self.themedLabel;
        }
        [self setupLabel];
    }
    
    return _label;
}

- (void)setupLabel
{
    if (self.enableAsync) {
        if (self.asyncLabel && !self.themedLabel) {
            return;
        }
        [self.themedLabel removeFromSuperview];
        self.themedLabel = nil;
        [self addSubview:self.label];
    } else {
        if (self.themedLabel && !self.asyncLabel) {
            return;
        }
        [self.asyncLabel removeFromSuperview];
        self.asyncLabel = nil;
        [self addSubview:self.label];
    }
}

- (CGSize)adjustedIconSizeWithSize:(CGSize)size
{
    //    CGFloat height = MAX(self.height, self.label.height) - 1;
    CGFloat height = self.font.pointSize - 1;
    if (self.iconMaxHeight > 0 && self.iconMaxHeight < height) {
        height = self.iconMaxHeight;
    }
    // 保持高度一定，等比缩放
    CGFloat width = height;
    if (size.width != 0 && size.height != 0) {
        width = size.width / size.height * height;
    }
    
    return CGSizeMake(width, height);
}

- (UIView *)iconContainerView
{
    if (!_iconContainerView) {
        _iconContainerView = [[SSThemedView alloc] init];
        [self addSubview:_iconContainerView];
    }
    
    return _iconContainerView;
}

- (CGSize)iconContainerSize
{
    CGFloat height = MAX(self.height, self.label.height);
    CGFloat width = self.iconLeftPadding + self.iconRightPadding;
    width += self.iconModels.count > 1 ? (self.iconModels.count - 1) * self.iconSpacing : 0;
    for (TTIconImageModel *model in self.iconModels) {
        CGSize iconSize = model.size;
        iconSize = [self adjustedIconSizeWithSize:iconSize];
        width += iconSize.width;
    }
    
    return CGSizeMake(width, height);
}

- (CGFloat)iconContainerWidth
{
    return [self iconContainerSize].width;
}

-(CGSize)sizeThatFits:(CGSize)size
{
    if (self.iconModels.count <= 0) {
        CGSize labelSize = [self.label sizeThatFits:size];
        if (!self.disableLabelSizeToFit) {
            [self.label sizeToFit];
            if (self.labelMaxWidth > 0 && labelSize.width > self.labelMaxWidth) {
                labelSize.width = self.labelMaxWidth;
            }
        }
        return labelSize;
    }
    
    CGSize containerSize = [self iconContainerSize];
    CGFloat restWidth = size.width - containerSize.width;
    restWidth = restWidth > 0 ? restWidth : 0;
    CGSize labelSize = [self.label sizeThatFits:CGSizeMake(restWidth, size.height)];
    
    if (self.labelMaxWidth > 0 && labelSize.width > self.labelMaxWidth) {
        labelSize.width = self.labelMaxWidth;
    }
    CGFloat height = MAX(containerSize.height, labelSize.height);
    
    return CGSizeMake(labelSize.width + containerSize.width, height);
}

- (CGSize)intrinsicContentSize
{
    CGSize labelSize = [self.label intrinsicContentSize];
    if (self.iconModels.count <= 0) {
        if (self.labelMaxWidth > 0 && labelSize.width > self.labelMaxWidth) {
            labelSize.width = self.labelMaxWidth;
        }
        return labelSize;
    }
    if (self.labelMaxWidth > 0 && labelSize.width > self.labelMaxWidth) {
        labelSize.width = self.labelMaxWidth;
    }
    CGSize containerSize = [self iconContainerSize];
    CGFloat height = MAX(containerSize.height, labelSize.height);
    
    return CGSizeMake(labelSize.width + containerSize.width, height);
}

- (void)refreshIconView
{
    self.iconContainerView.hidden = (self.iconModels.count <= 0);
    
    [self sizeToFit];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.iconModels.count <= 0) {
        self.label.frame = self.bounds;
        return;
    }
    
    if (!self.disableLabelSizeToFit) {
        [self.label sizeToFit];
        self.label.left = self.bounds.origin.x;
        CGFloat height = MAX(self.height, self.label.height);
        self.label.centerY = height / 2;
    }
    CGSize containerSize = [self iconContainerSize];
    
    // 先检查是否有长度上限
    if (self.labelMaxWidth > 0 && self.label.width > self.labelMaxWidth) {
        self.label.width = self.labelMaxWidth;
    }
    // 仍然为长文本
    if (self.label.width + containerSize.width > self.width) {
        CGFloat width = self.width - containerSize.width;
        width = width > 0 ? width : 0;
        self.label.width = width;
    }
    // 对齐方式调整
    if (self.textAlignment == NSTextAlignmentCenter) {
        CGFloat left = (self.width - self.label.width - containerSize.width) / 2;
        self.label.left = left;
    } else if (self.textAlignment == NSTextAlignmentRight) {
        CGFloat left = self.width - self.label.width - containerSize.width;
        self.label.left = left;
    }
    
    CGRect iconContainerFrame = CGRectMake(CGRectGetMaxX(self.label.frame), 0, containerSize.width, containerSize.height);
    self.iconContainerView.frame = iconContainerFrame;
    
    CGFloat previousX = self.iconLeftPadding;
    
    [self addImageViewsIfNeed]; // 保证imageViews数量 >= iconModels
    NSUInteger iconModelsCount = self.iconModels.count;
    NSUInteger imageViewsCount = self.imageViews.count;
    for (NSUInteger i = 0; i < imageViewsCount; i++) {
        UIImageView *imageView = [self iconViewAtIndex:i];
        if (i < iconModelsCount) {
            imageView.hidden = NO;
            TTIconImageModel *model = [self.iconModels objectAtIndex:i];
            
            CGSize iconSize = model.size;
            iconSize = [self adjustedIconSizeWithSize:iconSize];
            imageView.frame = CGRectMake(previousX, 0, iconSize.width, iconSize.height);
            previousX = previousX + self.iconSpacing + iconSize.width;
            imageView.centerY = self.iconContainerView.height / 2;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            [self updateImageView:imageView WithModel:model];
        } else {
            imageView.hidden = YES;
        }
    }
}

- (NSArray<UIImageView *> *)imageViews
{
    if (!_imageViews) {
        _imageViews = [NSArray array];
    }
    
    return _imageViews;
}

- (NSArray<TTIconImageModel *> *)iconModels
{
    if (!_iconModels) {
        _iconModels = [NSArray array];
    }
    
    return _iconModels;
}

- (BOOL)isDayMode
{
    return [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
}

- (void)themeChanged:(NSNotification*)notification
{
    [self setTextColor: [UIColor tt_themedColorForKey:self.textColorThemeKey]];
    
    [self.iconModels enumerateObjectsUsingBlock:^(TTIconImageModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [self iconViewAtIndex:idx];
        [self updateImageView:imageView WithModel:model];
    }];
}

#pragma mark - Insert & remove icon
- (UIImageView *)iconViewAtIndex:(NSUInteger)index
{
    if (index == NSNotFound || index >= self.imageViews.count) {
        return nil;
    }
    
    UIImageView *imageView = [self.imageViews objectAtIndex:index];
    
    return imageView;
}

- (void)updateImageView:(UIImageView *)imageView withImage:(UIImage *)image
{
    if (!imageView || !image) {
        return;
    }
    
    if (image.images.count > 0) {
        imageView.image = image.images.firstObject;
        imageView.animationRepeatCount = image.tt_imageLoopCount;
        imageView.animationDuration = image.duration;
        imageView.animationImages = image.images;
        [imageView startAnimating];
    } else {
        [imageView stopAnimating];
        imageView.animationImages = nil;
        imageView.animationDuration = 0;
        imageView.animationRepeatCount = 0;
        imageView.image = image;
    }
}


- (void)updateImageView:(UIImageView *)imageView WithModel:(TTIconImageModel *)model
{
    if (!imageView || !model) {
        return;
    }
    
    imageView.tt_nightMask.hidden = YES;
    BOOL isDayMode = [self isDayMode];
    
    if (model.imageName) {
        UIImage *image = [UIImage themedImageNamed:model.imageName];
        [self updateImageView:imageView withImage:image];
    } else if (model.dayIcon) {
        if (isDayMode || !model.nightIcon) {
            [self updateImageView:imageView withImage:model.dayIcon];
            if (!self.disableNightMode) {
                imageView.tt_nightMask.hidden = NO;
                imageView.tt_nightMask.size = imageView.bounds.size;
                [imageView.tt_nightMask refreshWithMaskImage:imageView.image];
            }
        } else {
            [self updateImageView:imageView withImage:model.nightIcon];
        }
    } else if (model.dayIconURL) {
        if (isDayMode || !model.nightIconURL) {
            [imageView sd_setImageWithURL:model.dayIconURL placeholderImage:self.placeholderImage options:SDWebImageRetryFailed | SDWebImageAvoidAutoSetImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (image) {
                    [self updateImageView:imageView withImage:image];
                    if (!self.disableNightMode) {
                        imageView.tt_nightMask.hidden = NO;
                        imageView.tt_nightMask.size = imageView.bounds.size;
                        [imageView.tt_nightMask refreshWithMaskImage:image];
                    }
                }
            }];
        } else {
            [imageView sd_setImageWithURL:model.nightIconURL placeholderImage:self.placeholderImage options:SDWebImageRetryFailed | SDWebImageAvoidAutoSetImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (image) {
                    [self updateImageView:imageView withImage:image];
                }
            }];
        }
    }
}

- (void)addImageViewsIfNeed
{
    if (self.iconModels.count == 0) {
        return;
    }
    
    if (self.imageViews.count >= self.iconModels.count) {
        return;
    }
    
    NSUInteger diff = self.iconModels.count - self.imageViews.count;
    NSMutableArray<UIImageView *> *imageViews = [self.imageViews mutableCopy];
    for (NSUInteger i = 0; i < diff; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageViews addObject:imageView];
        [self.iconContainerView addSubview:imageView];
    }
    
    self.imageViews = [imageViews copy];
}

- (void)addIconWithModel:(TTIconImageModel *)model
{
    if (!model) {
        return;
    }
    
    NSMutableArray<TTIconImageModel *> *iconModels = [self.iconModels mutableCopy];
    [iconModels addObject:model];
    self.iconModels = [iconModels copy];
    
    [self addImageViewsIfNeed];
}

- (void)addIconWithImageName:(NSString *)imageName size:(CGSize)size
{
    if (isEmptyString(imageName)) {
        return;
    }
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = [UIImage themedImageNamed:imageName].size;
    }
    [self addIconWithModel:[TTIconImageModel modelWithImageName:imageName size:size]];
}

- (void)addIconWithDayIcon:(UIImage *)dayIcon nightIcon:(UIImage *)nightIcon size:(CGSize)size
{
    if (!dayIcon) {
        return;
    }
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = dayIcon.size;
    }
    [self addIconWithModel:[TTIconImageModel modelWithDayIcon:dayIcon nightIcon:nightIcon size:size]];
}

- (void)addIconWithDayIconURL:(NSURL *)dayIconURL nightIconURL:(NSURL *)nightIconURL size:(CGSize)size
{
    if (!dayIconURL) {
        return;
    }
    
    [self addIconWithModel:[TTIconImageModel modelWithDayIconURL:dayIconURL nightIconURL:nightIconURL size:size]];
}

- (void)insertIconWithModel:(TTIconImageModel *)model atIndex:(NSUInteger)index
{
    if (!model || index > self.iconModels.count) {
        return;
    }
    
    NSMutableArray<TTIconImageModel *> *iconModels = [self.iconModels mutableCopy];
    [iconModels insertObject:model atIndex:index];
    self.iconModels = [iconModels copy];
    
    [self addImageViewsIfNeed];
}

- (void)insertIconWithImageName:(NSString *)imageName size:(CGSize)size atIndex:(NSUInteger)index
{
    if (isEmptyString(imageName) || index > self.iconModels.count) {
        return;
    }
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = [UIImage themedImageNamed:imageName].size;
    }
    [self insertIconWithModel:[TTIconImageModel modelWithImageName:imageName size:size] atIndex:index];
}

- (void)insertIconWithDayIcon:(UIImage *)dayIcon nightIcon:(UIImage *)nightIcon size:(CGSize)size atIndex:(NSUInteger)index
{
    if (!dayIcon || index > self.iconModels.count) {
        return;
    }
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = dayIcon.size;
    }
    [self insertIconWithModel:[TTIconImageModel modelWithDayIcon:dayIcon nightIcon:nightIcon size:size] atIndex:index];
}

- (void)insertIconWithDayIconURL:(NSURL *)dayIconURL nightIconURL:(NSURL *)nightIconURL size:(CGSize)size atIndex:(NSUInteger)index
{
    if (!dayIconURL || index > self.iconModels.count) {
        return;
    }
    
    [self insertIconWithModel:[TTIconImageModel modelWithDayIconURL:dayIconURL nightIconURL:nightIconURL size:size] atIndex:index];
}

- (void)removeIconAtIndex:(NSUInteger)index
{
    if (index == NSNotFound || index >= self.iconModels.count) {
        return;
    }
    
    TTIconImageModel *model = [self.iconModels objectAtIndex:index];
    if (model) {
        NSMutableArray<TTIconImageModel *> *iconModels = [self.iconModels mutableCopy];
        [iconModels removeObject:model];
        self.iconModels = [iconModels copy];
    }
}

- (void)removeIconView:(UIImageView *)iconView
{
    if (!iconView) return;
    
    NSUInteger index = [self.imageViews indexOfObject:iconView];
    if (index != NSNotFound) {
        [iconView removeFromSuperview];
        NSMutableArray<UIImageView *> *imageViews = [self.imageViews mutableCopy];
        [imageViews removeObject:iconView];
        self.imageViews = imageViews;
    }
}

- (void)removeAllIcons
{
    self.iconModels = [NSArray array];
}

- (NSUInteger)countOfIcons
{
    return self.iconModels.count;
}

@end
