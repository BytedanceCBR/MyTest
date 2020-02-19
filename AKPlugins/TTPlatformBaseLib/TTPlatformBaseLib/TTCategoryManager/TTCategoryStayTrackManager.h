//
//  TTCategoryStayTrackManager.h
//  Article
//
//  Created by xuzichao on 2017/5/23.
//
//

/**
 用于统计频道停留时间。进入详情页后， 则停止统计
 方法内部自动管理前后台切换。
 startTrackForCategoryID: 和 endTrackCategory配合统计列表停留时常
 */

#import <Foundation/Foundation.h>

@interface TTCategoryStayTrackManager : NSObject
@property(nonatomic, retain)NSString * trackingCategoryID;          //当前正在统计的category ID
@property(nonatomic, copy)NSString * trackingConcernID;             //当前正在统计的concern ID
@property(nonatomic, copy)NSString * enterType;                     //当前频道的进入方式flip/click

+ (TTCategoryStayTrackManager *)shareManager;

#pragma mark -- list track

/**
 *  开始统计列表
 *
 *  @param categoryID 列表Category ID
 */
- (void)startTrackForCategoryID:(NSString *)categoryID
                      concernID:(NSString *)concernID
                      enterType:(NSString *)enterType;

/**
 *  开始统计列表
 *
 *  @param extraParams 由各业务方自行传入的参数
 */
- (void)startTrackForCategoryID:(NSString *)categoryID
                      concernID:(NSString *)concernID
                      enterType:(NSString *)enterType
                    extraParams:(NSDictionary *)extraParams;

/**
 *  结束本次列表统计
 */
- (void)endTrackCategory:(NSString *)categoryID;

#pragma mark -- moment track

/**
 *  开始统计动态列表的停留时常
 */
- (void)startTrackForMomentList;
/**
 *  结束统计动态列表的停留时常
 */
- (void)endTrackForMomentList;
@end
