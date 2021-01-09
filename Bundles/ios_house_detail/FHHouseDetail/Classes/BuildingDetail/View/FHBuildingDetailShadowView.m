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
        UIImageView *shadowImageView = [[UIImageView alloc] init];
        shadowImageView.image = [[UIImage imageNamed:@"top_left_right_bottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(30,25,30,25) resizingMode:UIImageResizingModeStretch];
        [self addSubview:shadowImageView];
        self.shadowImageView = shadowImageView;
        [shadowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(-5, 0, 0, 0));
        }];
    }
    return self;
}

@end
