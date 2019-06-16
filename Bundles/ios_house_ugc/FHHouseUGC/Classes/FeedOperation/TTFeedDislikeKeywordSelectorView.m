//
//  TTFeedDislikeContentPopoverView.m
//  Bytedancebase-BDOpenSDK
//
//  Created by 曾凯 on 2018/7/13.
//

#import "TTFeedDislikeKeywordSelectorView.h"
#import "UIViewAdditions.h"
#import "TTFeedPopupController.h"
#import "SSThemed.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTFeedDislikeConfig.h"
#import "FHFeedOperationView.h"

NSString *const FeedDislikeNeedReportNotification = @"FeedDislikeNeedReportNotification";

@interface TTFeedDislikeKeywordSelectorView ()

@property (nonatomic, strong) TTFeedDislikeOption *option;
@property (nonatomic, strong) NSDictionary *textStrings;

@property (nonatomic, strong) SSThemedView *backgroundView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *topSepartor;
@property (nonatomic, strong) NSMutableArray<UIButton *> *keywordButtons;
@property (nonatomic, strong) NSMutableArray<UIView *> *tempViews;

@property (nonatomic, strong) UIWindow *backWindow;

@end

@implementation TTFeedDislikeKeywordSelectorView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textStrings = [TTFeedDislikeConfig textStrings];
        
        _backgroundView = ({
            SSThemedView *v = [[SSThemedView alloc] init];
            v.backgroundColorThemeKey = kColorBackground4;
            v;
        });
        [self addSubview:_backgroundView];
        
        _backButton = ({
            SSThemedButton *v = [SSThemedButton buttonWithType:UIButtonTypeSystem];
            [v setTitle:@"返回" forState:UIControlStateNormal];
            [v setImage:[UIImage themedImageNamed:@"feed_dislike_arrow_left" inBundle:FHFeedOperationView.resourceBundle] forState:UIControlStateNormal];
            v.tintColorThemeKey = kColorText1;
            v.titleLabel.font = [UIFont systemFontOfSize:16.0];
            [v addTarget:self action:@selector(onBackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            v;
        });
        [self addSubview:_backButton];
        
        _titleLabel = ({
            SSThemedLabel *v = [SSThemedLabel new];
            v.font = [UIFont systemFontOfSize:16.0];
            v.textColorThemeKey = kColorText1;
            v.accessibilityTraits = UIAccessibilityTraitHeader;
            v;
        });
        [self addSubview:_titleLabel];
        
        _topSepartor = ({
            SSThemedView *v = [SSThemedView new];
            v.backgroundColorThemeKey = kColorLine1;
            v;
        });
        [self addSubview:_topSepartor];
        
        _keywordButtons = [NSMutableArray array];
        _tempViews = [NSMutableArray array];
        
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.titleLabel);
    }
    return  self;
}

- (void)refreshWithOption:(TTFeedDislikeOption *)option {
    self.option = option;
    self.titleLabel.text = [self titleStrForOptionType:option.type];
    for (TTFeedDislikeWord *kw in option.words) {
        SSThemedButton *b = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [b addTarget:self action:@selector(onKeywordButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        NSString *name = kw.name;
        if (option.type == TTFeedDislikeOptionTypeShield) {
            name = [self replacePrefixStrForShieldTypeKeywordName:name];
        }
        [b setTitle:name forState:UIControlStateNormal];
        b.titleLabel.font = [UIFont systemFontOfSize:16.0];
        b.titleColorThemeKey = kColorText1;
        b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        b.contentEdgeInsets = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0);
        [self addSubview:b];
        [self.keywordButtons addObject:b];
    }
    [self setNeedsLayout];
}

- (NSString *)replacePrefixStrForShieldTypeKeywordName:(NSString *)name {
    NSString *header = @"不想看:";
    NSRange r = [name rangeOfString:header];
    if (r.location == 0) {
        name = [name stringByReplacingCharactersInRange:r withString:[NSString stringWithFormat:@"%@:", self.textStrings[@"new_dislike_nosee_pre"]]];
    }
    return name;
}

- (NSString *)titleStrForOptionType:(TTFeedDislikeOptionType)type {
    if (type == TTFeedDislikeOptionTypeFeedback) return @"反馈";
    if (type == TTFeedDislikeOptionTypeShield) return self.textStrings[@"new_dislike_nosee_title"];
    return  @"选择";
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.tempViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.tempViews removeAllObjects];
    
    CGFloat padding = 15.0;
    CGFloat offsetTop = padding;
    
    self.backgroundView.frame = self.bounds;
    
    [self.titleLabel sizeToFit];
    self.titleLabel.top = offsetTop;
    self.titleLabel.centerX = self.width / 2.0;
    offsetTop = self.titleLabel.bottom;
    
    [self.backButton sizeToFit];
    self.backButton.centerY = self.titleLabel.centerY;
    self.backButton.left = padding;
    
    self.topSepartor.size = CGSizeMake(self.width, [TTDeviceHelper ssOnePixel]);
    self.topSepartor.top = offsetTop + 16.0;
    self.topSepartor.left = 0.0;
    offsetTop = self.topSepartor.bottom;

    for (UIButton *b in self.keywordButtons) {
        [b sizeToFit];
        b.size = CGSizeMake(self.width, 46.0);
        b.top = offsetTop;
        
        offsetTop = b.bottom;

        if (b != self.keywordButtons.lastObject || self.option.type == TTFeedDislikeOptionTypeShield) {
            UIView *separator = ({
                SSThemedView *v = [SSThemedView new];
                v.backgroundColorThemeKey = kColorLine1;
                v;
            });
            [self addSubview:separator];
            [self.tempViews addObject:separator];
            separator.height = [TTDeviceHelper ssOnePixel];
            separator.top = offsetTop;
            separator.left = padding;
            separator.width = self.width - separator.left - padding;
            offsetTop = separator.bottom;
        }
    }
    
    if (self.option.type == TTFeedDislikeOptionTypeShield) {
        SSThemedButton *reportBTN = ({
            SSThemedButton *b = [SSThemedButton buttonWithType:UIButtonTypeCustom];
            [b addTarget:self action:@selector(onReportButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [b setImage:[UIImage themedImageNamed:@"write_new" inBundle:FHFeedOperationView.resourceBundle] forState:UIControlStateNormal];
            [b setTitle:@"我要吐槽" forState:UIControlStateNormal];
            b.titleLabel.font = [UIFont systemFontOfSize:16.0];
            b.titleColorThemeKey = kColorText1;
            b.tintColorThemeKey = kColorText1;
            b.backgroundColorThemeKey = kColorBackground3;
            b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            b.contentEdgeInsets = UIEdgeInsetsMake(0.0, 6.0, 0.0, 0.0);
            b.layer.cornerRadius = 16.0;
            b.layer.borderWidth = 0.5;
            b.borderColorThemeKey = kColorLine1;
            b;
        });
        [self.tempViews addObject:reportBTN];
        [self addSubview:reportBTN];
        reportBTN.width = self.width - 2 * padding;
        reportBTN.height = 32.0;
        reportBTN.top = offsetTop + 6.5;
        reportBTN.left = padding;
        offsetTop = reportBTN.bottom + 7.5;
    }
    
    self.contentSizeInPopup = CGSizeMake(self.width, offsetTop);
}

- (void)onReportButtonTapped:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:FeedDislikeNeedReportNotification object:nil];
}

- (void)onBackButtonTapped:(UIButton *)sender {
    [self.popupController popViewAnimated:true];
}

- (void)onKeywordButtonTapped:(UIButton *)sender {
    NSUInteger idx = [self.keywordButtons indexOfObject:sender];
    if (idx > self.option.words.count - 1) return;
    if (self.selectionFinished) self.selectionFinished(self.option.words[idx]);
}

@end
