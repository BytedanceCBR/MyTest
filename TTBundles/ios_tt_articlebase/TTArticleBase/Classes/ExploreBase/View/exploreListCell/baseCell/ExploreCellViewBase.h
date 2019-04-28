//
//  ExploreCellViewBase.h
//  Article
//
//  Created by Chen Hong on 14-9-9.
//
//

#import "SSViewBase.h"
//#import "TTSharedViewTransition.h"
#import "ExploreCellBase.h"
#import "TTFeedCellDefaultSelectHandler.h"
#import "TTTouchContext.h"

/** 分割条的高度 */
extern CGFloat kCellSeprateViewHeight(void);

@interface ExploreCellViewBase : SSViewBase/*<TTSharedViewTransitionFrom>*/
@property(nonatomic, weak, nullable)UITableView *tableView;
@property(nonatomic, weak, nullable)ExploreCellBase *cell;
@property(nonatomic, assign)ExploreOrderedDataListType listType;
@property(nonatomic, copy, nullable)NSString *reuseIdentifier;
@property(nonatomic,strong, nullable)NSString *umengEvent;
@property (nonatomic, strong, nullable) TTTouchContext *lastTouchContext;

// 卡片
@property(nonatomic, assign)BOOL isCardSubCellView; // 在卡片内
@property(nonatomic, assign)NSInteger cardSubCellIndex;
@property(nonatomic, copy, nullable)NSString *cardId;
@property(nonatomic, copy, nullable)NSString *cardCategoryId;

@property (nonatomic, assign) ExploreCellPosition position;

@property (nonatomic, assign) BOOL hideBottomLine;
//适配热点要闻卡片新增字段
@property (nonatomic, assign) BOOL isHotNewsCellInCard;
@property (nonatomic, assign) BOOL showAvatar;
@property (nonatomic, assign) BOOL showRedDot;


- (nonnull id)initWithFrame:(CGRect)frame reuseIdentifier:(nullable NSString *)identifier;

- (void)refreshUI;
- (void)refreshWithData:(nonnull id)data;
- (nullable id)cellData;
- (void)fontSizeChanged;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

+ (CGFloat)heightForData:(nonnull id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType;

- (BOOL)shouldRefresh;
- (void)refreshDone;

- (void)addKVO;
- (void)removeKVO;

+ (NSUInteger)cellTypeForCacheHeightFromOrderedData:(nullable id)orderedData;
- (NSUInteger)getRefer;

- (ExploreCellStyle)cellStyle;
- (ExploreCellSubStyle)cellSubStyle;

- (void)didSelectWithContext:(nullable TTFeedCellSelectContext *)context;
- (void)postSelectWithContext:(nullable TTFeedCellSelectContext *)context;

@end

@interface ExploreCellViewBase (TTAdCellLayoutInfo) <TTAdCellLayoutInfo>
- (nullable NSDictionary *)adCellLayoutInfo;
@end
