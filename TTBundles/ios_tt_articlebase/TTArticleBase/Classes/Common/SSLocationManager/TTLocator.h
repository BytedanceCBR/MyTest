//
//  TTLocator.h
//  Article
//
//  Created by SunJiangting on 15-4-29.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TTLocationManager.h"

typedef void (^TTLocateHandler) (CLLocation *location, NSError *error);

@interface TTLocator : NSObject

+ (instancetype)sharedLocator;

- (void)locateWithTimeoutInterval:(NSTimeInterval)timeInterval completionHandler:(TTLocateHandler)completionHandler;

@end