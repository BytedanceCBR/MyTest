//
//  LazyGifWebView.m
//  Gallery
//
//  Created by Zhang Leonardo on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "LazyGifWebView.h"
#import "SSSimpleCache.h"

@implementation LazyGifWebView

@synthesize lazyGifWebViewDelegate;
@synthesize imageMutableData;
@synthesize imageConnection;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        urlDict = [[NSMutableDictionary alloc] initWithCapacity:5];
        currentUrl = [[NSString alloc] initWithString:@""];
        
        gifWebView = [[GifDisplayView alloc] initWithFrame:CGRectMake(0, 0, 2, 1)];
        gifWebView.gifDisplayViewDelegate = self;
        gifWebView.opaque = NO;
        gifWebView.backgroundColor = [UIColor clearColor];
        [self addSubview:gifWebView];
        
        progressView = [[GalleryLoadingView alloc] init];
        progressView.frame  = CGRectMake((frame.size.width - 100) / 2, (frame.size.height - 100) / 2, progressView.frame.size.width, progressView.frame.size.height);
        
        [progressView setProgressNumber:0];
        [self addSubview:progressView];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews
{
    progressView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 - 45.f);
}

- (void)setImageData:(NSData *)data
{
    UIImage * image = [[UIImage alloc] initWithData:data];

    [gifWebView setImage:image];   
    [image release];
    
    int webViewWidth = image.size.width;
    int WebViewHeight = image.size.height;
    int selfWidth = self.frame.size.width;
    int selfHeigth = self.frame.size.height;
    int realWebViewWidth = selfWidth >= webViewWidth ? webViewWidth : selfWidth;
    int realWebViewHeight = selfHeigth >= WebViewHeight ? WebViewHeight : selfHeigth;
    int realWebViewX = selfWidth >= webViewWidth ? (selfWidth - webViewWidth) / 2 : 0;
    int realWebViewY = selfHeigth >= WebViewHeight ? (selfHeigth - WebViewHeight) / 2 : 0;
    
    gifWebView.frame = CGRectMake(realWebViewX, realWebViewY, realWebViewWidth, realWebViewHeight);
    
    [gifWebView startPlay:data];
}

- (void)loadDataWithUrl:(NSString *)gifUrlString
{
    gifWebView.image = nil;
    [gifWebView stopPlay];
    
    [progressView setHidden:NO];
    [progressView setProgressNumber:0];

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSData * data = [[SSSimpleCache sharedCache] dataForUrl:gifUrlString];
    if (data == nil) {
        [currentUrl release];
        currentUrl = [gifUrlString copy];
        
        if (imageMutableData) {
            self.imageMutableData = nil;
        }
        
        if (imageConnection) {
            [imageConnection cancel];
            self.imageConnection = nil;
        }
        
        NSMutableData * mutableData = [[NSMutableData alloc] init];
        self.imageMutableData = mutableData;
        [mutableData release];
        
        NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:gifUrlString]] 
                                                                 delegate:self];
        [urlDict removeAllObjects];
        [urlDict setObject:gifUrlString forKey:conn.description];       
        self.imageConnection = conn;
        [conn release];
        
        currentLength = 0;
        [progressView setProgressNumber:0];
    }
    else {
        [self setImageData:data];
        [progressView setHidden:YES];
    }
    [pool release];
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)updateProgressViewNumber
{
    if (currentLength <= 0 || totalLength <= 0) return;
    
    float progress = (double)currentLength / (double)totalLength;
    [progressView setProgressNumber:progress * 100];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageMutableData appendData:data];
    
    currentLength += [data length];
    [self updateProgressViewNumber];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    currentLength = 0;
    self.imageMutableData = nil;
    self.imageConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse && [httpResponse respondsToSelector:@selector(allHeaderFields)]) {
        NSDictionary * httpResponseHeaderFields = [httpResponse allHeaderFields];
        totalLength = [[httpResponseHeaderFields objectForKey:@"Content-Length"] longLongValue];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString * connectionUrl = [urlDict objectForKey:connection.description];
    if (connectionUrl == nil || ![connectionUrl isEqualToString:currentUrl]) return;
    
    NSData * data = self.imageMutableData;
    if (data != nil && [connectionUrl isEqualToString:currentUrl]) {
        [[SSSimpleCache sharedCache] setData:data forKey:connectionUrl];
        
        [self setImageData:data];
        [progressView setHidden:YES];
    }
    
    self.imageMutableData = nil;
    self.imageConnection = nil;
}

- (BOOL)loaded
{
    return progressView.hidden;
}

- (void)cancelDownload
{
    [imageConnection cancel];
    [imageConnection release];
    imageConnection = nil;
    
    [imageMutableData release];
    imageMutableData = nil;
}

- (void)loadDataWithResourceName:(NSString *)gifFileName
{
    [gifWebView setImage:[UIImage resourceImageNamed:gifFileName]];
    [progressView setHidden:YES];
}

#pragma mark -
#pragma mark touch action

- (void)tapOnce
{
//    if ([lazyGifWebViewDelegate respondsToSelector:@selector(lazyGifWebViewClickOnce)]) {
//        [lazyGifWebViewDelegate performSelector:@selector(lazyGifWebViewClickOnce)];
//    }
}

#pragma mark -
#pragma mark  touch delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    if ([touch tapCount] == 1) {
        [self performSelector:@selector(tapOnce) withObject:nil afterDelay:0.2];
    }
	
    if ([touch tapCount] == 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(tapOnce) 
                                                   object:nil];
    }
}

- (void)addGesture
{
    [gifWebView addGesture];
}

- (void)removeGesture
{
    [gifWebView removeGesture];
}

#pragma mark -
#pragma mark gif touch delegate

- (void)gifWebViewHadOnceTap
{
    [self tapOnce];
}

- (void)dealloc 
{
    [imageConnection cancel];
    [imageConnection release];
    [imageMutableData release];
    
    gifWebView.gifDisplayViewDelegate = nil;
    [gifWebView stopPlay];
    [progressView release];
    [gifWebView release];
    [urlDict release];
    [currentUrl release];
    
    [super dealloc];
}

@end