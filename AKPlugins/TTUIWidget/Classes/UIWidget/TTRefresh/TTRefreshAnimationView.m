//
//  ZDLoadingView.m
//  PullToRefreshControlDemo
//
//  Created by Nick Yu on 126/13.
//  Copyright (c) 2013 Zhang Kai Yu. All rights reserved.
//

#import "TTRefreshAnimationView.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeManager.h"
#import "TTThemeConst.h"


#define kLongTextWidth 17
#define kShortTextWidth 7
#define kImageWidth 7
#define kImageHeight 6
#define kLeadingMargin 3.5f
#define kShortLeadingMargin 13.5f
#define kTopMargin 4.5f
#define kShortTopMargin 13.5f
#define kLineSpace 3.0f
#define kContentHeight 13.5f


@interface TTRefreshAnimationView()
{
    UIImageView         *imageView;
}

@property (nonatomic,assign) BOOL isLoading;

@end

@implementation TTRefreshAnimationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.image = [UIImage imageNamed:@"TTUIWidgetResources.bundle/ak_refresh"];
        imageView.alpha = 0;
        imageView.transform = CGAffineTransformMakeScale(0, 0);
        [self addSubview:imageView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.image = [UIImage imageNamed:@"ak_refresh"];
        imageView.alpha = 0;
        imageView.transform = CGAffineTransformMakeScale(0, 0);
        [self addSubview:imageView];
    }
    return self;
}



-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    
}

-(IBAction)loadingAnimation
{
    imageView.alpha = 1;
    imageView.transform = CGAffineTransformIdentity;
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @(0);
    rotationAnimation.toValue = @(M_PI * 2);
    rotationAnimation.repeatCount = MAXFLOAT;
    rotationAnimation.duration = .67;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeBoth;
    [imageView.layer addAnimation:rotationAnimation forKey:@"rotation"];
}

-(void)setPercent:(CGFloat)precent
{
    
    precent = MAX(0, precent);
    precent = MIN(precent, 1);
    if(_percent == precent) return;
    
    _percent = precent;
    
    if (!self.isLoading) {
        imageView.transform = CGAffineTransformMakeScale(precent, precent);
        imageView.alpha = precent;
    }
}
-(void)startLoading
{
    self.isLoading = YES;
    
    [self loadingAnimation];
}

-(void)stopLoading
{
    self.isLoading = NO;
    imageView.transform = CGAffineTransformIdentity;
    [imageView.layer removeAllAnimations];
}

@end


@interface TTRefreshAnimationContainerView()
{
    NSString *_initText;
    NSString *_pullText;
    NSString *_loadingText;
    NSString *_noMoreText;
    CGFloat _pullRefreshLoadingHeight;
    
}

@property(nonatomic,strong)TTRefreshAnimationView *refreshAnimationView;

@property(nonatomic,strong)SSThemedLabel *titleLabel;



@end

@implementation TTRefreshAnimationContainerView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame WithLoadingHeight:0 WithinitText:nil WithpullText:nil WithloadingText:nil WithnoMoreText:nil];
}



-(id)initWithFrame:(CGRect)frame WithLoadingHeight:(CGFloat)loadingHeight WithinitText:(NSString *)initText WithpullText:(NSString *)pullText
   WithloadingText:(NSString *)loadingText WithnoMoreText:(NSString *)noMoreText{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _pullRefreshLoadingHeight = loadingHeight;
        _initText = initText;
        _pullText = pullText;
        _loadingText = loadingText;
        _noMoreText = noMoreText;
        
        self.refreshAnimationView = [[TTRefreshAnimationView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        [self addSubview:self.refreshAnimationView];
        
        self.titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        self.titleLabel.font = [UIFont systemFontOfSize:9.0f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColors = @[@"5D5D5D", @"707070"];
        [self addSubview:self.titleLabel];
        
    }
    
    return self;
    
}


-(void)startLoading{
    
    [self.refreshAnimationView startLoading];
}

-(void)stopLoading{
    
    [self.refreshAnimationView stopLoading];
    
}

- (void)updateAnimationWithScrollOffset:(CGFloat)offset{
    
    offset += 30;
    CGFloat fractionDragged = MIN(1, -offset / (kTTPullRefreshHeight - 30));
    self.refreshAnimationView.percent = fractionDragged;
}

-(void)updateViewWithPullState:(PullDirectionState)state{
    
    NSString *tmp;
    
    switch (state) {
        case PULL_REFRESH_STATE_INIT:
            
            if (_loadingText.length == 0) {
                tmp = @"";
            } else {
                tmp = _initText;
            }
            break;
        case PULL_REFRESH_STATE_PULL:
            
            tmp = _initText;
            break;
        case PULL_REFRESH_STATE_PULL_OVER:
            
            tmp = _pullText;
            break;
            
        case PULL_REFRESH_STATE_LOADING:
            
            tmp = _loadingText;
            break;
        case PULL_REFRESH_STATE_NO_MORE:
            
            self.refreshAnimationView.hidden = YES;
            tmp = _noMoreText;
            break;
        default:
            break;
    }
    
    self.titleLabel.text = tmp;
    [self.titleLabel sizeToFit];
    
    [self adjustSubviewFrame];
}

- (void)adjustSubviewFrame
{
    if (self.titleLabel.text == nil || [self.titleLabel.text isEqualToString:@""]) {
        self.titleLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2+10);
        self.refreshAnimationView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height - _pullRefreshLoadingHeight/2);
    }
    else {
        self.titleLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height - self.titleLabel.frame.size.height/2 - 8);
        self.refreshAnimationView.center = CGPointMake(self.frame.size.width/2, self.titleLabel.frame.origin.y - 6 - self.refreshAnimationView.frame.size.height/2);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self adjustSubviewFrame];
}

- (void)configurePullRefreshLoadingHeight:(CGFloat)pullRefreshLoadingHeight{
    _pullRefreshLoadingHeight = pullRefreshLoadingHeight;
}




@end
