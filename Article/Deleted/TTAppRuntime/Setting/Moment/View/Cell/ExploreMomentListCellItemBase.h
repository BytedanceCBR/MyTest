//
//  ExploreMomentListCellItemBase.h
//  Article
//
//  Created by Zhang Leonardo on 15-1-14.
//
//

#import "SSViewBase.h"
#import "ArticleMomentModel.h"
#import "ExploreMomentDefine.h"
#import "TTDeviceUIUtils.h"


#define kMomentCellItemViewLeftPadding  [TTDeviceUIUtils tt_paddingForMoment:60]
#define kMomentCellItemViewRightPadding [TTDeviceUIUtils tt_paddingForMoment:15]

#define kMomentListCellItemBaseUserInfoSourceTypeKey @"kMomentListCellItemBaseUserInfoSourceTypeKey"
#define kMomentListCellItemBaseIsDetailViewTypeKey   @"kMomentListCellItemBaseIsDetailViewTypeKey"

@interface ExploreMomentListCellItemBase : SSViewBase

@property(nonatomic, strong, readonly)ArticleMomentModel * momentModel;
@property(nonatomic, assign)ArticleMomentSourceType sourceType;
@property(nonatomic, assign)BOOL isDetailView;
@property(nonatomic, assign)CGFloat cellWidth;
@property(nonatomic, retain)NSDictionary * userInfo;

- (id)initWithWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo;

/**
 *  根据model的内容刷新UI
 *
 *  @param model 动态\讨论区model
 */
- (void)refreshForMomentModel:(ArticleMomentModel *)model;

/**
 *  根据model，返回高度
 *
 *  @param model 动态，讨论区的model
 *  @param cellWidth cell宽度
 *
 *  @return 根据model，返回高度
 */
+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo;
/**
 *  根据model，返回高度
 *
 *  @param model 动态，讨论区的model
 *  @param cellWidth cell宽度
 *
 *  @return 根据model，返回高度
 */
- (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth;


+ (BOOL)needShowForModel:(ArticleMomentModel *)model userInfo:(NSDictionary *)uInfo;

@property (nonatomic, copy, readonly) NSString  *listUmengEventName;
@property (nonatomic, copy, readonly) NSString  *detailUmengEventName;
/// 当前view是否在列表中
@property (nonatomic, readonly, getter=isInMomentListView) BOOL    inMomentListView;

@end
