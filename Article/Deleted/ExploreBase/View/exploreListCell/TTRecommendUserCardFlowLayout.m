//
//  TTRecommendUserCardFlowLayout.m
//  Article
//
//  Created by lipeilun on 2017/9/4.
//
//

#import "TTRecommendUserCardFlowLayout.h"


@implementation TTRecommendUserCardLayoutAttributes

- (id)copyWithZone:(NSZone *)zone {
    TTRecommendUserCardLayoutAttributes *attributes = [super copyWithZone:zone];
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
    
    if ([((TTRecommendUserCardLayoutAttributes *) object) transformAnimation] != [self transformAnimation]) {
        return NO;
    }
    
    return YES;
}

@end

@interface TTRecommendUserCardFlowLayout ()
@end

@implementation TTRecommendUserCardFlowLayout

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
