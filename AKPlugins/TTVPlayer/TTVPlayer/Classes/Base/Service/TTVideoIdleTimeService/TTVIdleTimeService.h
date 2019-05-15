//
//  TTVIdleTimeService.h
//  Article
//
//  Created by liuty on 2017/3/2.
//
//

#import <Foundation/Foundation.h>

@interface TTVIdleTimeService : NSObject

+ (instancetype)sharedService;

- (void)lockScreen:(BOOL)lock;
- (void)lockScreen:(BOOL)lock later:(BOOL)later;

@end
