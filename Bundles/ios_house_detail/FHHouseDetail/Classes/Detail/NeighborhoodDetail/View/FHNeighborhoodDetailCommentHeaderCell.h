//
//  FHNeighborhoodDetailCommentHeaderCell.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/12.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailCommentHeaderCell : FHDetailBaseCollectionCell

@end

@interface FHNeighborhoodDetailCommentHeaderModel : NSObject

@property(nonatomic , copy) NSString *title;
@property(nonatomic , copy) NSString *subTitle;
@property(nonatomic , copy) NSString *commentsListSchema;
@property(nonatomic , copy) NSString *neighborhoodId;
@property(nonatomic , strong) NSDictionary *detailTracerDic;

@end

NS_ASSUME_NONNULL_END
