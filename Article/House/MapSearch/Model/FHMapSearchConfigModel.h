//
//  FHMapSearchConfigModel.h
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMapSearchConfigModel : JSONModel

@property(nonatomic , strong) NSString *centerLatitude;
@property(nonatomic , strong) NSString *centerLongitude;
@property(nonatomic , assign) NSInteger resizeLevel;
@property(nonatomic , assign) NSInteger houseType;
@property(nonatomic , copy) NSString *originSearchId;
@property(nonatomic , copy) NSString *originFrom;
@property(nonatomic , copy) NSString *elementFrom;
@property(nonatomic , strong) NSDictionary * queryParam;

@end

NS_ASSUME_NONNULL_END
