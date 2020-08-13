//
//  FHBlockTransformer.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/7/30.
//

#import "FHBlockTransformer.h"

@interface FHBlockTransformer ()

@property (nonatomic, copy) FHTransformBlock block;

@end

@implementation FHBlockTransformer

- (nonnull NSString *)appendingStringForCacheKey {
    return @"FHBlockTransformer";
}

+ (instancetype)transformWithBlock:(FHTransformBlock)block;
{
    FHBlockTransformer *transformer = [FHBlockTransformer new];
    transformer.block = block;
    return transformer;
}

- (UIImage *)transformImageBeforeStoreWithImage:(UIImage *)image {
    if (self.block) {
        return self.block(image);
    }
    return image;
}

@end
