//
//  TTInterfaceTipModel.m
//  Article
//
//  Created by chenjiesheng on 2017/6/23.
//
//

#import "TTInterfaceTipBaseModel.h"
#import "TTInterfaceTipManager.h"
#import <objc/runtime.h>

@interface TTInterfaceTipBaseModel ()

@end

@implementation TTInterfaceTipBaseModel

- (NSString *)interfaceTipViewIdentifier{
    if (_interfaceTipViewIdentifier == nil){
        _interfaceTipViewIdentifier = @"TTInterfaceTipBaseView";
    }
    return _interfaceTipViewIdentifier;
}

- (id)context {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setContext:(id)context {
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setupContextWithDict:(NSDictionary *)dict
{
    self.topHeight = [dict tt_objectForKey:kTTInterfaceContextTopHeightKey];
    self.bottomHeight = [dict tt_objectForKey:kTTInterfaceContextBottomHeightKey];
    self.tabbarHeight = [dict objectForKey:kTTInterfaceContextTabbarHeightKey];
    self.currenSelectedViewController = [dict tt_objectForKey:kTTInterfaceContextCurrentSelectedViewControllerKey];
    self.mineIconView = [dict tt_objectForKey:kTTInterfaceContextMineIconViewKey];
}

#pragma mark -- TTGuideProtocol

- (BOOL)shouldDisplay:(id)context{
    id viewClass = NSClassFromString([self interfaceTipViewIdentifier]);
    if ([viewClass respondsToSelector:NSSelectorFromString(@"shouldDisplayWithContext:")]){
        return [viewClass performSelector:NSSelectorFromString(@"shouldDisplayWithContext:") withObject:context];
    }
    return YES;
}

- (void)showWithContext:(id)context{
    [self.manager showWithModel:self];
}
@end
