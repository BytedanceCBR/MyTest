//
//  FHHouseComfortFindHeaderView.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/22.
//

#import "FHHouseComfortFindHeaderView.h"
#import "FHCommonDefines.h"
#import <FHEnvContext.h>
#import <FHConfigModel.h>
#import "UIColor+Theme.h"
#import "UIViewAdditions.h"
#import "TTRoute.h"
#import "FHUserTracker.h"

@interface FHHouseComfortFindHeaderView ()
@property(nonatomic,strong) NSArray *items;
@property(nonatomic,weak) FHConfigDataModel *dataModel;
@end

@implementation FHHouseComfortFindHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor themeWhite]];
    }
    return self;
}

- (void)loadItemViews {
    FHConfigDataModel * dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    if(self.dataModel == dataModel) {
        return;
    }
    self.dataModel = dataModel;
    
    [self updateItems];
    [self refreshView];
}

- (void)updateItems {
    FHConfigDataModel * dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];

    NSArray *itemsName = @[@"地图找房",@"房贷计算",@"查房价",@"城市行情",@"购房百科"];
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
    _items = items;
}

-(NSUInteger)itemsCount{
    return _items.count;
}

-(void)refreshView {
    for(UIView *subView in self.subviews){
        [subView removeFromSuperview];
    }
    
    UIImage *placeHolder = [UIImage imageNamed:@"icon_placeholder"];;
    CGFloat iconMargin = (SCREEN_WIDTH - 5 * iconWidth - 2 * horizontalMargin) / 4;
    
    for (NSInteger i = 0 ; i < self.items.count; i++) {
        FHConfigDataOpDataItemsModel *model = self.items[i];
        FHHomeEntranceItemView *itemView = [[FHHomeEntranceItemView alloc] initWithFrame:CGRectMake(horizontalMargin + (iconWidth + iconMargin) * i, verticalMargin,iconWidth, itemViewHeight) iconSize:CGSizeMake(iconWidth, iconWidth)];
        [itemView setBackgroundColor:[UIColor themeWhite]];
        FHConfigDataOpDataItemsImageModel *imgModel = [model.image firstObject];
        [itemView updateWithIconUrl:imgModel.url name:model.title placeHolder:placeHolder];
        itemView.tag = i;
        [itemView addTarget:self action:@selector(itemViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:itemView];
    }
    
    UIView *seprateView = [[UIView alloc] initWithFrame:CGRectMake(horizontalMargin ,comfortFindHeaderViewHeight ,SCREEN_WIDTH - 2 * horizontalMargin ,0.5)];
    [seprateView setBackgroundColor:[UIColor themeGray6]];
    [self addSubview:seprateView];
}

- (void)itemViewClick:(FHHomeEntranceItemView *)itemView{
    NSInteger index = itemView.tag;
    if(index >= 0 && index < self.items.count) {
        FHConfigDataOpDataItemsModel *model = self.items[index];
        
        [self addIconClickTracerWithModel:model];
        
        NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
        tracerDict[@"origin_from"] = self.tracerDict[@"origin_from"];
        tracerDict[@"enter_from"] = @"f_house_finder";
        tracerDict[@"enter_type"] = @"click";
        NSDictionary *params = @{@"tracer":tracerDict};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:params];
        
        if (!isEmptyString(model.openUrl)) {
            NSURL *url = [NSURL URLWithString:model.openUrl];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

- (void)addIconClickTracerWithModel:(FHConfigDataOpDataItemsModel *)model {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";;
    params[@"page_type"] = @"f_house_finder";
    params[@"icon_name"] = [self getIconNameWithTitle:model.title];
    [FHUserTracker writeEvent:@"click_icon" params:params];
}

-(NSString *)getIconNameWithTitle:(NSString *)title {
    if([title isEqualToString:@"购房百科"]) {
        return @"new_user_guide";
    } else if([title isEqualToString:@"地图找房"]) {
        return @"mapfind";
    } else if([title isEqualToString:@"查房价"]) {
        return @"value_info";
    } else if([title isEqualToString:@"城市行情"]) {
        return @"city_market";
    } else if([title isEqualToString:@"房贷计算"]) {
        return @"debit_calculator";
    } else {
        return @"be_null";
    }
}

@end
