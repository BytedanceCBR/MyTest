//
//  AppAlertModel.h
//  Essay
//
//  Created by Tianhang Yu on 12-5-8.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "SSBaseAlertModel.h"

typedef enum {
    MobileAlertTypeNotChinaMobileInNotWifi = 0,  // 中国移动用户且在非wifi情况下
    MobileAlertTypeAll = 1
} MobileAlertType;

@interface AppAlertModel : SSBaseAlertModel

@property (nonatomic, copy)   NSString <Optional> *appleIDs;
@property (nonatomic, strong) NSNumber *rule_id;
/*
 * mobile_alert (弹出条件)
 * 1<默认>：所有用户都弹，
 * 0：若是中国移动用户且在非wifi情况下则不弹。
 * Tip. 需要手机端在弹窗时检查该条件是否符合当前的设备运营商及网络情况。
 */
@property (nonatomic, strong) NSNumber <Optional> *mobileAlert;
@property (nonatomic, copy)   NSString <Optional> *imageURLString;
@property (nonatomic, strong) NSNumber <Optional> *expectedIndex;

@end
