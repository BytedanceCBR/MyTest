//
//  TTVRelatedItem+TTVConvertToArticle.m
//  Article
//
//  Created by pei yun on 2017/6/13.
//
//

#import "TTVRelatedItem+TTVConvertToArticle.h"
#import <objc/runtime.h>

@implementation TTVRelatedItem (TTVConvertToArticle)

- (void)setSavedConvertedArticle:(Article *)savedConvertedArticle
{
    objc_setAssociatedObject(self, @selector(savedConvertedArticle), savedConvertedArticle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Article *)savedConvertedArticle
{
    return objc_getAssociatedObject(self, @selector(savedConvertedArticle));
}

@end
