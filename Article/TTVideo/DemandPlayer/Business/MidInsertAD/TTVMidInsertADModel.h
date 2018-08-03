//
//  TTVMidInsertADModel.h
//  Article
//
//  Created by lijun.thinker on 05/09/2017.
//
//

#import <JSONModel/JSONModel.h>
#import "TTVPasterADModel.h"

typedef NS_ENUM(NSUInteger, TTVMidInsertADStyle)
{
    TTVMidInsertADStyleNone = 0,
    TTVMidInsertADStyleImage = 1, // 图片
    TTVMidInsertADStyleVideo = 2, //视频
    TTVMidInsertADStyleMarkImage = 3, //角标
};

typedef NS_ENUM(NSUInteger, TTVMidInsertADPageType)
{
    TTVMidInsertADPageTypeAPP = 1,    // 应用下载
    TTVMidInsertADPageTypeWeb = 2,    // web
};

@class TTVMidInsertADInfoModel;
@interface TTVMidInsertADModel : NSObject

@property (nonatomic, assign)   TTVMidInsertADStyle style;//资源类型

@property (nonatomic, assign)   TTVMidInsertADPageType type;

@property (nonatomic, strong)   TTVMidInsertADInfoModel *midInsertADInfoModel;

@end

@class TTVideoURLInfo, TTImageInfosModel, TTVPasterADVideoInfoModel;

//@protocol TTImageInfosModel <NSObject>
//
//@end

@interface TTVMidInsertADInfoModel : JSONModel
@property (nonatomic, strong)   NSNumber <Optional> *adID; //贴片广告ID，统计用
@property (nonatomic, copy)     NSString <Optional> *type;//web/app
@property (nonatomic, strong)   NSNumber <Optional> *displayType; // 2:角标  5:插播
@property (nonatomic, strong)   NSNumber <Optional> *displayTime; // 广告展示时长 ms
@property (nonatomic, strong)   NSNumber <Optional> *skipTime; // 广告多久可跳过 ms  角标广告 0
@property (nonatomic, copy)     NSString <Optional> *logExtra;  //统计用
@property (nonatomic, strong)   NSNumber <Optional> *guideStartTime; // 引导视频偏移时间 ms （插播广告独有） 废弃
@property (nonatomic, strong)   NSNumber <Optional> *adStartTime; // 广告视频偏移时间 ms （插播广告独有）
@property (nonatomic, assign)   BOOL enableClose; // 广告是否可以关闭 0: 不可关闭，1: 可关闭 (如果enable_close是0（不可关闭），则忽略skip_time字段)
@property (nonatomic, copy)     NSString <Optional> *openURL;   // 头条scheme地址/应用直达号链接
@property (nonatomic, copy)     NSString <Optional> *webURL;    // 落地页地址
@property (nonatomic, copy)     NSString <Optional> *webTitle;  // 落地页标题
@property (nonatomic, copy)     NSString <Optional> *appleID;   // app id （app广告）
@property (nonatomic, copy)     NSString <Optional> *appName;   // 广告应用名 （app广告）
@property (nonatomic, copy)     NSString <Optional> *downloadURL;   // 应用下载链接 （app广告）
@property (nonatomic, copy)     NSString <Optional> *buttonText;    // 查看详情按钮文字
@property (nonatomic, copy)     NSArray <NSString *> <Optional> *trackURLList;
@property (nonatomic, copy)     NSArray <NSString *> <Optional> *clickTrackURLList;
@property (nonatomic, copy)     NSArray <TTImageInfosModel, Optional> *imageList; // 图片相关
@property (nonatomic, strong)   TTVPasterADVideoInfoModel <Optional> *videoInfo;// 广告视频相关
@property (nonatomic, strong)   TTVPasterADVideoInfoModel <Optional> *guideVideoInfo;// 引导视频相关

@property (nonatomic, copy) NSString<Optional> *guideWords;
@property (nonatomic, strong) NSNumber<Optional> *guideTime;

@end

