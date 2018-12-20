//
//  FHSearchConfigModel.h
//  FHBMain
//
//  Created by 谷春晖 on 2018/11/14.
//

#import "JSONModel.h"
#import "FHBaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHSearchConfigDataFilterModel<NSObject>

@end


@protocol FHSearchConfigDataFilterOptionsModel<NSObject>

@end


@protocol FHSearchConfigDataFilterOptionsOptionsModel<NSObject>

@end


@interface  FHSearchConfigDataFilterOptionsOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *dynamicFetchUrl;
@property (nonatomic, copy , nullable) NSString *value;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, assign) BOOL isDynamicFetch;

@end


@interface  FHSearchConfigDataFilterOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, assign) BOOL supportMulti;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigDataFilterOptionsOptionsModel> *options;

@end


@interface  FHSearchConfigDataFilterModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *rate;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigDataFilterOptionsModel> *options;
@property (nonatomic, copy , nullable) NSString *tabStyle;
@property (nonatomic, copy , nullable) NSString *tabId;

@end


@interface  FHSearchConfigDataAbtestParamsModel  : JSONModel


@end


@interface  FHSearchConfigDataAbtestModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *abtestVersions;
@property (nonatomic, strong , nullable) FHSearchConfigDataAbtestParamsModel *params ;

@end


@interface  FHSearchConfigDataModel  : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHSearchConfigDataFilterModel> *filter;
@property (nonatomic, strong , nullable) FHSearchConfigDataAbtestModel *abtest ;

@end


@interface  FHSearchConfigModel  : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHSearchConfigDataModel *data ;

@end

NS_ASSUME_NONNULL_END
