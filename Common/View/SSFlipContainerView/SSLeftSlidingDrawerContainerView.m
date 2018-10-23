//
//  SSLeftSlidingDrawerContainerView.m
//  Gallery
//
//  Created by Zhang Leonardo on 12-10-12.
//
//

#import "SSLeftSlidingDrawerContainerView.h"
#import "UIApplication+Addition.h"

@interface SSLeftSlidingDrawerContainerView()<UIGestureRecognizerDelegate>
@property(nonatomic, retain)UITapGestureRecognizer * tapRecognizer;
@property(nonatomic, retain)UISwipeGestureRecognizer * leftSwipGestureRecognizer;
@property(nonatomic, retain)UISwipeGestureRecognizer * rightSwipGestureRecognizer;
@property(nonatomic, retain)UISwipeGestureRecognizer * upSwipGestureRecognizer;
@property(nonatomic, retain)UISwipeGestureRecognizer * downSwipGestureRecognizer;

@end

@implementation SSLeftSlidingDrawerContainerView

@synthesize drawerView = _drawerView;
@synthesize tapRecognizer = _tapRecognizer;
@synthesize leftSwipGestureRecognizer = _leftSwipGestureRecognizer;
@synthesize rightSwipGestureRecognizer = _rightSwipGestureRecognizer;
@synthesize upSwipGestureRecognizer = _upSwipGestureRecognizer;
@synthesize downSwipGestureRecognizer = _downSwipGestureRecognizer;

- (void)dealloc
{
    [self removeGestureRecognizer:_tapRecognizer];
    self.tapRecognizer = nil;
    
    [self removeGestureRecognizer:_leftSwipGestureRecognizer];
    self.leftSwipGestureRecognizer = nil;
    
    [self removeGestureRecognizer:_rightSwipGestureRecognizer];
    self.rightSwipGestureRecognizer = nil;

    [self removeGestureRecognizer:_upSwipGestureRecognizer];
    self.upSwipGestureRecognizer = nil;

    [self removeGestureRecognizer:_downSwipGestureRecognizer];
    self.downSwipGestureRecognizer = nil;

    
    self.drawerView = nil;
    [super dealloc];
}

- (id)initWithOrientation:(UIInterfaceOrientation)currentOrientation
{
    CGSize size = screenSize();
    float largeSide = MAX(size.width, size.height);
    float shortSide = MIN(size.width, size.height);
    
    CGSize statusBarFrame = [[UIApplication sharedApplication] statusBarFrame].size;
    float y = MIN(statusBarFrame.height, statusBarFrame.width);
    
    CGRect currentRect;
    if (UIInterfaceOrientationIsPortrait(currentOrientation)) {
        currentRect = CGRectMake(0, y, shortSide, largeSide - y);
    }
    else {
        currentRect = CGRectMake(0, y, largeSide, shortSide - y);
    }
    
    self = [super initWithFrame:currentRect];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addGesture];
        
        [self buildViews];
    }
    
    return self;
}

#warning fix here
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//    [self refreshUI];
//}
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//}

#pragma mark -- public

- (void)show
{
    if (![self superview]) {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        CGRect tmpRect = self.frame;
        CGRect rect = self.frame;
        rect.origin.x = - keyWindow.frame.size.width;
        self.frame = rect;
        [keyWindow.rootViewController.view addSubview:self];
        [keyWindow.rootViewController.view bringSubviewToFront:self];
        [UIView animateWithDuration:0.4
                         animations:^{
                             self.frame = tmpRect;
                             self.alpha = 1.f;
                         }];
    }
}

- (void)close
{
    CGRect tempOriRect = self.frame;
    CGRect rect = self.frame;
    rect.origin.x = - rect.size.width;
    
    [UIView animateWithDuration:0.4f animations:^{
        self.frame = rect;
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.frame = tempOriRect;
    }];
}

#pragma mark -- private

- (void)addGesture
{
    self.tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizer:)] autorelease];
    _tapRecognizer.delegate = self;
    [self addGestureRecognizer:_tapRecognizer];
    
    self.leftSwipGestureRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipRecognizer:)] autorelease];
    _leftSwipGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    _leftSwipGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_leftSwipGestureRecognizer];

    self.rightSwipGestureRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipRecognizer:)] autorelease];
    _rightSwipGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    _rightSwipGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_rightSwipGestureRecognizer];
    
    self.downSwipGestureRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipRecognizer:)] autorelease];
    _downSwipGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    _downSwipGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_downSwipGestureRecognizer];
    
    self.upSwipGestureRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipRecognizer:)] autorelease];
    _upSwipGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    _upSwipGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_upSwipGestureRecognizer];
}

- (void)swipRecognizer:(UISwipeGestureRecognizer *)recognizer
{    
    if (recognizer.direction != UISwipeGestureRecognizerDirectionRight) {
        [self close];
    }
}

- (void)tapRecognizer:(UITapGestureRecognizer *)recognizer
{
    [self close];
}

- (void)refreshUI
{
    CGSize size = screenSize();
    float largeSide = MAX(size.width, size.height);
    float shortSide = MIN(size.width, size.height);
    
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    float y = MIN(statusBarSize.width, statusBarSize.height);
    
    CGRect currentRect;
    if ([UIApplication isPortraitOrientation]) {
        currentRect = CGRectMake(0, y, shortSide, largeSide - y);
    }
    else {
        currentRect = CGRectMake(0, y, largeSide, shortSide - y);
    }
    self.frame = currentRect;
}

#pragma mark -- protect

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[SSLeftSlidingDrawerContainerView class]]) {
        return YES;
    }
    return NO;
}

- (void)buildViews
{
    //subview implement
}


@end
