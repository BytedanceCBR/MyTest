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

@interface FHFeedUGCCellImageListModel : NSObject

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, copy , nullable) NSString *height;
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
@property (nonatomic, copy , nullable) NSString *desc;

@property (nonatomic, strong , nullable) NSArray<FHFeedUGCCellImageListModel *> *imageList;

//帖子相关
@property (nonatomic, strong , nullable) FHFeedUGCCellUserModel *user ;
@property (nonatomic, copy , nullable) NSString *diggCount;
@property (nonatomic, copy , nullable) NSString *commentCount;
@property (nonatomic, copy , nullable) NSString *contentRichSpan;
@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *behotTime;
//是否显示查看全文
@property (nonatomic, assign) BOOL showLookMore;

+ (FHFeedUGCCellModel *)modelFromFeed:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
