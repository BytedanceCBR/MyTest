//
//  TTVPartnerVideo+TTVVideoDetailNatantViewDataProtocolSupport.m
//  Article
//
//  Created by pei yun on 2017/5/26.
//
//

#import "TTVPartnerVideo+TTVVideoDetailNatantViewDataProtocolSupport.h"
#import <objc/runtime.h>

@implementation TTVPartnerVideo (TTVVideoDetailNatantViewDataProtocolSupport)

- (NSString *)appName
{
    return objc_getAssociatedObject(self, @selector(appName));
}

- (void)setAppName:(NSString *)appName
{
   objc_setAssociatedObject(self, @selector(appName), appName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
