//
//  FHSearchFilterOpenUrlModel.h
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/23.
//

#import <Foundation/Foundation.h>
#import "FHHouseType.h"


NS_ASSUME_NONNULL_BEGIN

@interface FHSearchFilterOpenUrlModel : NSObject

@property(nonatomic , assign) FHHouseType houseType;
@property(nonatomic , copy)   NSString *noneFilterQuery; //非当前筛选器中显示的筛选内容

@property(nonatomic , strong) NSMutableDictionary *queryDict;
@property(nonatomic , strong , readonly) NSString *query;

+(instancetype)instanceFromUrl:(NSString *)url;

-(instancetype) initWithUrl:(NSString *)url;

-(void)overwriteFliter:(NSString *)filter;

-(void)mergeWithQuery:(NSString *)query;

-(void)addQueryParams:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
