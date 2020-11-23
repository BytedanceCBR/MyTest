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

@interface FHHouseComfortFindHeaderView ()
@property(nonatomic,strong) NSArray *items;
@end

@implementation FHHouseComfortFindHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor themeWhite]];
        UIView *seprateView = [[UIView alloc] initWithFrame:CGRectMake(horizontalMargin ,comfortFindHeaderViewHeight ,SCREEN_WIDTH - 2 * horizontalMargin ,0.5)];
        [seprateView setBackgroundColor:[UIColor themeGray6]];
        [self addSubview:seprateView];
    }
    return self;
}

- (void)updateItems {
    FHConfigDataModel * dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];

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
    _items = items;
}

-(NSUInteger)itemsCount{
    return _items.count;
}

-(void)refreshView {
    for(UIView *itemView in self.subviews){
        if([itemView isKindOfClass:[FHHomeEntranceItemView class]]){
            [itemView removeFromSuperview];
        }
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
