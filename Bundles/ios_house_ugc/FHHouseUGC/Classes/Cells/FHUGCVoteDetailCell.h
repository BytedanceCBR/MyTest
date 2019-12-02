//
//  FHUGCVoteDetailCell.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/11/11.
//

#import <UIKit/UIKit.h>
#import "FHUGCBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const kFHUGCPostVoteSuccessNotification = @"k_fh_ugc_post_vote_finish";

// UGC 投票类型cell Feed和详情页共用
@interface FHUGCVoteDetailCell : FHUGCBaseCell
/*1、isFromDetail 从详情页过来的数据需要重新计算布局 全部展开 以及不显示“展开查看更多”
  2、非详情页，Feed中，布局需要折叠展开，默认展开 & 不添加展开按钮
 */
- (void)setupUIFrames;

@end

// 投票视图
@interface FHUGCVoteMainView : UIView

@property (nonatomic, weak)     UITableView       *tableView;
@property (nonatomic, weak)     FHUGCVoteDetailCell       *detailCell;

- (void)refreshWithData:(id)data;

// 选项点击
- (void)optionClickItem:(FHUGCVoteInfoVoteInfoItemsModel *)item;

@end

// 选项
@interface FHUGCOptionView : UIButton

@property (nonatomic, assign)   BOOL       mainSelected;// 当前投票是否已答完
@property (nonatomic, weak)     FHUGCVoteMainView       *mainView;
- (void)refreshWithData:(id)data;

@end

// 外部布局高度28
@interface FHUGCVoteFoldViewButton : UIButton

- (instancetype)initWithDownText:(NSString *)down upText:(NSString *)up isFold:(BOOL)isFold;
@property (nonatomic, assign)   BOOL       isFold;

@end

// 加载 loading button
@interface FHUGCLoadingButton : UIButton

- (void)startLoading;
- (void)stopLoading;

- (void)setLoadingImageName:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
