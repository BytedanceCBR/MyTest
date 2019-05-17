//
//  ArticleXPEssayGifWebView.h
//  Article
//
//  Created by 邓刚 on 14-4-4.
//
//

#import "SSViewBase.h"

@interface ArticleXPEssayGifWebView : SSViewBase
@property (nonatomic, assign) BOOL isGifPlaying;
@property (nonatomic, retain) UIButton *gifPlayButton;
- (void)clickGifImageWithEssayData:(EssayData *)essayData;
- (void)loadDataWithEssayData:(EssayData* )essayData;
- (void)stopPlayGifImage;

- (void)cancelDownload;
- (BOOL)loaded;

- (void)themeChanged:(NSNotification*)notification;


@end
