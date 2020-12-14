//
//  FHFlutterChannels.h
//  ABRInterface
//
//  Created by 谢飞 on 2020/9/6.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>


NS_ASSUME_NONNULL_BEGIN

@interface FHFlutterChannels : NSObject

+ (instancetype)sharedInstance;

+ (void)processChannelsImp:(FlutterMethodCall *)call callback:(FlutterResult)resultCallBack;


@end

NS_ASSUME_NONNULL_END
