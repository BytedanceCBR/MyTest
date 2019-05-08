//
//  TSVCardTopInfoViewModel.m
//  Article
//
//  Created by dingjinlu on 2017/11/29.
//

#import "TSVCardTopInfoViewModel.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "HorizontalCard.h"
#import "AWEVideoConstants.h"
#import "TSVShortVideoOriginalData.h"
#import "TTHorizontalCardCell.h"

#define kTopInfoViewHeight 40

@interface TSVCardTopInfoViewModel()

@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) HorizontalCard *horizontalCard;

@end

@implementation TSVCardTopInfoViewModel

+ (BOOL)shouldShowTopInfoViewForCollectionViewCellStyle:(TTHorizontalCardContentCellStyle)style
{
    return NO;
//    if (style == TTHorizontalCardContentCellStyle5 || style == TTHorizontalCardContentCellStyle6 || style == TTHorizontalCardContentCellStyle7 || style == TTHorizontalCardContentCellStyle8) {
//        return NO;
//    }
//    return YES;
}

+ (CGFloat)heightForData:(HorizontalCard *)data;
{
    return kTopInfoViewHeight;
}

- (instancetype)initWithOrderedData:(ExploreOrderedData *)orderedData
{
    self = [super init];
    if (self) {
        self.orderedData = orderedData;
        self.horizontalCard = orderedData.horizontalCard;
    }
    return self;
}

- (ExploreOrderedData *)data
{
    return self.orderedData;
}

- (TTHorizontalCardContentCellStyle)cellStyle
{
    ExploreOrderedData *itemData = [self.horizontalCard.originalCardItems firstObject];
    return [TTShortVideoHelper contentCellStyleWithItemData:itemData];
}

- (NSString *)title;
{
    return self.horizontalCard.cardTitle?:@"精彩小视频";
}

- (NSString *)enterFrom
{
    if ([self.orderedData.categoryID isEqualToString:@"__all__"]) {
        return @"click_headline";
    } else {
        return @"click_category";
    }
}

- (NSString *)categoryName
{
    return self.orderedData.categoryID;
}



@end
