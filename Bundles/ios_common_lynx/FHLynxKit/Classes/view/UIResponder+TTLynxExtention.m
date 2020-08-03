//
//  UIResponder+TTLynxExtention.m
//  TTLynxManager
//
//  Created by jinqiushi on 2019/7/10.
//

#import "UIResponder+TTLynxExtention.h"

@implementation UIResponder (TTLynxExtention)

- (void)lynx_actionWithSel:(SEL)selector param:(nullable id)param completeBlock:(void (^_Nullable)(NSDictionary * _Nullable))completeBlock {
    [[self nextResponder] lynx_actionWithSel:selector param:param completeBlock:completeBlock];
}

- (id)lynx_getResultWithSel:(SEL)selector param:(nullable id)param completeBlock:(void (^_Nullable)(NSDictionary * _Nullable))completeBlock {
    return [[self nextResponder] lynx_getResultWithSel:selector param:param completeBlock:completeBlock];
}


@end
