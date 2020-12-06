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
@property(nonatomic , copy) NSString *searchId;
@property(nonatomic , copy) NSString *originFrom;
@property(nonatomic , copy) NSString *elementFrom;
@property(nonatomic , copy) NSString *enterFrom;
@property(nonatomic , copy) NSString *enterCategory;
@property(nonatomic , strong) NSDictionary * conditionParams;
@property(nonatomic , strong) NSArray * houseTypeArray;
@property(nonatomic , copy) NSString * houseTypeList;
@property(nonatomic , copy) NSString *suggestionParams;
@property(nonatomic , copy) NSString *mapOpenUrl;
@property(nonatomic , assign) BOOL enterFromList;
@property (nonatomic, copy) NSArray *neighborhoodId;

@property(nonatomic , copy) NSString *conditionQuery;//conditaionParams转换成的query

-(NSString *)houseTypeName;

@end

NS_ASSUME_NONNULL_END
