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

NS_ASSUME_NONNULL_BEGIN

@interface FHFeedUGCCellImageListUrlListModel : NSObject

@property (nonatomic, copy , nullable) NSString *url;
@end

@interface FHFeedUGCCellImageListModel : NSObject

@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, copy , nullable) NSString *height;
@property (nonatomic, strong , nullable) NSArray<FHFeedUGCCellImageListUrlListModel *> *urlList;
@end

@interface FHFeedUGCCellUserModel : NSObject

@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *avatarUrl;

@end

@interface FHFeedUGCCellModel : NSObject

@property (nonatomic, copy , nullable) NSString *cellType;
@property (nonatomic, assign) FHUGCFeedListCellSubType cellSubType;
//文章相关
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSAttributedString *desc;
//问答跳转链接，优先使用这个值跳转
@property (nonatomic, copy , nullable) NSString *openUrl;
//列表页小图
@property (nonatomic, strong , nullable) NSArray<FHFeedUGCCellImageListModel *> *imageList;
//点击小图放大后的大图
@property (nonatomic, strong , nullable) NSArray<FHFeedUGCCellImageListModel *> *largeImageList;
//帖子相关
@property (nonatomic, strong , nullable) FHFeedUGCCellUserModel *user ;
@property (nonatomic, copy , nullable) NSString *diggCount;
@property (nonatomic, copy , nullable) NSString *commentCount;
@property (nonatomic, copy , nullable) NSString *contentRichSpan;
@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *behotTime;
//是否显示查看全文
@property (nonatomic, assign) BOOL showLookMore;
//跳转详情页的scheme
@property (nonatomic, copy , nullable) NSString *detailScheme;
//原始数据
@property (nonatomic, strong , nullable) id originData;

+ (FHFeedUGCCellModel *)modelFromFeed:(NSString *)content;

+ (FHFeedUGCCellModel *)modelFromFakeData;

@end

NS_ASSUME_NONNULL_END
