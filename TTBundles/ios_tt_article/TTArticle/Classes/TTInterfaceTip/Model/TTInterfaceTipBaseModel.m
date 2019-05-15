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


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dialogPriority = TTDialogPriorityNormal;
    }
    return self;
}

- (NSString *)interfaceTipViewIdentifier{
    if (_interfaceTipViewIdentifier == nil){
        _interfaceTipViewIdentifier = @"TTInterfaceTipBaseView";
    }
    return _interfaceTipViewIdentifier;
}

- (id)context {
    NSDictionary *context = objc_getAssociatedObject(self, _cmd);
    if (context == nil){
        context = [NSDictionary dictionaryWithObject:self forKey:@"model"];
    }else if ([context isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:context];
        [dict setValue:self forKey:@"model"];
        context = [dict copy];
    }
    return context;
}

- (void)setContext:(id)context {
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)needShowAfterMainListDidAppear
{
    return NO;
}

#pragma mark -- TTGuideProtocol

- (BOOL)shouldDisplay:(id)context
{
    id viewClass = NSClassFromString([self interfaceTipViewIdentifier]);
    if ([viewClass respondsToSelector:NSSelectorFromString(@"shouldDisplayWithContext:")]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [viewClass performSelector:NSSelectorFromString(@"shouldDisplayWithContext:") withObject:context];
#pragma clang diagnostic pop
    }
    return YES;
}

- (void)showWithContext:(id)context
{
    [self.manager showWithModel:self withDialogDirector:YES];
}

- (void)setupContextWithDict:(NSDictionary *)dict
{
    
}

- (BOOL)checkShouldDisplay
{
    BOOL shouldDisplay = YES;
    id viewClass = NSClassFromString([self interfaceTipViewIdentifier]);
    if ([viewClass respondsToSelector:NSSelectorFromString(@"shouldDisplayWithModel:")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        shouldDisplay = [viewClass performSelector:NSSelectorFromString(@"shouldDisplayWithModel:") withObject:self];
#pragma clang diagnostic pop
    }
    if (!shouldDisplay && [self needShowAfterMainListDidAppear]) {
        [TTInterfaceTipManager setupShowAfterMainListDidShowWithTipModel:self];
    }
    return shouldDisplay;
}

@end
