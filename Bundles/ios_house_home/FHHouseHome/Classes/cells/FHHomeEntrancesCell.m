//
//  FHHomeEntrancesCell.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeEntrancesCell.h"
#import "FHHomeCellHelper.h"
#import "TTDeviceHelper.h"
#import "FHHomeCellHelper.h"
#import <FHHouseBase/TTDeviceHelper+FHHouse.h>
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/FHCommonDefines.h>
#import "FHEnvContext.h"
#import <FHHouseBase/FHHomeEntranceItemView.h>




@interface FHHomeEntrancesCell ()

@property(nonatomic , strong) NSArray *items;
@property(nonatomic , strong) NSMutableArray *itemViews;

@end

@implementation FHHomeEntrancesCell

+(CGFloat)rowHeight
{
    if([[FHEnvContext sharedInstance] getConfigFromCache].mainPageBannerOpData.items.count > 0){
        return ceil(SCREEN_WIDTH/375.f*NORMAL_ICON_WIDTH+NORMAL_NAME_HEIGHT)+TOP_MARGIN_PER_ROW;
    }else
    {
        return ceil(SCREEN_WIDTH/375.f*NORMAL_ICON_WIDTH+NORMAL_NAME_HEIGHT)+TOP_MARGIN_PER_ROW + 10;
    }
}

+(CGFloat)cellHeightForModel:(id)model
{
    if (![model isKindOfClass:[FHConfigDataOpDataModel class]]) {
        return 0;
    }
    NSInteger countPerRow = [FHHomeCellHelper sharedInstance].kFHHomeIconRowCount;
    FHConfigDataOpDataModel *dataModel = (FHConfigDataOpDataModel *)model;
    NSInteger rows = ((dataModel.items.count+countPerRow-1)/countPerRow);
    return [self rowHeight]*rows;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _itemViews = [NSMutableArray new];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateWithItems:(NSArray<FHConfigDataOpDataItemsModel> *)items
{
    if(self.items == items){
        return;
    }
    
    self.items = items;
    
    NSInteger countPerRow = [FHHomeCellHelper sharedInstance].kFHHomeIconRowCount;
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
            [self.contentView addSubview:itemView];
        }
    }
    
    [self.itemViews enumerateObjectsUsingBlock:^(UIView *   obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    
    CGFloat margin = (SCREEN_WIDTH - countPerRow*itemFrame.size.width - 2*HOR_MARGIN)/(countPerRow-1);
    UIImage *placeHolder = [UIImage imageNamed:@"new_icon_placeholder"];;
    for (NSInteger i = 0 ; i < totalCount; i++) {
        FHConfigDataOpDataItemsModel *model = items[i];
        FHHomeEntranceItemView *itemView = _itemViews[i];
        itemView.tag = ITEM_TAG_BASE+i;
        FHConfigDataOpDataItemsImageModel *imgModel = [model.image firstObject];
        [itemView updateWithIconUrl:imgModel.url name:model.title placeHolder:placeHolder];
        NSInteger row = i / countPerRow;
        NSInteger col = i % countPerRow;
        itemView.origin = CGPointMake(HOR_MARGIN+(itemFrame.size.width+margin)*col, row*[self.class rowHeight]+TOP_MARGIN_PER_ROW);
        [itemView setBackgroundColor:[UIColor clearColor]];
        itemView.hidden = NO;
    }
    
    [self.contentView setBackgroundColor:[UIColor themeHomeColor]];
    [self setBackgroundColor:[UIColor themeHomeColor]];
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

