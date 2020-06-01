//
//  FHUGCencyclopediaTracerHelper.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/26.
//

#import <Foundation/Foundation.h>
#import "FHTracerModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHUGCencyclopediaTracerHelper : NSObject
@property(nonatomic, strong) FHTracerModel *tracerModel;
///购房百科下拉刷新埋点
- (void)trackCategoryRefresh;

///购房百科client_show
- (void)trackClientShow:(NSDictionary *)itemData;

///购房百科头部segment点击事件click_options
- (void)trackHeaderSegmentClickOptions:(NSInteger )index;


@end

NS_ASSUME_NONNULL_END
