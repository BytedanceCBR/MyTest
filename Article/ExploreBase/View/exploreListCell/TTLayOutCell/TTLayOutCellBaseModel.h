//
//  TTLayOutCellBaseModel.h
//  Article
//
//  Created by 王双华 on 16/10/13.
//
//

#import <Foundation/Foundation.h>
#import "ExploreCellBase.h"
#import "TTArticlePicView.h"
#import "TTFollowThemeButton.h"

#define kCellHeightChangeNotificationKey @"kCellHeightChangeNotificationKey"

@class ExploreOrderedData;

@interface TTLayOutCellBaseModel : NSObject

@property (nonatomic, assign) BOOL needUpdateAllFrame;
@property (nonatomic, weak, readonly) ExploreOrderedData *orderedData;
@property (nonatomic, assign, readonly) ExploreOrderedDataListType listType;
@property (nonatomic, assign, readonly) CGFloat cellWidth;
@property (nonatomic, assign) CGFloat originX;//cell 布局的left padding 现在都是15
@property (nonatomic, assign) CGFloat originY;
@property (nonatomic, assign) CGFloat containWidth;
@property (nonatomic, assign) CGFloat infoBarOriginY;
@property (nonatomic, assign) CGFloat actionLabelY;
@property (nonatomic, assign) CGFloat infoBarContainWidth;
@property (nonatomic, assign) BOOL hideTimeForRightPic;
//喜欢
@property (nonatomic, assign) CGRect likeLabelFrame;
@property (nonatomic, assign) BOOL likeLabelHidden;
//关注
@property (nonatomic, assign) CGRect subscriptLabelFrame;
@property (nonatomic, assign) BOOL subscriptLabelHidden;
//实体词
@property (nonatomic, assign) CGRect entityLabelFrame;
@property (nonatomic, assign) BOOL entityLabelHidden;
//更多
@property (nonatomic, assign) CGRect moreImageViewFrame;
@property (nonatomic, assign) BOOL moreImageViewHidden;
//更多按钮
@property (nonatomic, assign) CGRect moreButtonFrame;
@property (nonatomic, assign) BOOL moreButtonHidden;
//评论按钮
@property (nonatomic, assign) CGRect commentButtonFrame;
@property (nonatomic, assign) BOOL commentButtonHidden;
@property (nonatomic, copy)   NSString *commentButtonImageName;
@property (nonatomic, copy)   NSString *commentButtonTextColorThemeKey;
@property (nonatomic, assign) CGFloat commentButtonFontSize;
@property (nonatomic, assign) UIEdgeInsets commentButtonContentInsets;
@property (nonatomic, assign) UIEdgeInsets commentButtonTitleInsets;
//点赞按钮
@property (nonatomic, assign) CGRect digButtonFrame;
@property (nonatomic, assign) BOOL digButtonHidden;
@property (nonatomic, copy)   NSString *digButtonImageName;
@property (nonatomic, copy)   NSString *digButtonSelectedImageName;
@property (nonatomic, copy)   NSString *digButtonTextColorThemeKey;
@property (nonatomic, assign) CGFloat digButtonFontSize;
@property (nonatomic, assign) UIEdgeInsets digButtonContentInsets;
@property (nonatomic, assign) UIEdgeInsets digButtonTitleInsets;
@property (nonatomic, assign) BOOL needMultiDiggAnimation;
//转发按钮
@property (nonatomic, assign) CGRect forwardButtonFrame;
@property (nonatomic, assign) BOOL forwardButtonHidden;
@property (nonatomic, copy)   NSString *forwardButtonImageName;
@property (nonatomic, copy)   NSString *forwardButtonTextColorThemeKey;
@property (nonatomic, assign) CGFloat forwardButtonFontSize;
@property (nonatomic, assign) UIEdgeInsets forwardButtonContentInsets;
@property (nonatomic, assign) UIEdgeInsets forwardButtonTitleInsets;
//时间
@property (nonatomic, assign) CGRect timeLabelFrame;
@property (nonatomic, assign) BOOL timeLabelHidden;
//标题
@property (nonatomic, assign) CGRect titleLabelFrame;
@property (nonatomic, assign) BOOL titleLabelHidden;
@property (nonatomic, copy)   NSAttributedString *titleAttributedStr;
@property (nonatomic, assign) NSUInteger titleLabelNumberOfLines;
//图片
@property (nonatomic, assign) CGRect picViewFrame;
@property (nonatomic, assign) BOOL picViewHidden;
@property (nonatomic, assign) TTArticlePicViewStyle picViewStyle;
@property (nonatomic, assign) BOOL picViewHiddenMessage;
@property (nonatomic, assign) BOOL picViewUserInteractionEnabled;
//来源头像
@property (nonatomic, assign) CGRect sourceImageViewFrame;
@property (nonatomic, assign) BOOL sourceImageViewHidden;
@property (nonatomic, copy)   NSString *sourceImageURLStr;
@property (nonatomic, copy)   NSString *sourceNameFirstWord;
@property (nonatomic, assign) CGFloat sourceNameFirstWordFontSize;
@property (nonatomic, assign) BOOL sourceImageUserInteractionEnabled;
//来源名称
@property (nonatomic, assign) CGRect sourceLabelFrame;
@property (nonatomic, assign) BOOL sourceLabelHidden;
@property (nonatomic, assign) CGFloat sourceLabelFontSize;
@property (nonatomic, copy)   NSString *sourceLabelStr;
@property (nonatomic, copy)   NSString *sourceLabelTextColorThemeKey;
@property (nonatomic, assign) BOOL sourceLabelUserInteractionEnabled;
//不感兴趣
@property (nonatomic, assign) CGRect unInterestedButtonFrame;
@property (nonatomic, assign) BOOL unInterestedButtonHidden;
//信息栏
@property (nonatomic, assign) CGRect infoLabelFrame;
@property (nonatomic, assign) BOOL infoLabelHidden;
@property (nonatomic, assign) CGFloat infoLabelFontSize;
@property (nonatomic, copy)   NSString *infoLabelStr;
@property (nonatomic, copy)   NSString *infoLabelTextColorThemeKey;
//直播标签
@property (nonatomic, assign) CGRect liveTextLabelFrame;
@property (nonatomic, assign) BOOL liveTextLabelHidden;
//类型标签
@property (nonatomic, assign) CGRect typeLabelFrame;
@property (nonatomic, assign) BOOL typeLabelHidden;
@property (nonatomic, strong) NSString *typeLabelStr;
//摘要
@property (nonatomic, assign) CGRect abstractLabelFrame;
@property (nonatomic, assign) BOOL abstractLabelHidden;
@property (nonatomic, strong) NSString *abstractLabelTextColorThemeKey;
@property (nonatomic, assign) NSUInteger abstractLabelNumberOfLines;
@property (nonatomic, strong) NSAttributedString *abstractAttributedStr;
//评论
@property (nonatomic, assign) CGRect commentLabelFrame;
@property (nonatomic, assign) BOOL commentLabelHidden;
@property (nonatomic, strong) NSAttributedString *commentAttributedStr;
@property (nonatomic, assign) NSUInteger commentLabelNumberOfLines;
@property (nonatomic, assign) BOOL commentLabelUserInteractionEnabled;
@property (nonatomic, strong) NSString *commentLabelTextColorThemeKey;
@property (nonatomic, strong) NSAttributedString * commentAttrLabelAttributedStr;
@property (nonatomic, strong) NSAttributedString* commentAttrTruncationToken; //...全文按钮
//添加实体词view
@property (nonatomic, assign) CGRect entityWordViewFrame;
@property (nonatomic, assign) BOOL entityWordViewHidden;
//底部分割线
@property (nonatomic, assign) CGRect bottomLineViewFrame;
@property (nonatomic, assign) BOOL bottomLineViewHidden;
//广告view背景
@property (nonatomic, assign) CGRect adBackgroundViewFrame;
@property (nonatomic, assign) BOOL adBackgroundViewHidden;
//广告来源信息
@property (nonatomic, assign) CGRect adSubtitleLabelFrame;
@property (nonatomic, assign) BOOL adSubtitleLabelHidden;
@property (nonatomic, assign) CGFloat adSubtitleLabelFontSize;
@property (nonatomic, strong) NSString *adSubtitleLabelTextColorThemeKey;
@property (nonatomic, strong) NSString *adSubtitleLabelTextColorHex;
@property (nonatomic, assign) BOOL adSubtitleLabelUserInteractionEnabled;
@property (nonatomic, strong) NSString *adSubtitleLabelStr;

//广告位置icon信息
@property (nonatomic, assign) BOOL adLocationIconHidden;
@property (nonatomic, assign) CGRect adLocationIconFrame;
//广告位置label信息
@property (nonatomic, assign) BOOL adLocationLabelHidden;
@property (nonatomic, strong) NSString *adLocationLabelStr;
@property (nonatomic, assign) CGFloat adLocationLabelFontSize;
@property (nonatomic, strong) NSString *adLocationLabelTextColorThemeKey;
@property (nonatomic, assign) CGRect adLocationLabelFrame;

//竖向分割线
@property (nonatomic, assign) CGRect separatorViewFrame;
@property (nonatomic, assign) BOOL separatorViewHidden;
@property (nonatomic, copy)   NSString *separatorViewBackgroundColorThemeKey;
//广告按钮
@property (nonatomic, assign) CGRect actionButtonFrame;
@property (nonatomic, assign) BOOL actionButtonHidden;
@property (nonatomic, assign) CGFloat actionButtonFontSize;
@property (nonatomic, assign) CGFloat actionButtonBorderWidth;
//播放按钮
@property (nonatomic, assign) CGRect playButtonFrame;
@property (nonatomic, assign) BOOL playButtonHidden;
@property (nonatomic, copy)   NSString *playButtonImageName;
@property (nonatomic, assign) BOOL playButtonUserInteractionEnable;
//视频内广告按钮
@property (nonatomic, assign) CGRect adButtonFrame;
@property (nonatomic, assign) BOOL adButtonHidden;
//关注按钮
@property (nonatomic, assign) CGFloat subscribButtonRight;
@property (nonatomic, assign) CGFloat subscribButtonTop;
@property (nonatomic, assign) BOOL subscribButtonHidden;
//u11评论文章标题下背景
@property (nonatomic, assign) CGRect backgroundViewFrame;
@property (nonatomic, assign) BOOL backgroundViewHidden;
@property (nonatomic, strong) NSString *backgroundViewBackgroundColorThemeKey;
//u11评论的文章的标题
@property (nonatomic, assign) CGRect newsTitleLabelFrame;
@property (nonatomic, assign) BOOL newsTitleLabelHidden;
@property (nonatomic, strong) NSAttributedString *newsTitleAttributedStr;
//u11点赞／评论/发布文章来源
@property (nonatomic, assign) CGRect userNameLabelFrame;
@property (nonatomic, assign) BOOL userNameLabelHidden;
@property (nonatomic, copy)   NSString *userNameLabelStr;
//u11 用户大v标志
@property (nonatomic, assign) BOOL userVerifiedImgHidden;
@property (nonatomic, copy)   NSString *userVerifiedImgAuthInfo;
@property (nonatomic, copy)   NSString *userDecoration;
//u11认证信息
@property (nonatomic, assign) CGRect userVerifiedLabelFrame;
@property (nonatomic, assign) BOOL userVerifiedLabelHidden;
@property (nonatomic, strong) NSString *userVerifiedLabelTextColorThemeKey;
@property (nonatomic, copy)   NSString *userVerifiedLabelStr;
@property (nonatomic, assign) CGFloat userVerifiedLabelFontSize;
//u11推荐理由
@property (nonatomic, assign) CGRect recommendLabelFrame;
@property (nonatomic, assign) BOOL recommendLabelHidden;
@property (nonatomic, copy)   NSString *recommendLabelStr;
@property (nonatomic, assign) CGFloat recommendLabelFontSize;
//顶部10pi分隔条
@property (nonatomic, assign) CGRect topRectFrame;
@property (nonatomic, assign) BOOL topRectHidden;
//底部10pi分割条
@property (nonatomic, assign) CGRect bottomRectFrame;
@property (nonatomic, assign) BOOL bottomRectHidden;
//点赞按钮和评论按钮上发的分割线
@property (nonatomic, assign) CGRect actionSepLineFrame;
@property (nonatomic, assign) BOOL actionSepLineHidden;
//评论cell左边的竖线分割线
@property (nonatomic, assign) CGRect verticalLineViewFrame;
@property (nonatomic, assign) BOOL verticalLineViewHidden;

@property (nonatomic, assign) CGRect wenDaButtonFrame;
@property (nonatomic, assign) BOOL wenDaButtonHidden;

@property (nonatomic, assign) BOOL adInnerLoopPicViewHidden;
@property (nonatomic, assign) CGRect adInnerLoopPicViewFrame;
@property (nonatomic, assign) CGSize adInnerLoopPerPicSize;

@property (nonatomic, assign) CGRect motionViewFrame;
@property (nonatomic, assign) BOOL motionViewHidden;

@property (nonatomic, assign) BOOL isExpand;

//cell高度
@property (nonatomic, assign) NSUInteger cellCacheHeight;

- (BOOL)needUpdateHeightCacheForWidth:(CGFloat)width;

- (void)updateFrameForData:(ExploreOrderedData *)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType;

- (void)calculateAllFrame;

- (void)calculateNeedUpdateFrame;

- (CGFloat)heightForHeaderInfoRegionWithTop:(CGFloat)top;

- (CGFloat)heightForHeaderInfoRegionWithDislikeWithTop:(CGFloat)top;

- (CGFloat)heightForHeaderInfoRegionInTwoLinesWithTop:(CGFloat)top needLayoutDislike:(BOOL)layoutDislike;

- (TTFollowThemeButton*)generateFollowButton;
@end
