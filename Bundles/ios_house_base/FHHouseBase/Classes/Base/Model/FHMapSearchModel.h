//
//  FHMapSearchModel.h
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "FHBaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHMapSearchDataListModel<NSObject>

@end


@interface  FHMapSearchDataListLogPbModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *searchId;

@end


@interface  FHMapSearchDataListModel  : JSONModel

@property (nonatomic, strong , nullable) FHMapSearchDataListLogPbModel *logPb ;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *centerLatitude;
@property (nonatomic, copy , nullable) NSString *centerLongitude;
@property (nonatomic, copy , nullable) NSString *longitude;
@property (nonatomic, copy , nullable) NSString *pricePerSqm;
@property (nonatomic, copy , nullable) NSString *location;
@property (nonatomic, copy , nullable) NSString *onSaleCount;
@property (nonatomic, copy , nullable) NSString *houseListOpenUrl;
@property (nonatomic, copy , nullable) NSString *latitude;
@property (nonatomic, copy , nullable) NSString *mapFindHouseOpenUrl;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *nid;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSString *path;
@property (nonatomic, strong , nullable) NSArray *coordinateEnclosure;

@end


@interface  FHMapSearchDataModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *mapFindHouseOpenUrl;
@property (nonatomic, copy , nullable) NSString *tips;
@property (nonatomic, strong , nullable) NSArray<FHMapSearchDataListModel> *list;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *houseListOpenUrl;
@property (nonatomic, copy , nullable) NSArray<NSString *> *path;
@end


@interface  FHMapSearchModel  : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHMapSearchDataModel *data ;

@end


NS_ASSUME_NONNULL_END
