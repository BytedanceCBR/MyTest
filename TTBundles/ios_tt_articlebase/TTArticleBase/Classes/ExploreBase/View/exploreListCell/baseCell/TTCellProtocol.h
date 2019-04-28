//
//  TTCellProtocol.h
//  Article
//
//  Created by Chen Hong on 16/1/26.
//
//

#import <Foundation/Foundation.h>
#import "ExploreListHelper.h"

//cell所在列表disappear时的context
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


@protocol TTCellViewProtocol;

/**
 *  ‘首页’列表cell协议
 */
@protocol TTCellProtocol <NSObject>

@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, strong) UIView<TTCellViewProtocol> *cellView;

- (id)initWithTableView:(UITableView *)view reuseIdentifier:(NSString *)reuseIdentifier;
- (UIView<TTCellViewProtocol> *)createCellView;
- (void)refreshUI;
- (void)refreshWithData:(id)data;
- (id)cellData;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
- (void)didEndDisplaying;

// 参数context: 表示函数调用的上下文
- (void)cellInListWillDisappear:(CellInListDisappearContextType)context;

// cell所在列表类型
- (void)setDataListType:(ExploreOrderedDataListType)listType;

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)cellType;

- (BOOL)shouldRefesh;

+ (Class)cellViewClass;

- (CGFloat)paddingForCellView;

@end

/**
 *  ‘首页’列表cellView协议
 */
@protocol TTCellViewProtocol <NSObject>

@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, weak) id<TTCellProtocol> cell;
@property(nonatomic, assign) ExploreOrderedDataListType listType;
@property(nonatomic, copy) NSString *reuseIdentifier;

// 卡片
@property(nonatomic, assign) BOOL isCardSubCellView; // 在卡片内
@property(nonatomic, assign) NSInteger cardSubCellIndex;
@property(nonatomic, copy) NSString *cardId;

@property (nonatomic, assign) ExploreCellPosition position;

@property (nonatomic, assign) BOOL hideBottomLine;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier;

- (void)refreshUI;
- (void)refreshWithData:(id)data;
- (id)cellData;
- (void)fontSizeChanged;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType;

- (BOOL)shouldRefesh;
- (void)refreshDone;

+ (NSUInteger)cellTypeForCacheHeightFromOrderedData:(ExploreOrderedData *)orderedData;

@end