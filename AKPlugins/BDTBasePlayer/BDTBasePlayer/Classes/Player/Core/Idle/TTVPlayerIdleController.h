//
//  TTVPlayerIdleController.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import <Foundation/Foundation.h>

@interface TTVPlayerIdleController : NSObject

+ (TTVPlayerIdleController *)sharedInstance;
- (void)lockScreen:(BOOL)lock later:(BOOL)later;
- (BOOL)isLock;
@end
