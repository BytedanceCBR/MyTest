//
//  WDNewsHelpView.m
//  Article
//
//  Created by Dianwei on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WDNewsHelpView.h"

#import "TTDeviceHelper.h"

@interface WDNewsHelpView()
@end

@implementation WDNewsHelpView
@synthesize bgView, imageView, textLabel1;

- (void)dealloc
{
    self.bgView = nil;
    self.imageView = nil;
    self.textLabel1 = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        float width = 125;
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 125)];
        bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        bgView.layer.cornerRadius = 10.f;
        bgView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:bgView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [bgView addSubview:imageView];
        
        self.textLabel1 = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel1.textColor = [UIColor whiteColor];
        textLabel1.font = [UIFont systemFontOfSize:14];
        textLabel1.backgroundColor = [UIColor clearColor];
        [textLabel1 sizeToFit];
        
        [bgView addSubview:textLabel1];
    }
    
    return self;
}

- (void)layoutSubviews
{
    if ([TTDeviceHelper isPadDevice]) {
        [self trySSLayoutSubviews];
    }
}

- (void)ssLayoutSubviews
{
    bgView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

- (void)setImage:(UIImage*)image
{
    [imageView setImage:image];
    [imageView sizeToFit];
    CGRect imageRect = imageView.frame;
    imageRect.origin.y = 15;
    imageView.frame = imageRect;
    imageView.center = CGPointMake(bgView.frame.size.width/2, imageView.center.y);
}

- (void)setText:(NSString*)text
{
    textLabel1.text = text;
    [textLabel1 sizeToFit];
    CGRect leftRect = textLabel1.frame;
    leftRect.origin.y = CGRectGetMaxY(imageView.frame);
    textLabel1.frame = leftRect;
    textLabel1.center = CGPointMake(bgView.frame.size.width/2, textLabel1.center.y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeFromSuperview];
}

@end
