//
//  SSLocationPickerController.h
//  STKitDemo
//
//  Created by SunJiangting on 15-2-27.
//  Copyright (c) 2015年 SunJiangting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SSLocationPickerController : UIViewController

@property(nonatomic, strong) void(^completionHandler)(SSLocationPickerController *);

+ (CLLocationCoordinate2D)cachedFakeLocationCoordinate;
@end

@interface NSArray (STAccessor)

- (NSUInteger)firstIndexOfClass:(Class)aClass;

- (id)firstObjectOfClass:(Class)aClass;

- (NSArray *)objectsOfClass:(Class)aClass;

@end


extern NSString *const SSFakeLocationCoordinateCacheKey;