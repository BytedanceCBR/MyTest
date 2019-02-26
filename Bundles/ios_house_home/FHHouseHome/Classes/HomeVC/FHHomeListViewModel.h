//
//  FHHomeListViewModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/22.
//

#import <Foundation/Foundation.h>
#import "FHHomeViewController.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger , FHHomeCategoryTraceType){
    FHHomeCategoryTraceTypeEnter = 1, //enter
    FHHomeCategoryTraceTypeStay = 2, //stay
    FHHomeCategoryTraceTypeRefresh = 3  //刷新
};

@interface FHHomeListViewModel : NSObject
@property (nonatomic, assign) BOOL hasShowedData;
@property (nonatomic, strong) NSString *enterType; //当前enterType，用于enter_category
@property (nonatomic, assign) TTReloadType reloadType; //当前enterType，用于enter_category
@property (nonatomic, assign) NSTimeInterval stayTime; //页面停留时间

- (instancetype)initWithViewController:(UITableView *)tableView andViewController:(FHHomeViewController *)homeVC;

- (void)reloadHomeTableHeaderSection;

- (void)requestRecommendHomeList;

- (void)requestOriginData:(BOOL)isFirstChange;

- (void)sendTraceEvent:(FHHomeCategoryTraceType)traceType;

- (void)updateCategoryViewSegmented:(BOOL)isFirstChange;

@end

NS_ASSUME_NONNULL_END
