//
//  FHUGCCellMultiImageView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHUGCCellMultiImageView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIImageView+BDWebImage.h"
#import "FHFeedUGCCellModel.h"
#import "TTPhotoScrollViewController.h"
#import "TTBaseMacro.h"
#import "TTInteractExitHelper.h"
#import "FHUGCCellHelper.h"
#import "UIViewAdditions.h"
//#import "TTImageView+TrafficSave.h"
//#import "TTImageView.h"
#import "UIImageView+fhUgcImage.h"

#define itemPadding 4
#define kMaxCount 9

@interface FHUGCCellMultiImageView ()

@property(nonatomic, assign) NSInteger count;
@property(nonatomic, strong) NSMutableArray *imageViewList;
@property(nonatomic, assign) CGFloat imageWidth;
@property(nonatomic, assign) CGFloat imageHeight;
@property(nonatomic, strong) NSArray *largeImageList;
@property(nonatomic, strong) NSArray *imageList;
@property(nonatomic, strong) UILabel *infoLabel;

@end

@implementation FHUGCCellMultiImageView

- (instancetype)initWithFrame:(CGRect)frame count:(NSInteger)count {
    self = [super initWithFrame:frame];
    if (self) {
        _imageViewList = [[NSMutableArray alloc] init];
        _count = count;
        
        if(_count > kMaxCount){
            _count = kMaxCount;
        }
        
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    for (NSInteger i = 0; i < self.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.clipsToBounds = YES;
//        imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor themeGray6];
        imageView.layer.borderColor = [[UIColor themeGray6] CGColor];
        imageView.layer.borderWidth = 0.5;
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 4;
        imageView.hidden = YES;
        imageView.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTaped:)];
        [imageView addGestureRecognizer:tap];
        [self addSubview:imageView];
        
        [self.imageViewList addObject:imageView];
    }
    
    self.infoLabel = [[UILabel alloc] init];
    _infoLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    _infoLabel.textAlignment = NSTextAlignmentCenter;
    _infoLabel.font = [UIFont themeFontRegular:10];
    _infoLabel.textColor = [UIColor whiteColor];
    _infoLabel.layer.cornerRadius = 4;
    _infoLabel.layer.masksToBounds = YES;
    _infoLabel.hidden = YES;
    [self addSubview:_infoLabel];
}

- (void)initConstraints {
    if(self.count == 1){
        _imageWidth = self.bounds.size.width;
        _viewHeight = self.imageWidth * 9.0f/16.0f;
        _imageHeight = _viewHeight;
        UIImageView *imageView = [self.imageViewList firstObject];
        
        imageView.top = 0;
        imageView.left = 0;
        imageView.width = self.imageWidth;
        imageView.height = self.viewHeight;
    }else if(self.count == 2){
        _imageWidth = (self.bounds.size.width - itemPadding)/2;
        _viewHeight = self.imageWidth * 124.0f/165.0f;
        _imageHeight = _viewHeight;
        UIView *firstView = self;
        for (UIImageView *imageView in self.imageViewList) {
            
            imageView.top = 0;
            if(firstView == self){
                imageView.left = 0;
            }else{
                imageView.left = firstView.right + itemPadding;
            }

            imageView.width = self.imageWidth;
            imageView.height = self.viewHeight;
            
            firstView = imageView;
        }
    }else if(self.count == 4){
        _imageWidth = (self.bounds.size.width - itemPadding * 2)/3;
        _imageHeight = _imageWidth;
        _viewHeight = _imageWidth * 2 + itemPadding;
        
        UIView *topView = self;
        for (NSInteger i = 0; i < self.imageViewList.count; i++) {
            UIImageView *imageView = self.imageViewList[i];
            NSInteger row = i/2; // 0,1,2
            NSInteger column = i%2; //0,1,2
            CGFloat topMargin = row * _imageWidth + itemPadding * row;
            CGFloat leftMargin = column * _imageWidth + itemPadding * column;
            
            imageView.top = topMargin;
            imageView.left = leftMargin;
            imageView.width = self.imageWidth;
            imageView.height = self.imageWidth;
        }
    }else if(self.count >= 3){
        _imageWidth = (self.bounds.size.width - itemPadding * 2)/3;
        _imageHeight = _imageWidth;
        NSInteger row = (self.count - 1)/3;
        _viewHeight = _imageWidth * (row + 1) + itemPadding * row;
        
        UIView *topView = self;
        for (NSInteger i = 0; i < self.imageViewList.count; i++) {
            UIImageView *imageView = self.imageViewList[i];
            NSInteger row = i/3; // 0,1,2
            NSInteger column = i%3; //0,1,2
            CGFloat topMargin = row * _imageWidth + itemPadding * row;
            CGFloat leftMargin = column * _imageWidth + itemPadding * column;
            
            imageView.top = topMargin;
            imageView.left = leftMargin;
            imageView.width = self.imageWidth;
            imageView.height = self.imageWidth;
        }
    }else{
        
    }
    
    self.infoLabel.width = 38;
    self.infoLabel.height = 22;
    self.infoLabel.top = self.viewHeight - self.infoLabel.height - 4;
    self.infoLabel.left = self.frame.size.width - self.infoLabel.width - 4;
}

- (void)updateImageView:(NSArray *)imageList largeImageList:(NSArray *)largeImageList {
    self.largeImageList = largeImageList;
    
    for (NSInteger i = 0; i < self.imageViewList.count; i++) {
        UIImageView *imageView = self.imageViewList[i];
        if(i < imageList.count){
            FHFeedContentImageListModel *imageModel = imageList[i];
            
            imageView.hidden = NO;
            CGFloat width = [imageModel.width floatValue];
            CGFloat height = [imageModel.height floatValue];
            if(self.imageList && self.imageList.count == imageList.count){
                FHFeedContentImageListModel *oldImageModel = self.imageList[i];
                if([oldImageModel.uri isEqualToString:imageModel.uri]){
                    continue;
                }
            }
            
            //只对单图做重新布局，多图都是1：1
            if(self.count == 1 && !self.fixedSingleImage){
                self.viewHeight = self.imageWidth * height/width;
                imageView.height = self.viewHeight;
                self.imageHeight = self.viewHeight;
            }

            if (imageModel && imageModel.url.length > 0) {
//                [imageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:nil];
//                TTImageInfosModel *imageInfoModel = [FHUGCCellHelper convertTTImageInfosModel:imageModel];
//                __weak typeof(imageView) wImageView = imageView;
//                [imageView setImageWithModelInTrafficSaveMode:imageInfoModel placeholderImage:nil success:nil failure:^(NSError *error) {
//                    [wImageView setImage:nil];
//                }];
//                [imageView.imageView.layer removeAnimationForKey:@"contents"];
                
//                [imageView setImageWithModel:imageInfoModel placeholderImage:nil options:SDWebImageRetryFailed success:^(UIImage *image, BOOL cached) {
//                     if (image) {
//                         wImageView.imageView.image = image;
//                     }
                     
//                     if(!cached){
//                         CATransition *transition = [CATransition animation];
//                         transition.duration = 0.15;
//                         transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//                         transition.type = kCATransitionFade;
//                         [wImageView.imageView.layer addAnimation:transition forKey:@"contents"];
//                     }
//                 } failure:nil];
//                [imageView fh_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:nil];
                [imageView fh_setImageWithURLStringInTrafficSaveMode:imageModel.url placeholder:nil];
                
            }
        }else{
            imageView.hidden = YES;
        }
        
        //不传时不可点击
        if(largeImageList){
            imageView.userInteractionEnabled = YES;
        }else{
            imageView.userInteractionEnabled = NO;
        }
        
        //三图模式下多余三张图，最后一张图不能点击进入大图，直接进详情页
        if(self.count == 3 && imageList.count > self.count && i == 2){
            imageView.userInteractionEnabled = NO;
        }
    }
    
    if(imageList.count > self.count){
        self.infoLabel.hidden = NO;
        self.infoLabel.text = [NSString stringWithFormat:@"共%i张",imageList.count];
    }else{
        self.infoLabel.hidden = YES;
    }
    
    self.imageList = imageList;
}

#pragma mark - 处理大图逻辑
- (void)imageTaped:(UITapGestureRecognizer *)tap {
    if(!self.largeImageList){
        return;
    }
    
    UIImageView *view = (UIImageView *)tap.view;
    if (view.image == nil) {
        return;
    }
    [self imageTouched:tap.view];
}

- (void)imageTouched:(UIView *)sender {
    TTPhotoScrollViewController * controller = [[TTPhotoScrollViewController alloc] init];
    controller.finishBackView = [TTInteractExitHelper getSuitableFinishBackViewWithCurrentContext];
    NSInteger picCount = self.largeImageList.count;
    if (picCount > kMaxCount) {
        picCount = kMaxCount;
    }
    NSMutableArray * infoModels = [NSMutableArray arrayWithCapacity:10];
    for (NSInteger i = 0; i < picCount; i++) {
        FHFeedContentImageListModel *imageModel = self.largeImageList[i];
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:imageModel.uri forKey:kTTImageURIKey];
        [dict setValue:imageModel.url forKey:TTImageInfosModelURL];
        [dict setValue:imageModel.width forKey:kTTImageWidthKey];
        [dict setValue:imageModel.height forKey:kTTImageHeightKey];
        NSMutableArray * urls = [NSMutableArray arrayWithCapacity:10];
        for (FHFeedContentImageListUrlListModel *urlListModel in imageModel.urlList) {
            if (!isEmptyString(urlListModel.url)) {
                [urls addObject:@{TTImageInfosModelURL : urlListModel.url}];
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
    for (UIImageView *view in self.imageViewList) {
        CGRect frame = [view convertRect:view.bounds toView:nil];
        [frames addObject:[NSValue valueWithCGRect:frame]];
    }
    controller.placeholderSourceViewFrames = frames;
    controller.placeholders = [self photoObjs];
    [controller presentPhotoScrollView];
}

- (NSArray *)photoObjs {
    NSMutableArray *photoObjs = [NSMutableArray array];
    NSInteger picCount = self.largeImageList.count;
    if (picCount > kMaxCount) {
        picCount = kMaxCount;
    }
    for (NSInteger i = 0; i < picCount; i++) {
        if(i < self.imageViewList.count){
            UIImageView *view = self.imageViewList[i];
            //  此处需要优化
            if (view.image) {
                [photoObjs addObject:view.image];
            }
        }
    }
    return photoObjs;
}

+ (CGFloat)viewHeightForCount:(CGFloat)count width:(CGFloat)width {
    if(count == 1){
        return width * 9.0f/16.0f;
    }else if(count == 2){
        CGFloat imageWidth = (width - itemPadding)/2;
        return imageWidth * 124.0f/165.0f;
    }else if(count == 4){
        CGFloat imageWidth = (width - itemPadding * 2)/3;
        return imageWidth * 2 + itemPadding;
    }else if(count >= 3){
        CGFloat imageWidth = (width - itemPadding * 2)/3;
        NSInteger row = (count - 1)/3;
        return imageWidth * (row + 1) + itemPadding * row;
    }
    return 0;
}

@end

