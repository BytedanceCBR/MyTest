//
//  TTVRelatedVideoADPic+TTVComputedProperties.m
//  Article
//
//  Created by pei yun on 2017/6/4.
//
//

#import "TTVRelatedVideoADPic+TTVComputedProperties.h"
#import <TTVideoService/Common.pbobjc.h>

@implementation TTVRelatedVideoADPic (TTVComputedProperties)

- (BOOL)isValidAd
{
    BOOL validImage = self.ad.middleImage&&[self.ad.middleImage isKindOfClass:[TTVImageUrlList class]];
    BOOL validStr = !isEmptyString(self.article.title)&&!isEmptyString(self.article.source)&&!isEmptyString(self.ad.showTag)&&!isEmptyString(self.ad.webURL)&&!isEmptyString(self.ad.adId);
    return validImage && validStr;
}

@end
