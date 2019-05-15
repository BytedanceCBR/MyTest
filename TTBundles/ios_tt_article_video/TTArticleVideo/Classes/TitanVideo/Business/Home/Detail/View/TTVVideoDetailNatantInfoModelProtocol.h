//
//  TTVVideoDetailNatantInfoModelProtocol.h
//  Article
//
//  Created by lishuangyang on 2017/5/19.
//
//

#import <Foundation/Foundation.h>

@protocol TTVVideoDetailNatantInfoModelProtocol <NSObject>

@required
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *abstract;
@property (nonatomic, copy) NSArray  *zzComments;           //转载
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *digCount;
@property (nonatomic, strong) NSNumber *userDiged;
@property (nonatomic, copy) NSString *buryCount;
@property (nonatomic, strong) NSNumber *userBuried;
@property (nonatomic, strong) NSNumber *banBury;
@property (nonatomic, strong) NSNumber *banDig;
@property (nonatomic, strong) NSNumber *isOriginal;
@property (nonatomic, assign) double articlePublishTime;
@property (nonatomic, copy) NSString *titleRichSpan;
/**
 *埋点信息
 */
@property (nonatomic, copy) NSString *enterFrom;
@property (nonatomic, copy) NSDictionary *logPb;
@property (nonatomic, copy) NSString *authorId;

/**
 *  视频详情页给出可自定义跳转的入口 : 1.button_text  2.is_download_app 3.apple_id 4.url 如果需要delegate的话还得加。
 */
@property (nonatomic, copy) NSDictionary *VExtendLinkDic;

/**
 *视频详情页信息 :  1.VideoWatchCountKey  2.video_type
 */
@property (nonatomic, copy) NSDictionary *videoDetailInfo;
/**
 *顶／踩 信息
 */
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *categoryId;
@property(nonatomic, strong) NSNumber *aggrType;
@property(nonatomic, copy) NSString *adId;

@end
