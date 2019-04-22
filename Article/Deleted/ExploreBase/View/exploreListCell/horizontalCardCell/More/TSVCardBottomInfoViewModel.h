//
//  TSVCardBottomInfoViewModel.h
//  Article
//
//  Created by 邱鑫玥 on 2017/10/11.
//

#import <Foundation/Foundation.h>
#import "TTShortVideoHelper.h"

typedef NS_ENUM(NSUInteger, TSVCardBottomInfoViewStyle) {
    TSVCardBottomInfoViewStyleDoublePicture, //双图卡片更多
    TSVCardBottomInfoViewStyleHorizontalScroll, //滑动卡片更多
};

typedef NS_ENUM(NSUInteger, TSVCardBottomInfoContentStyle) {
    TSVCardBottomInfoContentStyleMore,
    TSVCardBottomInfoContentStyleDownload,
};

@class ExploreOrderedData;
@class HorizontalCard;

@interface TSVCardBottomInfoViewModel : NSObject

@property (nonatomic, assign) TSVCardBottomInfoContentStyle contentStyle;

+ (BOOL)shouldShowBottomInfoViewForData:(HorizontalCard *)data collectionViewCellStyle:(TTHorizontalCardContentCellStyle)style;

+ (CGFloat)heightForData:(HorizontalCard *)data;

- (instancetype)initWithOrderedData:(ExploreOrderedData *)orderedData;

- (NSString *)title;

- (NSString *)imageName;

- (ExploreOrderedData *)data;

- (TTHorizontalCardContentCellStyle)cellStyle;

- (TSVCardBottomInfoViewStyle)bottomInfoViewStyle;

- (void)handleClick;

@end
