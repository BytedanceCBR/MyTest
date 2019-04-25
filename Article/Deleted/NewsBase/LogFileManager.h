//
//  LogFileManager.h
//  Article
//
//  Created by Dianwei on 13-1-9.
//
//

#import <Foundation/Foundation.h>

@interface LogFileManager : NSObject
+ (id)shareManager;
- (void)appendContent:(NSString*)content;
- (NSString*)contents;
- (void)startSend;
@end
