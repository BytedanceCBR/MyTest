//
//  TTVFeedItem+TTVConvertToArticle.m
//  Article
//
//  Created by pei yun on 2017/4/11.
//
//

#import "TTVFeedItem+TTVConvertToArticle.h"
#import <libextobjc/extobjc.h>
#import "TTVArticleProtocol.h"
#import <Mantle/MTLReflection.h>
#import "TTVFeedItem+Extension.h"
#import "TTVUserInfo+Extension.h"
#import "TTVVideoArticle+Extension.h"
#import "TTVImageUrlList+Extension.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import <objc/runtime.h>

NSArray *ttv_propertyNamesInProtocol(NSString *protocolName)
{
    static NSMutableDictionary *ttv_properties = nil;
    if (!ttv_properties) {
        ttv_properties = [NSMutableDictionary dictionary];
    }
    if ([ttv_properties valueForKey:protocolName]) {
        return [ttv_properties valueForKey:protocolName];
    }
    Protocol *protocol = objc_getProtocol([protocolName UTF8String]);
    unsigned int count = 0;
    objc_property_t *properties = protocol_copyPropertyList(protocol, &count);
    NSMutableArray *propertyNames = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        if (propertyName) {
            [propertyNames addObject:propertyName];
        }
    }
    free(properties);
    [ttv_properties setValue:propertyNames forKey:protocolName];
    return propertyNames;
}

@implementation TTVFeedItem (TTVConvertToArticle)

- (void)setSavedConvertedArticle:(Article *)savedConvertedArticle
{
   objc_setAssociatedObject(self, @selector(savedConvertedArticle), savedConvertedArticle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Article *)savedConvertedArticle
{
   return objc_getAssociatedObject(self, @selector(savedConvertedArticle));
}

@end

@implementation Article (TTVConvertFromFeedItem)

- (void)setConvertedFromFeedItem:(BOOL)convertedFromFeedItem
{
   objc_setAssociatedObject(self, @selector(convertedFromFeedItem), @(convertedFromFeedItem), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)convertedFromFeedItem
{
   return [objc_getAssociatedObject(self, @selector(convertedFromFeedItem)) boolValue];
}

@end


