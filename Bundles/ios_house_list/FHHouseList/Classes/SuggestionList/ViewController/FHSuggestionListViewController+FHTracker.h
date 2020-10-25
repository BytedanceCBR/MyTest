//
//  FHSuggestionListViewController+FHTracker.h
//  FHHouseBase
//
//  Created by bytedance on 2020/10/13.
//

#import "FHSuggestionListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class FHSuggestionResponseModel;
@interface FHSuggestionListViewController(FHTracker)

@property (nonatomic, assign) BOOL tabSwitched;

- (void)trackPageShow;
- (void)trackTabIndexChange;
- (void)trackSuggestionWithWord:(NSString *)word houseType:(NSInteger)houseType result:(FHSuggestionResponseModel *)result;

@end

NS_ASSUME_NONNULL_END
