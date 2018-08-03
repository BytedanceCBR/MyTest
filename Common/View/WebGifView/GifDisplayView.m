//
//  GifDisplayView.m
//  Gallery
//
//  Created by 剑锋 屠 on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "GifDisplayView.h"

@implementation GifDisplayView

@synthesize gifDisplayViewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // do nothing
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

- (void)play
{
    if (count == 0) {
        self.layer.contents = nil;
        return;
    }
    
	index = (index+1) % count;
    if(index < [gifImageArray count])
    {
        self.layer.contents = [gifImageArray objectAtIndex:index];
        
        [self performSelector:@selector(play) 
                   withObject:nil 
                   afterDelay:[[gifDictArray objectAtIndex:index] doubleValue]];
    }
}

- (void)startPlay:(NSData *)data
{
    [gifProperties release];
    gifProperties = [[NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount]
                                                 forKey:(NSString *)kCGImagePropertyGIFDictionary] retain];
    if (gif != nil) CFRelease(gif);
    gif = CGImageSourceCreateWithData((CFDataRef)data, (CFDictionaryRef)gifProperties);
    count =CGImageSourceGetCount(gif);
    
    [gifDictArray release];
    gifDictArray = [[NSMutableArray alloc] initWithCapacity:count];
    [gifImageArray release];
    gifImageArray = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        id item = (id)CGImageSourceCreateImageAtIndex(gif, i, (CFDictionaryRef)gifProperties);
        [gifImageArray addObject:item];
        [item release];
        item = (id)CGImageSourceCopyPropertiesAtIndex(gif, i, (CFDictionaryRef)gifProperties);
        NSNumber * timeNumber = [[(NSDictionary *)item objectForKey:@"{GIF}"] objectForKey:(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
        double time = [timeNumber doubleValue];
        if (timeNumber == nil || time == 0) time = 0.1;
        [gifDictArray addObject:[NSNumber numberWithDouble:time]];
        [item release];
    }
    


    [self play];
}

- (void)stopPlay
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(play) object:nil];
    self.layer.contents = nil;
}

- (void)dealloc
{
//    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self removeGestureRecognizer:singleTap];
    [singleTap release];
    
    [gifProperties release];
    [gifImageArray release];
    [gifDictArray release];
    if (gif != nil) CFRelease(gif);

    [super dealloc];
}

- (void)addGesture
{
    [singleTap release];
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.delegate = self;
    singleTap.numberOfTapsRequired = 1.f;
    singleTap.numberOfTouchesRequired = 1.f;
    singleTap.cancelsTouchesInView = NO;
    [self addGestureRecognizer:singleTap];
}

- (void)removeGesture
{
    [self removeGestureRecognizer:singleTap];
}

@end
