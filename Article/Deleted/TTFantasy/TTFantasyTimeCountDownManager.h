//
//  TTFantasyTimeCountDownManager.h
//  Article
//
//  Created by chenren on 2018/01/18.
//

#import <Foundation/Foundation.h>

@interface TTFantasyTimeCountDownManager : NSObject

+ (instancetype)sharedManager;

- (void)fetchFantasyActivityTimes;

- (NSTimeInterval)nextActivityTime;

- (BOOL)isShowingTime;

@end
