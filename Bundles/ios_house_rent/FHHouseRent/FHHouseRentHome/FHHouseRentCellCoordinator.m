//
//  FHHouseRentCellCoordinator.m
//  FHHouseRent
//
//  Created by leo on 2018/11/18.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "FHHouseRentCellCoordinator.h"
#import "TableViewCellCoordinator.h"
#import "FHHouseRentCell.h"
#import <FHHouseRentModel.h>

@interface FHHouseRentCellRender : NSObject<TableCellRender>

@end

@implementation FHHouseRentCellRender


- (void)renderCell:(UITableViewCell *)cell withModel:(FHHouseRentDataItemsModel *)model atIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[FHHouseRentCell class]]) {
        FHHouseRentCell* theCell = (FHHouseRentCell*)cell;
        theCell.majorTitle.text = model.title;
        theCell.extendTitle.text = model.subtitle;
        theCell.priceLabel.text = model.pricing;
        if (model.tags.count > 0) {
            NSMutableArray *tags = [NSMutableArray new];
            for (FHSearchHouseDataItemsTagsModel *tag in model.tags) {
                FHTagItem *item = [FHTagItem instanceWithText:tag.content withColor:tag.textColor withBgColor:tag.backgroundColor];
                [tags addObject:item];
            }
            [theCell setTags:tags];
        }
    }
}

- (NSString *)reusedIdentifer {
    return @"item";
}

@end

@interface FHHouseRentCellCoordinator ()<TableViewCellCoordinator>
{
    FHHouseRentCellRender* _render;
}
@end

@implementation FHHouseRentCellCoordinator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _render = [[FHHouseRentCellRender alloc] init];
    }
    return self;
}

- (nonnull id<TableCellRender>)cellRenderAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return _render;
}

- (nonnull NSString *)cellReusedIdentiferForIndexPath:(nonnull NSIndexPath *)incexPath {
    return @"item";
}

@end
