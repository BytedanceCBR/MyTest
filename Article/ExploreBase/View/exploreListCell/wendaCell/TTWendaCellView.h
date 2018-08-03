//
//  TTWendaCellView.h
//  Article
//
//  Created by wangqi.kaisa on 2017/7/13.
//
//

#import "ExploreCellViewBase.h"

/*
 * 7.13  在feed展示的问答cell类中的实际内容展示view
 * 7.30  topPadding优先级高，1的bottom和2的top有冲突，隐藏1的bottom
 * 8.29  区分feed频道和关注频道
 * 9.04  稍后找时间将这两种cell拆分
 * 10.23 从UGC得到消息，顶部各控件间间距又变了，还要区分关注频道和推荐频道
 */

@class ExploreOrderedData;

@interface TTWendaCellView : ExploreCellViewBase

@property (nonatomic, strong) ExploreOrderedData *orderedData;

@end
