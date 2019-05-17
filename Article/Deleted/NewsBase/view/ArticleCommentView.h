//
//  ArticleCommentView.h
//  Article
//
//  Created by SunJiangting on 14-5-25.
//
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"
#import "SSThemed.h"

extern unsigned int g_momentForumCommentMaxCharactersLimit;

extern NSString *const kArticleCommentViewInsertForwardCommentNotification;

@class ArticleCommentView, ArticleMomentCommentModel, HPGrowingTextView;
@protocol ArticleComentViewDelegate <NSObject>

@required
- (void) commentView:(ArticleCommentView *) commentView didFinishPublishComment:(ArticleMomentCommentModel *) commentModel;

@optional
- (void) commentView:(ArticleCommentView *) commentView
     willChangeFrame:(CGRect) newFrame
      keyboardHidden:(BOOL) keyboardHidden
         contextInfo:(id) contextInfo;

- (void) commentView:(ArticleCommentView *) commentView
      didChangeFrame:(CGRect) newFrame
      keyboardHidden:(BOOL) keyboardHidden
         contextInfo:(id) contextInfo;

- (void) commentView:(ArticleCommentView *)commentView
     publishWithText:(NSString *)text;

/// 当点击空白时，该输入框会dismiss。如果是因为点击空白，则会触发此回掉。如果是主动调用dismissAnimated: 则不会触发
- (BOOL) commentViewShouldDismiss:(ArticleCommentView *) commentView;
- (void) commentViewDidDismiss:(ArticleCommentView *) commentView;

@end

typedef void(^ArticleCommentViewFinishBlock)(ArticleMomentCommentModel *model, NSError *error);
typedef void(^ArticleCommentViewDismissBlock)(ArticleCommentView *commentView);
/// 评论输入框
@interface ArticleCommentView : SSViewBase

/// SSThemedTextView中夜间模式键盘也是夜间的。
@property (nonatomic, strong) HPGrowingTextView    *textView;
////
@property (nonatomic, strong) SSThemedView        *backgroundView;

@property (nonatomic, strong) SSThemedView        *commentView;

@property (nonatomic, strong, readonly) SSThemedButton    *publishButton;

@property (nonatomic, weak) id<ArticleComentViewDelegate> delegate;

//block优先级高于delegate..真想把这个组件干掉
@property (nonatomic, copy) ArticleCommentViewFinishBlock finishBlock;
@property (nonatomic, copy) ArticleCommentViewDismissBlock dismissBlock;

/// 这里是一个万能参数。
@property (nonatomic, strong) NSDictionary  * contextInfo;

//需要额外发送的埋点数据，外部带入
@property (nonatomic, copy) NSDictionary *extraTrackDict;

@property (nonatomic, assign) BOOL fromThread;

/// if view == nil, view = keywindow. this commentView will be added to view
- (void) showInView:(UIView *) view animated:(BOOL) animated;

/* Called to dismiss the popover programmatically. The delegate methods for "should" and "did" dismiss are not called when the popover is dismissed in this way.
 */
- (void) dismissAnimated:(BOOL) animated;

@end

@class ArticleMomentCommentModel;
@interface ArticleCommentView (PublishAction)

- (void) publishCommentWithContextInfo:(NSDictionary *) contextInfo
                           finishBlock:(void(^)(ArticleMomentCommentModel *model, NSError *error))finishBlock ;

@end
/// 以下key是用于contextInfo中使用的
extern NSString * const ArticleMomentCommentModelKey;
extern NSString * const ArticleMomentModelKey;
extern NSString * const ArticleKeyboardHiddenKey;
extern NSString * const ArticleCommentModelKey; //同步到文章评论时需要CommentModel
