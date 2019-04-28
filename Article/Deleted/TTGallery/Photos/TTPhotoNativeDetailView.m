//
//  TTPhotoNativeDetailView.m
//  Article
//
//  Created by yuxin on 4/19/16.
//
//

#import "TTPhotoNativeDetailView.h"

@interface TTPhotoNativeDetailView ()


@end

@implementation TTPhotoNativeDetailView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
//    self.article = nil;
}

- (instancetype)initWithFrame:(CGRect)frame model:(TTDetailModel *)detailModel {
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.viewModel = detailViewModel;
//        self.hasShowNatant = NO;
        
        self.detailModel = detailModel;
        
        self.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        ExploreImageCollectionView *collectionView = [[ExploreImageCollectionView alloc] initWithFrame:self.bounds];
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        collectionView.delegate = self;
        [self addSubview:collectionView];
        self.imageCollectionView = collectionView;
        self.maximumVisibleIndex = 1;
 
        
        
//        [detailViewModel sharedDetailManager].delegate = self;
//        [[detailViewModel sharedDetailManager] startGetContentIfNeed];
        
        [self loadAllTypeContent];
     }
    return self;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    self.imageCollectionView.contentInset = contentInset;
}

- (UIView *)contentView {
    return self.imageCollectionView;
}



- (void)willAppear {
    [super willAppear];
//    [[UIApplication sharedApplication] setStatusBarHidden:!self.imageCollectionView.natantVisible
//                                            withAnimation:UIStatusBarAnimationFade];
//    if ([self.viewModel shouldBeginShowComment] && !_hasShowNatant) {
//        [self pushToNatantViewControllerAnimated:YES];
//    }
}

- (void)willDisappear
{
    [super willDisappear];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)loadAllTypeContent {

//    [self.natantViewController.natantView reloadWithDetailViewModel:self.viewModel];
//    ExploreDetailManager *manager = [self.viewModel sharedDetailManager];
//    [manager setArticleHasRead];
 //    [self showOriginalImageIfNeeded];
   // [self _reloadToolbarWithArticle:self.article];
    
    self.imageCollectionView.sourceArticle = [self.detailModel article];

}

#pragma mark - ExploreImageCollectionViewDelegate

- (void)imageCollectionView:(ExploreImageCollectionView *)collectionView didChangeNatantVisible:(BOOL)newNatantVisible {
    wrapperTrackEvent(@"slide_detail", newNatantVisible? @"show_content":@"hide_content");
}

- (void)imageCollectionView:(ExploreImageCollectionView *)collectionView didScrollToIndex:(NSInteger)index {
    wrapperTrackEvent(@"slide_detail", @"slide_pic");
    self.currentVisibleIndex = index+1;
    self.maximumVisibleIndex = MAX(index+1, self.maximumVisibleIndex);
}

- (void)imageCollectionView:(ExploreImageCollectionView *)collectionView didScrollTextView:(nonnull UITextView *)textView {
    wrapperTrackEvent(@"slide_detail", @"slide_content");
}

- (void)imageCollectionView:(nonnull ExploreImageCollectionView *)collectionView imagePositionType:(TTPhotoDetailImagePositon)imagePositionType tapOn:(BOOL)tapOn {
    
    if ([self.delegate respondsToSelector:@selector(photoNativeDetailView:imagePositionType:tapOn:)]) {
        [self.delegate photoNativeDetailView:self imagePositionType:imagePositionType tapOn:tapOn];
    }
}

- (void)imageCollectionView:(ExploreImageCollectionView *)collectionView scrollPercent:(CGFloat)scrollPercent {
    if ([self.delegate respondsToSelector:@selector(photoNativeDetailView:scrollPercent:)]) {
        [self.delegate photoNativeDetailView:self scrollPercent:scrollPercent];
    }
}

//- (void)imageCollectionView:(ExploreImageCollectionView *)collectionView didScrollInToImageRecommendCell:(BOOL)showRecommend
//{
//    if ([self.delegate respondsToSelector:@selector(photoNativeDetailView:didScrollToImageRecommend:)]) {
//        [self.delegate photoNativeDetailView:self didScrollToImageRecommend:showRecommend];
//    }
//}

-(void)imageCollectionView:(ExploreImageCollectionView *)collectionView didScrollImagePositionType:(TTPhotoDetailImagePositon)imagePositionType
{
    //通过delegate调整TTPhotoDetailViewController中UI
    if ([self.delegate respondsToSelector:@selector(photoNativeDetailView:didScrollToImagePostionType:)]) {
        [self.delegate photoNativeDetailView:self didScrollToImagePostionType:imagePositionType];
    }
}

- (void)imageCollectionView:(ExploreImageCollectionView *)collectionView didScrollToIndex:(NSInteger)index isLastPic:(BOOL)isLastPic {
    if ([self.delegate respondsToSelector:@selector(photoNativeDetailView:didScrollToIndex:isLastPic:)]) {
        [self.delegate photoNativeDetailView:self didScrollToIndex:index isLastPic:isLastPic];
    }
}

@end

@implementation TTPhotoNativeDetailView (ExploreCollectionViewCell)

- (TTShowImageView *)currentShowImageView
{
    NSArray <ExploreImageCollectionViewCell *> *collectionCells = [self.imageCollectionView.collectionView visibleCells];
    if (collectionCells.count) {
        if ([[collectionCells firstObject] respondsToSelector:@selector(imageScrollView)]) {
            return [[collectionCells firstObject] imageScrollView];
        }
    }
    return nil;
}

- (UIImage *)currentNativeGalleryImage
{
    return [[self currentShowImageView] imageData];
}

- (void)saveCurrentNativeGalleryIfCould
{
    [[self currentShowImageView] saveImage];
}

- (void)destructSaveImageAlert
{
    [[self currentShowImageView] destructSaveImageAlert];
}

- (CGRect)currentNativeGalleryImageViewFrame
{
    return [[self currentShowImageView] currentImageViewFrame];
}

@end
