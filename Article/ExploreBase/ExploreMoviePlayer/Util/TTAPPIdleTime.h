//
//  TTAPPIdleTime.h
//  Article
//
//  Created by panxiang on 2017/2/17.
//
//

#import <Foundation/Foundation.h>

@interface TTAPPIdleTime : NSObject<Singleton>
- (void)lockScreen:(BOOL)lock later:(BOOL)later;
- (void)lockScreen:(BOOL)lock;
@end
