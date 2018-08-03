//
//  TTMonitor+AppLog.h
//  Article
//
//  Created by 苏瑞强 on 16/9/6.
//
//

#import "TTMonitor.h"

@interface TTMonitor (AppLog)

-(void)trackAppLogWithTag:(NSString *)tag label:(NSString *)label;

-(void)trackAppLogWithTag:(NSString *)tag label:(NSString *)label extraValue:(NSDictionary *)extra;
@end
