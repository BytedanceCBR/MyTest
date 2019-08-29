//
// Created by zhulijun on 2019-08-27.
//

#import <Foundation/Foundation.h>
#import "FHDetailBaseModel.h"

@class FHDetailHouseReviewCommentItemView;
@class FHDetailHouseReviewCommentModel;
@class TTUGCAttributedLabel;

@protocol FHDetailHouseReviewCommentItemViewDelegate
- (void)onReadMoreClick:(FHDetailHouseReviewCommentItemView *)item;
@end

@interface FHDetailHouseReviewCommentItemView : UIView
@property(nonatomic, strong) FHDetailHouseReviewCommentModel *curData;
@property(nonatomic, weak) id <FHDetailHouseReviewCommentItemViewDelegate> delegate;
@property(nonatomic, strong) TTUGCAttributedLabel *commentView;

+(CGFloat)heightForData:(FHDetailHouseReviewCommentModel *)data;

- (void)refreshWithData:(NSObject *)data;
@end

