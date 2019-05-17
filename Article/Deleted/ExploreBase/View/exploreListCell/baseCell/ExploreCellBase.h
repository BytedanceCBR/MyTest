//
//  ExploreCellBase.h
//  Article
//
//  Created by Chen Hong on 14-9-10.
//
//

#import <UIKit/UIKit.h>
#import "TTCategoryDefine.h"
#import "ExploreCellStyle.h"
#import "ExploreOrderedData_Enums.h"

@class ExploreCellViewBase;
@class ExploreCellBase;
@class TTFeedContainerViewModel;
@class TTFeedCellSelectContext;

typedef NS_ENUM(NSUInteger, ExploreOrderedDataListLocation) {
    /**
     *  列表处于频道
     */
    ExploreOrderedDataListLocationCategory = 0,
    /**
     *  列表处于微头条tab
     */
    ExploreOrderedDataListLocationWeitoutiao,
    /**
     *  orderedData位于卡片中（用于查询列表orderedData时排除卡片内部的orderedData）
     */
    ExploreOrderedDataListLocationCard,
    /**
     * 列表处于ordered data的raw data中，用于扩展样式
     */
    ExploreOrderedDataListLocationRawData,
};

typedef NS_ENUM(NSInteger, CellInListDisappearContextType)
{
    CellInListDisappearContextTypeChangeCategory, // 切换频道
    CellInListDisappearContextTypeGoDetail, // 进入下一级（详情页）
};

//card中cell的位置
typedef NS_ENUM(NSUInteger, ExploreCellPosition) {
    ExploreCellPositionMiddle = 0,
    ExploreCellPositionTop,
    ExploreCellPositionBottom,
};

@protocol CustomTableViewCellEditDelegate <NSObject>

@optional

@property (nonatomic, readonly, getter=isFakeEditing) BOOL fakeEdit;
@property (nonatomic, strong, nullable) UIControl *customEditControl;
@property (nonatomic, assign) CGFloat customEditIndent;

@end

@interface ExploreCellBase : UITableViewCell

@property (nonatomic, assign) TTCategoryModelTopType tabType;
@property (nonatomic,weak, nullable)UITableView *tableView;
@property (nonatomic,strong, nullable)ExploreCellViewBase *cellView;
@property (nonatomic,strong, nullable)NSString *umengEvent;
@property (nonatomic)NSUInteger refer;
@property (nonatomic, weak, nullable) id <CustomTableViewCellEditDelegate> delegate;

#pragma mark - TTCellProtocol
- (nonnull id)initWithTableView:(nullable UITableView *)view reuseIdentifier:(nullable NSString *)reuseIdentifier;
- (nullable ExploreCellViewBase *)createCellView;
- (void)refreshUI;
- (void)refreshWithData:(nonnull id)data;
- (nullable id)cellData;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

- (void)willDisplay;
- (void)didEndDisplaying;
- (void)willAppear;
// 添加这个方法是因为resumeTrackAdCellsInVisibleCells中没有调用willDisplay
// 介于使用willDisplay怕有其他影响就单独新加个方法。。。
- (void)resumeDisplay;

// 参数context: 表示函数调用的上下文
- (void)cellInListWillDisappear:(CellInListDisappearContextType)context;

// cell所在列表类型
- (void)setDataListType:(ExploreOrderedDataListType)listType;

+ (CGFloat)heightForData:(nonnull id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)cellType;
- (BOOL)shouldRefesh;

+ (nullable Class)cellViewClass;

- (CGFloat)paddingForCellView;
- (CGFloat)paddingTopBottomForCellView;

- (void)setCustomControlSelected:(BOOL)isSelected;

- (void)didSelectWithContext:(nullable TTFeedCellSelectContext *)context;

- (void)didSelectAtIndexPath:(nonnull NSIndexPath *)indexPath viewModel:(nonnull TTFeedContainerViewModel *)viewModel;
- (void)willDisplayAtIndexPath:(nonnull NSIndexPath *)indexPath viewModel:(nonnull TTFeedContainerViewModel *)viewModel;
- (void)didEndDisplayAtIndexPath:(nonnull NSIndexPath *)indexPath viewModel:(nonnull TTFeedContainerViewModel *)viewModel;

#pragma mark -
- (void)fontSizeChanged;

- (void)themeChanged:(NSNotification * _Nullable)notification;

- (ExploreCellStyle)cellStyle;
- (ExploreCellSubStyle)cellSubStyle;

@end
