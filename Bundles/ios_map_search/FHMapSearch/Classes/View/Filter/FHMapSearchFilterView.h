//
//  FHMapSearchFilterView.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/7/10.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHMapSearchSelectModel.h"
#import "FHConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMapSearchFilterView : UIView

@property(nonatomic , strong) FHMapSearchSelectModel *selectionModel;
@property(nonatomic , copy) void (^confirmWithQueryBlock)(NSString *query);

-(void)updateWithFilters:(NSArray *)filters;

-(void)updateWithOldFilter:(NSArray<FHSearchFilterConfigItem> *)filter;

-(void)updateWithRentFilter:(NSArray<FHSearchFilterConfigItem> *)filter;

-(void)dismiss:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
