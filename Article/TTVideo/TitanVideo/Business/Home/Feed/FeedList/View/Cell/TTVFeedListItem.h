//
//  TTVFeedListItem.h
//  Article
//
//  Created by panxiang on 2017/4/13.
//
//

#import "TTVTableViewItem.h"
#import "TTImageInfosModel+Extention.h"
#import "TTVCellGroupStyle.h"
#import "TTTouchContext.h"
#import "TTVAdActionButtonCommand.h"
#import "TTVShareActionsTracker.h"
#import "TTADTrackEventLinkModel.h"

@protocol TTVDetailRelatedRecommendCellViewModelProtocol;
@class TTVFeedCellAction;
typedef NS_ENUM(NSUInteger, TTVFeedListCellSeparatorStyle){
    TTVFeedListCellSeparatorStyleHas = 0, //视频中间有一条分隔线
    TTVFeedListCellSeparatorStyleNone = 1,    //没有分隔线
};

typedef NS_OPTIONS(NSUInteger, TTVFromOption) {
    TTVFromOptionPullDown  = 1 << 0,
    TTVFromOptionPullUp    = 1 << 1,
    TTVFromOptionMemory    = 1 << 2,
    TTVFromOptionFile      = 1 << 3
    
};

@class TTVPlayVideo;
extern TTVFeedListCellSeparatorStyle ttv_feedListCellSeparatorStyleByTotalAndRow(NSInteger total,NSInteger row);

@interface TTVFeedListItem : TTVTableViewItem
@property (nonatomic, strong) TTVFeedItem *originData;
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, assign) TTVFeedListCellSeparatorStyle cellSeparatorStyle;
@property (nonatomic, assign)TTVFromOption comefrom;
@property (nonatomic, assign)TTVFromOption refer;
@property (nonatomic, assign)BOOL isFirstCached;

@property (nonatomic, strong) TTTouchContext *lastTouchContext;
@property (nonatomic, strong) TTVFeedCellAction *cellAction;
@property (nonatomic, strong) id<TTVAdActionButtonCommandProtocol> ttv_command;
//提前计算
@property (nonatomic, copy) NSString *playTimes;
@property (nonatomic, copy) NSString *durationTimeString;
@property (nonatomic, strong) TTImageInfosModel *imageModel;
@property (nonatomic, assign) CGRect logoFrame;
@property (nonatomic, assign) CGRect titleLabelFrame;
@property (nonatomic, assign) CGRect rightBottomLabelFrame;
@property (nonatomic, copy) NSString *rightBottomLabelTitle;
@property (nonatomic, assign) BOOL hasRead;
@property (nonatomic, assign) BOOL followedWhenInit;//网络请求回来的数据就是已关注,就隐藏关注按钮
@property (nonatomic, assign) BOOL alreadySetShareTracker;
@property (nonatomic, strong)TTVShareActionsTracker *shareTracker;
@property (nonatomic, weak) UIView *moreButton;
@property (nonatomic, weak) TTVPlayVideo *playVideo;
@property (nonatomic, assign)CGFloat titleHeight;
@property (nonatomic, assign)CGFloat imageHeight;
@property (nonatomic, assign)CGFloat recommendViewHeight;
@property (nonatomic, assign)BOOL showRelatedRecommendView; //列表页是否展开相关推荐
@property (nonatomic, strong) NSMutableArray<id<TTVDetailRelatedRecommendCellViewModelProtocol>> *recommendArray;
@property (nonatomic, assign) CGPoint recommednViewContentOffset;
@property (nonatomic, strong) TTADTrackEventLinkModel *adEventLinkModel;
- (BOOL)isPlayInDetailView;
- (BOOL)supportVideoProportion;
- (TTVVideoArticle *)article;
- (void)ttv_addShareTrcker;
- (void)fetchRecommendArray:(void (^)(NSError * error))comleteBLC;
- (NSDictionary *)realTimeAdExtraData:(NSString *)tag label:(NSString *)label extraData:(NSDictionary *)extraData;
@end
