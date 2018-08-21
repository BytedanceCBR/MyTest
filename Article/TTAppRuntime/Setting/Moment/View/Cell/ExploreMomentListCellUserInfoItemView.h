//
//  ExploreMomentListCellUserInfoItemView.h
//  Article
//
//  Created by Zhang Leonardo on 15-1-14.
//
//  动态cell中的元素, 用于展示用户的信息，位于最上面

#import "ExploreMomentListCellItemBase.h"
#import "TTDiggButton.h"

typedef void(^ReportActionBlock)();

@interface ExploreMomentListCellUserInfoItemView : ExploreMomentListCellItemBase

@property(nonatomic, strong)UIButton * arrowButton;
@property(nonatomic, strong)TTDiggButton *diggButton;
@property(nonatomic, assign)BOOL showTimeLabel;
//@property(nonatomic, copy) ReportActionBlock trigReportActionBlock;
/*
- (BOOL)needShowFollowUnFollowArrowButton;
- (BOOL)needShowDeleteArrowButton;
- (BOOL)needShowAdminArrowButton;
*/
@end
