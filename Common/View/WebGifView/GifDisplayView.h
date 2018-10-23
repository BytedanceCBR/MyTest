//
//  GifDisplayView.h
//  Gallery
//
//  Created by 剑锋 屠 on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>

@protocol GifDisplayViewDelegate <NSObject>

@optional

- (void)gifDisplayViewHadOnceTap;

@end

@interface GifDisplayView : UIImageView <UIGestureRecognizerDelegate> {
    UITapGestureRecognizer * singleTap;
    
	CGImageSourceRef gif;
	NSDictionary *gifProperties;
    NSMutableArray * gifImageArray;
    NSMutableArray * gifDictArray;
	size_t index;
	size_t count;
}

@property (nonatomic, assign) id<GifDisplayViewDelegate> gifDisplayViewDelegate;

- (void)removeGesture;
- (void)addGesture;
- (void)startPlay:(NSData *)data;
- (void)stopPlay;

@end
