//
//  FHSuggestionListViewController+FHTracker.h
//  FHHouseBase
//
//  Created by bytedance on 2020/10/13.
//

#import "FHSuggestionListViewController.h"
#import "FHSuggestionListModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHSuggestionResponseModel;
@interface FHSuggestionListViewController(FHTracker)

@property (nonatomic, assign) BOOL tabSwitched;

- (void)trackPageShow;
- (void)trackTabIndexChange;
- (void)trackSuggestionWithWord:(NSString *)word houseType:(NSInteger)houseType result:(FHSuggestionResponseModel *)result;
- (void)trackSugWordClickWithmodel:(FHSuggestionResponseItemModel *)rank eventName:(NSString *)eventName;

@end

NS_ASSUME_NONNULL_END
