//
// Created by zhulijun on 2019-08-27.
//

#import <Foundation/Foundation.h>
#import "FHDetailBaseModel.h"
#import "TTUGCAttributedLabel.h"
@class FHDetailHouseReviewCommentItemView;
@class FHDetailHouseReviewCommentModel;

@protocol FHDetailHouseReviewCommentItemViewDelegate
- (void)onReadMoreClick:(FHDetailHouseReviewCommentItemView *)item;

- (void)onCallClick:(FHDetailHouseReviewCommentItemView *)item;

- (void)onImClick:(FHDetailHouseReviewCommentItemView *)item;

- (void)onLicenseClick:(FHDetailHouseReviewCommentItemView *)item;

- (void)onRealtorInfoClick:(FHDetailHouseReviewCommentItemView *)item;
@end

@interface FHDetailHouseReviewCommentItemView : UIView
@property(nonatomic, strong) FHDetailHouseReviewCommentModel *curData;
@property(nonatomic, weak) id <FHDetailHouseReviewCommentItemViewDelegate> delegate;
@property(nonatomic, strong) TTUGCAttributedLabel *commentView;
@property (nonatomic, weak) UIImageView *identifyBacima;
+ (CGFloat)heightForData:(FHDetailHouseReviewCommentModel *)data;

- (void)refreshWithData:(NSObject *)data;

- (void)setComment:(FHDetailHouseReviewCommentModel *)modelData;
@end

