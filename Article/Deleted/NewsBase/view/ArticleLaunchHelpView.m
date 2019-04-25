//
//  ArticleLaunchHelpView.m
//  Article
//
//  Created by Zhang Leonardo on 13-11-27.
//
//

#import "ArticleLaunchHelpView.h"

@interface ArticleLaunchHelpView()<UIScrollViewDelegate>
@property(nonatomic, retain)UIScrollView * scrollView;
@property(nonatomic, retain)UIImageView * imgView;

@end

@implementation ArticleLaunchHelpView

- (void)dealloc
{
    [self cancelAnimation];
    self.closeButton = nil;
    self.imgView = nil;
    self.scrollView = nil;
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [ArticleLaunchHelpView setHasShowed];
        
        self.scrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
        _scrollView.delegate = self;
        _scrollView.bounces = NO;
        [self addSubview:_scrollView];
        
        self.imgView = [[[UIImageView alloc] initWithImage:[UIImage resourceImageNamed:@"help_introduce.jpg"]] autorelease];
        [_scrollView addSubview:_imgView];
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _imgView.frame.size.height);
        
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(0, _imgView.frame.size.height - 200, self.frame.size.width, 200);
        _closeButton.backgroundColor = [UIColor clearColor];
        [_scrollView addSubview:_closeButton];
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self performSelector:@selector(startAnimation) withObject:nil afterDelay:2.f];
    }
    return self;
}

+ (BOOL)showed
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ArticleLaunchHelpViewHasShowedKey311"];
}

+ (void)setHasShowed
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ArticleLaunchHelpViewHasShowedKey311"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)cancelAnimation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)startAnimation
{
    [UIView animateWithDuration:1 animations:^{
        _scrollView.contentOffset = CGPointMake(0, (_scrollView.contentSize.height - _scrollView.frame.size.height));
    }];
    

}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

@end
