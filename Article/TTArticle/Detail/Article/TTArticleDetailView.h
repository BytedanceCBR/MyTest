//
//  TTArticleDetailView.h
//  Article
//
//  Created by 冯靖君 on 16/4/8.
//
//

#import "SSThemed.h"
#import "TTDetailModel.h"
#import "ArticleInfoManager.h"
#import "TTArticleDetailViewModel.h"
#import "TTDetailWebviewContainer.h"
#import "ArticleInfoManager.h"

//定义一些需要通知VC处理的事件
@protocol TTArticleDetailViewDelegate <NSObject>

@optional
//- (void)tt_articleDetailViewShouldLoadNativeContent;
- (void)tt_articleDetailViewWillShowLargeImage;

//added 5.6, 展示第一条评论
- (void)tt_articleDetailViewWillShowFirstCommentCell;

//added 5.7, 浮层half状态时webView的相对offset
- (void)tt_articleDetailViewFooterHalfStatusOffset:(CGFloat)rOffset;

//added 5.7, 拖拽隐藏insert类型的浮层
- (void)tt_articleDetailViewWillCloseFooter;

//added 5.7, 更改字体通知VC
- (void)tt_articleDetailViewWillChangeFontSize;
- (void)tt_articleDetailViewDidChangeFontSize;

- (void)webView:(nullable TTDetailWebviewContainer *)webViewContainer scrollViewDidScroll:(nullable UIScrollView *)scrollView;
- (void)webView:(nullable TTDetailWebviewContainer *)webViewContainer
        scrollViewDidEndDragging:(nullable UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate;

//详情页插入菜单栏
- (void)tt_articleDetailViewWillShowActionSheet:(NSDictionary * _Nullable)result;

//详情页举报错别字
- (void)tt_articleDetailViewTypos:(NSArray * _Nullable)resultArray;

//详情页dislike
- (void)tt_articleDetailViewWillShowDislike:(nullable NSDictionary *)result;

- (void)tt_articleApplicationStautsBarDidRotate;

- (void)tt_articleDetailViewDidDomReady;
@end

@interface TTArticleDetailView : SSThemedView

@property(nonatomic, nonnull, strong) TTDetailModel *detailModel;
@property(nonatomic, nonnull, strong) TTArticleDetailViewModel *detailViewModel;
@property(nonatomic, nonnull, strong) TTDetailWebviewContainer *detailWebView;
@property(nonatomic, strong) ArticleInfoManager *infoManager;
@property(nonatomic, assign) BOOL domReady;

// titleView显示/隐藏触发高度
@property(nonatomic, assign) CGFloat titleViewAnimationTriggerPosY;

// 5.7 连载小说文章显示/隐藏native工具栏触发高度
@property(nonatomic, assign) CGFloat storyToolViewAnimationTriggerPosY;

@property(nonatomic, nullable, weak) id<TTArticleDetailViewDelegate> delegate;

- (nonnull instancetype)initWithFrame:(CGRect)frame
                          detailModel:(nullable TTDetailModel *)detailModel;


/**
 *  拿到可依赖数据后，开始渲染文章
 */
- (void)tt_startLoadWebViewContent;

/**
 *  information接口返回后更新文章
 *
 *  @param infomanager 存储数据的infoManager
 */
- (void)tt_handleDetailViewWithInfoManager:(nonnull ArticleInfoManager *)infoManager;

- (void)tt_setContentAndExtraWithArticle:(nonnull Article *)article;

/**
 *  根据information返回判断是否需要删除文章
 */
- (void)tt_deleteArticleByInfoFetchedIfNeeded;

/**
 *  给文章详情页添加特定类型的浮层
 *
 *  @param footerView 浮层View
 *  @param footerScrollView 浮层View的子scrollView
 */
- (void)tt_setNatantWithFooterView:(nullable UIView *)footerView includingFooterScrollView:(nonnull UIScrollView *)footerScrollView;

/**
 *  判断是否是连载小说
 *
 */
- (BOOL)tt_isNovelArticle;

/**
 *  详情页接口端监控
 *
 */
- (void)tt_initializeServerRequestMonitorWithName:(NSString * _Nullable)apiName;
- (void)tt_serverRequestTimeMonitorWithName:(NSString * _Nullable)apiName error:(NSError * _Nullable)error;

@end
