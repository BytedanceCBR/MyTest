//
//  FHHouseLeftImageView.m
//  ABRInterface
//
//  Created by bytedance on 2020/11/9.
//

#import "FHHouseLeftImageView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import "FHImageModel.h"
#import <BDWebImage/UIImageView+BDWebImage.h>


@implementation FHHouseLeftImageView

+ (instancetype)squareImageView {
    FHHouseLeftImageView *imageView = [[FHHouseLeftImageView alloc] initWithFrame:CGRectMake(0, 0, 84, 84)];
    imageView.layer.cornerRadius = 4;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 0.5;
    imageView.layer.borderColor = [UIColor themeGray7].CGColor;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    return imageView;
}

- (void)setImageModel:(FHImageModel *)imageModel {
    UIImage *placeholderImage = [UIImage imageNamed:@"house_cell_placeholder_square"];
    NSURL *imgUrl = imageModel.url && imageModel.url.length ? [NSURL URLWithString:imageModel.url] : nil;
    if (imgUrl) {
        [self bd_setImageWithURL:imgUrl placeholder:placeholderImage];
    } else {
        self.image = placeholderImage;
    }
}

@end
