//
//  TSVCardTopInfoViewModel.h
//  Article
//
//  Created by dingjinlu on 2017/11/29.
//

#import <UIKit/UIKit.h>
#import "TTShortVideoHelper.h"

@class ExploreOrderedData;
@class HorizontalCard;
@class ExploreItemActionManager;

@interface TSVCardTopInfoViewModel : NSObject

+ (BOOL)shouldShowTopInfoViewForCollectionViewCellStyle:(TTHorizontalCardContentCellStyle)style;

+ (CGFloat)heightForData:(HorizontalCard *)data;

- (instancetype)initWithOrderedData:(ExploreOrderedData *)orderedData;

- (ExploreOrderedData *)data;

- (TTHorizontalCardContentCellStyle)cellStyle;

- (NSString *)title;

- (NSString *)enterFrom;

- (NSString *)categoryName;

@end
