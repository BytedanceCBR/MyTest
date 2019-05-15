//
//  ExploreCellRecomUserHeaderView.h
//  Article
//
//  Created by Chen Hong on 14-10-26.
//
//

#import "SSViewBase.h"

typedef NS_ENUM(NSInteger, ExploreCardCellHeaderStyle)
{
    ExploreCardCellHeaderStyleAlignTop = 0,    // 标签顶部对齐
    ExploreCardCellHeaderStyleAlignMiddle = 1, // 标签居中对齐
    ExploreCardCellHeaderStyleVideoPGC = 2,    // 视频PCG定制header
    ExploreCardCellHeaderStyleNew = 3          // 新版统一样式
};

@interface ExploreCellRecomUserHeaderView : SSViewBase

@property(nonatomic,copy)NSString *iconUrl;
@property(nonatomic,copy)NSString *nightIconUrl;

- (void)setTarget:(id)target selector:(SEL)selector;

- (void)setTitle:(NSString *)title prefixStr:(NSString *)prefix headStyle:(ExploreCardCellHeaderStyle)headStyle;

- (void)refreshUI;

- (void)updateHeaderIconView;

@end
