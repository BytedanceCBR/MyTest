//
//  FRForumLocationSelectViewModel.h
//  Article
//
//  Created by 王霖 on 15/7/14.
//
//

#import <Foundation/Foundation.h>
#import "TTPlacemarkItemProtocol.h"

@class FRLocationEntity;
typedef void(^FRForumLocationLoadCompletion)(FRLocationEntity *cityLocationItem, NSArray*locationItems, NSError *error);

@interface FRForumLocationSelectViewModel : NSObject

@property (nonatomic, strong, readonly)NSArray *locationItems;
@property (nonatomic, assign, readonly)BOOL isQuery;
@property (nonatomic, assign, readonly)BOOL hasMore;
@property (nonatomic, assign, readonly)BOOL isLastLoadError;

/**
   最近一次的定位信息，如果可用（根据时间间隔），无需重新定位和反编码
*/
- (void)lastPlacemarks:(NSArray<id<TTPlacemarkItemProtocol>> *)placemarks;
/**
    向数据源特定位置插入数据。一般用于插入用户已经选择的地理位置
 */
- (void)insertLocation:(FRLocationEntity*)location atIndex:(NSUInteger)index;
/**
    加载附近位置
 */
- (void)loadNearbyLocationsWithCompletionHandle:(FRForumLocationLoadCompletion)completionHandle;

/**
    搜索附近位置
 */
- (void)searchNearbyLocationsWithKeyword:(NSString*)keyword CompletionHandle:(FRForumLocationLoadCompletion)completionHandle;

/*
    清除附近位置
 */

- (void)clearLocationItems;

@end
