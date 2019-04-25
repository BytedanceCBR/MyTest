//
//  TTVDetailFollwRecommendCollectionViewFLowLayout.m
//  Article
//
//  Created by lishuangyang on 2017/10/24.
//

#import "TTVDetailFollwRecommendCollectionViewFLowLayout.h"

@implementation TTVDetailFollwRecommendCollectionViewFLowLayoutAttributes

- (id)copyWithZone:(NSZone *)zone {
    TTVDetailFollwRecommendCollectionViewFLowLayoutAttributes *attributes = [super copyWithZone:zone];
    attributes.transformAnimation = _transformAnimation;
    return attributes;
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    
    if (!object ||![[object class] isEqual:[self class]]) {
        return NO;
    }
    
    if ([((TTVDetailFollwRecommendCollectionViewFLowLayoutAttributes *) object) transformAnimation] != [self transformAnimation]) {
        return NO;
    }
    
    return YES;
}

@end

@interface TTVDetailFollwRecommendCollectionViewFLowLayout ()
@end

@implementation TTVDetailFollwRecommendCollectionViewFLowLayout

- (instancetype)init {
    if (self = [super init]) {
        self.index = -1;
    }
    return self;
}

- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attr = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    if (self.index == itemIndexPath.item) {
        attr.transform = CGAffineTransformMakeScale(0.2, 0.2);
        self.index = -1;
    }
    return attr;
}

@end
