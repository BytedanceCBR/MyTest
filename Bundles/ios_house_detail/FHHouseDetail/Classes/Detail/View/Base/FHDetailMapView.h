//
//  FHDetailMapView.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/12.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <MAMapKit/MAAnnotationView.h>
#import <AMapSearchKit/AMapSearchKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailMapView : NSObject

// 单例
+ (instancetype)sharedInstance;
// 清空标注点(自定义的annotation点)
- (void)clearAnnotationDatas;
// 获取mapView，只有一个实例，使用方需要weak的方式引入
- (MAMapView *)defaultMapView;
- (MAMapView *)defaultMapViewWithFrame:(CGRect)mapFrame;
- (MAMapView *)defaultMapViewWithPoint:(CLLocationCoordinate2D)center frame:(CGRect)mapFrame;
// 位置和周边
- (MAMapView *)nearbyMapviewWithFrame:(CGRect)mapFrame;
- (void)resetDetailMapView;
@end

NS_ASSUME_NONNULL_END
