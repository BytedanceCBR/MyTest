//
//  ExploreListCellReadMe.h
//  Article
//
//  Created by Chen Hong on 15/9/9.
//
//

/*
 
 1. 产品文档 -- 列表页UI样式汇总（包含相关逻辑）
 https://wiki.bytedance.com/pages/viewpage.action?pageId=33390912
 
 2. 头条信息流API文档
 https://wiki.bytedance.com/pages/viewpage.action?pageId=35029249
 
 3. Feed流cell类继承关系

 +---------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 |                                                                 文章                                                                                                 |
 |   +-----------------+       +---------------+         +-------------------------------+                                                                             |
 |   | UITableViewCell | <---+ |ExploreCellBase| <-----+ |ExploreArticlePureTitleCell    |                                                                             |
 |   +-----------------+       +---------------+         |                               |                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       |ExploreArticleTitleRightPicCell|                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       |ExploreArticleTitleGroupPicCell|                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       |ExploreArticleTitleLargePicCell| <------+ ExploreArticleTitleLargePicPlayVideoCell <ExploreArticleVideoCell> |
 |                                                       +-------------------------------+                                                                             |
 |                                                                 段子                                                                                                 |
 |                                                       +-------------------------------+                                                                             |
 |                                                       |ExploreArticleEssayCell        |                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       |ExploreArticleEssayGIFCell     |                                                                             |
 |                                                       +-------------------------------+                                                                             |
 |                                                                                                                                                                     |
 |                                                                财经、本地频道webCell                                                                                  |
 |                                                       +-------------------------------+                                                                             |
 |                                                       |ExploreArticleWebCell          |                                                                             |
 |                                                       +-------------------------------+                                                                             |
 |                                                                广告                                                                                                  |
 |                                                       +-------------------------------+     +---------------------------+                                           |
 |                                                       |ExploreBaseADCell              | <-- |ExploreEmbedGuideCell      |                                           |
 |                                                       +-------------------------------+     |                           |                                           |
 |                                                                                             |ExploreOrderedActionCell   |                                           |
 |                                                                                             |                           |      +--------------------------------+   |
 |                                                                                             |ExploreOrderedArticleADCell+ <---+|ExploreOrderedArticleADSmallCell|   |
 |                                                                美团                          +---------------------------+      |                                |   |
 |                                                       +-------------------------------+                                        |ExploreOrderedArticleADBigCell  |   |
 |                                                       |ExploreArticleMeituanAdCell    |                                        +--------------------------------+   |
 |                                                       +-------------------------------+                                                                             |
 |                                                                上次读到这里                                                                                           |
 |                                                       +-------------------------------+                                                                             |
 |                                                       |ExploreLastReadCell            |                                                                             |
 |                                                       +-------------------------------+                                                                             |
 |                                                                                                                                                                     |
 |                                                                订阅频道                                                                                              |
 |                                                       +-------------------------------+                                                                             |
 |                                                       |ExploreSubscribePGCCell        |                                                                             |
 |                                                       +-------------------------------+                                                                             |
 |                                                                 卡片                                                                                                 |
 |                                                       +-------------------------------+                                                                             |
 |                                                       |ExploreArticleCardCell         |                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       |ExploreCardItemCell            |                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       |ExploreArticleChannelCell      |                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       |ExploreFeedMomentCell          |                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       |ExploreArticlePGCCell          |                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       |ExploreRecommendUsersCell      |                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       |ExploreFeedTalkCell            |                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       |ExploreArticleUserCell         |                                                                             |
 |                                                       +-------------------------------+                                                                             |
 |                                                                                                                                                                     |
 |                                                                  视频                                                                                                |
 |                                                       +-------------------------------+                                                                             |
 |                                                       |ExploreArticleVideoCell        |                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       |ExploreArticleVideoCellStyleA  | <ExploreArticleVideoCell>                                                   |
 |                                                       |                               |                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       |                               |                                                                             |
 |                                                       +-------------------------------+                                                                             |
 |                                                                                                                                                                     |
 |                                                                                                                                                                     |
 |                                                                                                                                                                     |
 +---------------------------------------------------------------------------------------------------------------------------------------------------------------------+

 4. cell类说明
 
 ExploreCellBase，所有列表cell的基类，负责创建各子类的cellView，监听字体变化，夜间模式通知，refreshWithData/refreshUI/点击高亮/cell高度计算转发到cellView
 +--------------------------------+
 | cell                           |
 | +----------------------------+ |
 | | contentView                | |
 | | +------------------------+ | |
 | | | cellView               | | |
 | | |                        | | |
 | | |                        | | |
 | | +------------------------+ | |
 | +----------------------------+ |
 +--------------------------------+

 
 ExploreCellViewBase，所有cell中cellView的基类，定义一些共有属性，如当前cell相邻前/后一个cell是否为lastReadCell，是否隐藏bottomline，是否在卡片cell内等
 
 ExploreArticleCellView，所有文章类型cellView的基类，包含共有UI属性，标题，摘要，标签，infoBar，不感兴趣按钮，分割线
 
 纯标题文章 ExploreArticlePureTitleCellView
 右图文章 ExploreArticleTitleRightPicCellView
 三图文章 ExploreArticleTitleGroupPicCellView
 大图文章 ExploreArticleTitleLargePicCellView
 大图文章类型的视频 ExploreArticleTitleLargePicPlayVideoCellView
 段子/趣图 ExploreArticleEssayCellView
 GIF趣图 ExploreArticleEssayGIFCellView
 标题在图片内（上部）的视频 ExploreArticleVideoCellView
 标题在图片外（下部）的视频 ExploreArticleVideoCellViewStyleA

 卡片容器 ExploreArticleCardCellView，可动态包含其他cellView，其他类型cell与卡片cell相邻时要注意分割线的显隐，不然多条分割线会重叠
 
 +----------------------------------------------------------------------------------------------------------------------------------------------------------+
 |                                                                                                                                                          |
 |   ExploreCellViewBase <----+  ExploreArticleCellView <----+ ExploreArticlePureTitleCellView                                                              |
 |                                                                                                                                                          |
 |                                                             ExploreArticleTitleRightPicCellView                                                          |
 |                                                                                                                                                          |
 |                                                             ExploreArticleTitleGroupPicCellView                                                          |
 |                                                                                                                                                          |
 |                                                             ExploreArticleTitleLargePicCellView <------+  ExploreArticleTitleLargePicPlayVideoCellView   |
 |                                                                                                                                                          |
 |                                                                                                                                                          |
 |                                                             ExploreArticleEssayCellView         <------+  ExploreArticleEssayGIFCellView                 |
 |                                                                                                                                                          |
 |                                                                                                                                                          |
 |                                                             ExploreArticleVideoCellView                                                                  |
 |                                                                                                                                                          |
 |                                                             ExploreArticleVideoCellViewStyleA                                                            |
 |                                                                                                                                                          |
 |                                                             ExploreArticleCardCellView                                                                   |
 |                                                                                                                                                          |
 +----------------------------------------------------------------------------------------------------------------------------------------------------------+

 财经股指，本地频道webCell，第一次加载时先取模板内容，加载到webView中，然后取data，调用js填充data到模板页面中
 +-------------------------------------------------------------+
 |                                                             |
 |   ExploreCellViewBase <----+  ExploreArticleWebCellView     |
 |                                                             |
 +-------------------------------------------------------------+

 +-----------------------------------------+
 | ExploreArticleWebCellView               |
 | +-------------------------------------+ |
 | |ArticleJSBridgeWebView               | |
 | |                                     | |
 | +-------------------------------------+ |
 +-----------------------------------------+

 */


#ifndef Article_ExploreListCellReadMe_h
#define Article_ExploreListCellReadMe_h


#endif
