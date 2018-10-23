//
//  TTNPopupView.m
//  Article
//
//  Created by Zuopeng Liu on 7/23/16.
//
//

#import "TTNPopupView.h"
//#import <SDWebImage/SDImageCache.h>
#import <BDWebImage/SDWebImageAdapter.h>

#define kTTPopupViewWidthDefault            (540.f / 2)
#define kTTPopupViewHeightDefault           (790.f / 2)
#define kTTCloseButtonWidthDefault          (48.f / 2)
#define kTTCloseButtonHeightDefault         (48.f / 2)
#define kTTButtonWidthDefault               (432.f / 2)
#define kTTButtonHeightDefault              (88.f / 2)
#define kTTSpacingFromCloseButtonToMargin   (10.f / 2)
#define kTTSpacingFromImageToMarginTop      (72.f / 2)
#define kTTSpacingFromTitleToImage          (72.f / 2)
#define kTTSpacingFromButtonToMarginBottom  (42.f / 2)
#define kTTSpacingOfText                    (20.f / 2) // title to content
#define kTTSpacingFromTextToDescription     (36.f / 2) // title/content to description

#define kTTTitleFontSizeDefault   (34.f / 2)
#define kTTContentFontSizeDefault (34.f / 2)
#define kTTButtonFontSizeDefault  (30.f / 2)
#define kTTTitleColorKeyDefault   (kColorText1)
#define kTTContentColorKeyDefault (kColorText1)
#define kTTButtonColorKeyDefault  (kColorText12)

#define TTAdaptiveSize(size)     [TTDeviceHelper tt_padding:size]


typedef void (^TTNCompletionDidTapButtonBlock)(id sender);
@interface TTNPopupButtonCell : SSThemedTableViewCell
@property (nonatomic,   copy) TTNCompletionDidTapButtonBlock completionDidTap;
@property (nonatomic, strong) SSThemedButton *titleButton;

- (instancetype)initWithReuseIdentifier:(NSString *)identifier;
- (void)reloadWithTitle:(NSString *)title;
+ (CGFloat)cellHeight;
+ (CGFloat)footerViewHeight;
@end


@implementation TTNPopupButtonCell
- (instancetype)initWithReuseIdentifier:(NSString *)identifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier])) {
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.titleButton];
        
        [self.titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.leading.equalTo(self.contentView.mas_leading).with.offset(0);
            make.trailing.equalTo(self.contentView.mas_trailing).with.offset(0);
            make.height.equalTo(self.contentView.mas_height);
        }];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.titleButton setTitle:@"" forState:UIControlStateNormal];
}

- (void)reloadWithTitle:(NSString *)title {
    if (!title) return;
    [self.titleButton setTitle:title forState:UIControlStateNormal];
}

- (SSThemedButton *)titleButton {
    if (!_titleButton) {
        _titleButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_titleButton addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
        _titleButton.backgroundColorThemeKey = kColorBackground7;
        _titleButton.highlightedBackgroundColorThemeKey = kColorBackground7Highlighted;
        _titleButton.titleColorThemeKey = kColorText7;
        _titleButton.highlightedTitleColorThemeKey = kColorText7Highlighted;
        _titleButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _titleButton.layer.cornerRadius = 6.f;
        _titleButton.clipsToBounds = YES;
        _titleButton.frame = CGRectMake(0, 0, self.contentView.width, [self.class cellHeight]);
        [_titleButton.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kTTButtonFontSizeDefault]]];
    }
    return _titleButton;
}

- (void)didTapButton:(id)sender {
    if (self.completionDidTap) self.completionDidTap(sender);
}

+ (CGFloat)cellHeight {
    return [TTDeviceUIUtils tt_padding:kTTButtonHeightDefault];
}

+ (CGFloat)footerViewHeight {
    return [TTDeviceUIUtils tt_padding:15.f];
}
@end


/**
 * TTNPopupView
 */
@interface TTNPopupView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) SSThemedView *containerView;

@property (nonatomic, strong) SSThemedImageView *imageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *contentLabel;
@property (nonatomic, strong) SSThemedLabel *descriptionLabel;
@property (nonatomic, strong) SSThemedButton *closeButton;
@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, strong) NSArray<NSString *> *buttonTitles;

@property (nonatomic, strong) UIActivityIndicatorView *loadImageIndicator;

@property (nonatomic, copy) TTNCompletionDidTapButtonBlock didTapTitleButtonCallback;

@end

@implementation TTNPopupView

+ (CGRect)frameOfFullScreenView {
    return CGRectMake(0, 0, [TTUIResponderHelper screenSize].width, [TTUIResponderHelper screenSize].height);
}

+ (CGRect)adpativeRectForOriginalRect:(CGRect)rect {
    return CGRectMake(rect.origin.x, rect.origin.y, [TTDeviceUIUtils tt_padding:rect.size.width], [TTDeviceUIUtils tt_padding:rect.size.height]);
}

- (instancetype)init {
    @throw @"Cann't init directly";
}

- (instancetype)initWithFrame:(CGRect)frame
                     imageURL:(NSURL *)url
                        title:(NSString *)title
                      content:(NSString *)content
                  description:(NSString *)description
           confirmButtonTitle:(NSString *)confirmButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... {
    NSMutableArray<NSString *> *buttonTitles = [@[confirmButtonTitle] mutableCopy];
    if (otherButtonTitles) {
        [buttonTitles addObject:otherButtonTitles];
        
        id eachObject;
        va_list argList;
        va_start(argList, otherButtonTitles);
        while ((eachObject = va_arg(argList, id))) {
            [buttonTitles addObject:eachObject];
        }
        va_end(argList);
    }
    
    _imageLoadIndicatorEnabled = YES;
    SSThemedImageView *tmpImageView = nil;
    if (url && [url isKindOfClass:[NSURL class]]) {
        _loadImageIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        tmpImageView = [[SSThemedImageView alloc] init];
        [tmpImageView addSubview:_loadImageIndicator];
        
        if (_imageLoadIndicatorEnabled) [_loadImageIndicator startAnimating];
        [tmpImageView sda_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            tmpImageView.image = image;
            [_loadImageIndicator stopAnimating];
        }];
    }
    
    return [self initWithFrame:frame
                     imageView:tmpImageView
                         title:title
                       content:content
                   description:description
                  buttonTitles:buttonTitles];
}

- (instancetype)initWithFrame:(CGRect)frame
                        image:(UIImage *)image
                        title:(NSString *)title
                      content:(NSString *)content
                  description:(NSString *)description
           confirmButtonTitle:(NSString *)confirmButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... {
    NSMutableArray<NSString *> *buttonTitles = [@[confirmButtonTitle] mutableCopy];
    if (otherButtonTitles) {
        [buttonTitles addObject:otherButtonTitles];
        
        id eachObject;
        va_list argList;
        va_start(argList, otherButtonTitles);
        while ((eachObject = va_arg(argList, id))) {
            [buttonTitles addObject:eachObject];
        }
        va_end(argList);
    }
    
    SSThemedImageView *tmpImageView = nil;
    if (image && [image isKindOfClass:[UIImage class]]) {
        tmpImageView = [[SSThemedImageView alloc] init];
        tmpImageView.image = image;
    }
    
    return [self initWithFrame:frame
                     imageView:tmpImageView
                         title:title
                       content:content description:description buttonTitles:buttonTitles];
}

- (instancetype)initWithFrame:(CGRect)frame
                    imageView:(SSThemedImageView *)imageView
                        title:(NSString *)title
                      content:(NSString *)content
                  description:(NSString *)description
                 buttonTitles:(NSArray<NSString *> *)buttonTitles {
    if ((self = [super initWithFrame:[self.class frameOfFullScreenView]])) {
        _touchDismissEnabled = YES;
        _imageLoadIndicatorEnabled = YES;
        _buttonTitles = buttonTitles;
        
        _titleColorKey      = kTTTitleColorKeyDefault;
        _contentColorKey    = kTTContentColorKeyDefault;
        _buttonTextColorKey = kTTButtonColorKeyDefault;
        _titleFontSize      = kTTTitleFontSizeDefault;
        _contentFontSize    = kTTContentFontSizeDefault;
        _buttonTextFontSize = kTTButtonFontSizeDefault;
        
        _spacingToMarginTop    = kTTSpacingFromTitleToImage;
        _spacingOfText         = kTTSpacingOfText;
        _spacingToMarginBottom = kTTSpacingFromButtonToMarginBottom;
        _widthOfButton         = kTTButtonWidthDefault;
        
        [self setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.5f]];
        [self setTintColor:[UIColor clearColor]];
        
        if (CGRectEqualToRect(frame, CGRectZero))
        frame = CGRectMake(0.0f, 0.0f, kTTPopupViewWidthDefault, kTTPopupViewHeightDefault);
        _containerView = [[SSThemedView alloc] initWithFrame:[self.class adpativeRectForOriginalRect:frame]];
        _containerView.center = self.center;
        _containerView.userInteractionEnabled = YES;
        _containerView.layer.cornerRadius = [TTDeviceUIUtils tt_padding:12.f];
        _containerView.backgroundColorThemeKey = kColorBackground4;
        _containerView.clipsToBounds = YES;
        [self addSubview:_containerView];
        
        if (imageView) {
            _imageView = imageView;
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
            
            [_containerView addSubview:_imageView];
            [self changeTheme];
        }
        
        if (title) {
            _titleLabel = [SSThemedLabel new];
            _titleLabel.numberOfLines = 1;
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:_titleFontSize]];
            _titleLabel.textColorThemeKey = _titleColorKey;
            [_titleLabel setAttributedText:[self.class attributedStringWithString:title fontSize:_titleLabel.font.pointSize lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]];
            [_containerView addSubview:_titleLabel];
        }
        
        if (content) {
            _contentLabel = [SSThemedLabel new];
            _contentLabel.numberOfLines = 0;
            _contentLabel.textAlignment = NSTextAlignmentCenter;
            _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _contentLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:_contentFontSize]];
            _contentLabel.textColorThemeKey = _contentColorKey;
            [_contentLabel setAttributedText:[self.class attributedStringWithString:content fontSize:_contentLabel.font.pointSize lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]];
            [_containerView addSubview:_contentLabel];
        }
        
        if (description) {
            _descriptionLabel = [SSThemedLabel new];
            _descriptionLabel.numberOfLines = 1;
            _descriptionLabel.textAlignment = NSTextAlignmentCenter;
            _descriptionLabel.text = description;
            _descriptionLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:10.f]];
            _descriptionLabel.textColorThemeKey = kColorText3;
            [_containerView addSubview:_descriptionLabel];
        }
        
        if ([_buttonTitles count] > 0) {
            _tableView = [[SSThemedTableView alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_padding:_widthOfButton], 0) style:UITableViewStylePlain];
            _tableView.backgroundColor = [UIColor clearColor];
            _tableView.tableFooterView = [[UIView alloc] init];
            _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
            _tableView.showsHorizontalScrollIndicator = NO;
            _tableView.showsVerticalScrollIndicator = NO;
            _tableView.delegate = self;
            _tableView.dataSource = self;
            _tableView.bounces = NO;
            [_containerView addSubview:_tableView];
        }
        
        _closeButton = [[SSThemedButton alloc]initWithFrame:CGRectMake([TTDeviceUIUtils tt_padding:226], kTTSpacingFromCloseButtonToMargin, [TTDeviceUIUtils tt_padding:kTTCloseButtonWidthDefault], [TTDeviceUIUtils tt_padding:kTTCloseButtonHeightDefault])];
        _closeButton.right = _containerView.width - kTTSpacingFromCloseButtonToMargin;
        [_closeButton addTarget:self action:@selector(didTapCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        
        SSThemedImageView *closeImageView = [[SSThemedImageView alloc]init];
        closeImageView.imageName = @"icon_popup_close";
        closeImageView.enableNightCover = NO;
        closeImageView.frame = CGRectMake(0, 0, closeImageView.image.size.width, closeImageView.image.size.height);
        closeImageView.center = CGPointMake(_closeButton.width / 2, _closeButton.height / 2);
        [_closeButton addSubview:closeImageView];
        [_containerView addSubview:_closeButton];
        
        UITapGestureRecognizer *tapGestureReg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMaskView:)];
        tapGestureReg.numberOfTapsRequired = 1;
        tapGestureReg.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGestureReg];
        self.userInteractionEnabled = YES;
        
        [self makeLayoutIfNeeded];
    }
    return self;
}

- (void)makeLayoutIfNeeded {
    CGFloat offsetY  = 0;
    CGFloat maxWidth = [TTDeviceUIUtils tt_padding:_widthOfButton];
    if (_imageView) {
        offsetY += [TTDeviceUIUtils tt_padding:_spacingToMarginTop];
        _imageView.frame = CGRectMake(0, offsetY, [TTDeviceUIUtils tt_padding:164.f], [TTDeviceUIUtils tt_padding:164.f]);
        _imageView.centerX = _containerView.width / 2;
        offsetY += _imageView.height;
    }
    
    if (_titleLabel) {
        offsetY += [TTDeviceUIUtils tt_padding:_spacingToMarginTop];
        
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:_titleFontSize]];
        _titleLabel.textColorThemeKey = _titleColorKey;
        [_titleLabel setAttributedText:[self.class attributedStringWithString:_titleLabel.text fontSize:_titleLabel.font.pointSize lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]];
        CGRect rect = [_titleLabel.text boundingRectWithSize:CGSizeMake(maxWidth, 300) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_titleLabel.font} context:nil];
        _titleLabel.frame = CGRectIntegral(CGRectMake(0, offsetY, rect.size.width, rect.size.height));
        _titleLabel.centerX = _containerView.width / 2;
        
        offsetY += _titleLabel.height;
    }
    
    if (_contentLabel) {
        offsetY += [TTDeviceUIUtils tt_padding:_spacingOfText];
        
        _contentLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:_contentFontSize]];
        _contentLabel.textColorThemeKey = _contentColorKey;
        [_contentLabel setAttributedText:[self.class attributedStringWithString:_contentLabel.text fontSize:_contentLabel.font.pointSize lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]];
        CGRect rect = [_contentLabel.text boundingRectWithSize:CGSizeMake(maxWidth, 300) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_contentLabel.font} context:nil];
        _contentLabel.frame = CGRectIntegral(CGRectMake(0, offsetY, rect.size.width, rect.size.height));
        _contentLabel.centerX = _containerView.width / 2;
        
        offsetY += _contentLabel.height;
    }
    
    
    if (_descriptionLabel) {
        offsetY += [TTDeviceUIUtils tt_padding:kTTSpacingFromTextToDescription];
        
        CGRect rect = [_descriptionLabel.text boundingRectWithSize:CGSizeMake(maxWidth, 300) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _descriptionLabel.font} context:nil];
        _descriptionLabel.frame = CGRectIntegral(CGRectMake(0, offsetY, rect.size.width, rect.size.height));
        _descriptionLabel.centerX = _containerView.width / 2;
        
        offsetY += _descriptionLabel.height;
    }
    
    if (_tableView) {
        offsetY += [TTDeviceUIUtils tt_padding:10.f]; // default
        
        /* sure to put a button at least */
        CGFloat totalHeight = offsetY + [TTNPopupButtonCell cellHeight] + [TTDeviceUIUtils tt_padding:_spacingToMarginBottom];
        _containerView.height = MAX(_containerView.height, totalHeight);
        
        CGFloat widthOfTable = [TTDeviceUIUtils tt_padding:_widthOfButton];
        CGFloat maxHeightOfTable = _containerView.height - offsetY  - [TTDeviceUIUtils tt_padding:_spacingToMarginBottom];
        CGFloat heightOfTable = MIN(maxHeightOfTable, [TTNPopupButtonCell cellHeight] * [_buttonTitles count]);
        offsetY  = _containerView.height - heightOfTable - [TTDeviceUIUtils tt_padding:_spacingToMarginBottom];
        
        _tableView.frame = CGRectMake(0, offsetY, widthOfTable, heightOfTable);
        _tableView.centerX = _containerView.width / 2;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.frame = CGRectMake(0, 0, [self.class frameOfFullScreenView].size.width, [self.class frameOfFullScreenView].size.height);
    self.containerView.center = CGPointMake(self.width/2, self.height/2);
    
    if (self.superview) {
        [self.superview bringSubviewToFront:self];
    }
}

#pragma mark - theme

- (void)changeTheme {
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        _imageView.alpha = 0.5;
    } else {
        _imageView.alpha = 1;
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    [self changeTheme];
}

#pragma mark - events of tap

- (void)didTapMaskView:(UITapGestureRecognizer *)gestureRecognizer {
    if (_touchDismissEnabled && !CGRectContainsPoint(_containerView.frame, [gestureRecognizer locationInView:self])) {
        [self dismiss];
    }
}

- (void)didTapCloseButton:(id)sender {
    [self dismiss];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.buttonTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TTNPopupButtonCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIndentifier = @"kTTNPopupButtonCellIdentifier";
    TTNPopupButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIndentifier];
    if (!cell) {
        cell = [[TTNPopupButtonCell alloc] initWithReuseIdentifier:reuseIndentifier];
    }
    if (indexPath.row < [_buttonTitles count]) {
        __weak typeof(self) wself = self;
        cell.completionDidTap = ^(id sender) {
            __strong typeof(wself) sself = wself;
            [sself dismissWithAnimated:YES withIndex:indexPath.section completion:sself.didDismissHandler];
        };
        cell.titleButton.titleColorThemeKey = _buttonTextColorKey;
        cell.titleButton.titleLabel.font = [UIFont systemFontOfSize:_buttonTextFontSize];
        [cell reloadWithTitle:[_buttonTitles objectAtIndex:indexPath.row]];
    }
    
    return cell ? : [[UITableViewCell alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return (section != [self.buttonTitles count] - 1) ? [TTNPopupButtonCell footerViewHeight] : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    SSViewBase *aView = nil;
    if (section != [self.buttonTitles count] - 1) {
        aView = [[SSViewBase alloc] initWithFrame:CGRectMake(0, 0, tableView.width, [TTNPopupButtonCell footerViewHeight])];
        aView.backgroundColor = [UIColor clearColor];
    }
    return aView;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - show / dismiss

- (void)showWithCompletion:(TTNPopupViewDidShowBlock)completion {
    [self showInView:[TTUIResponderHelper mainWindow] completion:completion];
}

- (void)showInView:(UIView *)view completion:(TTNPopupViewDidShowBlock)completion {
    if (self.superview) [self removeFromSuperview];
    if (!view) view = [TTUIResponderHelper mainWindow];
    if (!view) return;
    if ([view isKindOfClass:[UIWindow class]]) {
        UIViewController *vc = ((UIWindow *)view).rootViewController;
        while (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).topViewController;
        }
        view = vc.view;
    }
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    self.alpha = 0.3;
    self.hidden = NO;
    __weak typeof(self) wself = self;
    self.containerView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.13 animations:^{
        wself.alpha = 1.0f;
        wself.containerView.transform = CGAffineTransformMakeScale(1.03, 1.03);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.07 animations:^{
            wself.containerView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (completion) completion();
        }];
    }];
}

- (void)dismiss {
    [self dismissWithAnimated:YES];
}

- (void)dismissWithAnimated:(BOOL)animated {
    [self dismissWithAnimated:animated withIndex:-1 completion:self.didDismissHandler];
}

- (void)dismissWithAnimated:(BOOL)animated withIndex:(NSInteger)index completion:(TTNPopupViewDidDismissBlock)didDismissBlock {
    if (animated) {
        __weak typeof(self) wself = self;
        [UIView animateWithDuration:0.1 animations:^{
            __strong typeof(wself) sself = wself;
            sself.alpha = 0.f;
            sself.containerView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        } completion:^(BOOL finished) {
            __strong typeof(wself) sself = wself;
            [sself removeFromSuperview];
            if (didDismissBlock) didDismissBlock(index);
        }];
    } else {
        [self removeFromSuperview];
        if (didDismissBlock) didDismissBlock(index);
    }
}

#pragma mark - Getter/Setter

- (void)setImageLoadIndicatorEnabled:(BOOL)imageLoadIndicatorEnabled {
    _imageLoadIndicatorEnabled = imageLoadIndicatorEnabled;
    if (imageLoadIndicatorEnabled) [_loadImageIndicator startAnimating];
    else [_loadImageIndicator stopAnimating];
}

- (void)setSpacingToMarginTop:(CGFloat)spacingToMarginTop {
    if (_spacingToMarginBottom != spacingToMarginTop) {
        _spacingToMarginBottom = spacingToMarginTop;
        [self makeLayoutIfNeeded];
    }
}

- (void)setSpacingOfText:(CGFloat)spacingOfText {
    if (_spacingOfText != spacingOfText) {
        _spacingOfText = spacingOfText;
        [self makeLayoutIfNeeded];
    }
}

- (void)setSpacingToMarginBottom:(CGFloat)spacingToMarginBottom {
    if (_spacingToMarginBottom != spacingToMarginBottom) {
        _spacingToMarginBottom = spacingToMarginBottom;
        [self makeLayoutIfNeeded];
    }
}

- (void)setWidthOfButton:(CGFloat)widthOfButton {
    if (_widthOfButton != widthOfButton) {
        _widthOfButton = widthOfButton;
        [self makeLayoutIfNeeded];
    }
}

- (void)setTitleColorKey:(NSString *)titleColorKey {
    if (_titleColorKey != titleColorKey) {
        [self makeLayoutIfNeeded];
    }
}

- (void)setTitleFontSize:(CGFloat)titleFontSize {
    if (_titleFontSize != titleFontSize) {
        _titleFontSize = titleFontSize;
        [self makeLayoutIfNeeded];
    }
}

- (void)setContentColorKey:(NSString *)contentColorKey {
    if (_contentColorKey != contentColorKey) {
        _contentColorKey = contentColorKey;
        [self makeLayoutIfNeeded];
    }
}

- (void)setContentFontSize:(CGFloat)contentFontSize {
    if (_contentFontSize != contentFontSize) {
        _contentFontSize = contentFontSize;
        [self makeLayoutIfNeeded];
    }
}

- (void)setButtonTextColorKey:(NSString *)buttonTextColorKey {
    if (_buttonTextColorKey != buttonTextColorKey) {
        _buttonTextColorKey = buttonTextColorKey;
        [_tableView reloadData];
    }
}

- (void)setButtonTextFontSize:(CGFloat)buttonTextFontSize {
    if (_buttonTextFontSize != buttonTextFontSize) {
        _buttonTextFontSize = buttonTextFontSize;
        [_tableView reloadData];
    }
}

#pragma mark - NSMutableAttributedString Helper

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)fontSize lineSpacing:(CGFloat)lineSpace lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)alignment {
    if (isEmptyString(string)) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    NSDictionary *attributes = [self _attributesWithFontSize:fontSize lineSpacing:lineSpace lineBreakMode:lineBreakMode textAlignment:alignment];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setAttributes:attributes range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}

+ (NSDictionary *)_attributesWithFontSize:(CGFloat)fontSize lineSpacing:(CGFloat)lineSpace lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)alignment {
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = lineBreakMode;
    style.lineSpacing = lineSpace;
    style.alignment = alignment;
    
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style};
    return attributes;
}

@end
