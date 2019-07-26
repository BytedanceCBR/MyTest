//
//  FHHouseDislikeKeywordsView.h
//  FHHouseHome
//
//  Created by 谢思铭 on 2019/7/23.
//

//#import <UIKit/UIKit.h>
//
//NS_ASSUME_NONNULL_BEGIN
//
//@interface FHHouseDislikeKeywordsView : UIView
//
//@end
//
//NS_ASSUME_NONNULL_END

#import "SSViewBase.h"

@protocol FHHouseDislikeKeywordsViewDelegate;

@interface FHHouseDislikeKeywordsView : SSViewBase

@property(nonatomic,weak)id<FHHouseDislikeKeywordsViewDelegate> delegate;

- (void)refreshWithData:(NSArray *)keywords;

// 所有选中的
- (NSArray *)selectedKeywords;

// 是否有选中的
- (BOOL)hasKeywordSelected;

- (CGFloat)paddingY;

@end

@protocol FHHouseDislikeKeywordsViewDelegate <NSObject>

@optional
// 选中/未选切换
- (void)dislikeKeywordsSelectionChanged;

@end
