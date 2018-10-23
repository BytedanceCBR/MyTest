//
//  WDDetailNatantItemModel.m
//  Article
//
//  Created by xuzichao on 2017/7/13.
//
//

#import "WDDetailNatantItemModel.h"
#import "WDDefines.h"

#define kLeftPadding (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kRightPadding (([TTDeviceHelper isPadDevice]) ? 20 : 15)

@implementation WDDetailNatantRelatedItemModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"title"             : @"title",
                           @"open_page_url"     : @"schema",
                           @"type_name"         : @"typeName",
                           @"type_color"        : @"typeDayColor",
                           @"type_color_night"  : @"typeNightColor",
                           @"group_id"          : @"groupId",
                           @"item_id"           : @"itemId",
                           @"item_id"           : @"aggrType",
                           @"impr_id"           : @"impressionID"};
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

@end


@implementation WDDetailNatantRelateReadViewModel
//
//- (float)titleHeightForArticle:(Article *)article cellWidth:(float)width
//{
//    return 0;
//}

- (void)bgButtonClickedBaseViewController:(nonnull UIViewController *)baseController{}

+ (CGSize)imgSizeForViewWidth:(CGFloat)width
{
    static float w = 0;
    static float h = 0;
    static float cellW = 0;
    if (h < 1 || cellW != width) {
        cellW = width;
        float picOffsetX = 4.f;
        w = (width - kLeftPadding - kRightPadding - picOffsetX * 2)/3;
        h = w * (9.f / 16.f);
        w = ceilf(w);
        h = ceilf(h);
    }
    return CGSizeMake(w, h);
}

@end
