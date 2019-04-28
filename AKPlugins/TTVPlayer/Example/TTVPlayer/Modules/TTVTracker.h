//
//  TTVTracker.h
//  Pods
//
//  Created by panxiang on 2018/12/12.
//

#import <Foundation/Foundation.h>

@protocol TTVTracker <NSObject>

@required
+ (void)eventV3:(nonnull NSString *)event params:(nullable NSDictionary *)params;
@end


@interface TTVTracker : NSObject<TTVTracker>
+ (void)configTrackerClass:(Class <TTVTracker>)tracker;
@end

