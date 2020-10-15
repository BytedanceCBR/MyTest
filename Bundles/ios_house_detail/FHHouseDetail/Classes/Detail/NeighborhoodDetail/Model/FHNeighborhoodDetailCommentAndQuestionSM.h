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
#import "FHNeighborhoodDetailCommentTagsCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailCommentAndQuestionSM : FHNeighborhoodDetailSectionModel

@property(nonatomic , strong) FHNeighborhoodDetailCommentHeaderModel *commentHeaderModel;
@property(nonatomic , strong) FHNeighborhoodDetailCommentTagsModel *commentTagsModel;
@property(nonatomic , strong) FHNeighborhoodDetailQuestionHeaderModel *questionHeaderModel;

@property(nonatomic, copy) NSDictionary *extraDic;
@property(nonatomic, copy) NSDictionary *detailTracerDic; // 详情页基础埋点数据
@end

NS_ASSUME_NONNULL_END


