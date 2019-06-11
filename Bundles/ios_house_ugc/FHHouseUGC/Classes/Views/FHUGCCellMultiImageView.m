//
//  FHUGCCellMultiImageView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHUGCCellMultiImageView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import <UIImageView+BDWebImage.h>
#import "FHFeedUGCCellModel.h"
#import "TTPhotoScrollViewController.h"
#import "TTBaseMacro.h"
#import "TTInteractExitHelper.h"

#define itemPadding 4
#define kMaxCount 9

@interface FHUGCCellMultiImageView ()

@property(nonatomic, assign) NSInteger count;
@property(nonatomic, strong) NSMutableArray *imageViewList;
@property(nonatomic, assign) CGFloat imageWidth;
@property(nonatomic, strong) NSArray *largeImageList;
@property(nonatomic, strong) UILabel *infoLabel;

@end

@implementation FHUGCCellMultiImageView

- (instancetype)initWithFrame:(CGRect)frame count:(NSInteger)count {
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageViewList = [[NSMutableArray alloc] init];
        _count = count;
        
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    
    for (NSInteger i = 0; i < self.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor themeGray6];
        imageView.layer.borderColor = [[UIColor themeGray6] CGColor];
        imageView.layer.borderWidth = 0.5;
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
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(self).offset(-4);
        make.width.mas_equalTo(38);
        make.height.mas_equalTo(22);
    }];
    
    if(self.count == 1){
        _imageWidth = self.bounds.size.width;
        UIImageView *imageView = [self.imageViewList firstObject];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.mas_equalTo(self);
            make.width.mas_equalTo(self.imageWidth);
            make.height.mas_equalTo(self.imageWidth * 251.0f/355.0f);
        }];
    }else if(self.count == 2){
        _imageWidth = (self.bounds.size.width - itemPadding)/2;
        UIView *firstView = self;
        for (UIImageView *imageView in self.imageViewList) {
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self);
                if(firstView == self){
                    make.left.mas_equalTo(firstView);
                    make.bottom.mas_equalTo(firstView);
                }else{
                    make.left.mas_equalTo(firstView.mas_right).offset(itemPadding);
                }
                make.width.mas_equalTo(self.imageWidth);
                make.height.mas_equalTo(self.imageWidth * 124.0f/165.0f);
            }];
            firstView = imageView;
        }
    }else if(self.count >= 3){
        _imageWidth = (self.bounds.size.width - itemPadding * 2)/3;
        UIView *topView = self;
        for (NSInteger i = 0; i < self.imageViewList.count; i++) {
            UIImageView *imageView = self.imageViewList[i];
            NSInteger row = i/3; // 0,1,2
            NSInteger column = i%3; //0,1,2
            CGFloat topMargin = row * _imageWidth + itemPadding * row;
            CGFloat leftMargin = column * _imageWidth + itemPadding * column;
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self).offset(topMargin);
                make.left.mas_equalTo(self).offset(leftMargin);
                make.width.mas_equalTo(self.imageWidth);
                make.height.mas_equalTo(self.imageWidth);
                //整个view的高度到最后一个imageView的底部
                if(i == self.imageViewList.count - 1){
                    make.bottom.mas_equalTo(self);
                }
            }];
        }
    }else{
        
    }
}

- (void)updateImageView:(NSArray *)imageList largeImageList:(NSArray *)largeImageList {
    self.largeImageList = largeImageList;
    
    for (NSInteger i = 0; i < self.imageViewList.count; i++) {
        UIImageView *imageView = self.imageViewList[i];
        if(i < imageList.count){
            FHFeedUGCCellImageListModel *imageModel = imageList[i];
            imageView.hidden = NO;
            CGFloat width = [imageModel.width floatValue];
            CGFloat height = [imageModel.height floatValue];
            [imageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:nil];
            //只对单图做重新布局，多图都是1：1
            if(self.count == 1){
                [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.imageWidth * height/width);
                }];
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
        
        if(imageList.count > self.count){
            self.infoLabel.hidden = NO;
            self.infoLabel.text = [NSString stringWithFormat:@"共%i张",imageList.count];
        }else{
            self.infoLabel.hidden = YES;
        }
    }
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
        FHFeedUGCCellImageListModel *imageModel = self.largeImageList[i];
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:imageModel.uri forKey:kTTImageURIKey];
        [dict setValue:imageModel.url forKey:TTImageInfosModelURL];
        [dict setValue:imageModel.width forKey:kTTImageWidthKey];
        [dict setValue:imageModel.height forKey:kTTImageHeightKey];
        NSMutableArray * urls = [NSMutableArray arrayWithCapacity:10];
        for (FHFeedUGCCellImageListUrlListModel *urlListModel in imageModel.urlList) {
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
            UIImageView *View = self.imageViewList[i];
            //  此处需要优化
            if (View.image) {
                [photoObjs addObject:View.image];
            }
        }
    }
    return photoObjs;
}

@end
