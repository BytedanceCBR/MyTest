//
//  TTVPlayerBackgroundManager.h
//  Article
//
//  Created by panxiang on 2017/6/12.
//
//

#import <Foundation/Foundation.h>
typedef void (^ActiveBlock) (void);
@interface TTVPlayerBackgroundManager : NSObject
@property (nonatomic ,assign)BOOL showVideoFirstFrame;
- (void)addDidBecomeActiveBlock:(ActiveBlock)becomeActive willResignActive:(ActiveBlock)resignActive;
@end





