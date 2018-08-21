//
//  MoJiSDK.h
//  MoJiSDK
//
//  Created by 刘 超 on 13-1-28.
//  Copyright (c) 2013年 Moji.China. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MoJiDelegate <NSObject>

- (void)initializeSuccess;
- (void)initializeFailedWithStateCode:(int) stateCode;

@end

@class MojiSdkDelegate;
@class WeatherConciseView;

@interface MoJiSdk : NSObject{
    MojiSdkDelegate * sdkDelegate;
    WeatherConciseView * _conciseView;
    id<MoJiDelegate> mojiDelegate;
    
}
@property (nonatomic, retain) MojiSdkDelegate *sdkDelegate;
@property (nonatomic, assign) id<MoJiDelegate> mojiDelegate;
/*
 作用：获取MojiSdk类的实例
 参数：NULL
 返回值：MojiSdk类的实例
 */
+(MoJiSdk *)sdkInstance;

/*
 作用：初始化sdk
 参数：@appKey: 分配给sdk调用方的key
 返回值：NULL
 */
-(void)initialize: (NSString *)appKey MoJiDelegate:(id<MoJiDelegate>) delegate;


/*
 作用：获取精简天气视图
 参数：assistCityName 辅助定位用城市名,只有在手机自身定位失败时才会使用
 返回值：精简天气视图,在认证失败时,返回为nil;
 */
-(UIView *)getConciseView:(NSString*) assistCityName;

/*
 作用：刷新天气数据
 参数：assistCityName 辅助定位用城市名,只有在手机自身定位失败时才会使用
 返回值：NULL
 */
-(void)updateWeather:(NSString*) assistCityName;

/*
 作用：判断是否认证成功
 参数：NULL
 返回值：YES为成功
 */
- (BOOL)isAuthSuccess;


/*
 作用：是否为夜间模式
 参数：NULL
 返回值：YES为夜间模式
 */
- (BOOL)isNightMode;

/*
 作用：设置夜间模式
 参数：YES:设置成夜间模式.NO为日间模式
 返回值：void
 */
- (void)setNightMode:(BOOL) isNightMode;

@end


