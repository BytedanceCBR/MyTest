//
//  UIResponder+TTLynxExtention.h
//  TTLynxManager
//
//  Created by jinqiushi on 2019/7/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (TTLynxExtention)

- (void)lynx_actionWithSel:(SEL)selector param:(nullable id)param completeBlock:(void(^ _Nullable)( NSDictionary * _Nullable completeDict))completeBlock;

- (id)lynx_getResultWithSel:(SEL)selector param:(nullable id)param completeBlock:(void(^ _Nullable)(NSDictionary * _Nullable completeDict))completeBlock;

@end

NS_ASSUME_NONNULL_END
