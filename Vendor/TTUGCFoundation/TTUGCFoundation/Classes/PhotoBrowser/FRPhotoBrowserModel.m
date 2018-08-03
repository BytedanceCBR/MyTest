//
//  FRPhotoBrowserModel.m
//  Article
//
//  Created by 王霖 on 17/1/19.
//
//

#import "FRPhotoBrowserModel.h"
#import "FRImageInfoModel.h"

@interface FRPhotoBrowserModel ()

@end

@implementation FRPhotoBrowserModel

- (instancetype)initWithImageInfosModel:(FRImageInfoModel *)imageInfosModel
                       placeholderImage:(nullable UIImage *)placeholderImage
                          originalFrame:(nullable NSValue *)originalFrame {
    self = [super init];
    if (self) {
        NSAssert(imageInfosModel!=nil, @"Image infos model can not be nil!");
        self.imageInfosModel = imageInfosModel;
        self.placeholderImage = placeholderImage;
        self.originalFrame = originalFrame;
    }
    return self;
}


@end
