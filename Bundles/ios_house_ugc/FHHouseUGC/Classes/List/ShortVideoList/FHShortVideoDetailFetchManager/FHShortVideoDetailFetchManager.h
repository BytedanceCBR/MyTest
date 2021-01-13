//
//  FHShortVideoDetailFetchManager.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/9/18.
//

#import <Foundation/Foundation.h>
#import "TSVDataFetchManager.h"
#import "FHFeedUGCCellModel.h"
#import "TSVShortVideoDataFetchManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^DataDidChangeBlock)(void);
@interface FHShortVideoDetailFetchManager : NSObject
@property (nonatomic,strong) FHFeedUGCCellModel *currentShortVideoModel;
@property (nonatomic,strong) NSArray<FHFeedUGCCellModel* > *otherShortVideoModels;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, copy) NSString *groupID;
@property (nonnull, copy) NSString *topID;
@property (nonatomic, copy) NSString *enterFrom;
@property (nonatomic, strong) NSDictionary *tracerDic;
@property (nonatomic, assign) BOOL hasMoreToLoad;//是否还能loadmore
@property (nonatomic, assign) BOOL isLoadingRequest;//是否正在加载中
@property (nonatomic, assign) BOOL canLoadMore;//是否可以加载更多
@property (nonatomic, assign) BOOL shouldShowNoMoreVideoToast;//是否需要弹没有更多视频的toast
@property (nonatomic, copy) DataDidChangeBlock dataDidChangeBlock;
- (FHFeedUGCCellModel *)itemAtIndex:(NSInteger)index;
- (NSUInteger)numberOfShortVideoItems;
- (void)requestDataAutomatically:(BOOL)isAutomatically
                     finishBlock:(TTFetchListFinishBlock)finishBlock;

@end

NS_ASSUME_NONNULL_END
