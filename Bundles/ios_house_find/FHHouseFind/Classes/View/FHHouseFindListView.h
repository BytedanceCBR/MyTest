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

- (void)updateDataWithItem: (FHHouseFindSectionItem *)item;
- (void)handleSugSelection:(TTRouteParamObj *)paramObj;

@end

NS_ASSUME_NONNULL_END
