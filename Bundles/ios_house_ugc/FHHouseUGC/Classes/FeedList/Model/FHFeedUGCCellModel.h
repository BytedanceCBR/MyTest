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
#import <TTVFeedItem+Extension.h>
#import <TTVFeedListItem.h>

@class FHCommunityFeedListController;

NS_ASSUME_NONNULL_BEGIN

@interface FHFeedUGCCellCommunityModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *socialGroupId;
@end

@interface FHFeedUGCCellUserModel : NSObject

@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *userId;
@property (nonatomic, copy , nullable) NSString *schema;

@end

@interface FHFeedUGCOriginItemModel : NSObject

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) FHFeedContentImageListModel *imageModel;
@property (nonatomic, copy , nullable) NSAttributedString *contentAStr;

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
@property (nonatomic, copy , nullable) NSString *userDigg;
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

+ (FHFeedUGCCellModel *)modelFromFeed:(NSString *)content;

+ (FHFeedUGCCellModel *)modelFromFeedUGCContent:(FHFeedUGCContentModel *)model;

+ (FHFeedUGCCellModel *)modelFromFeedContent:(FHFeedContentModel *)model;

+ (FHFeedUGCCellModel *)modelFromFake;

+ (FHFeedUGCCellModel *)modelFromFake2;

@end

NS_ASSUME_NONNULL_END
