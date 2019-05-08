//
//  TTAdDetailViewUtil.m
//  Article
//
//  Created by carl on 2017/6/22.
//
//

#import "TTAdDetailViewUtil.h"
#import "ArticleDetailADModel.h"
#import "TTDeviceHelper.h"

@implementation TTAdDetailViewUtil

+ (CGFloat)imageFitHeight:(ArticleDetailADModel *)adModel width:(CGFloat) width {
    if (adModel.imageWidth * width == 0) {
        return 0.0;
    }
    CGFloat imageHeight = width * (adModel.imageHeight / adModel.imageWidth);
    imageHeight = ceilf(imageHeight);
    return imageHeight;
}

+ (CGSize)imgSizeForViewWidth:(CGFloat)width {
    CGFloat iPhone6ScreenWidth = 375.f;
    CGFloat cellW = MIN(width, iPhone6ScreenWidth);
    float picOffsetX = 4.f;
    CGFloat w = (cellW - (([TTDeviceHelper isPadDevice]) ? 20 : 15) - (([TTDeviceHelper isPadDevice]) ? 20 : 15) - picOffsetX * 2)/3;
    CGFloat h = w * (124.f / 190.f);
    w = ceilf(w);
    h = ceilf(h);
    return CGSizeMake(w, h);
}

@end

