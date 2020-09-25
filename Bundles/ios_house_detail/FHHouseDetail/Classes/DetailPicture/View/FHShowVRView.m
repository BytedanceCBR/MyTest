//
//  FHShowVRView.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/22.
//

#import "FHShowVRView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"

@interface FHShowVRView ()

@property (nonatomic, strong) UIImageView *vrIconView;
@property (nonatomic, strong) UIView *maskView;

@end

@implementation FHShowVRView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.vrIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic-movic-vr"]];

    

    
    [self addSubview:self.vrIconView];
    [self.vrIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(70);
        make.width.mas_equalTo(70);
    }];
}


-(void)showVRIcon {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        [self.largeImageView addSubview:self.maskView];
        [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self.largeImageView);
        }];
    }
    [self bringSubviewToFront:self.vrIconView];
}

// 不支持手势放大
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}


@end
