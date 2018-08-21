//
//  TTUGCBacktraceLogger.h
//  Article
//
//  Created by SongChai on 2017/8/21.
//

@interface TTUGCBacktraceLogger : NSObject

+ (NSString *)ttugc_backtraceOfAllThread;
+ (NSString *)ttugc_backtraceOfCurrentThread;
+ (NSString *)ttugc_backtraceOfMainThread;
+ (NSString *)ttugc_backtraceOfNSThread:(NSThread *)thread;

@end

