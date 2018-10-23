//
//  ImageIndicator.m
//  ActivityIndicator
//
//  Created by Tu Jianfeng on 8/12/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ImageIndicator.h"


@implementation ImageIndicator

static UIImageView * mLoadingImageView = nil;
static UILabel * mLoadingLabel = nil;

+ (void)show:(UIImage *)loadingImage withText:(NSString *)message
{
    if (mLoadingImageView == nil) {
        mLoadingImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    if (mLoadingLabel == nil) {
        mLoadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        mLoadingLabel.textColor = [UIColor lightGrayColor];
        mLoadingLabel.backgroundColor = [UIColor clearColor];
    }
    
    [mLoadingImageView removeFromSuperview];
    [mLoadingLabel removeFromSuperview];
    
    CGRect frame = mLoadingImageView.frame;
    frame.size = loadingImage.size;
    mLoadingImageView.frame = frame;
    mLoadingImageView.image = loadingImage;
    
    mLoadingLabel.text = message;
    [mLoadingLabel sizeToFit];

    [[[UIApplication sharedApplication] keyWindow] addSubview:mLoadingImageView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:mLoadingLabel];
    
    CGPoint center = [[UIApplication sharedApplication] keyWindow].center;
    mLoadingImageView.center = center;
    center.x += 10.f;
    mLoadingLabel.center = center;
    
    frame = mLoadingLabel.frame;
    frame.origin.y = mLoadingImageView.frame.origin.y + mLoadingImageView.frame.size.height + 10.f;
    mLoadingLabel.frame = frame;
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	mLoadingImageView.alpha = 1;
    mLoadingLabel.alpha = 1;
	
	[UIView commitAnimations];
}

+ (void)hide
{
	//[UIView beginAnimations:nil context:NULL];
	//[UIView setAnimationDuration:0.3];
	
	mLoadingImageView.alpha = 0;
    mLoadingLabel.alpha = 0;
    
    [mLoadingImageView removeFromSuperview];
    [mLoadingImageView release];
    mLoadingImageView = nil;
    
    [mLoadingLabel removeFromSuperview];
    [mLoadingLabel release];
    mLoadingLabel = nil;
	
	//[UIView commitAnimations];    
}


@end
