//
//  TTLiveSimpleCell.m
//  Article
//
//  Created by 王双华 on 16/9/27.
//
//

#import "TTLiveSimpleCell.h"
#import "UIViewAdditions.h"
#import "TTArticleCellConst.h"
#import "TTArticleCellHelper.h"
#import "NSString-Extension.h"

@implementation TTLiveSimpleCell

/** 获取CellView类名 */
+ (Class)cellViewClass {
    return [TTLiveSimpleCellView class];
}

@end

@implementation TTLiveSimpleCellView
/** 更新界面数据 */
- (void)refreshWithData:(id)data {
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    if (orderedData && [orderedData managedObjectContext]) {
        self.orderedData = orderedData;
        if ([[orderedData live] managedObjectContext]) {
            [self updateTitleView];
            [self updatePicView];
            [self updateOnlineView];
            [self updateStatusView];
            [self updateInfoView];
        }
    } else {
        self.orderedData = nil;
    }
}

/** 更新界面UI */
- (void)refreshUI {
    ExploreOrderedData *orderedData = self.orderedData;
    if (orderedData && [orderedData live]) {
        if ([orderedData preCellHasBottomPadding]) {
            CGRect bounds = self.bounds;
            bounds.origin.y = 0;
            self.bounds = bounds;
            self.topRect.hidden = YES;
        } else {
            CGRect bounds = self.bounds;
            bounds.origin.y = - kCellSeprateViewHeight();
            self.bounds = bounds;
            self.topRect.bottom = 0;
            self.topRect.width = self.width;
            self.topRect.hidden = NO;
        }
        
        if (!([orderedData nextCellHasTopPadding])) {
            self.bottomRect.bottom = self.height + self.bounds.origin.y;
            self.bottomRect.width = self.width;
            self.bottomRect.hidden = NO;
        }
        else{
            self.bottomRect.hidden = YES;
        }
        
        
        CGFloat containWidth = self.width - kPaddingLeft() - kPaddingRight();
        
        self.statusView.top = 15;
        self.statusView.left = kPaddingLeft();
        
        self.followView.centerY = self.statusView.centerY;
        self.followView.right = self.width - kPaddingLeft();
        self.followView.hidden = ![[[orderedData live] showFollowed] boolValue];
        self.followView.highlighted = [[[orderedData live] followed] boolValue];
        
        self.onlineView.centerY = self.statusView.centerY;
        self.onlineView.left = self.statusView.right + 8;
        
        self.onlineConstView.centerY = self.onlineView.centerY;
        self.onlineConstView.left = self.onlineView.right;
        
        self.titleView.top = self.statusView.bottom + 16;
        self.titleView.left = kPaddingLeft();
        [self.titleView sizeToFit:containWidth];
        
        self.picView.frame = CGRectMake(kPaddingLeft(), self.titleView.bottom + 16, containWidth, ceil(containWidth / 16 * 9));
                
//        self.sourceView.top = self.picView.bottom + 8;
//        self.sourceView.left = kPaddingLeft();
        
        self.dislikeView.right = self.width + 6;
        self.dislikeView.centerY = self.picView.bottom + 16;
        
        CGFloat x = kPaddingLeft();
        if (self.tagView.width != 0) {
            self.tagView.left = x;
            self.tagView.centerY = self.dislikeView.centerY;
            x = self.tagView.right + 5;
        }
        
        [self.sourceLabel sizeToFit:(self.dislikeView.left + 19 - 5) - x];
        self.sourceLabel.centerY = self.dislikeView.centerY;
        self.sourceLabel.left = x;
    }
    [self reloadThemeUI];
}

/**
 计算数据对应Cell高度
 
 - parameter data:      Data数据
 - parameter cellWidth: Cell宽度
 - parameter listType:  列表类型
 
 - returns: 数据对应Cell高度
 */
+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    Live *live = [orderedData live];
    NSString *title = [live title];
    if (orderedData && live && title) {
        // 查询是否存在缓存高度
        NSUInteger cellViewType = [self cellTypeForCacheHeightFromOrderedData:orderedData];
        CGFloat cacheHeight = [orderedData cacheHeightForListType:listType cellType:cellViewType];
        if (cacheHeight > 0 && ![live needRefreshUI]) {
            if ([orderedData preCellHasBottomPadding]) {
                cacheHeight -= kCellSeprateViewHeight();
            }
            if ([orderedData nextCellHasTopPadding]) {
                cacheHeight -= kCellSeprateViewHeight();
            }
            return cacheHeight;
        }
        
        // 计算上下边距
        CGFloat height = 0;
        CGFloat containWidth = width - kPaddingLeft() - kPaddingRight();
        
        // 顶部信息栏
        height += 15 + 20;
        
        // 计算标题控件
        CGFloat titleViewHeight = [title tt_sizeWithMaxWidth:containWidth font:[UIFont tt_fontOfSize:kTitleViewFontSize()] lineHeight:kTitleViewLineHeight() numberOfLines:2].height;
        height += 16 + titleViewHeight;
        
        height += 16 + ceil(containWidth / 16 * 9);
        
        height += 8 + 16 + 14;
        
        height += 2 * kCellSeprateViewHeight();
        
        // 缓存高度
        height = ceilf(height);
        
        [orderedData saveCacheHeight:height forListType:listType cellType:cellViewType];
        
        if ([orderedData preCellHasBottomPadding]) {
            height -= kCellSeprateViewHeight();
        }
        if ([orderedData nextCellHasTopPadding]) {
            height -= kCellSeprateViewHeight();
        }
        
        return height;
    }
    return 0;
}

@end
