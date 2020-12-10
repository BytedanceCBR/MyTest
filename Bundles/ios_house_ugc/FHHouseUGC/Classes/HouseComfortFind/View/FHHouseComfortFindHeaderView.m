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

    if ([dataModel isKindOfClass:[FHConfigDataModel class]]) {
        NSArray *items = dataModel.houseFinderOpData.items;
        if(items.count == 0) {
            items = dataModel.houseOpData2.items;
        }
        
        if (items.count > 5) {
            _items = [items subarrayWithRange:NSMakeRange(0,5)];
        }else{
            _items = items;
        }
    }
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
    params[@"icon_name"] = [self getIconNameWithTitle:model];
    [FHUserTracker writeEvent:@"click_icon" params:params];
}

-(NSString *)getIconNameWithTitle:(FHConfigDataOpDataItemsModel *)model {
    NSDictionary *logPb = model.logPb;
    if([logPb isKindOfClass:[NSDictionary class]]) {
        NSString *operationName = logPb[@"operation_name"];
        if(!isEmptyString(operationName)){
            return operationName;
        }
    }
    return @"bd_null";
}

@end
