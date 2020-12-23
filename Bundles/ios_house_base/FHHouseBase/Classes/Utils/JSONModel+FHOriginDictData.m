//
//  JSONModel+FHOriginDictData.m
//  FHHouseBase
//
//  Created by bytedance on 2020/12/23.
//

#import "JSONModel+FHOriginDictData.h"
#import <objc/runtime.h>

@implementation JSONModel (FHOriginDictData)

- (NSDictionary *)fhOriginDictData {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFhOriginDictData:(NSDictionary *)fhOriginDictData {
    objc_setAssociatedObject(self, @selector(fhOriginDictData), fhOriginDictData, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
