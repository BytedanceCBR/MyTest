//
//  Created by David Alpha Fox on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "BaseHeader.h"
#import "ActivityIndicator.h"

@implementation SSActivityIndicator

@synthesize centerMessageLabel = _centerMessageLabel;
@synthesize subMessageLabel = _subMessageLabel;
@synthesize activityIndicator = _activityIndicator;

static SSActivityIndicator * __currentIndicator = nil;

+ (void)showCenterAutoMutableLineMessage:(NSString *)message msgFontSize:(NSUInteger)fontSize afterDelay:(float)second
{
    [[SSActivityIndicator currentIndicator] hideImmediately];
    [[SSActivityIndicator currentIndicator] setCenterAutoMutableLineMessage:message msgFontSize:fontSize];
    [[SSActivityIndicator currentIndicator] show];
    [[SSActivityIndicator currentIndicator] hideAfterSecond:second];
}

+ (void)showCenterMsg:(NSString *)msg subMsg:(NSString *)subMsg afterDelay:(float)second
{
    [[SSActivityIndicator currentIndicator] hideImmediately];
    [[SSActivityIndicator currentIndicator] setCenterMessage:msg];
    [[SSActivityIndicator currentIndicator] setSubMessage:subMsg];
    [[SSActivityIndicator currentIndicator] show];
    [[SSActivityIndicator currentIndicator] hideAfterSecond:second];
}

+ (void)showMsg:(NSString *)msg afterDelay:(float)second
{
    [[SSActivityIndicator currentIndicator] hideImmediately];
    [[SSActivityIndicator currentIndicator] setCenterMessage:msg];
    [[SSActivityIndicator currentIndicator] show];
    [[SSActivityIndicator currentIndicator] hideAfterSecond:second];
}

+ (SSActivityIndicator *)currentIndicator
{
    if (__currentIndicator == nil) {
        @synchronized(self) {
            if (__currentIndicator == nil) {
                UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
		
                CGFloat width = 120;
                CGFloat height = 120;
                CGRect centeredFrame = CGRectMake(round(keyWindow.bounds.size.width/2 - width/2),
											  round(keyWindow.bounds.size.height/2 - height/2),
											  width,
											  height);
		
                __currentIndicator = [[SSActivityIndicator alloc] initWithFrame:centeredFrame];
		
                __currentIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
                __currentIndicator.opaque = NO;
                __currentIndicator.alpha = 0;
		
                __currentIndicator.layer.cornerRadius = 10;
		
                __currentIndicator.userInteractionEnabled = NO;
                __currentIndicator.autoresizesSubviews = YES;
                __currentIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
												UIViewAutoresizingFlexibleRightMargin |  
												UIViewAutoresizingFlexibleTopMargin | 
												UIViewAutoresizingFlexibleBottomMargin;
            }
        }
	}
	return __currentIndicator;
}

#pragma mark -

- (void)dealloc
{
    
    SS_RELEASE_SAFELY(_centerMessageLabel);
    SS_RELEASE_SAFELY(_subMessageLabel);
    SS_RELEASE_SAFELY(_activityIndicator);
    
	[super dealloc];
}

#pragma mark Creating Message

- (void)show
{	
    [__currentIndicator removeFromSuperview];
    
	if ([self superview] != [[UIApplication sharedApplication] keyWindow]) 
		[[[UIApplication sharedApplication] keyWindow] addSubview:self];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	self.alpha = 1;
	
	[UIView commitAnimations];
}

+ (void)hidden
{
    if (__currentIndicator.alpha > 0)
		return;
	
    @synchronized(self) {
        [__currentIndicator removeFromSuperview];
        SS_RELEASE_SAFELY(__currentIndicator);
    }
}

- (void)hideAfterDelay
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
	[self performSelector:@selector(hide) withObject:nil afterDelay:0.6];
}

- (void)hideAfterSecond:(NSTimeInterval)second
{
    if (second <= 0.6) {
        [self hideAfterDelay];
    }
    else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
        [self performSelector:@selector(hide) withObject:nil afterDelay:second];
    }
}

- (void)hide
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideImmediately)];
	
	self.alpha = 0;
	
	[UIView commitAnimations];
}

- (void)hideImmediately
{
    self.alpha = 0;
    
    [SSActivityIndicator hidden];
}

- (void)persist
{	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.1];
	
	self.alpha = 1;
	
	[UIView commitAnimations];
}

- (void)displayActivity:(NSString *)message
{
	[self setSubMessage:message];
	[self showActivityIndicator];	
	
	[_centerMessageLabel removeFromSuperview];
	_centerMessageLabel = nil;
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
}

- (void)displayCompleted:(NSString *)message
{	
	[self setCenterMessage:SSLocalizedString(@"Completed", @"完成")];
	[self setSubMessage:message];
	
	[_activityIndicator removeFromSuperview];
	_activityIndicator = nil;
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
		
	[self hideAfterDelay];
}

- (void)setCenterMessage:(NSString *)message
{	
	if (message == nil && _centerMessageLabel != nil)
		self.centerMessageLabel = nil;

	else if (message != nil) {
		if (_centerMessageLabel == nil) {
			self.centerMessageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12,round(self.bounds.size.height/2-50/2),self.bounds.size.width-24,50)] autorelease];
			_centerMessageLabel.backgroundColor = [UIColor clearColor];
			_centerMessageLabel.opaque = NO;
			_centerMessageLabel.textColor = [UIColor whiteColor];
			_centerMessageLabel.font = [UIFont boldSystemFontOfSize:20];
			_centerMessageLabel.textAlignment = UITextAlignmentCenter;
			_centerMessageLabel.shadowColor = [UIColor darkGrayColor];
			_centerMessageLabel.shadowOffset = CGSizeMake(1,1);
			_centerMessageLabel.adjustsFontSizeToFitWidth = YES;
			
			[self addSubview:_centerMessageLabel];
		}
		
		_centerMessageLabel.text = message;
	}
}

- (void)setCenterAutoMutableLineMessage:(NSString *)message msgFontSize:(NSUInteger)fontSize
{
    if (message == nil && _centerMessageLabel != nil)
		self.centerMessageLabel = nil;
    
	else if (message != nil) {
		if (_centerMessageLabel == nil) {
            
            float height = heightOfContent(message, self.bounds.size.width - 24, fontSize);
            self.centerMessageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12,(self.bounds.size.height - height) / 2,self.bounds.size.width-24,height)] autorelease];
            _centerMessageLabel.numberOfLines = 0;
            _centerMessageLabel.font = [UIFont boldSystemFontOfSize:fontSize];
            
//			self.centerMessageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12,round(self.bounds.size.height/2-50/2),self.bounds.size.width-24,50)] autorelease];
			_centerMessageLabel.backgroundColor = [UIColor clearColor];
			_centerMessageLabel.opaque = NO;
			_centerMessageLabel.textColor = [UIColor whiteColor];
//			_centerMessageLabel.font = [UIFont boldSystemFontOfSize:20];
			_centerMessageLabel.textAlignment = UITextAlignmentCenter;
			_centerMessageLabel.shadowColor = [UIColor darkGrayColor];
			_centerMessageLabel.shadowOffset = CGSizeMake(1,1);
			_centerMessageLabel.adjustsFontSizeToFitWidth = YES;
			
			[self addSubview:_centerMessageLabel];
		}
		
		_centerMessageLabel.text = message;
	}
}


- (void)setSubMessage:(NSString *)message
{	
	if (message == nil && _subMessageLabel != nil)
		self.subMessageLabel = nil;
	
	else if (message != nil) {
		if (_subMessageLabel == nil) {
			self.subMessageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12,self.bounds.size.height-45,self.bounds.size.width-24,30)] autorelease];
			_subMessageLabel.backgroundColor = [UIColor clearColor];
			_subMessageLabel.opaque = NO;
			_subMessageLabel.textColor = [UIColor whiteColor];
			_subMessageLabel.font = [UIFont boldSystemFontOfSize:13];
			_subMessageLabel.textAlignment = UITextAlignmentCenter;
			_subMessageLabel.shadowColor = [UIColor darkGrayColor];
			_subMessageLabel.shadowOffset = CGSizeMake(1,1);
			_subMessageLabel.adjustsFontSizeToFitWidth = YES;
			
			[self addSubview:_subMessageLabel];
		}
		
		_subMessageLabel.text = message;
	}
}

- (void)showActivityIndicator
{
	if (_activityIndicator == nil) {
		UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator = activityIndicator;
        [activityIndicator release];

		_activityIndicator.frame = CGRectMake(round(self.bounds.size.width/2 -_activityIndicator.frame.size.width/2),
								round(self.bounds.size.height/2 - _activityIndicator.frame.size.height/2),
								_activityIndicator.frame.size.width,
								_activityIndicator.frame.size.height);
	}
	
	[self addSubview:_activityIndicator];
	[_activityIndicator startAnimating];
}

#pragma mark -
#pragma mark Rotation

- (void)setProperRotation
{
	[self setProperRotation:YES];
}

- (void)setProperRotation:(BOOL)animated
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
	}
	
	if (orientation == UIDeviceOrientationPortraitUpsideDown)
		self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, SSdegreesToRadians(180));	
	
	else if (orientation == UIDeviceOrientationLandscapeLeft)
		self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, SSdegreesToRadians(90));	
	
	else if (orientation == UIDeviceOrientationLandscapeRight)
		self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, SSdegreesToRadians(-90));
	
	if (animated)
		[UIView commitAnimations];
}

@end
