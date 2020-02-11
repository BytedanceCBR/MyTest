//
//  FHDetailQACellModel.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/2/7.
//

#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"
#import "FHNeighbourhoodQuestionCell.h"

NS_ASSUME_NONNULL_BEGIN


@interface FHDetailQACellModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailNeighborhoodDataQuestionModel *question;
@property (nonatomic, strong , nullable) FHDetailOldDataNeighborhoodInfoModel *neighborhoodInfo;
@property (nonatomic , strong) NSDictionary *tracerDict;
@property (nonatomic, copy) NSString *neighborhoodId;
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic , strong) NSMutableArray *dataList;
@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, assign) CGFloat footerViewHeight;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *askTitle;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *contentEmptyTitle;
@property (nonatomic, copy) NSString *askSchema;
@property (nonatomic, copy) NSString *questionListSchema;

@end

NS_ASSUME_NONNULL_END
