//
//  FHBuildingDetailShadowView.m
//  Pods
//
//  Created by bytedance on 2020/7/5.
//

#import "FHBuildingDetailShadowView.h"
#import <Masonry/Masonry.h>
#import <FHHouseBase/UIImage+FIconFont.h>
#import <FHCommonUI/UIColor+Theme.h>

@interface FHBuildingDetailShadowView ()

@property (nonatomic, weak) UIImageView *shadowImageView;

@end

@implementation FHBuildingDetailShadowView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImage *cornerImage = [UIImage fh_outerRoundRectMaskImageWithCornerRadius:10 color:[UIColor whiteColor] size:CGSizeMake(50, 50)];
        UIImageView *shadowImageView = [[UIImageView alloc] init];
        shadowImageView.image = [cornerImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
        [self addSubview:shadowImageView];
        [shadowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
