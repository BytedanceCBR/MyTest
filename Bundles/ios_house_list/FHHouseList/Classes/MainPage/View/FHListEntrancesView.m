//
//  FHListEntrancesView.m
//  FHHouseList
//
//  Created by 张静 on 2019/12/13.
//

#import "FHListEntrancesView.h"
#import <FHHouseBase/FHConfigModel.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/FHHomeEntranceItemView.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <FHCommonUI/UIColor+Theme.h>

#define LIST_HOR_MARGIN 15

@interface FHListEntrancesView ()

@property(nonatomic , strong) NSArray *items;
@property(nonatomic , strong) NSMutableArray *itemViews;

@end

@implementation FHListEntrancesView

+(CGFloat)rowHeight
{
    return ceil((SCREEN_WIDTH - 15 * 2)/375.f*NORMAL_ICON_WIDTH+NORMAL_NAME_HEIGHT)+TOP_MARGIN_PER_ROW;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _itemViews = [NSMutableArray new];
    }
    return self;
}

-(void)updateWithItems:(NSArray<FHConfigDataOpDataItemsModel> *)items
{
    if(self.items == items){
        return;
    }
    
    self.items = items;
    
    NSInteger countPerRow = _countPerRow;
    if(items.count > countPerRow*2){
        items = [items subarrayWithRange:NSMakeRange(0, countPerRow*2)];
    }
    NSInteger rowCount = (items.count+countPerRow-1)/countPerRow;
    NSInteger totalCount = MIN(items.count, rowCount*countPerRow);
    CGFloat ratio = SCREEN_WIDTH/375;
    
    CGRect itemFrame = CGRectMake(0, 0, MAX(ceil(ratio*NORMAL_ICON_WIDTH),NORMAL_ITEM_WIDTH), ceil(ratio*NORMAL_ICON_WIDTH+NORMAL_NAME_HEIGHT));
    
    if(self.itemViews.count < totalCount){
        CGSize iconSize = CGSizeMake(ceil(NORMAL_ICON_WIDTH*ratio), ceil(NORMAL_ICON_WIDTH*ratio));
        for (NSInteger i = _itemViews.count; i < totalCount; i++) {
            FHHomeEntranceItemView *itemView = [[FHHomeEntranceItemView alloc] initWithFrame:itemFrame iconSize:iconSize];
            [itemView setBackgroundColor:[UIColor clearColor]];
            [itemView addTarget:self action:@selector(onItemAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.itemViews addObject:itemView];
            [self addSubview:itemView];
        }
    }
    
    [self.itemViews enumerateObjectsUsingBlock:^(UIView *   obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    
    CGFloat margin = (SCREEN_WIDTH - countPerRow*itemFrame.size.width - 2*LIST_HOR_MARGIN)/(countPerRow-1);
    UIImage *placeHolder = [UIImage imageNamed:@"icon_placeholder"];;
    for (NSInteger i = 0 ; i < totalCount; i++) {
        FHConfigDataOpDataItemsModel *model = items[i];
        FHHomeEntranceItemView *itemView = _itemViews[i];
        itemView.tag = ITEM_TAG_BASE+i;
        FHConfigDataOpDataItemsImageModel *imgModel = [model.image firstObject];
        [itemView updateWithIconUrl:imgModel.url name:model.title placeHolder:placeHolder];
        NSInteger row = i / countPerRow;
        NSInteger col = i % countPerRow;
        itemView.origin = CGPointMake(LIST_HOR_MARGIN+(itemFrame.size.width+margin)*col, row*[self.class rowHeight]+TOP_MARGIN_PER_ROW);
        [itemView setBackgroundColor:[UIColor clearColor]];
        itemView.hidden = NO;
    }
}

-(void)onItemAction:(FHHomeEntranceItemView *)itemView
{
    if(self.clickBlock){
        NSInteger index = itemView.tag - ITEM_TAG_BASE;
        FHConfigDataOpDataItemsModel *model = nil;
        if(_items.count > index){
            model = _items[index];
        }
        self.clickBlock(index , model);
    }
}


@end
