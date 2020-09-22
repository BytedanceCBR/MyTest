//
//  FHShowVRView.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/22.
//

#import "FHShowVRView.h"
#import "Masonry.h"

@interface FHShowVRView ()

@property (nonatomic, strong) UIImageView *vrIconView;

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
    self.vrIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dingding"]];
    
    [self addSubview:self.vrIconView];
    [self.vrIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(70);
        make.width.mas_equalTo(70);
    }];
}


-(void)showVRIcon {
    [self bringSubviewToFront:self.vrIconView];
}

// 不支持手势放大
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}


@end
