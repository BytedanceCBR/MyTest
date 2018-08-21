//
//  TTImagePickerTrackDelegate.h
//  Article
//
//  Created by tyh on 2017/4/25.
//
//

#import <Foundation/Foundation.h>

#import "TTImagePickerTrackManager.h"

@interface TTImagePickerTrackDelegate : NSObject<TTImagePickTrackDelegate>

- (instancetype)initWithEventName:(NSString *)eventName TrackDic:(NSDictionary *)ssTrackDict;

@end
