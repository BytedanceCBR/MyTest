//
//  FHChildSuggestionListViewModel.h
//  FHHouseList
//
//  Created by xubinbin on 2020/4/16.
//

#import <Foundation/Foundation.h>
#import "FHHouseListAPI.h"
#import "FHSuggestionListModel.h"
#import "FHChildSuggestionListViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface FHChildSuggestionListViewModel : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign)     FHHouseType       houseType;
@property (nonatomic, strong)   NSDictionary       *homePageRollDic;
@property (nonatomic, assign)   NSInteger       loadRequestTimes; // 历史记录和猜你想搜都回来才需要更新列表
@property (nonatomic, strong)   NSMutableDictionary       *guessYouWantShowTracerDic; // 埋点key记录
@property (nonatomic, assign)   NSInteger       associatedCount;
@property (nonatomic, assign)   FHEnterSuggestionType       fromPageType;
@property (nonatomic, copy)     NSString       *pageTypeStr;
@property (nonatomic, assign)   BOOL isAssociatedCanTrack;
@property (nonatomic, assign)   NSInteger       jumpHouseType;

- (NSString *)pageTypeString;
- (NSString *)categoryNameByHouseType;

-(instancetype)initWithController:(FHChildSuggestionListViewController *)viewController;
- (void)clearSugTableView;
- (void)clearHistoryTableView;
- (void)requestSearchHistoryByHouseType:(NSString *)houseType;
- (void)requestSuggestion:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query;
- (void)requestGuessYouWant:(NSInteger)cityId houseType:(NSInteger)houseType;
- (void)requestDeleteHistoryByHouseType:(NSString *)houseType;
- (void)requestSugSubscribe:(NSInteger)cityId houseType:(NSInteger)houseType;
- (void)reloadHistoryTableView;
- (void)viewWillDisappear;
- (NSString *)elementFromNameByHouseType:(NSInteger)houseType;
@end

NS_ASSUME_NONNULL_END
