//
//  ArticleMomentListCellNameLikeView.h
//  Article
//
//  Created by Zhang Leonardo on 14-5-22.
//
//  动态中cell中用名字显示赞的view

#import "SSViewBase.h"
#import "ArticleMomentModel.h"

@protocol ArticleMomentListCellNameLikeViewDelegate;

@interface ArticleMomentListCellNameLikeView : SSViewBase
@property(nonatomic, retain)NSString * umengEventName;
@property(nonatomic, weak)id<ArticleMomentListCellNameLikeViewDelegate> delegte;
+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model viewWidth:(CGFloat)width;

- (void)showBottomLine:(BOOL)show;
@end

@protocol ArticleMomentListCellNameLikeViewDelegate <NSObject>

- (void)momentNameLikeViewClickedShowAllDiggerView:(ArticleMomentListCellNameLikeView *)likeView;

@end
