//
//  FHNeighborhoodDetailCommentAndQuestionSM.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/12.
//

#import "FHNeighborhoodDetailSectionModel.h"
#import "FHNeighborhoodDetailCommentHeaderCell.h"
#import "FHNeighborhoodDetailQuestionHeaderCell.h"
#import "FHNeighborhoodDetailSpaceCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailCommentAndQuestionSM : FHNeighborhoodDetailSectionModel

@property(nonatomic , strong) FHNeighborhoodDetailCommentHeaderModel *commentHeaderModel;
@property(nonatomic , strong) FHNeighborhoodDetailQuestionHeaderModel *questionHeaderModel;
@property(copy, nonatomic) NSString *title;
@property(copy, nonatomic) NSString *houseInfoBizTrace;
@property (nonatomic, strong) NSNumber *count;


@property(nonatomic, copy) NSDictionary *extraDic;
@property(nonatomic, copy) NSDictionary *detailTracerDic; // 详情页基础埋点数据
@end

NS_ASSUME_NONNULL_END


