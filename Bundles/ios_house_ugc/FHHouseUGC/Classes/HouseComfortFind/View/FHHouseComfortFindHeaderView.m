//
//  FHHouseComfortFindHeaderView.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/22.
//

#import "FHHouseComfortFindHeaderView.h"
#import <FHEnvContext.h>
#import <FHConfigModel.h>
#import "UIColor+Theme.h"
#import "UIViewAdditions.h"
#import "FHCommuteManager.h"
#import "TTRoute.h"

@interface FHHouseComfortFindHeaderView ()
@property(nonatomic,strong) NSArray *items;
@end

@implementation FHHouseComfortFindHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    FHConfigDataModel * dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    if (!dataModel) {
        dataModel = [[FHEnvContext sharedInstance] readConfigFromLocal];
    }
    
    NSArray *itemsName = @[@"地图找房",@"查房价",@"帮我找房",@"城市行情",@"房贷计算"];
    NSMutableArray *items = [NSMutableArray array];
    NSMutableDictionary *itemsDict = [NSMutableDictionary dictionary];
    
    if ([dataModel isKindOfClass:[FHConfigDataModel class]]) {
        for(FHConfigDataOpDataItemsModel *model in dataModel.opData.items){
            if([itemsName containsObject:model.title]) {
                itemsDict[model.title] = model;
            }
        }
        
        for(FHConfigDataOpDataItemsModel *model in dataModel.toolboxData.items){
            if([itemsName containsObject:model.title]) {
                itemsDict[model.title] = model;
            }
        }
        
        for(NSString *title in itemsName) {
            FHConfigDataOpDataItemsModel *model = [itemsDict objectForKey:title];
            if(model){
                [items addObject:model];
            }
        }
    }
    self.items = items;

    if(items.count) {
        
        CGFloat ratio = SCREEN_WIDTH/375;
        CGRect itemFrame = CGRectMake(0, 0, MAX(ceil(ratio*NORMAL_ICON_WIDTH),NORMAL_ITEM_WIDTH), ceil(ratio*NORMAL_ICON_WIDTH+NORMAL_NAME_HEIGHT));
        CGFloat margin = (SCREEN_WIDTH - 5 * itemFrame.size.width - 2 * HOR_MARGIN) / 4;
        CGSize iconSize = CGSizeMake(ceil(NORMAL_ICON_WIDTH*ratio), ceil(NORMAL_ICON_WIDTH*ratio));
        UIImage *placeHolder = [UIImage imageNamed:@"icon_placeholder"];;

        for (NSInteger i = 0 ; i < items.count; i++) {
            FHConfigDataOpDataItemsModel *model = items[i];
            FHHomeEntranceItemView *itemView = [[FHHomeEntranceItemView alloc] initWithFrame:itemFrame iconSize:iconSize];
            [itemView setBackgroundColor:[UIColor themeWhite]];
            FHConfigDataOpDataItemsImageModel *imgModel = [model.image firstObject];
            [itemView updateWithIconUrl:imgModel.url name:model.title placeHolder:placeHolder];
            itemView.origin = CGPointMake(HOR_MARGIN+(itemFrame.size.width+margin) * i, TOP_MARGIN_PER_ROW);
            [itemView addTarget:self action:@selector(itemViewClick:) forControlEvents:UIControlEventTouchUpInside];
            itemView.tag = i;
            [self addSubview:itemView];
        }
        [self setBackgroundColor:[UIColor themeWhite]];
    }
}

- (void)itemViewClick:(FHHomeEntranceItemView *)itemView{
    NSInteger index = itemView.tag;
    if(index >= 0 && index < self.items.count) {
        FHConfigDataOpDataItemsModel *model = self.items[index];
        
        NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
        NSDictionary *params = @{@"tracer":tracerDict};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:params];
        
        if (!isEmptyString(model.openUrl)) {
            NSURL *url = [NSURL URLWithString:model.openUrl];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

@end
