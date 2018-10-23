//
//  TSVDebugInfoConfig.h
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 05/12/2017.
//

#import <Foundation/Foundation.h>

@interface TSVDebugInfoConfig : NSObject

+ (instancetype)config;

@property (nonatomic, assign) BOOL debugInfoEnabled;

@end
