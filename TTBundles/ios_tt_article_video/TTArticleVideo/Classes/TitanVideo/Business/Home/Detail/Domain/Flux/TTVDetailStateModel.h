//
//  TTVDetailStateModel.h
//  Article
//
//  Created by panxiang on 2017/7/7.
//
//

#import <Foundation/Foundation.h>
#import "TTVDetailContentEntity.h"
#import "TTVVideoDetailVCDefine.h"
#import "TTVWhiteBoard.h"

@interface TTVDetailStateModel : NSObject
@property (nonatomic, strong) TTVDetailContentEntity *entity;
@property (nonatomic, copy  ) NSString *titleRichSpan;
@property (nonatomic, assign) BOOL forbidLayout;
@property (nonatomic, assign) BOOL hasCommodity;//视频详情页有特卖控件
@property (nonatomic, assign) BOOL isFullScreen;//播放器全屏
@property (nonatomic, assign) CGRect movieFrame;
@property (nonatomic, assign) BOOL isChangingMovieSize;
@property (nonatomic, assign) BOOL forbidFullScreenWhenPresentAd;
@property (nonatomic, assign) BOOL shouldPlayWhenBack;//上一个视频的时候,从头开始播放视频
@property (nonatomic, assign) BOOL clickedBackBtn;
@property (nonatomic, weak) TTVWhiteBoard *whiteBoard;
@property (nonatomic, assign) TTVVideoDetailViewFromType fromType;
@property (nonatomic, assign) BOOL isBackAction;
@property (nonatomic, assign) BOOL hasClickRelated;
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, copy) NSString *enterFrom;
@property (nonatomic, copy) NSString *authorId;
@property (nonatomic, copy) NSDictionary *logPb;
@property (nonatomic, copy) NSDictionary *rawAdData;
@property (nonatomic, assign) CGFloat videoProgress;   //记录播放进度
- (float)currentStayDuration;
- (NSNumber *)detailReadPCT;
@end


@interface TTVDetailStateModel (Data)
- (void)setDetailModel:(id)detailModel;
- (NSNumber *)ttv_adid;
- (NSString *)ttv_itemId;
- (NSNumber *)ttv_aggrType;
- (NSString *)ttv_groupId;
- (NSString *)ttv_fromGid;
@end
