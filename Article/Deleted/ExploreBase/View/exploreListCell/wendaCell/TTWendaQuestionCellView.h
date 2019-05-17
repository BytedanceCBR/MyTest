//
//  TTWendaQuestionCellView.h
//  Article
//
//  Created by wangqi.kaisa on 2017/10/12.
//

#import "ExploreCellViewBase.h"

/*
 * 10.12  在feed展示的问答提问cell类中的实际内容展示view
 *        topPadding优先级高，1的bottom和2的top有冲突，隐藏1的bottom
 *        要区分feed频道和关注频道
 * 10.15  引入两个属性为了支持区分AB方案，默认展示B方案
 *        为了减少测试工作量，A方案暂不做代码优化
 * 10.19  从UGC得到消息，关注频道去掉已阅读状态
 * 10.23  从UGC得到消息，顶部各控件间间距又变了，还要区分关注频道和推荐频道
 * 12.11  从UGC得到消息，对feed／关注频道中的问答cell做大的UI调整（根据模型类中的layout_type字段做控制）
 */

@interface TTWendaQuestionCellView : ExploreCellViewBase

@end
