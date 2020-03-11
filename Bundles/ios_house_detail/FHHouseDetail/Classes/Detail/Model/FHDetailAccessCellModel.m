//
//  FHDetailAccessCellModel.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/3/6.
//

#import "FHDetailAccessCellModel.h"

@implementation FHDetailAccessCellModel

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setStrategy:(FHDetailNeighborhoodDataStrategyModel *)strategy {
    _strategy = strategy;

    NSMutableArray *cards = [NSMutableArray array];
    for (FHDetailNeighborhoodDataStrategyArticleListModel *model in strategy.articleList) {
        FHCardSliderCellModel *cellModel = [[FHCardSliderCellModel alloc] init];
        cellModel.title = model.title;
        cellModel.desc = model.desc;
        cellModel.imageUrl = model.picture;
        cellModel.schema = model.schema;
        cellModel.type = model.articleType;
        cellModel.groupId = model.groupId;
        [cards addObject:cellModel];
    }
    _cards = cards;
}

- (void)setTracerDic:(NSDictionary *)tracerDic {
    _tracerDic = tracerDic;
}

@end
