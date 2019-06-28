//
//  FRForumLocationSelectViewController.h
//  Article
//
//  Created by 王霖 on 15/7/13.
//
//

#import <UIKit/UIKit.h>
#import <TTLocationManager/TTLocationManager.h>

@class FRLocationEntity;

typedef void(^TTSelectedLocationCompletion)(FRLocationEntity *_Nullable location, BOOL dismiss);

@interface FRForumLocationSelectViewController : UIViewController
@property(nonatomic, copy, nullable) NSString * concernId;
@property(nonatomic, copy, nullable) NSString * categoryID;
@property(nonatomic, copy, nullable)NSDictionary *trackDic;
/**
 *  指定初始化器
 *
 *  @param location   已经选择的地理位置
 *  @param placemarks 最新的地理位置
 *  @param completion 选择地理位置回调
 *
 *  @return FRForumLocationSelectViewController实例
 */
-(instancetype _Nonnull)initWithSelectedLocation:(FRLocationEntity * _Nullable)location placemarks:(NSArray <TTPlacemarkItem *> * _Nullable)placemarks completionHandle:(TTSelectedLocationCompletion _Nullable)completion NS_DESIGNATED_INITIALIZER;

/**
 指定初始化器，选择是否隐藏定位

 @param location 已经选择的地理位置
 @param placemarks 最新的地理位置
 @param isHideNilLocationCell 是否隐藏 不选地址cell
 @param completion 选择地址回调
 @return 实例
 */
-(instancetype _Nonnull)initWithSelectedLocation:(FRLocationEntity * _Nullable)location placemarks:(NSArray <TTPlacemarkItem *> * _Nullable)placemarks hideNilLocationCell:(BOOL)isHideNilLocationCell completionHandle:(TTSelectedLocationCompletion _Nullable)completion;

+ (BOOL)locationServiceAvailable;

@end
