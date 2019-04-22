//
//  TTVRelatedItem+TTVComputedProperties.m
//  Article
//
//  Created by pei yun on 2017/6/16.
//
//

#import "TTVRelatedItem+TTVComputedProperties.h"

@implementation TTVRelatedItem (TTVComputedProperties)

- (TTVRelatedVideoAD *)ad
{
    TTVRelatedVideoAD *relatedAD = nil;
    if (self.hasAdPic) {
        relatedAD = self.adPic.ad;
    } else if (self.hasVideoItem) {
        relatedAD = self.videoItem.ad;
    }
    return relatedAD;
}

@end
