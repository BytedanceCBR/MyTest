//
//  FHUGCGuideView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/19.
//

#import "FHUGCGuideView.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface FHUGCGuideView ()

@property(nonatomic, assign) FHUGCGuideViewType type;

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UILabel *contentLabel;

@end

@implementation FHUGCGuideView

- (void)show:(UIView *)parentView dismissDelayTime:(NSTimeInterval)delayTime {
    [parentView addSubview:self];
    
    if(delayTime > 0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    }
}

- (void)hide {
    [self removeFromSuperview];
}

- (instancetype)initWithFrame:(CGRect)frame andType:(FHUGCGuideViewType)type {
    self = [super initWithFrame:frame];
    if(self){
        _type = type;
        [self initViews];
    }
    return self;
}

- (void)initViews {
//    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
    self.userInteractionEnabled = NO;
    
    if(self.type == FHUGCGuideViewTypeSearch){
        [self initSearchView];
    }else if(self.type == FHUGCGuideViewTypeSecondTab){
        [self initSecondTabView];
    }
}

- (void)initSearchView {
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.image = [UIImage imageNamed:@"fh_ugc_guide_bg_up"];
    [self addSubview:_imageView];
    
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, self.bounds.size.width - 20, 18)];
    _contentLabel.text = @"点击搜索与你相关的小区圈";
    _contentLabel.textColor = [UIColor whiteColor];
    _contentLabel.font = [UIFont themeFontMedium:13];
    [self addSubview:_contentLabel];
}

- (void)initSecondTabView {
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.image = [UIImage imageNamed:@"fh_ugc_guide_bg_down"];
    [self addSubview:_imageView];
    
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 9, self.bounds.size.width - 20, 16)];
    _contentLabel.text = @"速来围观附近的小区趣事";
    _contentLabel.textColor = [UIColor whiteColor];
    _contentLabel.font = [UIFont themeFontMedium:13];
    [self addSubview:_contentLabel];
}

@end
