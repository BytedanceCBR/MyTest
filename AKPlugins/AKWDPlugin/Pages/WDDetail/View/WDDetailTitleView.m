//
//  WDDetailTitleView.m
//  Article
//
//  Created by 延晋 张 on 2016/12/6.
//
//

#import "WDDetailTitleView.h"
#import "WDFontDefines.h"
#import "WDDefines.h"

@interface WDDetailTitleView () <UIGestureRecognizerDelegate>

@property(nonatomic, strong) SSThemedLabel  *titleLabel;
@property(nonatomic, copy) WDTitleViewTapHandler titleViewTapHandler;
@property(nonatomic, assign) BOOL isAnimating;
@property(nonatomic, assign) BOOL isShow;
@property(nonatomic, strong) NSString *title;

@property(nonatomic, assign) CGFloat foneSize;

@end

@implementation WDDetailTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame fontSize:16];
}

- (instancetype)initWithFrame:(CGRect)frame fontSize:(CGFloat)foneSize {
    frame.size.height = 44;
    self = [super initWithFrame:frame];
    if (self) {
        SSThemedLabel * titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        titleLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
        titleLabel.font = [UIFont systemFontOfSize:foneSize];
        titleLabel.backgroundColor = [UIColor clearColor];
        //default header titlelable set to invisiable.
        titleLabel.alpha = 0.f;
        //titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTitleView:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        [self show:NO animated:NO];
        
        [self reloadThemeUI];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self refreshUI];
}

- (void)refreshUI {
    CGFloat left = 0, w;
    
    if (self.titleLabel.alpha > 0 && !self.isAnimating) {
        self.titleLabel.centerY = self.height/2;
    }
    
    w = self.titleLabel.width;
    
    if (w <= self.width) {
        left = (self.width - w)/2;
    } else {
        self.titleLabel.width = self.width;
    }
    
    self.titleLabel.left = left;
}

- (void)updateNavigationTitle:(NSString *)title
{
    if (isEmptyString(title)) {
        return;
    }
    
    self.title = title;
    //self.title = title;
    //self.titleLabel.attributedText = [self attributeTitleWith:title];
    self.titleLabel.text = self.title;
    [self.titleLabel sizeToFit];
    
    self.width = self.titleLabel.width;
    
    [self setNeedsLayout];
}

- (NSAttributedString *)attributeTitleWith:(NSString *)text
{
    NSString *title = text;
    NSMutableAttributedString *textString = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0f], NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1]}];
    NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:ask_arrow_right attributes:@{NSFontAttributeName : [UIFont fontWithName:wd_iconfont size:8.0f], NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1], NSBaselineOffsetAttributeName : @(3.0f)}];
    [textString appendAttributedString:titleString];

    return textString;
}

- (void)setTapHandler:(WDTitleViewTapHandler)tapHandler {
    self.titleViewTapHandler = tapHandler;
}

- (void)clickTitleView:(UIGestureRecognizer *)gesture {
    if (self.titleViewTapHandler) {
        self.titleViewTapHandler();
    }
}

- (void)setTitleAlpha:(CGFloat)alpha {
    self.titleLabel.alpha = alpha;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.titleLabel.alpha > 0;
}

- (void)show:(BOOL)bShow animated:(BOOL)animated
{
    if (bShow && animated && self.isAnimating) {
        return;
    }
    
    if (self.isShow && bShow) {
        return;
    }
    
    self.isShow = bShow;
    
    self.titleLabel.centerY = self.height/2;

    CGFloat destAlpha = bShow ? 1 : 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (animated) {
            _isAnimating = YES;
            
            UIViewAnimationOptions option = bShow ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseIn;
            
            [UIView animateWithDuration:0.15 delay:0 options:option animations:^{
                
                self.titleLabel.alpha = destAlpha;
            } completion:^(BOOL finished) {
                self.isAnimating = NO;
            }];
            
        } else {
            self.titleLabel.alpha = destAlpha;
        }
    });
}

- (void)themeChanged:(NSNotification *)notification {
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        self.titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    }
    else {
        self.titleLabel.textColor = [UIColor colorWithHexString:@"#707070"];
    }
}

@end
