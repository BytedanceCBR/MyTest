//
//  ArticleXPEssayGifWebView.m
//  Article
//
//  Created by 邓刚 on 14-4-4.
//
//

#import "ArticleXPEssayGifWebView.h"
#import <ImageIO/ImageIO.h>
//#import "SDImageCache.h"

#import "VVeboImageView.h"
#import "VVeboImage.h"
#import "UIColor+TTThemeExtension.h"
#import "UIImage+TTThemeExtension.h"
#import <TTImage/TTImageDownloader.h>

#define kProgressBgViewHeight 3

@interface ArticleXPEssayGifWebView ()

@property (nonatomic, retain) UIImageView *progressBgView;
@property (nonatomic, retain) UIImageView *progressIndicatorView;
//@property (nonatomic, retain) UIImageView *gifIndicatorView;
@property (nonatomic, retain) VVeboImage* gifVVeboImage;
@property (nonatomic, retain) VVeboImageView *gifVVeboImageView;
@property (nonatomic, assign) float currentPercent;


@property (nonatomic ,retain) EssayData *essayData;
//@property (nonatomic, retain) ArticleXPEssayFetchGifManager* essayFetchGifManager;
@property(nonatomic, strong)TTImageDownloader *imageDownloader;

@end


@implementation ArticleXPEssayGifWebView

- (void)dealloc{
    self.progressBgView = nil;
    self.progressIndicatorView = nil;
    self.gifPlayButton = nil;
    self.gifVVeboImageView = nil;
    self.essayData = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _isGifPlaying = NO;
        
        _gifVVeboImageView = [[VVeboImageView alloc] initWithImage:nil];
        _gifVVeboImageView.repeats = YES;
        [self addSubview:_gifVVeboImageView];
        _gifVVeboImageView.hidden = YES;
        
        _progressBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 4, kProgressBgViewHeight)];
        _progressBgView.backgroundColor = [UIColor colorWithHexString:@"e7eff4"];
        [self addSubview:_progressBgView];
        _progressBgView.hidden = YES;
        
        _progressIndicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 2, kProgressBgViewHeight)];
        _progressIndicatorView.backgroundColor = [UIColor colorWithHexString:@"2a90d7"];
        
        
        [self addSubview:_progressIndicatorView];
        _progressIndicatorView.hidden = YES;
        
        self.gifPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_gifPlayButton setImage:[UIImage themedImageNamed:@"gificon_textpage.png"] forState:UIControlStateNormal];
        
//        _gifPlayButton.backgroundColor = [UIColor redColor];
        [_gifPlayButton sizeToFit];
        [self addSubview:_gifPlayButton];
//        _gifIndicatorView.backgroundColor = [UIColor clearColor];
//        [self addSubview:_gifIndicatorView];
//        _gifIndicatorView.hidden = NO;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    
    if (CGRectEqualToRect(frame, self.frame)) {
        return;
    }
    
    [super setFrame:frame];
    
    _progressBgView.frame = CGRectMake(0, 0, self.bounds.size.width, kProgressBgViewHeight);
    _progressIndicatorView.frame = CGRectMake(0, 0, 10, kProgressBgViewHeight);
    
    CGRect gifFrame = _gifPlayButton.frame;
    _gifPlayButton.frame = CGRectMake((self.frame.size.width - gifFrame.size.width) / 2, (self.frame.size.height - gifFrame.size.height) / 2, gifFrame.size.width, gifFrame.size.height);
    
}

- (void)themeChanged:(NSNotification*)notification;
{
    _progressBgView.backgroundColor = [UIColor colorWithHexString:@"e7eff4"];
    _progressIndicatorView.backgroundColor = [UIColor colorWithHexString:@"2a90d7"];
    
    [_gifPlayButton setImage:[UIImage themedImageNamed:@"gificon_textpage.png"] forState:UIControlStateNormal];
}

- (void)setImageData:(NSData *)data
{
    _gifVVeboImage = [VVeboImage gifWithData:data];
    _gifVVeboImageView.image = _gifVVeboImage;
    
    self.gifVVeboImageView.frame = self.bounds;
}

- (void)clickGifImageWithEssayData:(EssayData *)essayData{
    
    _isGifPlaying = !_isGifPlaying;
    
    if (_isGifPlaying) {
        
        [self loadDataWithEssayData:essayData];
        
    }else{
        
        [self stopPlayGifImage];
    }
}

- (void)stopPlayGifImage{
    
    _isGifPlaying = NO;
//    _gifIndicatorView.hidden = NO;
    _gifPlayButton.hidden = NO;
    self.gifVVeboImageView.image = nil;
    [self cancelDownload];
    [self hideProgressView];
    
}

- (void)loadDataWithEssayData:(EssayData* )essayData{
    if (!essayData) {
        return;
    }
    
    [self cancelDownload];
    
    self.essayData = essayData;
    
    self.gifVVeboImageView.image = nil;
    
    [self initProgressView];
    
    NSString *gifUrlString = [[[self.essayData.largeImageDict objectForKey:@"url_list"] objectAtIndex:0] objectForKey:@"url"];
    
    if (!self.imageDownloader) {
        self.imageDownloader = [[TTImageDownloader alloc] init];
    }
    
    [self.imageDownloader downloadImageWithURL:gifUrlString options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (expectedSize > 0) {
            float progress = receivedSize / (float)expectedSize;
            if (progress < 1) {
                [self showProgressView];
            }
            
            self.currentPercent = progress;
            [self updateProgressViewNumber];
        }
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
        [self hideProgressView];
        if (data != nil) {
            [self setImageData:data];
        }
    }];
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)updateProgressViewNumber
{
    [self updateProgressView:self.currentPercent];
}

- (BOOL)loaded
{
    return self.progressIndicatorView.hidden;
}

- (void)cancelDownload
{
    [self.imageDownloader cancelAll];
}

#pragma mark -
#pragma mark - private

- (void)initProgressView{
    
    self.gifPlayButton.hidden = YES;
    self.gifVVeboImageView.hidden = YES;
    
    self.progressBgView.hidden = YES;
    self.progressIndicatorView.hidden = YES;
    
    self.progressBgView.frame = CGRectMake(0, 0, self.frame.size.width, kProgressBgViewHeight);
    self.progressIndicatorView.frame = CGRectMake(0, 0, 1, kProgressBgViewHeight);
    
}

- (void)updateProgressView:(float)progress{
    
    int width = (int)self.frame.size.width * progress;
    self.progressIndicatorView.frame = CGRectMake(0, 0, width, kProgressBgViewHeight);
    
}

- (void)hideProgressView{
    
    self.gifVVeboImageView.hidden = NO;
    self.progressBgView.hidden = YES;
    self.progressIndicatorView.hidden = YES;
}

- (void)showProgressView{
    
    self.gifVVeboImageView.hidden = YES;
    self.progressBgView.hidden = NO;
    self.progressIndicatorView.hidden = NO;
}

@end
