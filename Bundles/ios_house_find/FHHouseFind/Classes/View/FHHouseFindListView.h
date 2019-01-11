//
//  FHHouseFindListView.h
//  Pods
//
//  Created by 张静 on 2019/1/2.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"

#import "FHHouseFindSectionItem.h"

NS_ASSUME_NONNULL_BEGIN

@class TTRouteParamObj;
@interface FHHouseFindListView : UIView

@property(nonatomic , copy) void (^houseListOpenUrlUpdateBlock)(TTRouteParamObj *paramObj);
@property (nonatomic , strong) NSDictionary *tracerDict;
@property (nonatomic , assign) BOOL showRedirectTip;

- (void)updateDataWithItem: (FHHouseFindSectionItem *)item;
- (void)handleSugSelection:(TTRouteParamObj *)paramObj;
// findTab过来的houseSearch需要单独处理下埋点数据
- (void)updateHouseSearchDict:(NSDictionary *)houseSearchDic;
- (NSDictionary *)categoryLogDict;
- (BOOL)isEnterCategory;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
