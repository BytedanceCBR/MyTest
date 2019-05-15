//
//  ArticleMomentRefreshTitleView.m
//  Article
//
//  Created by Huaqing Luo on 17/12/14.
//
//

#import "ArticleMomentRefreshTitleView.h"
#import "UIImage+TTThemeExtension.h"

#define kRefreshImageViewLeftPadding 2

@interface ArticleMomentRefreshTitleView() <CAAnimationDelegate>
{
    BOOL _animating;
}

@property(nonatomic, strong)SSThemedLabel * titleLabel;
@property(nonatomic, strong)UIImageView * refreshImageView;
@property(nonatomic, strong)UITapGestureRecognizer * tapRecognizer;
//@property(nonatomic, strong)CABasicAnimation * rotateAnimation;
@property(nonatomic, strong)NSDate * startDate;


@end

@implementation ArticleMomentRefreshTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _animating = NO;
        
        self.titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColors = SSThemedColors(@"464646", @"707070");
        self.titleLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
        self.titleLabel.font = [UIFont systemFontOfSize:20.];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.titleLabel.text = @"动态";
        [self addSubview:self.titleLabel];
        
        self.refreshImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.refreshImageView];
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicked:)];
        [self addGestureRecognizer:self.tapRecognizer];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)dealloc
{
    [self removeGestureRecognizer:self.tapRecognizer];
}

- (void)themeChanged:(NSNotification *)notification
{
    [self.refreshImageView setImage:[UIImage themedImageNamed:@"refreshicon_dynamic_titlebar.png"]];
    
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.titleLabel sizeToFit];
    [self.refreshImageView sizeToFit];
    CGFloat maxTitleWidth = self.width - (self.refreshImageView.width) - kRefreshImageViewLeftPadding;
    if ((self.titleLabel.width) > maxTitleWidth) {
        self.titleLabel.width = maxTitleWidth;
    }
    
    CGFloat totalWidth = (self.titleLabel.width) + kRefreshImageViewLeftPadding + (self.refreshImageView.width);
//  self.size = CGSizeMake(MAX(totalWidth, self.width), self.height);
    
    self.titleLabel.left = (self.width - totalWidth) / 2;
    self.refreshImageView.left = (self.titleLabel.right) + 2;
    
    self.titleLabel.centerY = self.height / 2;
    self.refreshImageView.centerY = self.height / 2;
}

- (void)clicked:(UIGestureRecognizer*)recognizer
{
    if (self.delegate)
    {
        [self.delegate rotationViewDidClicked:self];
    }
}

- (void)startAnimation
{
    if(![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(startAnimation) withObject:nil waitUntilDone:NO];
        return;
    }
    
    if(!_animating)
    {
        _animating = YES;
        CABasicAnimation * rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotateAnimation.delegate = self;
        rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];
        rotateAnimation.duration = 1;
        rotateAnimation.repeatCount = HUGE_VALF;
        [self.refreshImageView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
    }
}

- (void)stopAnimation
{
    NSTimeInterval duration = fabs([self.startDate timeIntervalSinceNow]);
    duration = 1 - (duration - (int)duration);
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.refreshImageView.layer removeAllAnimations];
    });
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    _animating = NO;
}

- (void)animationDidStart:(CAAnimation *)anim
{
    self.startDate = [NSDate date];
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self setNeedsLayout];
}

- (void)sizeToFit
{
    [self.titleLabel sizeToFit];
    [self.refreshImageView sizeToFit];
    CGFloat totalWidth = (self.titleLabel.width) + kRefreshImageViewLeftPadding + (self.refreshImageView.width);
    self.width = totalWidth;
    [self setNeedsLayout];
}

@end
