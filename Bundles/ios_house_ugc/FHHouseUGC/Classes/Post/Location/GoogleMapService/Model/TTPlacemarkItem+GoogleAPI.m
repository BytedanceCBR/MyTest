//
//  TTPlacemarkItem+GoogleAPI.m
//  TTPostThread
//
//  Created by Vic on 2018/11/25.
//

#import "TTPlacemarkItem+GoogleAPI.h"

#import <objc/runtime.h>

@implementation TTPlacemarkItem (GoogleAPI)

//@property (nonatomic, copy) NSArray *locationTags;

- (void)setType:(PlacemarkItemType)type {
    objc_setAssociatedObject(self, @selector(type), @(type), OBJC_ASSOCIATION_ASSIGN);
}

- (PlacemarkItemType)type {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setCountry:(NSString *)country {
    objc_setAssociatedObject(self, @selector(country), country, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)country {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setName:(NSString *)name {
    objc_setAssociatedObject(self, @selector(name), name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)name {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLocationTags:(NSArray *)locationTags {
    objc_setAssociatedObject(self, @selector(locationTags), locationTags, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSArray *)locationTags {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)iskindOfLocality {
    for (NSString *tag in self.locationTags) {
        if ([tag isEqualToString:@"locality"] ||
            [tag isEqualToString:@"sublocality"] ||
            [tag isEqualToString:@"country"] ||
            [tag containsString:@"administrative_area_level_"]) {
            return YES;
        }
    }
    return NO;
}

@end
