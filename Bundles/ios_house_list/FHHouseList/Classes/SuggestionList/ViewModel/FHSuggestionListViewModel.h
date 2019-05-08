//
//  FHSuggestionListViewModel.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import "FHHouseListAPI.h"
#import "FHSuggestionListModel.h"
#import "FHSuggestionListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHSuggestionListViewModel : NSObject

@property (nonatomic, assign)     FHHouseType       houseType;
@property (nonatomic, strong)   NSDictionary       *homePageRollDic;
@property (nonatomic, strong)   NSMutableArray       *guessYouWantWords;// 猜你想搜前3个词，外部轮播传入
@property (nonatomic, assign)   NSInteger       loadRequestTimes; // 历史记录和猜你想搜都回来才需要更新列表
@property (nonatomic, strong)   NSMutableDictionary       *historyShowTracerDic; // 埋点key记录
@property (nonatomic, assign)   NSInteger       associatedCount;
@property (nonatomic, assign)   FHEnterSuggestionType       fromPageType;
@property (nonatomic, copy)     NSString       *pageTypeStr;

- (NSString *)pageTypeString;
- (NSString *)categoryNameByHouseType;
- (NSString *)createQueryCondition:(NSDictionary *)conditionDic;

-(instancetype)initWithController:(FHSuggestionListViewController *)viewController;
- (void)clearSugTableView;
- (void)clearHistoryTableView;

- (void)requestSearchHistoryByHouseType:(NSString *)houseType;
- (void)requestSuggestion:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query;
- (void)requestGuessYouWant:(NSInteger)cityId houseType:(NSInteger)houseType;
- (void)requestDeleteHistoryByHouseType:(NSString *)houseType;
- (void)requestSugSubscribe:(NSInteger)cityId houseType:(NSInteger)houseType;

@end

NS_ASSUME_NONNULL_END
