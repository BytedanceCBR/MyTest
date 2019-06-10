//
//  FHUGCCellMultiImageView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHUGCCellMultiImageView.h"
#import "UIColor+Theme.h"
#import <Masonry.h>
#import <UIImageView+BDWebImage.h>
#import "FHFeedUGCCellModel.h"

#define itemPadding 4

@interface FHUGCCellMultiImageView ()

@property(nonatomic, assign) NSInteger count;
@property(nonatomic, strong) NSMutableArray *imageViewList;
@property(nonatomic, assign) CGFloat imageWidth;

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
        [self addSubview:imageView];
        
        [self.imageViewList addObject:imageView];
    }
}

- (void)initConstraints {
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
                make.height.mas_equalTo(self.imageWidth);
            }];
            firstView = imageView;
        }
    }else{
        
    }
}

- (void)updateImageView:(NSArray *)imageList {
    for (NSInteger i = 0; i < self.imageViewList.count; i++) {
        UIImageView *imageView = self.imageViewList[i];
        if(i < imageList.count){
            FHFeedUGCCellImageListModel *imageModel = imageList[i];
            imageView.hidden = NO;
            CGFloat width = [imageModel.width floatValue];
            [imageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:nil];
        }else{
            imageView.hidden = YES;
        }
    }
}

@end
