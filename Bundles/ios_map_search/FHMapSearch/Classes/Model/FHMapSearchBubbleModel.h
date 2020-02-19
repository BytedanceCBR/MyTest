//
//  FHMapSearchBubbleModel.h
//  FHMapSearch
//
//  Created by 谷春晖 on 2018/11/19.
//

#import <Foundation/Foundation.h>
#import "FHHouseType.h"
#import "FHMapSearchShowMode.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHMapSearchBubbleModel : NSObject

@property(nonatomic , assign) CGFloat resizeLevel;
@property(nonatomic , assign) CGFloat centerLatitude;
@property(nonatomic , assign) CGFloat centerLongitude;
@property(nonatomic , assign) FHHouseType houseType;
@property(nonatomic , copy)   NSString *noneFilterQuery; //非当前筛选器中显示的筛选内容

@property(nonatomic , strong) NSMutableDictionary *queryDict;
@property(nonatomic , strong , readonly) NSString *query;

@property(nonatomic , assign) FHMapSearchShowMode lastShowMode;//跳转之前的展示模式

+(instancetype)bubbleFromUrl:(NSString *)url;

-(instancetype) initWithUrl:(NSString *)url;

-(void)overwriteFliter:(NSString *)filter;

-(void)mergeWithQuery:(NSString *)query;

-(void)updateResizeLevel:(CGFloat)resizeLevel centerLatitude:(CGFloat)centerLatitude centerLongitude:(CGFloat)centerLongitude;

-(void)addQueryParams:(NSDictionary *)params;

-(void)removeQueryOfKey:(NSString *)key;

-(BOOL)validCenter;

-(BOOL)validResizeLevel;

@end

NS_ASSUME_NONNULL_END
