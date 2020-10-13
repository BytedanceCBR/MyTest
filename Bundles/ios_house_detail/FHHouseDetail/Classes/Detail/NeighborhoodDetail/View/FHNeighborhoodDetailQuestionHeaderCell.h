//
//  FHNeighborhoodDetailQuestionHeaderCell.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailQuestionHeaderCell : FHDetailBaseCollectionCell

@end

@interface FHNeighborhoodDetailQuestionHeaderModel : NSObject

@property(nonatomic , copy) NSString *title;
@property(nonatomic , copy) NSString *questionListSchema;
@property(nonatomic , copy) NSString *neighborhoodId;
@property(nonatomic , strong) NSDictionary *detailTracerDic;
@property(nonatomic , assign) CGFloat topMargin;
@property(nonatomic , assign) BOOL hiddenTopLine;

@end

NS_ASSUME_NONNULL_END
