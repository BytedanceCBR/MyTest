//
//  TFManager.h
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-26.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFManager : NSObject

+ (void)saveTestFlightAccountEmail:(NSString *)email;
+ (NSString *)testFlightAccountEmail;

+ (void)saveTestFlightAccountIdentifier:(NSString *)identifier;
+ (NSString *)testFlightAccountIdentifier;

+ (void)saveIsUserAvailable:(BOOL)userAvailable;
+ (BOOL)testFlightIsAccountUserAvailable;

+ (NSArray *)tfAppInfosModels;
+ (void)saveTFAppInfosModels:(NSMutableArray *)ary;

@end
