//
//  TTADRefreshAnimation.m
//  Pods
//
//  Created by ranny_90 on 2017/3/24.
//
//

#import "TTADRefreshAnimationView.h"
#import "TTRefreshAnimationView.h"
#import "UIImage+MultiFormat.h"
#import "TTADRefreshManager.h"

@interface TTADRefreshAnimationView()

@property (nonatomic,strong)SSThemedImageView *adImageView;

@property (nonatomic,strong)NSData *adImageData;

@property (nonatomic,strong)TTRefreshAnimationView *adLoadingAnimateView;

@property (nonatomic,strong)SSThemedLabel *adLoadingLabel;

@property (nonatomic,strong)SSThemedView *bgView;

@property (nonatomic,strong)NSString *loadingText;

@property (nonatomic,assign)BOOL hasNotiShowADRefreshAnimate;

@property (nonatomic,assign)NSTimeInterval beginRefreshAnimateTime;

@property (nonatomic,assign)NSTimeInterval endRefreshAnimateTime;

@property (nonatomic,assign)CGFloat animatePercent;

@property (nonatomic,assign)BOOL isloading;

@property (nonatomic,assign)CGFloat pullRefreshLoadingHeight;

@end

@implementation TTADRefreshAnimationView


-(id)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame WithLoadingHeight:0 WithLoadingText:nil];
    
}

-(id)initWithFrame:(CGRect)frame WithLoadingHeight:(CGFloat)loadingHeight WithLoadingText:(NSString *)loadingText{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.pullRefreshLoadingHeight = loadingHeight;
        self.loadingText = loadingText;
        self.adImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
        [self addSubview:_adImageView];
        [self.adImageView.layer setAnchorPoint:CGPointMake(0.5, 1)];
        self.isloading = NO;

        self.bgView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        self.bgView.backgroundColor = [UIColor clearColor];
        [self addSubview:_bgView];
        
        self.adLoadingAnimateView = [[TTRefreshAnimationView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        [self.bgView addSubview:_adLoadingAnimateView];
        
        self.adLoadingLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        self.adLoadingLabel.font = [UIFont systemFontOfSize:9.0f];
        self.adLoadingLabel.textAlignment = NSTextAlignmentCenter;
        self.adLoadingLabel.textColors = @[@"5D5D5D", @"707070"];
        if (!isEmptyString(self.loadingText)) {
            _adLoadingLabel.text = self.loadingText;
            [self.bgView addSubview:_adLoadingLabel];
            [_adLoadingLabel sizeToFit];
        }

        [self resetAdAnimateFrame];
        
        self.bgView.layer.masksToBounds = YES ;
        
        self.beginRefreshAnimateTime = 0;
        self.endRefreshAnimateTime = 0;
        
    }
    return self;
    
}


-(void)resetSubviewsCenter{
    
    self.adImageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height);
    [self.adLoadingAnimateView stopLoading];
    if (!self.adImageView.superview) {
        [self addSubview:_adImageView];
    }
    
    if (isEmptyString(self.loadingText)) {
        if (self.adLoadingLabel.superview) {
            [self.adLoadingLabel removeFromSuperview];
        }
        
        self.adLoadingAnimateView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height + CGRectGetHeight(self.adLoadingAnimateView.frame)/2);
        
    }
    else {
        
        if (!self.adLoadingLabel.superview) {
            [self.bgView addSubview:self.adLoadingLabel];
        }
        
        self.adLoadingAnimateView.center = CGPointMake(self.bgView.frame.size.width/2, self.frame.size.height + CGRectGetHeight(self.adLoadingAnimateView.frame)/2);
        
        self.adLoadingLabel.center = CGPointMake(self.frame.size.width/2, CGRectGetMaxY(self.adLoadingAnimateView.frame) + 6 + CGRectGetHeight(self.adLoadingLabel.frame)/2);
        
    }
    
}

-(void)resetAdAnimateFrame{
    
    [self resetSubviewsCenter];
    self.adImageView.transform=CGAffineTransformMakeScale(0, 0);
    
}

-(BOOL)configureAdImageData:(NSData *)adImageData{
    if (!adImageData) {
        return NO;
    }
    
    _adImageData = adImageData;
    
    UIImage *adImage = [UIImage sd_imageWithData:_adImageData];
    if (adImage) {
        self.adImageView.image = adImage;
        return YES;
    }
    
    return NO;
}

- (void)startLoading{
    
    [self.adLoadingAnimateView startLoading];
    if (!self.hasNotiShowADRefreshAnimate) {
        self.hasNotiShowADRefreshAnimate = YES;
        [[TTADRefreshManager sharedManager] trackAdFreshShowWithChannelId:self.channelId WithADItemModel:self.adItemModel];

        self.endRefreshAnimateTime = [[NSDate date] timeIntervalSince1970];
        
        if (self.endRefreshAnimateTime > self.beginRefreshAnimateTime) {
            NSTimeInterval loadingInterval = self.endRefreshAnimateTime - self.beginRefreshAnimateTime;
            
            [[TTADRefreshManager sharedManager] trackAdFreshShowIntervalWithChannelId:self.channelId WithADItemModel:self.adItemModel WithTimeInteval:loadingInterval];
        }
        
        self.beginRefreshAnimateTime = 0;
        self.endRefreshAnimateTime = 0;
    }
    
    else {
    }
}

-(void)animationWithScrollViewBackToLoading{
    
    self.isloading = YES;
    
    if (!isEmptyString(self.loadingText)) {
        
        if (!self.adLoadingLabel.superview) {
            [self addSubview:_adLoadingLabel];
        }
        
        self.adLoadingLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height - self.adLoadingLabel.frame.size.height/2 - 8);
         self.adLoadingAnimateView.center = CGPointMake(self.frame.size.width/2, self.adLoadingLabel.frame.origin.y - 6 - self.adLoadingAnimateView.frame.size.height/2);
        

    }
    else {
        
        if (self.adLoadingLabel.superview) {
            [self.adLoadingLabel removeFromSuperview];
        }
        
        self.adLoadingAnimateView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height - self.pullRefreshLoadingHeight/2);

    }
    
    self.adImageView.center = CGPointMake(self.frame.size.width/2, -CGRectGetHeight(self.adImageView.frame)/2);
    
}

-(void)completionWithScrollViewBackToLoading{
    
    if (self.adImageView.superview) {
        [self.adImageView removeFromSuperview];
    }
    self.isloading = NO;
    
}

- (void)updateAnimationWithScrollOffset:(CGFloat)offset{
    
    offset += 10;
    CGFloat percent = MIN(1, -offset / (kTTPullRefreshHeight - 10));
    
    percent = MAX(0, percent);
    percent = MIN(percent, 1);
    
    
    
    if (self.isloading) {
        return;
    }
    
    if(_animatePercent == percent) return;
    
    _animatePercent = percent;
    
    self.adImageView.transform=CGAffineTransformMakeScale(_animatePercent, _animatePercent);
    
}

- (void)updateViewWithPullState:(PullDirectionState)state{
    switch (state) {
        case PULL_REFRESH_STATE_INIT:
            
            self.beginRefreshAnimateTime = 0;
            [self resetAdAnimateFrame];
            break;
        case PULL_REFRESH_STATE_PULL:
    
            if (self.beginRefreshAnimateTime == 0) {
                self.beginRefreshAnimateTime = [[NSDate date] timeIntervalSince1970];
            }
            
            [self resetSubviewsCenter];
            break;
        case PULL_REFRESH_STATE_PULL_OVER:
            [self resetSubviewsCenter];
            break;
            
        case PULL_REFRESH_STATE_LOADING:
        
            break;
        case PULL_REFRESH_STATE_NO_MORE:
            
            break;
        default:
            break;
    }
    
}

- (void)stopLoading{
    [self.adLoadingAnimateView stopLoading];
    
    self.hasNotiShowADRefreshAnimate = NO;
    
}

- (void)configurePullRefreshLoadingHeight:(CGFloat)pullRefreshLoadingHeight{
    self.pullRefreshLoadingHeight = pullRefreshLoadingHeight;
}


@end
