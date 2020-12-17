//
//  FHNeighborhoodDetailShadowView.m
//  FHHouseDetail
//
//  Created by 谢雷 on 2020/12/9.
//

#import "FHNeighborhoodDetailShadowView.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/Masonry.h>

@implementation FHNeighborhoodDetailShadowView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
//        UIImage *cornerImage = [UIImage fh_roundRectMaskImageWithCornerRadius:10 color:[UIColor whiteColor] size:CGSizeMake(50, 50)];
//        UIImageView *shadowImageView = [[UIImageView alloc] init];
//        shadowImageView.image = [cornerImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
//        [self addSubview:shadowImageView];
//        [shadowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(UIEdgeInsetsZero);
//        }];
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10;
    }
    return self;
}

@end


