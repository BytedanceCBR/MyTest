//
//  TTWendaAnswerCellView.h
//  Article
//
//  Created by wangqi.kaisa on 2017/10/12.
//

#import "ExploreCellViewBase.h"

/*
 * 10.12  在feed展示的问答回答cell类中的实际内容展示view
 *        topPadding优先级高，1的bottom和2的top有冲突，隐藏1的bottom
 *        要区分feed频道和关注频道
 * 10.19  从UGC得到消息，关注频道去掉已阅读状态
 * 10.23  从UGC得到消息，顶部各控件间间距又变了，还要区分关注频道和推荐频道
 * 11.13  从UGC得到消息，在关注频道中左右间距从15改成14
 * 12.12  从UGC得到消息，对feed／关注频道中的问答cell做大的UI调整（根据模型类中的layout_type字段做控制）
 * 1.11   从UGC得到消息，下发字段可控是否显示U13底部的阅读数label和三个按钮上面的线
 */

@interface TTWendaAnswerCellView : ExploreCellViewBase

@end
