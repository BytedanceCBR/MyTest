//
//  LazyGifWebView.h
//  Gallery
//
//  Created by Zhang Leonardo on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "GifWebView.h"
#import "GifDisplayView.h"
#import "GalleryLoadingView.h"

@protocol LazyGifWebViewDelegate <NSObject>

@optional

- (void)lazyGifWebViewClickOnce;

@end

@interface LazyGifWebView : UIView <UIWebViewDelegate, GifDisplayViewDelegate>
{
    NSURLConnection * imageConnection;
    NSMutableData * imageMutableData;
    NSMutableDictionary * urlDict;
    
    GalleryLoadingView * progressView;
    GifDisplayView * gifWebView;
    NSString * currentUrl;
    
    long int totalLength;
    long int currentLength;
}

@property (nonatomic, assign) id<LazyGifWebViewDelegate> lazyGifWebViewDelegate;
@property (nonatomic, retain) NSMutableData * imageMutableData;
@property (nonatomic, retain) NSURLConnection * imageConnection;

- (void)loadDataWithUrl:(NSString *)gifUrlString;
- (void)loadDataWithResourceName:(NSString *)gifFileName;
- (void)cancelDownload;
- (void)addGesture;
- (void)removeGesture;
- (BOOL)loaded;

@end