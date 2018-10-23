//
//  DebugUmengIndicator.h
//  Article
//
//  Created by Dianwei on 14-6-10.
//
//

#import <Foundation/Foundation.h>

@interface DebugUmengIndicator : NSObject
+ (instancetype)sharedIndicator;
- (void)addDisplayString:(NSString*)string;
- (void)startDisplay;
- (void)stopDisplay;
+ (BOOL)displayUmengISOn;
+ (void)setDisplayUmengIsOn:(BOOL)set;
@end
