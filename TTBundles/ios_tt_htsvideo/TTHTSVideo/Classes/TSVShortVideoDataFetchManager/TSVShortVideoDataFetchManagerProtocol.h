//
//  TSVShortVideoDataFetchManagerProtocol.h
//  Article
//
//  Created by 王双华 on 2017/6/20.
//
//

#import "TSVShortVideoOriginalData.h"

typedef void(^TTFetchListFinishBlock)(NSUInteger increaseCount, NSError *error);
typedef void(^TTFetchListDataDidChangeBlock)(void);

typedef enum : NSUInteger {
    TSVShortVideoListEntranceOther,
    TSVShortVideoListEntranceFeedCard,
    TSVShortVideoListEntranceProfile,
    TSVShortVideoListEntranceStory
} TSVShortVideoListEntrance;

@protocol TSVShortVideoDataFetchManagerProtocol<NSObject>

@property (nonatomic, assign) NSInteger currentIndex;//当前位置
@property (nonatomic, assign) BOOL hasMoreToLoad;//是否还能loadmore
@property (nonatomic, assign) BOOL isLoadingRequest;//是否正在加载中
@property (nonatomic, assign) BOOL shouldShowNoMoreVideoToast;//是否需要弹没有更多视频的toast

@property (nonatomic, assign) NSInteger listCellCurrentIndex;//列表上归位cell的index
@property (nonatomic, strong) id detailCellCurrentItem;        //列表上归位cell的model

/*
 *  列表items数量
 */
- (NSUInteger)numberOfShortVideoItems;

/*
 *  对应位置下的model
 */
- (TTShortVideoModel *)itemAtIndex:(NSInteger)index;

/*
 *  对应位置下的model
 *  params:
 *  replaced 是否返回被替换的model
 */
- (TTShortVideoModel *)itemAtIndex:(NSInteger)index replaced:(BOOL)replaced;

/*
 *  请求数据
 */
- (void)requestDataAutomatically:(BOOL)isAutomatically
                     finishBlock:(TTFetchListFinishBlock)finishBlock;

/*
 *  替换当前位置的model
 */
- (void)replaceModel:(TTShortVideoModel *)model atIndex:(NSInteger)index;

/*
 *  返回被替换的index
 */
- (NSInteger)replacedIndex;

@optional

@property (nonatomic, readonly) TSVShortVideoListEntrance entrance;
@property (nonatomic, copy) TTFetchListDataDidChangeBlock dataDidChangeBlock;

@end
