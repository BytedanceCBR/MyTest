//
//  TTXiguaLiveRecommendUser.h
//  Article
//
//  Created by lipeilun on 2017/11/30.
//

#import "ExploreOriginalData.h"
#import "TTXiguaLiveModel.h"


@interface TTXiguaLiveRecommendUser : ExploreOriginalData
@property (nonatomic, copy) NSArray *dataArray;

- (NSArray<TTXiguaLiveModel *> *)modelArray;
@end
