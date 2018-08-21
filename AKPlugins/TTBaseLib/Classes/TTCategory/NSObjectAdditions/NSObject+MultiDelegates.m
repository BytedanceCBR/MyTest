//
//  NSObject+MultiDelegates.m
//  Article
//
//  Created by yuxin on 3/3/16.
//
//

#import "NSObject+MultiDelegates.h"
@import ObjectiveC;



#pragma mark WeakObj

@interface TTWeakObj : NSObject
@property (nonatomic,weak) NSObject * targetObject;
@end

@implementation TTWeakObj
@end
 

#pragma mark TTProxyDelegate


@interface TTProxyDelegate : NSProxy

@property(nonatomic, weak) NSObject * mainDelegate;
@property(nonatomic, strong) NSMutableArray * delegates;

@end

@implementation TTProxyDelegate


- (instancetype)init
{
    self.delegates = [NSMutableArray array];
    return self;
}

- (void)addDelegate:(id)delegate {
    
    for (TTWeakObj * weakObj in self.delegates) {
        if ([weakObj.targetObject isEqual:delegate]) {
            
            return;
        }
    }
    
    TTWeakObj * weakObj = [TTWeakObj new];
    weakObj.targetObject = delegate;
    [self.delegates addObject:weakObj];
}

- (void)removeDelegate:(id)delegate {
    
    if ([self.mainDelegate isEqual:delegate]) {
        self.mainDelegate = nil;
    }
    for (TTWeakObj * weakObj in self.delegates) {
        if ([weakObj.targetObject isEqual:delegate]) {
            [self.delegates removeObject:weakObj];
            break;
        }
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    BOOL hasReturn = ![[NSString stringWithCString:invocation.methodSignature.methodReturnType encoding:NSUTF8StringEncoding] isEqualToString:@"v"];
    
    if([_mainDelegate respondsToSelector:invocation.selector])
    {
        [invocation invokeWithTarget:_mainDelegate];
        if(hasReturn)
        {
            return;
        }
    }
    
    // if has return value, use its first delegate as its return value
    for(TTWeakObj *weakObject in _delegates)
    {
        if ([weakObject.targetObject isEqual:_mainDelegate]) {
            continue;
        }
        if([weakObject.targetObject respondsToSelector:invocation.selector])
        {
            [invocation invokeWithTarget:weakObject.targetObject];
            if(hasReturn)
            {
                break;
            }
        }
    }
    
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL result = NO;
    if([_mainDelegate respondsToSelector:aSelector])
    {
        result = YES;
    }
    else
    {
        for(TTWeakObj *weakObject in _delegates)
        {
            result = [weakObject.targetObject respondsToSelector:aSelector];
            if(result)
            {
                break;
            }
        }
    }
    
    return result;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *signature = [[_mainDelegate class] instanceMethodSignatureForSelector:sel];
    if(!signature)
    {
        for(TTWeakObj *weakObject in _delegates)
        {
            signature = [[weakObject.targetObject class] instanceMethodSignatureForSelector:sel];
            if(signature)
            {
                break;
            }
        }
    }
    //添加一个默认返回 防止crash
    if (!signature) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return signature;
}

@end



#pragma mark NSObject (MultiDelegates)

@implementation NSObject (MultiDelegates)



-(BOOL)tt_addDelegate:(id)delegate asMainDelegate:(BOOL)asMain {
    if ([self respondsToSelector:@selector(setDelegate:)]) {
        
        if (!self.ttProxyDelegate) {
            self.ttProxyDelegate = [[TTProxyDelegate alloc] init];
            
            id defaultDelegate = [self performSelector:@selector(delegate)];
            if (defaultDelegate) {
                self.ttProxyDelegate.mainDelegate = defaultDelegate;
            }
            else {
                self.ttProxyDelegate.mainDelegate = delegate;
            }
        }
        
        if (asMain) {
            self.ttProxyDelegate.mainDelegate = delegate;
        }
        
        [self.ttProxyDelegate addDelegate:delegate];
        [self performSelector:@selector(setDelegate:) withObject:self.ttProxyDelegate];
        
        return YES;
    }
    return NO;
}

-(BOOL)tt_removeDelegate:(id)deldegate {
    
    if ([self respondsToSelector:@selector(setDelegate:)]) {
        if (self.ttProxyDelegate) {
            [self.ttProxyDelegate removeDelegate:deldegate];
            return YES;
        }
        else {
            return NO;
        }

    }
    return NO;
}

- (void)tt_removeAllDelegates {
    if ([self respondsToSelector:@selector(setDelegate:)]) {
        if (self.ttProxyDelegate) {
            NSObject *newObject = [[NSObject alloc] init];
            self.ttProxyDelegate.mainDelegate = newObject;
        }
        [self performSelector:@selector(setDelegate:) withObject:nil];
    }
}

#pragma mark Getters/Setters
- (TTProxyDelegate*)ttProxyDelegate {
    
    return (TTProxyDelegate*)objc_getAssociatedObject(self, @selector(ttProxyDelegate));
}

- (void)setTtProxyDelegate:(TTProxyDelegate *)ttProxyDelegate {
    
    objc_setAssociatedObject(self, @selector(ttProxyDelegate),ttProxyDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
