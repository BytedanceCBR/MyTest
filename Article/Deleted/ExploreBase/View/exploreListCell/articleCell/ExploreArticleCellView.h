//
//  ExploreListCellView.h
//  Article
//
//  Created by Chen Hong on 14-9-9.
//
//

#import "ExploreCellViewBase.h"
#import "ExploreArticleCellCommentView.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "SSThemed.h"
#import "TTActivity.h"
#import "TTLabel.h"
#import "TTArticlePicView.h"

@class ExploreOrderedData;
@class TTImageView;

#define kCellBottomViewHeight   10.f

@interface ExploreArticleCellView : ExploreCellViewBase<ExploreArticleCellCommentViewDelegate>

@property (nonatomic, strong) TTLabel                       *titleLabel;// 标题
@property (nonatomic, strong) UILabel                       *typeLabel;// 分类标签，如专题/要闻/推广等
@property (nonatomic, strong) TTImageView                   *logoIcon;// logo(广告)
@property (nonatomic, strong) UILabel                       *abstractLabel;// 摘要
@property (nonatomic, strong) UIView                        *bottomLineView;// 底部分割线
@property (nonatomic, strong) UIButton                      *unInterestedButton;// 不感兴趣
@property (nonatomic, strong) UIView                        *infoBarView;// 底栏
@property (nonatomic, strong) UILabel                       *infoLabel;//来源+评论数+时间+直播在线人数
@property (nonatomic, strong) SSThemedLabel                 *liveTextLabel;//直播标签
@property (nonatomic, strong) TTArticlePicView              *picView;//图片样式
@property (nonatomic, strong) UILabel                       *sourceLabel;// 推荐理由+来源

@property (nonatomic, assign) BOOL                          hasAbstract;
@property (nonatomic, assign) BOOL                          hasCommentView;// 普通评论
@property (nonatomic, assign) BOOL                          hideUnInerestedButton;// 无不感兴趣按钮
@property (nonatomic, assign) BOOL                          hideTimeLabel;// 不显示时间

@property (nonatomic, strong) ExploreArticleCellCommentView *commentView;
@property (nonatomic, strong) ExploreOrderedData            *orderedData;
@property (nonatomic, strong) ExploreOriginalData           *originalData;//需要retain一下，避免orderData在其他地方remove时将originalData置为nil，导致KVO add/remove不匹配


- (void)removeAbstractLabel;

- (void)removeCommentView;

- (void)updateAbstract;

- (void)updateCommentView;

- (void)updateTypeLabel;

///...
- (void)updateEntityWordView;

- (void)updateContentColor;

- (void)layoutTypeLabel;

- (BOOL)hasLogoIcon;

- (void)layoutUnInterestedBtn;

- (void)layoutBottomLine;

- (void)layoutInfoBarSubViews;

- (void)layoutInfoLabel;

- (void)layoutAbstractAndCommentView:(CGPoint)origin;

- (void)layoutEntityWordViewWithPic:(BOOL)hasPic;

- (void)updateTitleLabel;

- (void)showComment:(id)sender;

- (void)setLabelsColorClear:(BOOL)clear;

@end
