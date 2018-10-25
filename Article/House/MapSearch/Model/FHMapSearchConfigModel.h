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

@end

NS_ASSUME_NONNULL_END
