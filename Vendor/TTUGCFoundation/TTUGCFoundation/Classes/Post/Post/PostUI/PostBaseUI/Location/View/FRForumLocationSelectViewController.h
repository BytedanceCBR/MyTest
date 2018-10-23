//
//  FRForumLocationSelectViewController.h
//  Article
//
//  Created by 王霖 on 15/7/13.
//
//

#import <UIKit/UIKit.h>
#import "TTPlacemarkItemProtocol.h"

@class FRLocationEntity;

typedef void(^TTSelectedLocationCompletion)(FRLocationEntity *_Nullable location, BOOL dismiss);

@interface FRForumLocationSelectViewController : UIViewController
@property(nonatomic, strong, nullable) NSString * concernId;
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
-(instancetype _Nonnull)initWithSelectedLocation:(FRLocationEntity* _Nullable)location placemarks:(NSArray<id<TTPlacemarkItemProtocol>>* _Nullable)placemarks completionHandle:(TTSelectedLocationCompletion _Nullable)completion NS_DESIGNATED_INITIALIZER;

@end
