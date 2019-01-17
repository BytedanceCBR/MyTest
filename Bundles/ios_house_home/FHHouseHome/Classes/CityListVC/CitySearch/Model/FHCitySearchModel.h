//
//  FHCitySearchModel.h
//  FHHouseHome
//
//  Created by 张元科 on 2018/12/26.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "FHBaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHCitySearchDataDataModel<NSObject>

@end


@interface  FHCitySearchDataDataModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *cityId;
@property (nonatomic, copy , nullable) NSString *fullPinyin;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *simplePinyin;

@end


@interface  FHCitySearchDataModel  : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHCitySearchDataDataModel> *data;

@end


@interface  FHCitySearchModel  : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHCitySearchDataModel *data ;

@end


NS_ASSUME_NONNULL_END
