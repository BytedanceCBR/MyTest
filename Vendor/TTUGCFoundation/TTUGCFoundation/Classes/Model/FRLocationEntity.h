//
//  FRLocationEntity.h
//  Article
//
//  Created by ZhangLeonardo on 15/7/28.
//
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, FRLocationEntityType) {
    FRLocationEntityTypeNomal = 0,
    FRLocationEntityTypeCity
};
@class FRGeographyStructModel;
@interface FRLocationEntity : NSObject

@property (nonatomic, assign)FRLocationEntityType locationType;
@property (nonatomic, assign)double latitude;
@property (nonatomic, assign)double longitude;
@property (nonatomic, strong)NSString *city;//城市名称
@property (nonatomic, strong)NSString *locationName;//位置名称（poi点名称）
@property (nonatomic, strong)NSString *locationAddress;//详细地理位置，目前服务器端不需要

+ (FRLocationEntity *)genLocationFromStruct:(FRGeographyStructModel *)structModel;

@end
