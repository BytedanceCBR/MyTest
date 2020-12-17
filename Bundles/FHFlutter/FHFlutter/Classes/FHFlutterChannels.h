//
//  FHFlutterChannels.h
//  ABRInterface
//
//  Created by 谢飞 on 2020/9/6.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@class FHHouseDetailContactViewModel;
@class FHNeighborhoodDetailViewModel;
NS_ASSUME_NONNULL_BEGIN

@interface FHFlutterChannels : NSObject

+ (instancetype)sharedInstance;

+ (void)processChannelsImp:(FlutterMethodCall *)call callback:(FlutterResult)resultCallBack;

- (void)updateTempNeighborhoodViewModel:(FHNeighborhoodDetailViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
