//
//  TTArticleDetailMonitor.h
//  Article
//
//  Created by muhuai on 2017/7/30.
//
//

#import <Foundation/Foundation.h>

@interface TTArticleDetailMonitor : NSObject

@property (nonatomic, assign) CFTimeInterval webRequestStartTime;
@property (nonatomic, strong) NSMutableDictionary *serverRequestStartTimeDict;

- (void)initializeWebRequestTimeMonitor;
- (void)initializeServerRequestTimeMonitorWithName:(NSString *)apiName;
- (NSString *)intervalFromWebRequestStartTime;
- (NSString *)intervalFromServerRequestStartTimeWithName:(NSString *)apiName;

@end
