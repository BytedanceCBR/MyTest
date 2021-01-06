//
//  FHOneTouchBackManager.h
//  FHHouseBase
//
//  Created by bytedance on 2021/1/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHOneTouchBackManager : NSObject

+ (instancetype)sharedInstance;

- (void)setButtonWithUrl:(NSURL *)url WithWindow:(UIWindow *)window;

@end

NS_ASSUME_NONNULL_END
