//
//  WDImageBoxView.m
//  wenda
//
//  Created by xuzichao on 17/6/9.
//  Copyright (c) 2017年 toutiao. All rights reserved.
//

#import "WDImageBoxView.h"

#import "TTImageView.h"
#import "TTPhotoScrollViewController.h"
#import "WDDefines.h"

#define kMaxCount 9

@interface WDImageBoxView()

@property(nonatomic,strong) NSMutableArray *imgViews;
@property(nonatomic,assign) NSInteger imageCount;
@property(nonatomic,strong) TTImageInfosModel *infoModel;

@end

@implementation WDImageBoxView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self imgBoxCommonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self imgBoxCommonInit];
    }
    return self;
}

- (void)imgBoxCommonInit
{
    self.backgroundColorThemeKey = kColorBackground4;
    self.halfViewSpacing = 7.0f;
    self.imgViews = [NSMutableArray array];
}

- (TTImageView *)imgView
{
    TTImageView *View = [[TTImageView alloc] initWithFrame:CGRectZero];
    View.enableNightCover = YES;
    [self addSubview:View];
    View.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground2];
    [View setContentMode:UIViewContentModeScaleAspectFill];
    [View setClipsToBounds:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTaped:)];
    [View addGestureRecognizer:tap];
    [View setUserInteractionEnabled:YES];
    return View;
}

- (void)setLargeModelArray:(NSArray *)largeModelArray
{
    if ([largeModelArray count] <= kMaxCount) {
        _largeModelArray = largeModelArray;
    }
    else {
        NSMutableArray * ary = [NSMutableArray arrayWithArray:largeModelArray];
        _largeModelArray = [ary subarrayWithRange:NSMakeRange(0, kMaxCount)];
    }
}

- (void)setImgModelArray:(NSArray *)imgModelArray
{
    if ([imgModelArray count] > kMaxCount) {
        NSMutableArray * ary = [NSMutableArray arrayWithArray:imgModelArray];
        imgModelArray = [ary subarrayWithRange:NSMakeRange(0, kMaxCount)];
    }

    _imgModelArray = imgModelArray;

    NSInteger idx = 0;
    for (TTImageView * view in _imgViews) {
        view.hidden = YES;
        view.image = nil;
    }
    
    for (WDImageUrlStructModel *m in imgModelArray) {
        [self tileViewWithIndex:idx model:m];
        idx++;
    }
    
    [self invalidateIntrinsicContentSize];
}

- (void)tileViewWithIndex:(NSInteger)idx model:(WDImageUrlStructModel *)model
{
    @try {
        self.infoModel = [[TTImageInfosModel alloc] initWithDictionary:[model toDictionary]];
    }
    @catch (NSException *exception) {
        // nothing to do...
    }
    
    //idx默认全部从0开始
    TTImageView *imageView = nil;
    if (self.imgViews.count > idx) {
        imageView = self.imgViews[idx];
        imageView.hidden = NO;
    } else {
        imageView = [self imgView];
        imageView.tag = idx;
        [self.imgViews insertObject:imageView atIndex:idx];
        [self addSubview:imageView];
    }
    
    __weak typeof(imageView) wimageView = imageView;
    [imageView setImageWithModel:self.infoModel placeholderImage:nil options:SDWebImageCacheMemoryOnly success:^(UIImage *image, BOOL cached) {
        wimageView.alpha = 1;
    } failure:^(NSError *error) {
        
    }];
    
    
    CGFloat singleHeight = (self.preferredMaxLayoutWidth - self.halfViewSpacing*2) / 3.0f;
    
    if(self.imageCount == 1) {
        
        CGSize imageSize = CGSizeMake(self.infoModel.width, self.infoModel.height);
        CGSize size = [self.class limitedSizeWithSize:imageSize maxLimit:self.preferredMaxLayoutWidth];
        imageView.frame = CGRectMake(0, 0, size.width, size.height);
        
    } else if(self.imageCount <= 3){
        
        imageView.frame = CGRectMake(idx*(singleHeight+self.halfViewSpacing), 0, singleHeight, singleHeight);
        
    } else if(self.imageCount == 4){
        
        imageView.frame = CGRectMake(idx%2*(singleHeight + self.halfViewSpacing), idx/2*(singleHeight + self.halfViewSpacing), singleHeight, singleHeight);
    } else {
        
        imageView.frame = CGRectMake(idx%3*(singleHeight + self.halfViewSpacing), idx/3*(singleHeight + self.halfViewSpacing), singleHeight, singleHeight);
        
    }
}

- (NSInteger)imageCount
{
    return self.imgModelArray.count;
}

- (void)imageTaped:(UITapGestureRecognizer *)tap
{
    if (!isEmptyString(_umengEventStr) && tap.view != nil && _threadId != 0) {
        [TTTracker category:@"umeng" event:_umengEventStr label:@"click_image" dict:@{@"value":@(_threadId), @"ext_value":@(tap.view.tag)}];
    }
    UIImageView *view = (UIImageView *)tap.view;
    if (view.image == nil) {
        return;
    }
    [self imageTouched:tap.view];
}

- (void)imageTouched:(UIView *)sender
{
    TTPhotoScrollViewController * controller = [[TTPhotoScrollViewController alloc] init];
    NSInteger picCount = self.imageCount;
    if (picCount > kMaxCount) {
        picCount = kMaxCount;
    }
    NSMutableArray * infoModels = [NSMutableArray arrayWithCapacity:10];
    for (NSInteger i = 0; i < picCount; i++) {
        WDImageUrlStructModel *m = self.largeModelArray[i];
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:m.uri forKey:kTTImageURIKey];
        [dict setValue:m.url forKey:TTImageInfosModelURL];
        [dict setValue:m.width forKey:kTTImageWidthKey];
        [dict setValue:m.height forKey:kTTImageHeightKey];
        NSMutableArray * urls = [NSMutableArray arrayWithCapacity:10];
        for (WDMagicUrlStructModel * magicModel in m.url_list) {
            if (!isEmptyString(magicModel.url)) {
                [urls addObject:@{TTImageInfosModelURL : magicModel.url}];
            }
        }
        [dict setValue:urls forKey:kTTImageURLListKey];
        
        TTImageInfosModel * iModel = [[TTImageInfosModel alloc] initWithDictionary:dict];
        if (iModel) {
            [infoModels addObject:iModel];
        }
    }
    controller.imageInfosModels = infoModels;
    [controller setStartWithIndex:sender.tag];
    
    NSMutableArray * frames = [NSMutableArray arrayWithCapacity:9];
    for (TTImageView * view in _imgViews) {
        CGRect frame = [view convertRect:view.bounds toView:nil];
        [frames addObject:[NSValue valueWithCGRect:frame]];
    }
    controller.placeholderSourceViewFrames = frames;
    controller.placeholders = [self photoObjs];
    [controller presentPhotoScrollView];
}

- (NSArray *)photoObjs
{
    NSMutableArray *photoObjs = [NSMutableArray array];
    NSInteger picCount = self.imageCount;
    if (picCount > kMaxCount) {
        picCount = kMaxCount;
    }
    for (NSInteger i = 0; i < picCount; i++) {
        UIImageView *View = self.imgViews[i];
//  此处需要优化
        if (View.image) {
            [photoObjs addObject:View.image];
        }
    }
    return photoObjs;
}

+ (CGSize)limitedSizeWithSize:(CGSize)aSize maxLimit:(CGFloat)maxLimit
{
    
    CGSize maxSize = {maxLimit,maxLimit};
    //如果宽高都没有超出那么直接返回
    if (aSize.width <= maxSize.width && aSize.height <= maxSize.height) {
        return aSize;
    }
    CGFloat ratio = aSize.width/aSize.height;
    CGSize scaledSize = aSize;
    
    if (ratio > 1.0f) {//宽大于高
        if (ratio > 3.0f) {
            scaledSize.width = maxSize.width;
            scaledSize.height = maxSize.height/3;
        } else {
            scaledSize.width = maxSize.width;
            scaledSize.height = maxSize.width/ratio;
        }
    } else {//高大于宽
        if (ratio < 0.33f) {
            scaledSize.height = maxSize.height;
            scaledSize.width = maxSize.width/3;
        } else {
            scaledSize.height = maxSize.height;
            scaledSize.width = maxSize.height*ratio;
        }
    }
    return CGSizeMake(ceilf(scaledSize.width), ceilf(scaledSize.height));
}

+ (CGSize)limitedSizeForGif:(CGSize)aSize maxLimit:(CGFloat)maxlimit
{
    CGFloat width = maxlimit;
    CGFloat radio = aSize.height / aSize.width;
    CGFloat height = radio * width;
    
    return CGSizeMake(ceilf(width), ceilf(height));
}

- (CGSize)intrinsicContentSize
{
    NSAssert(self.preferredMaxLayoutWidth != 0.0f, @"这个不能是0, 如果真的是0,那么设置成0.01");
    if (self.imgModelArray.count <= 0) {
        return CGSizeZero;
    }
    CGSize returnSize = CGSizeZero;
    if(self.imageCount == 1) {
        WDImageUrlStructModel *model = self.imgModelArray[0];
        CGSize imageSize = CGSizeMake(model.width.floatValue, model.height.floatValue);
        CGSize size = [self.class limitedSizeWithSize:imageSize maxLimit:self.preferredMaxLayoutWidth];
        returnSize.width = size.width;
        returnSize.height = size.height;
    } else if(self.imageCount <= 3){
        returnSize.width = _preferredMaxLayoutWidth;
        returnSize.height = ((_preferredMaxLayoutWidth - _halfViewSpacing*2)/3.0f);
    } else if(self.imageCount <= 6) {
        returnSize.width = _preferredMaxLayoutWidth;
        returnSize.height = ((_preferredMaxLayoutWidth - _halfViewSpacing*2)/3.0f)*2 + _halfViewSpacing;
    } else {
        returnSize.width = _preferredMaxLayoutWidth;
        returnSize.height = ((_preferredMaxLayoutWidth - _halfViewSpacing*2)/3.0f)*3 + _halfViewSpacing*2;
    }
    return returnSize;
}

@end








