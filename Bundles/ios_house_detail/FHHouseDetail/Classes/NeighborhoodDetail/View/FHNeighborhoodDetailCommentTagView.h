//
//  FHNeighborhoodDetailCommentTagView.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FHNeighborhoodDetailCommentTagModel;

@interface FHNeighborhoodDetailCommentTagView : UIView

- (instancetype)initWithFrame:(CGRect)frame model:(FHNeighborhoodDetailCommentTagModel *)model;
+ (CGFloat)getTagViewWidth:(FHNeighborhoodDetailCommentTagModel *)model;

@end

@interface FHNeighborhoodDetailCommentTagModel : NSObject

@property(nonatomic , copy) NSString *persent;
@property(nonatomic , copy) NSString *content;

@end

NS_ASSUME_NONNULL_END
