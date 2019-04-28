//
//  FHLazyLoadModel.m
//  AKCommentPlugin
//
//  Created by leo on 2019/4/25.
//

#import "FHLazyLoadModel.h"
#import "JSONModel.h"
@implementation FHLazyLoadModel

+ (instancetype)proxyWithClass:(NSString*)className withData:(NSArray*)data {
    FHLazyLoadModel* result = [FHLazyLoadModel alloc];
    result.className = className;
    result.data = data;
    return result;
}

+ (instancetype)proxyWithObj:(id)object {
    FHLazyLoadModel* result = [FHLazyLoadModel alloc];
    result.ref = object;
    return result;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    [self checkRefExisted];
    return [_ref methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self checkRefExisted];
    if (_ref != nil && [_ref respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:_ref];
    }
}

-(void)checkRefExisted {
    if (_ref == nil) {
        _ref = [[NSMutableArray alloc] initWithCapacity:_data.count];
        [_data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id inst = [[NSClassFromString(_className) alloc] init];
            if ([inst isKindOfClass:[JSONModel class]]) {
                JSONModel* model = (JSONModel*)inst;
                NSError* error;
                [model mergeFromDictionary:obj useKeyMapping:YES error:&error];
                [_ref addObject:model];
            }
        }];
    }
}

@end
