//
//  NSObject+PerformSelector.h
//  TTVPlayer
//
//  Created by lisa on 2019/1/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PerformSelector)
- (id)redux_performSelector:(SEL)aSelector withObjects:(NSArray *)objects;

@end

NS_ASSUME_NONNULL_END
