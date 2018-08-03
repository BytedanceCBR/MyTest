//
//  WDListQuestionHeaderImageBoxView.m
//  Article
//
//  Created by 延晋 张 on 16/8/23.
//
//

#import "WDListQuestionHeaderImageBoxView.h"
#import "WDListViewModel.h"
#import "WDQuestionEntity.h"
#import "WDQuestionDescEntity.h"
#import "WDUIHelper.h"

#import "TTPhotoScrollViewController.h"
#import "UIImageView+WebCache.h"

#import "TTModuleBridge.h"

CGFloat const kQuestionListImageWidth = 80.0f;
CGFloat const kQuestionListImagePadding = 10.0f;

CGFloat const kQuestionListImageNewWidth = 60.0f;
CGFloat const kQuestionListImageNewPadding = 5.0f;

CGFloat const kQuestionListLongImageRatio = (690 / 455);

@interface WDListQuestionHeaderImageBoxView ()

@property (nonatomic, strong) WDListViewModel *viewModel;
@property (nonatomic, strong) NSMutableArray *imageViews;

@end

@implementation WDListQuestionHeaderImageBoxView

- (instancetype)initWithViewModel:(WDListViewModel *)viewModel
                            frame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _viewModel = viewModel;
        _imageViews = @[].mutableCopy;
        [self createImageViews];
    }
    return self;
}

- (void)createImageViews
{
    CGFloat originX = 0.0f;
    if ([self imageList].count > 1) {
        for (TTImageInfosModel *imageModel in self.imageList) {
            NSUInteger index = [self.imageList indexOfObject:imageModel];
            CGFloat width = WDPadding(kQuestionListImageWidth);
            SSThemedImageView *imageView = [self imageViewWithFrame:CGRectMake(originX, 0, width, width)];
            [imageView sd_setImageWithURL:[NSURL URLWithString:[imageModel urlStringAtIndex:0]]];
            imageView.tag = index;
            [self addSubview:imageView];
            
            CGFloat padding = WDPadding(kQuestionListImagePadding);
            originX += (SSWidth(imageView) + padding);
            [self.imageViews addObject:imageView];
        }
    } else if ([self imageList].count == 1){
        TTImageInfosModel *imageModel = [self.imageList firstObject];
        CGSize imageSize = [self sizeForImageModel:imageModel];
        CGFloat imageWidth = imageSize.width;
        CGFloat imageHeight = imageSize.height;
        SSThemedImageView *imageView = [self imageViewWithFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:[imageModel urlStringAtIndex:0]]];
        imageView.tag = 0;
        [self addSubview:imageView];
        [self.imageViews addObject:imageView];
        if ([self isSuperWidthImageWithImageModel:imageModel] || [self isSuperHeightImageWithImageModel:imageModel]) {
            [imageView addSubview:[self longImageLabelWithParentViewSize:imageView.size]];
        }
        
        self.height = (SSMaxY(imageView));
    }
}

#pragma mark - public methods

- (void)refreshImageView
{
    [self removeAllSubviews];
    [self createImageViews];
}

- (void)removeAllSubviews {
    while (self.subviews.count >= 1) {
        UIView *subview = self.subviews.lastObject;
        [subview removeFromSuperview];
    }
    [self.imageViews removeAllObjects];
}

- (CGFloat)viewHeight
{
    if ([self imageList].count > 0) {
        if ([self imageList].count == 1) {
            TTImageInfosModel *imageModel = [self.imageList firstObject];
            return [self sizeForImageModel:imageModel].height;
        } else {
            return WDPadding(kQuestionListImageWidth);
        }
    } else {
        return 0.0f;
    }
}

#pragma mark - action & response

- (void)imageTaped:(UITapGestureRecognizer *)gesture
{
    TTPhotoScrollViewController *showImageViewController = [[TTPhotoScrollViewController alloc] init];
    showImageViewController.finishBackView = [self getSuitableFinishBackViewWithCurrentContext];
    showImageViewController.imageURLs = [self largeImageUrls];
    NSUInteger index = gesture.view.tag;
    if ([gesture.view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)gesture.view;
        if (imageView && imageView.image) {
//            CGRect frame = [self convertRect:imageView.frame toView:nil];
            NSMutableArray *placeHoldersFrames = [[NSMutableArray alloc] init];
            for (NSUInteger i = 0; i < [self largeImageUrls].count; i++) {
                UIImageView *currentImageView = [self.imageViews objectAtIndex:i];
                CGRect frame = [self convertRect:currentImageView.frame toView:nil];
                [placeHoldersFrames addObject:[NSValue valueWithCGRect:frame]];
            }
            showImageViewController.placeholderSourceViewFrames = placeHoldersFrames;
            UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self];
            CGFloat topBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height + nav.navigationBar.height;
            showImageViewController.dismissMaskInsets = UIEdgeInsetsMake(topBarHeight, 0, 0, 0);
        }
    }
    [showImageViewController setStartWithIndex:index];
    [showImageViewController presentPhotoScrollView];
}

- (UIView *)getSuitableFinishBackViewWithCurrentContext
{
    __block UIView *view;
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"getSuitableFinishBackViewWithCurrentContext" object:nil withParams:nil complete:^(id  _Nullable result) {
        if ([result isKindOfClass:[UIView class]]) {
            view = result;
        }
    }];
    return view;
}

#pragma mark - util

- (CGSize)sizeForImageModel:(TTImageInfosModel *)imageInfoModel
{
    if ([self isWidthImageWithImageModel:imageInfoModel]) {
        if ([self isSuperWidthImageWithImageModel:imageInfoModel]) {
            return [self sizeForSuperWidthImageModel:imageInfoModel];
        } else {
            return [self sizeForNormalWidthImageModel:imageInfoModel];
        }
    } else {
        if ([self isSuperHeightImageWithImageModel:imageInfoModel]) {
            return [self sizeForSuperHeightImageModel:imageInfoModel];
        } else {
            return [self sizeForNormalHeightImageModel:imageInfoModel];
        }
    }
}

- (BOOL)isWidthImageWithImageModel:(TTImageInfosModel *)imageInfoModel
{
    if (imageInfoModel.width >= imageInfoModel.height) {
        return YES;
    }
    return NO;
}

- (BOOL)isSuperWidthImageWithImageModel:(TTImageInfosModel *)imageInfoModel
{
    if (imageInfoModel.width >= imageInfoModel.height * 3) {
        return YES;
    }
    return NO;
}

- (BOOL)isSuperHeightImageWithImageModel:(TTImageInfosModel *)imageInfoModel
{
    if (imageInfoModel.width * 3 <= imageInfoModel.height) {
        return YES;
    }
    return NO;
}

- (CGSize)sizeForSuperWidthImageModel:(TTImageInfosModel *)imageInfoModel
{
    CGFloat height = [self basicUnitForImageSize];
    CGFloat width = height * 1.5;
    return CGSizeMake(width, height);
}

- (CGSize)sizeForNormalWidthImageModel:(TTImageInfosModel *)imageInfoModel
{
    CGFloat width = [self basicUnitForImageSize];
    CGFloat height = width * imageInfoModel.height / imageInfoModel.width;
    return CGSizeMake(width, height);
}

- (CGSize)sizeForNormalHeightImageModel:(TTImageInfosModel *)imageInfoModel
{
    CGFloat height = [self basicUnitForImageSize];
    CGFloat width = height * imageInfoModel.width / imageInfoModel.height;
    return CGSizeMake(width, height);
}

- (CGSize)sizeForSuperHeightImageModel:(TTImageInfosModel *)imageInfoModel
{
    CGFloat width = [self basicUnitForImageSize];
    CGFloat height = width * 1.5;
    return CGSizeMake(width, height);
}

- (CGFloat)basicUnitForImageSize
{
    return SSWidth(self) / 2.0f;
}

- (NSArray<NSString *> *)largeImageUrls
{
    NSMutableArray *imageUrls = @[].mutableCopy;
    for (TTImageInfosModel *infoModel in [self.viewModel.questionEntity.content largeImageList]) {
        [imageUrls addObject:[infoModel urlStringAtIndex:0]];
    }
    return [imageUrls copy];
}

- (SSThemedImageView *)imageViewWithFrame:(CGRect)frame
{
    SSThemedImageView *imageView = [[SSThemedImageView alloc] initWithFrame:frame];
    imageView.enableNightCover = YES;
    imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    imageView.layer.borderColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTaped:)]];
    return imageView;
}

#pragma mark - getter

- (NSArray<TTImageInfosModel *> *)imageList
{
    return [self.viewModel.questionEntity.content thumbImageList];
}

- (SSThemedLabel *)longImageLabelWithParentViewSize:(CGSize)parentSize
{
    SSThemedLabel *longImageLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(parentSize.width - 4.0f - 44.0f, parentSize.height - 4.0f - 20.0f, 44.0f, 20.0f)];
    longImageLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    longImageLabel.layer.cornerRadius = 10.0f;
    longImageLabel.backgroundColorThemeKey = kColorBackground15;
    longImageLabel.textColorThemeKey = kColorText12;
    longImageLabel.font = [UIFont systemFontOfSize:10.0f];
    longImageLabel.text = @"长图";
    longImageLabel.textAlignment = NSTextAlignmentCenter;
    longImageLabel.clipsToBounds = YES;
    return longImageLabel;
}

@end
