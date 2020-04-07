//
//  FHDetailCommentsCellModel.h
//  FHHouseDetail
//
//  Created by wangzhizhou on 2020/2/23.
//

#import "FHDetailBaseModel.h"
#import "FHDetailNeighborhoodModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface FHDetailCommentsCellModel : FHDetailBaseModel
@property (nonatomic, strong , nullable) FHDetailNeighborhoodDataCommentsModel *comments;
@property (nonatomic, copy) NSString *commentsSchema;
@property (nonatomic, copy) NSString *commentsListSchema;
@property (nonatomic , strong) NSMutableArray *dataList;
@property (nonatomic , strong) NSDictionary *tracerDict;
@property (nonatomic, copy) NSString *neighborhoodId;
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, assign) CGFloat footerViewHeight;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *commentTitle;
@property (nonatomic, copy) NSString *contentEmptyTitle;
@property (nonatomic, assign) CGFloat topMargin;
@property (nonatomic, assign) CGFloat bottomMargin;

@end

NS_ASSUME_NONNULL_END
