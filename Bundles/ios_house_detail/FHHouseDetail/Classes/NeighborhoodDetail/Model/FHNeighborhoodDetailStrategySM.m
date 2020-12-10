//
//  FHNeighborhoodDetailStrategySM.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

#import "FHNeighborhoodDetailStrategySM.h"
#import "FHFeedUGCCellModel.h"

@implementation FHNeighborhoodDetailStrategySM

- (void)updateDetailModel:(FHDetailNeighborhoodModel *)model {
    NSMutableArray *itemArray = [NSMutableArray array];
    FHDetailNeighborhoodDataStrategyModel *strategy = model.data.strategy;
    if (strategy.article) {
        NSDictionary *article = strategy.article;
        [itemArray addObject:article];
    }
//    if(strategy.articleList.count > 0){
//        self.title = strategy.title;
//        for (int i = 0; i < strategy.articleList.count;i++) {
//            FHDetailNeighborhoodDataStrategyArticleListModel *articleModel = strategy.articleList[i];
//            articleModel.hiddenBottomLine = (i == (strategy.articleList.count - 1));
//            if (articleModel) {
//                [itemArray addObject:articleModel];
//            }
//        }
//
//        FHNeighborhoodDetailSpaceModel *spaceModel = [[FHNeighborhoodDetailSpaceModel alloc] init];
//        spaceModel.height = 5;
//        [itemArray addObject:spaceModel];
//    }
//
    self.items = [itemArray copy];
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end
