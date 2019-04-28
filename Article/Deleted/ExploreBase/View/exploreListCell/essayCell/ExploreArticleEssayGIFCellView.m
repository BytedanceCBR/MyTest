//
//  ExploreArticleEssayGIFCellView.m
//  Article
//
//  Created by Chen Hong on 14-9-16.
//
//

#import "ExploreArticleEssayGIFCellView.h"
#import "ArticleXPEssayGifWebView.h"
#import "TTArticleCategoryManager.h"
//#import "SSSimpleCache.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellHelper.h"


@interface ExploreArticleEssayGIFCellView () <UIGestureRecognizerDelegate>

@property (nonatomic, retain)ArticleXPEssayGifWebView *essayGifWebView;

@property (nonatomic, retain) EssayData * essay;
@end


@implementation ExploreArticleEssayGIFCellView

- (void)dealloc
{
    [_essayGifWebView stopPlayGifImage];
}

- (ArticleXPEssayGifWebView *)essayGifWebView
{
    if (!_essayGifWebView) {
        _essayGifWebView = [[ArticleXPEssayGifWebView alloc] init];
        _essayGifWebView.userInteractionEnabled = YES;
        _essayGifWebView.hidden = YES;
        [_essayGifWebView.gifPlayButton addTarget:self action:@selector(playGIF:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageView addSubview:_essayGifWebView];
        
        //gif图片的点击
        UITapGestureRecognizer *contentGifImageSingleTap = [[UITapGestureRecognizer alloc]
                                                            initWithTarget:self action:@selector(contentGifImageSingleTapRecognizer:)];
        contentGifImageSingleTap.numberOfTouchesRequired = 1;
        contentGifImageSingleTap.numberOfTapsRequired = 1;
        contentGifImageSingleTap.delegate = self;
        [_essayGifWebView addGestureRecognizer:contentGifImageSingleTap];
    }
    return _essayGifWebView;
}

- (void)updatePic:(EssayData *)essay
{
    self.essay = essay;
    TTImageInfosModel *imageModel = essay.middleImageModel;
    if (imageModel) {
        [self.imageView setImageWithModel:imageModel placeholderImage:nil];
        self.essayGifWebView.hidden = NO;
        self.hasImage = YES;
    } else {
        [self.imageView setImageWithModel:nil];
        self.essayGifWebView.hidden = YES;
        self.hasImage = NO;
    }
    
    [self.essayGifWebView stopPlayGifImage];
}

- (void)layoutPic
{
    [super layoutPic];
    self.essayGifWebView.frame = self.imageView.bounds;

    // list
    if (self.from == EssayCellStyleList) {
    }
    // detail
    else if (self.from == EssayCellStyleDetail) {
        //修改一个bug mid图的尺寸不对 导致 gif图 尺寸不对 这里修正一下
        CGFloat imageHeight = 0.f;
        CGFloat imageWidth = self.width - kCellLeftPadding - kCellRightPadding;
        
        TTImageInfosModel *imageModel = self.essay.largeImageModel;
        
        if (imageModel && imageModel.width > 0) {
            imageHeight = (imageWidth * imageModel.height) / imageModel.width;
        }

        self.essayGifWebView.height =  imageHeight;
    }
}

- (void)contentGifImageSingleTapRecognizer:(UITapGestureRecognizer *)sender
{
    [self.essayGifWebView clickGifImageWithEssayData:self.orderedData.essayData];
    
    self.essayGifWebView.height = self.imageView.height;
    
    switch (self.listType) {
        case ExploreOrderedDataListTypeCategory:
        {
            if (!isEmptyString([self.orderedData categoryID])) {
                if ([[self.orderedData categoryID] isEqualToString:kTTMainCategoryID]) {
                    wrapperTrackEvent(@"list_content", @"pause_headline");
                }
                else {
                    wrapperTrackEvent(@"list_content", @"pause_channel");
                }
            }
        }
            break;
        case ExploreOrderedDataListTypeFavorite:
        {
            wrapperTrackEvent(@"list_content", @"pause_favor");
        }
            break;

        default:
            break;
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return _essayGifWebView.isGifPlaying;
}

- (void)playGIF:(UIButton*)button
{
    EssayData *essayData = (EssayData *)self.originalData?:self.essayData;
    if (![essayData isKindOfClass:[EssayData class]]) {
        return;
    }
    
    [self.essayGifWebView clickGifImageWithEssayData:essayData];
    
    TTImageInfosModel *imageModel = self.essay.largeImageModel;
//    CGFloat imageHeight = (self.imageView.width * imageModel.height) / imageModel.width;
    CGFloat imageHeight = [ExploreCellHelper heightForVideoImageWidth:imageModel.width height:imageModel.height constraintWidth:self.imageView.width];
    self.essayGifWebView.height =  imageHeight;

    switch (self.listType) {
        case ExploreOrderedDataListTypeCategory:
        {
            if (!isEmptyString(self.orderedData.categoryID)) {
                if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
                    wrapperTrackEvent(@"list_content", @"play_gif_headline");
                }
                else {
                    wrapperTrackEvent(@"list_content", @"play_gif_channel");
                }
            }
        }
            break;
        case ExploreOrderedDataListTypeFavorite:
        {
            wrapperTrackEvent(@"list_content", @"play_gif_favor");
        }
            break;

        default:
            break;
    }
}

@end
