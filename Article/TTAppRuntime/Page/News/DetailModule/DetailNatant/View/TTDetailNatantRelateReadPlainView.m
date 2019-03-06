//
//  TTDetailNatantRelateReadPlainView.m
//  Article
//
//  Created by yuxin on 5/5/16.
//
//

#import "TTDetailNatantRelateReadPlainView.h"
#import "SSThemed.h"
#import "UIViewAdditions.h"
#import "TTRoute.h"
#import "SSUserSettingManager.h"
#import "TTUISettingHelper.h"
#import "NSString-Extension.h"
#import "TTStringHelper.h"
#import "TTLabelTextHelper.h"
#import "TTIconFontDefine.h"
#import "UIColor+TTThemeExtension.h"
#import "TTArticleDetailViewController.h"
#import "TTTrackerWrapper.h"
#import "TTImageView.h"
#import "UIColor+Theme.h"
#define kTitleFontSize [SSUserSettingManager newDetailRelateReadFontSize]

@interface TTDetailNatantRelateReadPlainView ()

@property (nonnull, strong, nonatomic) TTDetailNatantRelatedItemModel * model;
@property(nonatomic, strong)SSThemedLabel * titleLabel;
@property(nonatomic, strong)TTImageView * rightImageView;

@property(nonatomic, strong)SSThemedView * bottomLineView;
@property(nonatomic, strong)SSThemedButton * bgButton;

@end

@implementation TTDetailNatantRelateReadPlainView

+ (nullable TTDetailNatantRelateReadPlainView *)genViewForModel:(nullable TTDetailNatantRelatedItemModel *)model
                                                       width:(float)width
{
    TTDetailNatantRelateReadPlainView *view = [[TTDetailNatantRelateReadPlainView alloc] initWithWidth:width];
    [view refreshModel:model];
    return view;
}

- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        self.backgroundColorThemeKey= kColorBackground14;
        self.bgButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_bgButton addTarget:self action:@selector(bgButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _bgButton.frame = self.bounds;
        _bgButton.backgroundColor = [UIColor clearColor];;
        _bgButton.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
        _bgButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bgButton];
        
        self.titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
        _titleLabel.textColors = [TTUISettingHelper detailViewBodyColors];
        _titleLabel.textColors = @[ [UIColor themeGray1],[UIColor colorWithHexString:@"707070"] ];
        [self addSubview:_titleLabel];
        
        
        self.rightImageView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _rightImageView.layer.masksToBounds = YES;
        _rightImageView.layer.cornerRadius = 4;
        _rightImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_rightImageView];
        
        self.bottomLineView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
        _bottomLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _bottomLineView.hidden = YES;
//        [self addSubview:_bottomLineView];
        
        [self reloadThemeUI];
        
    }
    return self;
}

- (void)refreshFrame {

    CGFloat finalHeight = 45;
    if ([_model.middle_image isKindOfClass:[NSDictionary class]] && [_model.middle_image.allKeys containsObject:@"url"]) {
        NSString *imageUrlStr = [_model.middle_image valueForKey:@"url"];
        if (imageUrlStr) {
            [self.rightImageView setImageWithURLString:imageUrlStr placeholderImage:nil options:0 success:^(UIImage *image, BOOL cached) {
                
                
            } failure:nil];
        }
        self.rightImageView.frame = CGRectMake(self.width - 80, 10.0f, 80.0f, 60.0f);
        
        finalHeight = self.rightImageView.height;
        
        _titleLabel.frame = CGRectMake(0, [TTDeviceUIUtils tt_padding:8.f], self.width - self.rightImageView.width - 15, 60);
    }else
    {
        _titleLabel.frame = CGRectMake(0, [TTDeviceUIUtils tt_padding:8.f], self.width - self.rightImageView.width, 60);
    }
    
    if (isEmptyString(_model.typeName)) {
        self.titleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:_model.title fontSize:kTitleFontSize lineHeight:ceil(1.4 * kTitleFontSize) lineBreakMode:NSLineBreakByTruncatingTail];
    }
    else {
        [self resetContentString];
    }
    self.titleLabel.height = [TTLabelTextHelper heightOfText:self.titleLabel.text fontSize:kTitleFontSize forWidth:(_titleLabel.width) forLineHeight:ceil(1.4 * kTitleFontSize) constraintToMaxNumberOfLines:2];

    if (self.rightImageView.width == 0) {
        finalHeight = self.titleLabel.height;
    }
    
    self.frame = CGRectMake(0, 0, self.width, finalHeight + [TTDeviceUIUtils tt_padding:20.f]);
    self.titleLabel.centerY = self.centerY;
    [self refreshBottomLineView];
}

- (void)refreshModel:(nullable TTDetailNatantRelatedItemModel *)model
{
    _model = model;

    _titleLabel.frame = CGRectMake(15, [TTDeviceUIUtils tt_padding:8.f], self.width - 30, 45);

    if (isEmptyString(model.typeName)) {
        self.titleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:model.title fontSize:kTitleFontSize lineHeight:ceil(1.4 * kTitleFontSize) lineBreakMode:NSLineBreakByTruncatingTail];
    }
    else {
        [self resetContentString];
    }
    self.titleLabel.height = [TTLabelTextHelper heightOfText:self.titleLabel.text fontSize:kTitleFontSize forWidth:(self.width - 30.f) forLineHeight:ceil(1.4 * kTitleFontSize) constraintToMaxNumberOfLines:2];

    self.frame = CGRectMake(0, 0, self.width, self.titleLabel.height + [TTDeviceUIUtils tt_padding:20.f]);
    self.titleLabel.centerY = self.centerY;
    [self refreshBottomLineView];
    
    [self sendSubviewToBack:_bgButton];
}

- (void)resetContentString {
    NSString *contentString = [[_model.typeName stringByAppendingString:iconfont_verticalLine] stringByAppendingString:_model.title];
    UIFont *font = [UIFont systemFontOfSize:kTitleFontSize];
    CGFloat lineHeightMultiple = 1.4 * kTitleFontSize / font.lineHeight;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.lineHeightMultiple = lineHeightMultiple;
    style.minimumLineHeight = font.lineHeight * lineHeightMultiple;
    style.maximumLineHeight = font.lineHeight * lineHeightMultiple;
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:contentString attributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName:style}];
    NSRange range = [contentString rangeOfString:iconfont_verticalLine];
    [mutableAttributedString addAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"iconfont" size:kTitleFontSize], NSForegroundColorAttributeName: [UIColor tt_themedColorForKey:kColorText14]} range:range];
    self.titleLabel.attributedText = mutableAttributedString;
}

- (void)fontChanged{
    _titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
}

- (void)refreshBottomLineView
{
    _bottomLineView.frame = CGRectMake(15, self.height - [TTDeviceHelper ssOnePixel], self.width - 30, [TTDeviceHelper ssOnePixel]);
}

- (void)hideBottomLine:(BOOL)hide
{
    self.bottomLineView.hidden = hide;
}

-(void)bgButtonClicked
{
    NSString * openPageURL = self.model.schema;
    if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:openPageURL]]) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openPageURL]];
    }
    
    self.titleLabel.textColors = [TTUISettingHelper cellViewHighlightedtTitleColors];
    
    UIViewController *vc = self.viewController.parentViewController;
    if (vc && [vc isKindOfClass:[TTArticleDetailViewController class]]) {
        TTArticleDetailViewController *articleVC = (TTArticleDetailViewController *)vc;
        if (articleVC.shouldShowTipsOnNavBar) {
            [TTTrackerWrapper eventV3:@"push_detail_read" params:@{@"value":@(1)}];
        }
    }
}
@end
