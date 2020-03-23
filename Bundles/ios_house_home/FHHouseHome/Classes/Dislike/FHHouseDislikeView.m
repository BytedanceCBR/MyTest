//
//  FHHouseDislikeView.m
//  FHHouseHome
//
//  Created by 谢思铭 on 2019/7/23.
//

#import "FHHouseDislikeView.h"
#import "FHHouseDislikeKeywordsView.h"
#import "SSThemed.h"

#import "TTThemeConst.h"
#import "UIColor+TTThemeExtension.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceUIUtils.h"
//#import "TTTracker.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHUserTracker.h"
#import "JSONAdditions.h"

#define kMaskViewTag 20141209

#pragma mark - global variable

// 在内存中保存上次选中的dislikeWords
static NSString *__lastGroupID;
static NSMutableArray *__lastDislikedWords;
static BOOL s_enable = YES;
static FHHouseDislikeView *__visibleDislikeView;


@implementation FHHouseDislikeViewModel
@end

#pragma mark - TTFeedDislikeView
//---------------------------------------------------------------
@interface FHHouseDislikeView () <FHHouseDislikeKeywordsViewDelegate>

@property(nonatomic, strong)UIView *arrowBgView;
@property(nonatomic, strong)UIView *contentBgView;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic,strong)SSThemedButton *okBtn;
@property(nonatomic, strong)UIImageView *arrowImageView;
@property(nonatomic, strong)FHHouseDislikeKeywordsView *keywordsView;
@property(nonatomic, strong)SSThemedButton *dislikeBtn;
@property(nonatomic, copy)NSString *adLogExtra;
@property(nonatomic, strong)FHHouseDislikeBlock didDislikeBlock;
@property(nonatomic, strong)FHHouseDislikeViewModel *model;

@end


@implementation FHHouseDislikeView

- (void)dealloc {
    __visibleDislikeView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIWindow *window = SSGetMainWindow();

        self.layer.cornerRadius = 4.f;
        self.width = MIN(window.frame.size.width - 30, 400);
        
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
        
        _okBtn.backgroundColorThemeKey = @"orange4";
        _okBtn.highlightedBackgroundColorThemeKey = @"orange4";
        [_okBtn addTarget:self action:@selector(okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_contentBgView addSubview:_okBtn];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        self.titleLabel.text = NSLocalizedString(@"可选理由，精准屏蔽", nil);
        [_titleLabel sizeToFit];
        [_contentBgView addSubview:_titleLabel];
        
        self.keywordsView = [[FHHouseDislikeKeywordsView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        self.keywordsView.backgroundColor = [UIColor clearColor];
        self.keywordsView.delegate = self;
        [_contentBgView addSubview:_keywordsView];
        
        self.dislikeBtn = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, [self dislikeButtonWidth], [self dislikeButtonHeight])];
        _dislikeBtn.highlightedTitleColorThemeKey = kColorText8;
        _dislikeBtn.backgroundColorThemeKey = @"orange4";
        _dislikeBtn.highlightedBackgroundColorThemeKey = @"orange4";
        
        [_dislikeBtn addTarget:self action:@selector(okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _dislikeBtn.layer.cornerRadius = 4;
        [self addSubview:_dislikeBtn];
        
        [self reloadThemeUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rootViewWillTransitionToSize:) name:@"kRootViewWillTransitionToSize" object:nil];
        
        self.adLogExtra = @"";
        
        _contentBgView.layer.cornerRadius = 4.f;
        _contentBgView.clipsToBounds = YES;
        [_okBtn.titleLabel setFont:[UIFont themeFontMedium:13]];
        [_okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_okBtn setTitle:NSLocalizedString(@"不感兴趣", nil) forState:UIControlStateNormal];
        [_titleLabel setFont:[UIFont themeFontMedium:18]];
        [_dislikeBtn setTitle:NSLocalizedString(@"不感兴趣", nil) forState:UIControlStateNormal];
        [_dislikeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_dislikeBtn.titleLabel setFont:[UIFont themeFontMedium:13]];
        _okBtn.layer.cornerRadius = 4;
        [_okBtn setBackgroundColor:[UIColor themeOrange4]];
        
    }
    return self;
}

- (void)refreshWithModel:(nullable FHHouseDislikeViewModel *)model {
    self.model = model;
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
                    FHHouseDislikeWord *word = [[FHHouseDislikeWord alloc] initWithDict:dict];
                    [self.dislikeWords addObject:word];
                }
            }
        }
        
        __lastGroupID = groupID;
        
        _keywordsView.width = self.width;
        [_keywordsView refreshWithData:self.dislikeWords];
        
    }

    NSMutableDictionary *tracerDict = [model.extrasDict mutableCopy];
    [tracerDict removeObjectsForKeys:@[@"element_type"]];
    TRACK_EVENT(@"house_dislike_popup_show", tracerDict);
}

- (void)refreshArrowUI {
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

- (void)refreshContentUI {
    [self refreshOKBtn];
    [self refreshTitleLabel];
    
    _okBtn.origin = CGPointMake(_contentBgView.width - [self leftPadding] - _okBtn.width, 20.0f);
    _titleLabel.left = [self leftPadding];
    _titleLabel.centerY = _okBtn.centerY;
    _keywordsView.origin = CGPointMake(0, _okBtn.bottom + 20.f);
    _contentBgView.height = _keywordsView.bottom + 22.f;
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
        __lastDislikedWords = nil;
        __lastGroupID = nil;
        
        if(self.selectedWords.count > 0){
            [self trackHouseDislikePopupClick:YES];
        }else{
            [self trackHouseDislikePopupClick:NO];
        }
        
    } else {
        [self showDislikeButton:NO atPoint:self.origin];
    }
}

- (void)trackHouseDislikePopupClick:(BOOL)isConfirm {
    NSMutableDictionary *tracerDict = [self.model.extrasDict mutableCopy];
    if(isConfirm){
        tracerDict[@"click_position"] = @"confirm";
        
        NSMutableDictionary *dislikeInfo = [NSMutableDictionary dictionary];
        for (FHHouseDislikeWord *word in self.dislikeWords) {
            if(word.isSelected){
                [dislikeInfo setObject:word.name forKey:word.ID];
            }
        }
        
        NSString *result = [dislikeInfo tt_JSONRepresentation];
        tracerDict[@"result"] = result;
    }else{
        tracerDict[@"click_position"] = @"no_evaluate";
    }
    [tracerDict removeObjectsForKeys:@[@"element_type"]];
    TRACK_EVENT(@"house_dislike_popup_click", tracerDict);
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
    for (FHHouseDislikeWord *word in self.dislikeWords) {
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
        [self.okBtn setTitle:@"不感兴趣" forState:UIControlStateNormal];
    }
}

- (void)refreshTitleLabel
{
    if (self.selectedWords.count > 0) {
        NSString * title = [NSString stringWithFormat:@"已选%lu个理由", (unsigned long)self.selectedWords.count];
        NSRange range = NSMakeRange(2, 1);
        NSMutableAttributedString * atrrTitle = [[NSMutableAttributedString alloc] initWithString:title];
        [atrrTitle setAttributes:@{ NSForegroundColorAttributeName : [UIColor themeRed1] } range:range];
        [self.titleLabel setAttributedText:atrrTitle];
    } else {
        [self.titleLabel setText:@"可选理由，精准屏蔽"];
    }
    
    [self.titleLabel sizeToFit];
    self.titleLabel.left = [self leftPadding];
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    _contentBgView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    [self.titleLabel setTextColor:[UIColor themeGray1]];
}

- (void)showAtPoint:(CGPoint)p
           fromView:(UIView *)fromView
    didDislikeBlock:(FHHouseDislikeBlock)didDislikeBlock
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
    
    if (p.x + self.width/2 > self.maskView.width) {
        self.right = self.maskView.width - 15;
    } else {
        self.right = p.x + self.width/2;
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
            padding = 15.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            padding = 15.f;
        } else {
            padding = 12.f;
        }
    }
    return padding;
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
