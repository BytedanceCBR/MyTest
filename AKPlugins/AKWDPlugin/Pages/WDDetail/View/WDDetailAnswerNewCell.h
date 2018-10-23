//
//  WDDetailAnswerNewCell.h
//  Article
//
//  Created by wangqi.kaisa on 2017/6/30.
//
//

#import <UIKit/UIKit.h>
#import <AKCommentPlugin/TTCommentWriteManager.h>
#import <AKCommentPlugin/TTCommentViewControllerProtocol.h>

/*
 * 6.30 新方案使用的cell，初步想法是内部包含一个原来的DetailVC
 */

@class WDDetailModel;
@class WDDetailNatantViewModel;
@class TTRouteParamObj;

@protocol WDDetailAnswerNewCellDelegate <NSObject>

- (void)wd_detailAnswerNewCellAfterDeleteAnswer;
- (void)wd_detailAnswerNewCellShowSlideHelperView;
- (void)wd_detailAnswerNewCellShowIndicatorPolicyView;
- (void)wd_detailAnswerNewCellAfterFetchContentSuccessFirstTime:(BOOL)firstTime;
- (void)wd_detailAnswerNewCellDidScroll:(UIScrollView *)scrollView index:(NSInteger)index;
- (void)wd_detailAnswerNewCellDidScrollWithContentOffsetY:(CGFloat)offsetY index:(NSInteger)index;
- (void)wd_detailAnswerNewCellWriteCommentWithReservedText:(NSString *)reservedText;
- (void)wd_detailAnswerNewCellWriteCommentWithCondition:(NSDictionary *)condition;
- (void)wd_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didSelectWithInfo:(NSDictionary *)info;

@end

@interface WDDetailAnswerNewCell : UICollectionViewCell

@property (nonatomic, assign) NSInteger index; // 当作唯一标示使用
@property (nonatomic, strong) WDDetailModel *detailModel;
@property (nonatomic, strong) WDDetailNatantViewModel *natantViewModel;

@property (nonatomic, weak) id<WDDetailAnswerNewCellDelegate>delegate;

- (void)setDetailAnswerFromDetailModel:(WDDetailModel *)detailModel;

- (void)setDetailAnswerRouteParamObj:(TTRouteParamObj *)paramObj;

- (void)cellStartDisplay;

- (void)cellEndDisplay;

- (void)cellWillDisappear;

- (void)cellDidDisappear;

- (void)cellWillReappear;

- (void)cellDidReappear;

- (void)cellEnterBackground;

- (void)cellEnterForeground;

- (void)loadInfomationIfNeeded;

- (double)getReadPct;

- (NSInteger)getPageCount;

- (NSString *)getDetailViewUserID;

- (void)commentCountButtonTapped;

- (void)commentView:(TTCommentWriteView *) commentView sucessWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager responsedData:(NSDictionary *)responseData;

- (BOOL)banEmojiInput;

- (NSString *)writeCommentViewPlaceholder;

@end
