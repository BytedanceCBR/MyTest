//
// Created by fengbo on 2019-08-29.
// 用户房源评论露出
//

#import <Foundation/Foundation.h>
#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHUserHouseCommentModel;

@interface FHDetailUserHouseCommentCell : FHDetailBaseCell
@end


@interface FHDetailUserHouseCommentModel : FHDetailBaseModel

@property(nonatomic, strong, nullable) NSArray <FHUserHouseCommentModel> *userComments;

@end

NS_ASSUME_NONNULL_END
