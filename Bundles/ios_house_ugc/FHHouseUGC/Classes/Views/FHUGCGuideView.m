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
#import "UIViewAdditions.h"
#import "FHUGCConfig.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface FHUGCGuideView ()

@property(nonatomic, assign) FHUGCGuideViewType type;

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UILabel *contentLabel;

@property(nonatomic, strong) UILabel *focusLabel;
@property(nonatomic, strong) UILabel *knowLabel;

@end

@implementation FHUGCGuideView

- (void)show:(UIView *)parentView dismissDelayTime:(NSTimeInterval)delayTime completion:(void (^)(void))completion {
    [parentView addSubview:self];
    
    if(delayTime > 0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
            if(completion){
                completion();
            }
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
    if(self.type == FHUGCGuideViewTypeSearch){
        self.userInteractionEnabled = NO;
        [self initSearchView];
    }else if(self.type == FHUGCGuideViewTypeSecondTab){
        self.userInteractionEnabled = NO;
        [self initSecondTabView];
    }else{
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
        [self addGestureRecognizer:tapGesture];
        
        [self initDetailView];
    }
}

- (void)initSearchView {
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.image = [UIImage imageNamed:@"fh_ugc_guide_bg_up"];
    [self addSubview:_imageView];
    
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, self.bounds.size.width - 20, 18)];
    _contentLabel.text = [[FHUGCConfig sharedInstance] searchLeadSuggest] ? [[FHUGCConfig sharedInstance] searchLeadSuggest] : @"点击搜索你感兴趣的圈子";
    _contentLabel.textColor = [UIColor whiteColor];
    _contentLabel.font = [UIFont themeFontMedium:13];
    [self addSubview:_contentLabel];
}

- (void)initSecondTabView {
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.image = [UIImage imageNamed:@"fh_ugc_guide_bg_down"];
    [self addSubview:_imageView];
    
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 9, self.bounds.size.width - 20, 16)];
    _contentLabel.text = [[FHUGCConfig sharedInstance] secondTabLeadSuggest] ? [[FHUGCConfig sharedInstance] secondTabLeadSuggest] : @"速来围观附近的小区趣事";
    _contentLabel.textColor = [UIColor whiteColor];
    _contentLabel.font = [UIFont themeFontMedium:13];
    [self addSubview:_contentLabel];
}

- (void)initDetailView {
    
//    UIImageView *knowBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 110, 36)];
//    knowBgView.image = [UIImage imageNamed:@"fh_ugc_guide_kown_bg"];
//    [self addSubview:knowBgView];
//
//    knowBgView.bottom = self.bottom - 100;
//    knowBgView.centerX = self.centerX;
//
//    self.knowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 56, 20)];
//    _knowLabel.text = @"我知道了";
//    _knowLabel.textAlignment = NSTextAlignmentCenter;
//    _knowLabel.textColor = [UIColor whiteColor];
//    _knowLabel.font = [UIFont themeFontRegular:14];
//    [self addSubview:_knowLabel];
//
//    _knowLabel.centerY = knowBgView.centerY;
//    _knowLabel.centerX = knowBgView.centerX;
    
    self.focusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 58, 26)];
    _focusLabel.backgroundColor = [UIColor whiteColor];
    _focusLabel.text = @"关注";
    _focusLabel.textColor = [UIColor themeRed1];
    _focusLabel.font = [UIFont themeFontRegular:12];
    _focusLabel.textAlignment = NSTextAlignmentCenter;
    _focusLabel.layer.masksToBounds =YES;
    _focusLabel.layer.cornerRadius = 4;
    [self addSubview:_focusLabel];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 202, 42)];
    _imageView.image = [UIImage imageNamed:@"fh_ugc_guide_bg_detail_up"];
    [self addSubview:_imageView];
    
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 182, 18)];
    _contentLabel.text = [[FHUGCConfig sharedInstance] ugcDetailLeadSuggest] ? [[FHUGCConfig sharedInstance] ugcDetailLeadSuggest] : @"关注圈子，不错过小区新鲜事";
    _contentLabel.textColor = [UIColor whiteColor];
    _contentLabel.font = [UIFont themeFontMedium:13];
    [self addSubview:_contentLabel];
}

- (void)setFocusBtnTopY:(CGFloat)focusBtnTopY {
    _focusLabel.right = self.right - 20;
    _focusLabel.top = self.top + focusBtnTopY;
    
    _imageView.top = _focusLabel.bottom + 10;
    _imageView.right = self.right - 10;
    
    _contentLabel.top = _imageView.top + 15;
    _contentLabel.left = _imageView.left + 10;
}

- (void)click {
    if(self.clickBlock){
        self.clickBlock();
    }
}

@end
