//
//  FHFeedUGCCellModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/6.
//

#import <Foundation/Foundation.h>
#import "FHFeedContentModel.h"
#import "FHFeedUGCContentModel.h"
#import "FHHouseUGCHeader.h"
#import "TTRichSpanText.h"
#import "TTRichSpanText+Emoji.h"
#import "TTVFeedItem+Extension.h"
#import "TTVFeedListItem.h"
#import "FHUGCScialGroupModel.h"

@class FHCommunityFeedListController;

NS_ASSUME_NONNULL_BEGIN

@interface FHFeedUGCCellCommunityModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *socialGroupId;
//1为不可见，其他可见
@property (nonatomic, copy , nullable) NSString *showStatus;
@end

@interface FHFeedUGCCellUserModel : NSObject

@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *userId;
@property (nonatomic, copy , nullable) NSString *schema;
@property (nonatomic, copy , nullable) NSString *userAuthInfo;

@end

@interface FHFeedUGCOriginItemModel : NSObject

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *contentRichSpan;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) FHFeedContentImageListModel *imageModel;
@property (nonatomic, copy , nullable) NSAttributedString *contentAStr;
@property (nonatomic, strong) TTRichSpanText *richContent;

@end

@interface FHFeedUGCVoteModel : NSObject

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *personDesc;
@property (nonatomic, copy , nullable) NSString *leftDesc;
@property (nonatomic, copy , nullable) NSString *rightDesc;
@property (nonatomic, copy , nullable) NSString *leftValue;
@property (nonatomic, copy , nullable) NSString *rightValue;
@property (nonatomic, copy , nullable) NSString *contentAStr;
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, assign) BOOL needUserLogin;

@end

@interface FHFeedUGCCellContentDecorationModel : JSONModel
@property (nonatomic, copy , nullable) NSString *url;
@end


typedef NS_ENUM(NSUInteger, FHFeedUGCDiggType) {
    FHFeedUGCDiggType_Unknown, // 未知
    FHFeedUGCDiggType_Increase,// 点赞加一
    FHFeedUGCDiggType_Decrease,// 点选减一
};
@interface FHFeedUGCCellModel : NSObject

@property (nonatomic, assign) FHUGCFeedListCellType cellType;
@property (nonatomic, assign) FHUGCFeedListCellSubType cellSubType;
//文章相关
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSAttributedString *desc;
@property (nonatomic, copy , nullable) NSString *aggrType;
//问答跳转链接，优先使用这个值跳转
@property (nonatomic, copy , nullable) NSString *openUrl;
//列表页小图
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel *> *imageList;
//点击小图放大后的大图
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel *> *largeImageList;
//帖子相关
@property (nonatomic, strong , nullable) FHFeedUGCCellUserModel *user ;
@property (nonatomic, copy , nullable) NSString *diggCount;
@property (nonatomic, copy , nullable) NSString *readCount;
@property (nonatomic, copy , nullable) NSString *userDigg;
@property (nonatomic, assign) FHFeedUGCDiggType lastUserDiggType; // 上一次点赞操作的类型
@property (nonatomic, copy , nullable) NSString *commentCount;
@property (nonatomic, copy , nullable) NSString *contentRichSpan;
@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *behotTime;
//计算高度相关
@property (nonatomic, strong , nullable) NSAttributedString *contentAStr;
@property (nonatomic, assign) CGFloat contentHeight;
//是否显示查看全文
@property (nonatomic, assign) BOOL showLookMore;
//是否需要link解析，默认不解析
@property (nonatomic, assign) BOOL needLinkSpan;
@property (nonatomic, strong) TTRichSpanText *richContent;
//支持的link解析类型
@property (nonatomic, strong) NSArray *supportedLinkType;
//文字的显示行数,默认是0
@property (nonatomic, assign) NSInteger numberOfLines;
//跳转详情页的scheme
@property (nonatomic, copy , nullable) NSString *detailScheme;
//原始数据
@property (nonatomic, strong , nullable) id originData;
//tableview
@property (nonatomic, weak) UITableView *tableView;
//feedVC
@property (nonatomic, weak) FHCommunityFeedListController *feedVC;
//感兴趣的小区
@property (nonatomic, strong , nullable) NSArray<FHFeedContentRecommendSocialGroupListModel> *recommendSocialGroupList;
//唯一Id
@property (nonatomic, copy , nullable) NSString *groupId;
//频道Id
@property (nonatomic, copy , nullable) NSString *categoryId;
//是否需要插入了引导页
@property (nonatomic, assign) BOOL isInsertGuideCell;
//圈子相关
@property (nonatomic, strong , nullable) FHFeedUGCCellCommunityModel *community;
//是否显示圈子名称，默认为YES
@property (nonatomic, assign) BOOL showCommunity;
//原始文章或者问答
@property (nonatomic, strong , nullable) FHFeedUGCOriginItemModel *originItemModel;
@property (nonatomic, assign) CGFloat originItemHeight;
//热门话题
@property (nonatomic, strong , nullable) NSArray<FHFeedContentRawDataHotTopicListModel> *hotTopicList;
//投票
@property (nonatomic, strong , nullable) FHFeedUGCVoteModel *vote;
//UGC 投票
@property (nonatomic, strong , nullable) FHUGCVoteInfoVoteInfoModel *voteInfo;
//视频和小视频相关
@property (nonatomic, assign) BOOL hasVideo;
@property (nonatomic, strong , nullable) TTVFeedItem *videoFeedItem;
@property (nonatomic, strong , nullable) TTVFeedListItem *videoItem;
@property (nonatomic, assign) NSInteger videoDuration;
@property (nonatomic, strong , nullable) FHFeedContentVideoDetailInfoModel *videoDetailInfo ;
//埋点相关
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy) NSString *elementFrom;
@property (nonatomic, copy) NSString *enterFrom;
@property (nonatomic, strong) NSDictionary *tracerDic;
// 是否置顶
@property (nonatomic, assign) BOOL isStick;
// 置顶类型：精华或其它
@property (nonatomic, assign) FHFeedContentStickStyle stickStyle;
// 内容装饰
@property (nonatomic, strong) FHFeedUGCCellContentDecorationModel *contentDecoration;
// 隐藏...,默认为显示
@property (nonatomic, assign) BOOL hiddenMore;
// 数据内容是否有变化，如果有则刷新数据时候会刷新，没有则不会刷新，在对cellModel改动需要刷新页面时候，需要设置成YES
@property (nonatomic, assign) BOOL ischanged;
@property (nonatomic, assign) BOOL isCustomDecorateImageView;
// 来自详情页
@property (nonatomic, assign)   BOOL       isFromDetail;
// 区分是否是头条的帖子 （113）
@property (nonatomic, copy , nullable) NSString *groupSource;
// 是否已编辑
@property (nonatomic, assign) BOOL hasEdit;
// 是否来源于编辑历史页面
@property (nonatomic, assign) BOOL isFromEditHistory;
// 热门小区，买房问答
@property (nonatomic, strong , nullable) NSArray<FHFeedContentRawDataHotCellListModel> *hotCellList;
//热门小区的二级类型，用来区分热门小区和感兴趣的小区
@property (nonatomic, copy , nullable) NSString *hotCommunityCellType;
//帖子编辑状态。默认是none
@property (nonatomic, assign) FHUGCPostEditState editState;
//小区问答模块
@property (nonatomic, copy , nullable) NSString *qid;
@property (nonatomic, assign) NSInteger answerCount;
@property (nonatomic, copy , nullable) NSString *answerCountText;
@property (nonatomic, copy , nullable) NSString *writeAnswerSchema;
@property (nonatomic, copy , nullable) NSString *questionStr;
@property (nonatomic, copy , nullable) NSString *answerStr;
@property (nonatomic, strong , nullable) NSAttributedString *questionAStr;
@property (nonatomic, assign) CGFloat questionHeight;
@property (nonatomic, strong , nullable) NSAttributedString *answerAStr;
@property (nonatomic, assign) CGFloat answerHeight;
//是否在小区问答列表页
@property (nonatomic, assign) BOOL isInNeighbourhoodQAList;
//小区点评模块

//是否在小区点评列表页
@property (nonatomic, assign) BOOL isInNeighbourhoodCommentsList;
//底部分割线高度
@property (nonatomic, assign) CGFloat bottomLineHeight;
@property (nonatomic, assign) CGFloat bottomLineLeftMargin;
@property (nonatomic, assign) CGFloat bottomLineRightMargin;
//底部卡片
@property (nonatomic, strong , nullable) FHFeedUGCContentAttachCardInfoModel *attachCardInfo ;
@property (nonatomic, strong, nullable) NSArray<FHUGCScialGroupDataModel> *hotSocialList;
//cell距离顶部
@property (nonatomic, copy , nullable) NSString *upSpace;
//cell距离底部
@property (nonatomic, copy , nullable) NSString *downSpace;
//分割线设置
@property (assign, nonatomic) BOOL hidelLine;
//百科内容
@property (nonatomic, copy , nullable) NSString *articleTitle;
//百科图标
@property (nonatomic, copy , nullable) NSString *avatar;
//查看全部
@property (nonatomic, copy , nullable) NSString *allSchema;


+ (FHFeedContentModel *)contentModelFromFeedContent:(NSString *)content;

+ (FHFeedUGCCellModel *)modelFromFeed:(id)content;

+ (FHFeedUGCCellModel *)modelFromFeedWithDict:(NSDictionary *)content;

+ (FHFeedUGCCellModel *)modelFromFeedUGCContent:(FHFeedUGCContentModel *)model;

+ (FHFeedUGCCellModel *)modelFromFeedContent:(FHFeedContentModel *)model;

+ (FHFeedUGCCellModel *)modelFromFake;

+ (FHFeedUGCCellModel *)modelFromFake2;

+ (FHFeedUGCCellModel *)modelFromFake3:(BOOL)isList;

@end

NS_ASSUME_NONNULL_END
