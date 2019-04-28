//
//  TTArticlePureTitleCell.m
//  Article
//
//  Created by 杨心雨 on 16/8/23.
//
//

#import "TTArticlePureTitleCell.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTArticleCellHelper.h"
#import "TTArticleCellConst.h"
#import "TTDeviceHelper.h"

@implementation TTArticlePureTitleCell

/**
 获取CellView类名
 
 - returns: CellView类名
 */
+ (Class)cellViewClass {
    return [TTArticlePureTitleCellView class];
}

@end

@implementation TTArticlePureTitleCellView
/**
 更新数据界面
 
 - parameter data: Data数据
 */
- (void)refreshWithData:(id)data {
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    if ([orderedData managedObjectContext]) {
        self.orderedData = orderedData;
        if ([[orderedData article] managedObjectContext]) {
            [self updateFunctionView];
            [self updateTitleView];
            [self updateAbstractView];
            [self updateCommentView];
            [self updateInfoView];
            [self updateBottomLineView];
        }
    } else {
        self.orderedData = nil;
    }
}

/** 更新UI界面 */
- (void)refreshUI {
    ExploreOrderedData *orderedData = self.orderedData;
    Article *article = [orderedData article];
    if (article) {
        CGFloat containWidth = self.width - kPaddingLeft() - kPaddingRight();
        CGFloat x = kPaddingLeft();
        CGFloat y = kPaddingTop();
        ExploreOrderedDataListType listType = [orderedData listType];
        
        // 布局功能区控件
        CGSize functionSize = [TTArticleCellHelper getFunctionSize:orderedData width:containWidth];
        self.functionView.frame = CGRectMake(x, y, functionSize.width, functionSize.height);
        y += functionSize.height;
        
        // 布局更多按钮
        [self layoutMoreView];
        
        // 布局标题控件
        if (!isEmptyString([article title])) {
            y += kPaddingFunctionBottom();
            [self.titleView sizeToFit:containWidth];
            self.titleView.origin = CGPointMake(x, y);
            y += self.titleView.height;
        }
        
        // 布局摘要控件
        BOOL displayAbstractView = [TTArticleCellHelper shouldDisplayAbstractView:article listType:listType mustShow:[orderedData isShowAbstract]];
        if (displayAbstractView) {
            y += kPaddingTitleToAbstract();
            [self.abstractView sizeToFit:containWidth];
            self.abstractView.origin = CGPointMake(x, y);
            y += self.abstractView.height;
        }
        
        // 布局评论控件
        BOOL displayCommentView = [TTArticleCellHelper shouldDisplayCommentView:article listType:listType];
        if (displayCommentView) {
            y += kPaddingTitleOrAbstractToComment();
            CGSize commentSize = [TTArticleCellHelper getCommentSize:article width:containWidth];
            self.commentView.frame = CGRectMake(x, y, commentSize.width, commentSize.height);
            y += commentSize.height;
        }
        
        // 布局信息栏控件
        y += kPaddingInfoTop();
        CGSize infoSize = [TTArticleCellHelper getInfoSize:containWidth];
        self.infoView.frame = CGRectMake(x, y, infoSize.width, infoSize.height);
        
        // 布局底部分割线
        self.bottomLineView.frame = CGRectMake(0, self.height - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel]);
    }
}
    
/**
 计算数据对应Cell高度
 
 - parameter data:      Data数据
 - parameter cellWidth: Cell宽度
 - parameter listType:  列表类型
 
 - returns: 数据对应Cell高度
 */
+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)cellWidth listType:(ExploreOrderedDataListType)listType {
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    Article *article = [orderedData article];
    if (article) {
        // 查询是否存在缓存高度
        ExploreOrderedDataListType cellViewType = [self cellTypeForCacheHeightFromOrderedData:orderedData];
        CGFloat cacheHeight = [orderedData cacheHeightForListType:listType cellType:cellViewType];
        if (cacheHeight > 0) {
            return cacheHeight;
        }
        
        // 计算上下边距
        CGFloat height = kPaddingTop() + kPaddingBottom();
        CGFloat containWidth = cellWidth - kPaddingLeft() - kPaddingRight();
        
        // 计算功能区控件
        CGSize functionSize = [TTArticleCellHelper getFunctionSize:orderedData width:containWidth];
        height += functionSize.height;
        
        // 计算标题控件
        if (!isEmptyString([article title])) {
            CGSize titleSize = [TTArticleCellHelper getTitleSize:[article title] width:containWidth];
            height += kPaddingFunctionBottom() + titleSize.height;
        }
        
        // 计算摘要控件
        BOOL displayAbstractView = [TTArticleCellHelper shouldDisplayAbstractView:article listType:listType mustShow:[orderedData isShowAbstract]];
        if (displayAbstractView) {
            CGSize abstractSize = [TTArticleCellHelper getAbstractSize:article width:containWidth];
            height += kPaddingTitleToAbstract() + abstractSize.height;
        }
        
        // 计算评论控件
        BOOL displayCommentView = [TTArticleCellHelper shouldDisplayCommentView:article listType:listType];
        if (displayCommentView) {
            CGSize commentSize = [TTArticleCellHelper getCommentSize:article width:containWidth];
            height += kPaddingTitleOrAbstractToComment() + commentSize.height;
        }
        
        // 计算信息栏控件
        CGSize infoSize = [TTArticleCellHelper getInfoSize:containWidth];
        height += kPaddingInfoTop() + infoSize.height;
        
        // 缓存高度
        [orderedData saveCacheHeight:height forListType:listType cellType:cellViewType];
        
        return height;
    }
    return 0;
}

@end
