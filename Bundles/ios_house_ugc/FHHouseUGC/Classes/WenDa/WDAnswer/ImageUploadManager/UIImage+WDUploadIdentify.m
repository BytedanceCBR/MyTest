//
//  UIImage+WDUploadIdentify.m
//  WDPublisher
//
//  Created by 延晋 张 on 2018/1/23.
//

#import "UIImage+WDUploadIdentify.h"
#import <objc/runtime.h>

static void *UIImageIdentifyKey = &UIImageIdentifyKey;

@implementation UIImage (WDUploadIdentifier)

- (NSString *)uploadIdentifier
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setUploadIdentifier:(NSString *)uploadIdentifier
{
    objc_setAssociatedObject(self, @selector(uploadIdentifier), uploadIdentifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
