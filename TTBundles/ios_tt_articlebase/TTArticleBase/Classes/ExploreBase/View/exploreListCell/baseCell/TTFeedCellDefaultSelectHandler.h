//
//  TTFeedCellDefaultSelectHandler.h
//  Article
//
//  Created by Chen Hong on 2017/2/10.
//
//

#import <Foundation/Foundation.h>
#import "TTArticlePicView.h"
#import "ArticleDetailHeader.h"

@class ExploreCellViewBase;
//@class ArticleJSBridgeWebView;
//@class SSJSBridgeWebViewDelegate;
@class ExploreOrderedData;

#pragma mark cellSelect上下文
@interface TTFeedCellSelectContext : NSObject

// 卡片id
@property(nonatomic, copy) NSString *cardId;

// 卡片项index
@property(nonatomic) NSInteger cardIndex;

// 隐藏的移动建站广告落地页 预加载webview
//@property (nonatomic, strong) ArticleJSBridgeWebView *hiddenWebView;

// 在预加载广告时，将delegate对象传出去，为了之后delegate方法调用
//@property (nonatomic, strong) SSJSBridgeWebViewDelegate *transformDelegate;

// 保存外部传递的condition
@property(nonatomic, strong) NSDictionary *externalRequestCondtion;

// 入口refer
@property(nonatomic) NSUInteger refer;

// data
@property(nonatomic, strong) ExploreOrderedData *orderedData;

// categoryId (卡片内文章的所属的orderedData比较特殊）
@property(nonatomic, copy) NSString *categoryId;

// 点击cell上的评论
@property(nonatomic) BOOL clickComment;

@property (nonatomic, assign) CGRect picViewFrame;

@property (nonatomic, assign) TTArticlePicViewStyle picViewStyle;

@property (nonatomic, weak)UIView *targetView;

@end


#pragma mark cellSelect默认处理
@interface TTFeedCellDefaultSelectHandler : NSObject

// 一些不依赖具体cell和cell数据类型的通用处理（处理ExploreOrderedData）
+ (void)postSelectCellView:(ExploreCellViewBase *)cellView context:(TTFeedCellSelectContext *)context;

// 一些不依赖具体cell，与具体数据类型相关的处理（如，Article，HuoShan）
+ (void)didSelectCellView:(ExploreCellViewBase *)cellView context:(TTFeedCellSelectContext *)context;

+ (NewsGoDetailFromSource)goDetailFromSouce:(ExploreOrderedData *)orderedData;
@end
