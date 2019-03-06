//
//  TTFeedDislikeView.m
//  Article
//
//  Created by Chen Hong on 14/11/19.
//
//

#import "TTFeedDislikeView.h"
#import "TTFeedDislikeKeywordsView.h"
#import "TTFeedDislikeWord.h"
#import "SSThemed.h"

#import "TTThemeConst.h"
#import "UIColor+TTThemeExtension.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceUIUtils.h"
#import "TTTracker.h"
#import "UIColor+Theme.h"

#define kMaskViewTag 20141209

#pragma mark - global variable

// 在内存中保存上次选中的dislikeWords
static NSString *__lastGroupID;
static NSMutableArray *__lastDislikedWords;
static BOOL s_enable = YES;
static TTFeedDislikeView *__visibleDislikeView;


@implementation TTFeedDislikeViewModel
@end

#pragma mark - TTFeedDislikeView
//---------------------------------------------------------------
@interface TTFeedDislikeView () <TTFeedDislikeKeywordsViewDelegate>

@property(nonatomic, strong)UIView *arrowBgView;
@property(nonatomic, strong)UIView *contentBgView;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic,strong)SSThemedButton *okBtn;
@property(nonatomic, strong)UIImageView *arrowImageView;
@property(nonatomic, strong)TTFeedDislikeKeywordsView *keywordsView;
@property(nonatomic, strong)NSMutableArray *dislikeWords;
@property(nonatomic, strong)SSThemedButton *dislikeBtn;
@property(nonatomic, copy)NSString *adLogExtra;
@property(nonatomic, strong)TTFeedDislikeBlock didDislikeBlock;
@end


@implementation TTFeedDislikeView

- (void)dealloc {
    __visibleDislikeView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIWindow *window = SSGetMainWindow();
        if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
            self.layer.cornerRadius = 0;
            if ([TTDeviceHelper isPadDevice]) {
                self.width = MIN(window.frame.size.width - 30, 400);
            }
            else {
                self.width = window.frame.size.width;
            }
        }
        else {
            self.layer.cornerRadius = 4.f;
            UIWindow *window = SSGetMainWindow();
            self.width = MIN(window.frame.size.width - 30, 400);
        }
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        if (!__lastDislikedWords) {
            __lastDislikedWords = [NSMutableArray arrayWithCapacity:10];
        }
        self.dislikeWords = [NSMutableArray arrayWithCapacity:10];
        
        self.arrowBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        _arrowBgView.backgroundColor = [UIColor clearColor];
        [self addSubview:_arrowBgView];
        
        self.contentBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        [self addSubview:_contentBgView];
        
        self.okBtn = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, [self buttonWidth], [self buttonHeight])];
        
        _okBtn.backgroundColorThemeKey = kFHColorClearBlue;
        _okBtn.highlightedBackgroundColorThemeKey = kFHColorClearBlue;
        [_okBtn addTarget:self action:@selector(okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_contentBgView addSubview:_okBtn];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        self.titleLabel.text = NSLocalizedString(@"可选理由，精准屏蔽", nil);
        [_titleLabel sizeToFit];
        [_contentBgView addSubview:_titleLabel];
        
        self.keywordsView = [[TTFeedDislikeKeywordsView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        self.keywordsView.backgroundColor = [UIColor clearColor];
        self.keywordsView.delegate = self;
        [_contentBgView addSubview:_keywordsView];
        
        self.dislikeBtn = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, [self dislikeButtonWidth], [self dislikeButtonHeight])];
        [_dislikeBtn.titleLabel setFont:[UIFont systemFontOfSize:[self fontSizeForDislikeButton]]];
        _dislikeBtn.highlightedTitleColorThemeKey = kColorText8;
        _dislikeBtn.backgroundColorThemeKey = kFHColorClearBlue;
        _dislikeBtn.highlightedBackgroundColorThemeKey = kFHColorClearBlue;

        [_dislikeBtn addTarget:self action:@selector(okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _dislikeBtn.layer.cornerRadius = 4;
        [self addSubview:_dislikeBtn];
        
        [self reloadThemeUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rootViewWillTransitionToSize:) name:@"kRootViewWillTransitionToSize" object:nil];
        
        self.adLogExtra = @"";
        
        if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
            [_okBtn.titleLabel setFont:[UIFont systemFontOfSize:13.f]];
            [_okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_okBtn setTitle:NSLocalizedString(@"不喜欢", nil) forState:UIControlStateNormal];
            [_titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:18] ? : [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:18.f]]];
            [_dislikeBtn setTitle:NSLocalizedString(@"不喜欢", nil) forState:UIControlStateNormal];
        }
        else {
            _contentBgView.layer.cornerRadius = 4.f;
            _contentBgView.clipsToBounds = YES;
            [_okBtn.titleLabel setFont:[UIFont systemFontOfSize:13.f]];
            [_okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_okBtn setTitle:NSLocalizedString(@"不感兴趣", nil) forState:UIControlStateNormal];
            [_titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:13] ? : [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:13.f]]];
            [_dislikeBtn setTitle:NSLocalizedString(@"不感兴趣", nil) forState:UIControlStateNormal];
            [_dislikeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_dislikeBtn.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
            _okBtn.layer.cornerRadius = 4;
        }

    }
    return self;
}

- (void)refreshWithModel:(nullable TTFeedDislikeViewModel *)model {
    NSArray *keywords = model.keywords;
    NSString *groupID = model.groupID;

    self.adLogExtra = model.logExtra;

    if (keywords.count > 0) {
        // 如果上次已选择过，使用上次的选择，理论上应该全量比较__lastDislikedWords和keywords，关键词完全一致才能使用之前缓存的
        if ([__lastGroupID isEqualToString:groupID] && __lastDislikedWords.count == keywords.count) {
            self.dislikeWords = __lastDislikedWords;
        } else {
            [self.dislikeWords removeAllObjects];
            [__lastDislikedWords removeAllObjects];
            
            for (NSDictionary *dict in keywords) {
                if ([dict isKindOfClass:[NSDictionary class]]) {
                    TTFeedDislikeWord *word = [[TTFeedDislikeWord alloc] initWithDict:dict];
                    [self.dislikeWords addObject:word];
                }
            }
        }
        
        __lastGroupID = groupID;
        
        _keywordsView.width = self.width;
        [_keywordsView refreshWithData:self.dislikeWords];
        
    }
    
    NSMutableDictionary *extValueDic = [NSMutableDictionary dictionary];
    if (self.adLogExtra) {
        extValueDic[@"log_extra"] = self.adLogExtra;
    }

    if (model.extrasDict) {
        [extValueDic addEntriesFromDictionary:model.extrasDict];
    }

    NSString *source = model.source;
    ttTrackEventWithCustomKeys(@"dislike", keywords.count > 0 ? @"menu_with_reason" : @"menu_no_reason", __lastGroupID, source, extValueDic);
}

- (void)refreshArrowUI
{
    if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
        NSString *imageName = @"ugc_pop_corner";
        [self.arrowImageView removeFromSuperview];
        self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:imageName]];
        [_arrowImageView sizeToFit];
        [_arrowBgView addSubview:self.arrowImageView];
        _arrowBgView.height = _arrowImageView.height;
        _arrowImageView.top = self.arrowDirection == TTFeedPopupViewArrowUp ? 1.f : -1.f; // overlapping
        CGPoint arrowPoint = [self convertPoint:self.arrowPoint fromView:self.maskView];
        _arrowImageView.right = arrowPoint.x + 8;
        CGFloat angle = (self.arrowDirection == TTFeedPopupViewArrowUp ? 0 : M_PI);
        self.arrowImageView.transform = CGAffineTransformMakeRotation(angle);
    }
    else {
        NSString *imageName = self.arrowDirection == TTFeedPopupViewArrowUp ? @"arrow_up_popup_textpage.png" : @"arrow_down_popup_textpage.png";
        [self.arrowImageView removeFromSuperview];
        self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:imageName]];
        [_arrowImageView sizeToFit];
        [_arrowBgView addSubview:self.arrowImageView];
        _arrowBgView.height = _arrowImageView.height;
        _arrowImageView.top = self.arrowDirection == TTFeedPopupViewArrowUp ? 1.f : -1.f; // overlapping
        CGPoint arrowPoint = [self convertPoint:self.arrowPoint fromView:self.maskView];
        _arrowImageView.right = arrowPoint.x + 8;
    }
    
}

- (void)refreshContentUI
{
    [self refreshOKBtn];
    [self refreshTitleLabel];
    
    if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
        _keywordsView.origin = CGPointMake(0, [TTDeviceUIUtils tt_newPadding:20.f]);
        _okBtn.origin = CGPointMake(_contentBgView.width - [self leftPadding] - _okBtn.width, _keywordsView.bottom +  12.f);
        _titleLabel.centerX = ceilf(self.width / 4);
        _okBtn.width = [TTDeviceUIUtils tt_newPadding:90];
        _okBtn.height = [TTDeviceUIUtils tt_newPadding:30.f];
        _okBtn.centerX = self.width * 3 / 4 - 5;
        _okBtn.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:4.f];
        
        _titleLabel.centerY = _okBtn.centerY;
        _contentBgView.height = _okBtn.bottom + [TTDeviceUIUtils tt_newPadding:20.f];
        
        _titleLabel.left = ceilf(_titleLabel.left);
        _titleLabel.top = ceilf(_titleLabel.top);
    }
    else {
        _okBtn.origin = CGPointMake(_contentBgView.width - [self leftPadding] - _okBtn.width, 12.f);
        _titleLabel.left = [self leftPadding];
        _titleLabel.centerY = _okBtn.centerY;
        _keywordsView.origin = CGPointMake(0, _okBtn.bottom + 10.f);
        _contentBgView.height = _keywordsView.bottom + 12.f;
    }
    
}

- (void)refreshUI {
    if (self.dislikeWords.count == 0) {
        self.contentBgView.hidden = YES;
        self.arrowBgView.hidden = YES;
        self.dislikeBtn.hidden = NO;
        
        self.bounds = self.dislikeBtn.bounds;
    } else {
        self.contentBgView.hidden = NO;
        self.arrowBgView.hidden = NO;
        self.dislikeBtn.hidden = YES;
        
        [self refreshArrowUI];
        if (self.arrowDirection == TTFeedPopupViewArrowUp) {
            _arrowBgView.origin = CGPointMake(0, 0);
            _contentBgView.origin = CGPointMake(0, _arrowBgView.bottom);
            [self refreshContentUI];
        } else {
            _contentBgView.origin = CGPointMake(0, 0);
            [self refreshContentUI];
            _arrowBgView.origin = CGPointMake(0, _contentBgView.bottom);
        }
        
        self.height = _contentBgView.height + _arrowBgView.height;
    }
}

- (void)viewWillDisappear {
    __lastDislikedWords = self.dislikeWords;
}

- (void)okBtnClicked:(id)sender {
    
    if (self.didDislikeBlock) {
        self.didDislikeBlock(self);
    }

    NSMutableDictionary *extValueDic = [NSMutableDictionary dictionary];
    if (self.adLogExtra) {
        extValueDic[@"log_extra"] = self.adLogExtra;
    }

    if (self.dislikeWords.count > 0) {
        [self dismiss];
        
        ttTrackEventWithCustomKeys(@"dislike", @"confirm_with_reason", __lastGroupID, nil, extValueDic);

        __lastDislikedWords = nil;
        __lastGroupID = nil;

    } else {
        [self showDislikeButton:NO atPoint:self.origin];
        
        ttTrackEventWithCustomKeys(@"dislike", @"confirm_no_reason", __lastGroupID, nil, extValueDic);
    }
}

- (void)clickMask {
    if (self.dislikeWords.count > 0) {
        [self dismiss];
    } else {
        [self showDislikeButton:NO atPoint:self.origin];
    }
}

//["id1", "id2", ...]
- (NSArray<NSString *> *)selectedWords {
    NSMutableArray *array = [NSMutableArray array];
    for (TTFeedDislikeWord *word in self.dislikeWords) {
        if (word.isSelected) {
            [array addObject:word.ID];
        }
    }
    return array;
}

#pragma mark - TTFeedDislikeKeywordsViewDelegate

- (void)dislikeKeywordsSelectionChanged {
    [self refreshOKBtn];
    [self refreshTitleLabel];
}

- (void)refreshOKBtn {
    if (self.selectedWords.count > 0) {
        [self.okBtn setTitle:@"确定" forState:UIControlStateNormal];
    } else {
        if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
            [self.okBtn setTitle:@"不喜欢" forState:UIControlStateNormal];
        }
        else {
            [self.okBtn setTitle:@"不感兴趣" forState:UIControlStateNormal];
        }
    }
}

- (void)refreshTitleLabel
{
    if (self.selectedWords.count > 0) {
        NSString * title = [NSString stringWithFormat:@"已选%lu个理由", (unsigned long)self.selectedWords.count];
        NSRange range = NSMakeRange(2, 1);
        NSMutableAttributedString * atrrTitle = [[NSMutableAttributedString alloc] initWithString:title];
        [atrrTitle setAttributes:@{ NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kFHColorClearBlue] } range:range];
        [self.titleLabel setAttributedText:atrrTitle];
    } else {
        [self.titleLabel setText:@"可选理由，精准屏蔽"];
    }
    
    [self.titleLabel sizeToFit];
    if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
        self.titleLabel.centerX = ceilf(self.width / 4);
    }
    else {
        self.titleLabel.left = [self leftPadding];
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    _contentBgView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
        [self.titleLabel setTextColor:[UIColor themeGray1]];
    }
    else {
        [self.titleLabel setTextColor:[UIColor themeGray1]];
    }
}

- (void)showAtPoint:(CGPoint)p
           fromView:(UIView *)fromView
       didDislikeBlock:(TTFeedDislikeBlock)didDislikeBlock
{
   if (!s_enable || !fromView) {
        return;
    }

    UIView *parentView = ({
        UIView *view;
        UIWindow *window = SSGetMainWindow();
        if (window.rootViewController.view) {
            view = window.rootViewController.view;
        } else {
            view = window;
        }

        view;
    });
    
    __visibleDislikeView = self;
    
    self.didDislikeBlock = didDislikeBlock;
    
    if (!self.maskView) {
        self.maskView = [UIButton buttonWithType:UIButtonTypeCustom];
        self.maskView.frame = parentView.bounds;
        self.maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self.maskView addTarget:self action:@selector(clickMask) forControlEvents:UIControlEventTouchUpInside];
        [self.maskView addSubview:self];
    }
    
    [parentView addSubview:self.maskView];
    [parentView bringSubviewToFront:self.maskView];
    self.maskView.tag = kMaskViewTag;
    
    p = [self.maskView convertPoint:p fromView:fromView.superview];
    
    CGPoint dislikeOrigin = p;
    self.arrowPoint = p;
    [self refreshUI];
    
    if (p.y + [self arrowOffsetY] + self.height + 15 > parentView.height) {
        p.y -= [self arrowOffsetY];
        self.arrowDirection = TTFeedPopupViewArrowDown;
        self.bottom = p.y;
    } else {
        p.y += [self arrowOffsetY];
        self.arrowDirection = TTFeedPopupViewArrowUp;
        self.top = p.y;
    }
    
    if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
        if ([TTDeviceHelper isPadDevice]) {
            if (p.x + self.width/2 > self.maskView.width) {
                self.right = self.maskView.width - 15;
            } else {
                self.right = p.x + self.width/2;
            }
        }
        else {
            self.right = self.maskView.width;
            self.left = 0;
        }
    }
    else {
        if (p.x + self.width/2 > self.maskView.width) {
            self.right = self.maskView.width - 15;
        } else {
            self.right = p.x + self.width/2;
        }
    }
    
    [self refreshUI];
    
    CGPoint arrowPoint = [self convertPoint:p fromView:self.maskView];
    
    if (self.frame.size.width > 0 && self.frame.size.height > 0) {
        CGRect frame = self.frame;
        self.layer.anchorPoint = CGPointMake(arrowPoint.x / self.width, arrowPoint.y / self.height);
        self.frame = frame;
    }
    
    if (self.dislikeWords.count > 0) {
        self.alpha = 1.f;
        self.maskView.alpha = 0.f;
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
            //self.alpha = 1.f;
            self.maskView.alpha = 1.f;
        } completion:^(BOOL finished) {
            //self.alpha = 1.f;
            self.maskView.alpha = 1.f;
            [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:nil];
        }];
    } else {
        [self showDislikeButton:YES atPoint:dislikeOrigin];
    }
}

- (void)showDislikeButton:(BOOL)bShow atPoint:(CGPoint)dislikeOrigin {
    CGFloat w = [self dislikeButtonWidth];
    CGFloat h = [self dislikeButtonHeight];
    
    if (bShow) {
        self.alpha = 0.f;
        self.maskView.alpha = 0.f;
        self.frame = CGRectMake(dislikeOrigin.x - [self dislikeButtonGapX], dislikeOrigin.y - h/2, 0, h);
        
        CGPoint destPoint = CGPointMake(dislikeOrigin.x - [self dislikeButtonGapX] - w, dislikeOrigin.y - h/2);
        [UIView animateWithDuration:0.15 delay:0.f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.alpha = 1.f;
            self.maskView.alpha = 1.f;
            self.frame = CGRectMake(destPoint.x, destPoint.y, w, h);
        } completion:^(BOOL finished) {
            self.alpha = 1.f;
            self.maskView.alpha = 1.f;
        }];
    } else {
        CGPoint origin = self.origin;
        CGPoint destPoint = CGPointMake(origin.x + w, origin.y);
        [UIView animateWithDuration:0.15 delay:0.f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.alpha = 0.f;
            self.maskView.alpha = 0.f;
            self.frame = CGRectMake(destPoint.x, destPoint.y, 0, h);
        } completion:^(BOOL finished) {
            self.alpha = 0.f;
            self.maskView.alpha = 0.f;
            [self dismiss:NO];
        }];
    }
}

#pragma mark - size & height

- (CGFloat)leftPadding {
    static CGFloat padding = 0;
    if (padding == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            padding = 14.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            padding = 14.f;
        } else {
            padding = 12.f;
        }
    }
    return padding;
}

- (CGFloat)bottomPadding {
    static CGFloat padding = 0;
    if (padding == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            padding = 11.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            padding = 12.f;
        } else {
            padding = 10.f;
        }
    }
    return padding;
}

- (CGFloat)heightForTitleBar {
    static CGFloat h = 0;
    if (h == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            h = 37.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            h = 38.f;
        } else {
            h = 36.f;
        }
    }
    return h;
}

- (CGFloat)fontSizeForTitleLabel {
    static float fontSize = 0;
    if (fontSize == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            fontSize = 18.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            fontSize = 18.f;
        } else {
            fontSize = 15.f;
        }
    }
    return fontSize;
}

- (CGFloat)fontSizeForSubTitleLabel {
    static float fontSize = 0;
    if (fontSize == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            fontSize = 12.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            fontSize = 13.f;
        } else {
            fontSize = 11.f;
        }
    }
    return fontSize;
}

- (CGFloat)buttonWidth {
    static float w = 0;
    if (w == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            w = 84.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            w = 84.f;
        } else {
            w = 80.f;
        }
    }
    return w;
}


- (CGFloat)buttonHeight {
    static float h = 0;
    if (h == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            h = 30.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            h = 30.f;
        } else {
            h = 30.f;
        }
    }
    return h;
}

- (CGFloat)fontSizeForButton {
    static float fontSize = 0;
    if (fontSize == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            fontSize = 17.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            fontSize = 17.f;
        } else {
            fontSize = 15.f;
        }
    }
    return fontSize;
}

- (CGFloat)buttonGapX {
    static float gapx = 0;
    if (gapx == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            gapx = 21.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            gapx = 22.f;
        } else {
            gapx = 20.f;
        }
    }
    return gapx;
}

- (CGFloat)buttonRightPadding {
    static float gapx = 0;
    if (gapx == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            gapx = 11.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            gapx = 12.f;
        } else {
            gapx = 10.f;
        }
    }
    return gapx;
}

- (CGFloat)arrowOffsetY {
    static float gapY = 0;
    if (gapY == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            gapY = 8.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            gapY = 9.f;
        } else {
            gapY = 7.f;
        }
    }
    return gapY;
}

- (void)dismiss:(BOOL)animated {
    if (self.dislikeWords.count > 0 && animated) {
        [self viewWillDisappear];
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            self.maskView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.maskView removeFromSuperview];
            self.maskView = nil;
        }];
    } else {
        [super dismiss:animated];
    }
    __visibleDislikeView = nil;
}

+ (void)dismissIfVisible {
    if (__visibleDislikeView) {
        [__visibleDislikeView dismiss:NO];
        __visibleDislikeView = nil;
        return;
    }
}

+ (void)enable
{
    s_enable = YES;
}

+ (void)disable
{
    s_enable = NO;
}

+ (BOOL)isFeedDislikeRefactorEnabled
{
    if ([TTDeviceHelper isPadDevice]) {
        return NO;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_article_feed_dislike_refactor"];
}

#pragma mark - dislike btn

- (CGFloat)dislikeButtonWidth {
    static float w = 0;
    if (w == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            w = 84.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            w = 84.f;
        } else {
            w = 80.f;
        }
    }
    return w;
}

- (CGFloat)dislikeButtonHeight {
    static float h = 0;
    if (h == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            h = 30.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            h = 30.f;
        } else {
            h = 30.f;
        }
    }
    return h;
}

- (CGFloat)fontSizeForDislikeButton {
    static float fontSize = 0;
    if (fontSize == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            fontSize = 18.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            fontSize = 18.f;
        } else {
            fontSize = 15.f;
        }
    }
    return fontSize;
}

- (CGFloat)dislikeButtonGapX {
    static float w = 0;
    if (w == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            w = 17.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            w = 18.f;
        } else {
            w = 16.f;
        }
    }
    return w;
}

- (CGFloat)dislikeButtonImageTitleSpacing {
    static float w = 0;
    if (w == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            w = 5.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            w = 6.f;
        } else {
            w = 4.f;
        }
    }
    return w;
}

- (void)rootViewWillTransitionToSize:(NSNotification *)noti
{
//    CGSize size = [noti.object CGSizeValue];
    [[self class] dismissIfVisible];
}

@end
