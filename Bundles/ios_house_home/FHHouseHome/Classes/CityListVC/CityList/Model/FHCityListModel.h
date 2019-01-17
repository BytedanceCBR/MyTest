//
//  FHCityListModel.h
//  FHHouseHome
//
//  Created by 张元科 on 2018/12/26.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "FHBaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHistoryCityListModel<NSObject>

@end

@interface  FHHistoryCityListModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *simplePinyin;
@property (nonatomic, copy , nullable) NSString *cityId;
@property (nonatomic, copy , nullable) NSString *pinyin;

@end

@interface FHHistoryCityCacheModel : JSONModel

@property (nonatomic, strong)   NSArray<FHHistoryCityListModel>       *datas;

@end

NS_ASSUME_NONNULL_END
