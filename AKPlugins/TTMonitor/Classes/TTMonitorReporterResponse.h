//
//  TTMonitorReporterResponse.h
//  Pods
//
//  Created by 苏瑞强 on 2017/7/20.
//
//

#import <Foundation/Foundation.h>

@interface TTMonitorReporterResponse : NSObject

@property (nonatomic, assign) BOOL serverCrashed;
@property (nonatomic, strong) NSError * error;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, assign) BOOL hasResponse;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) NSDictionary * uploadDebugrealCommands;
@property (nonatomic, strong) NSDictionary * uploadFileCommands;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
