//
//  TTVideoPasterADModel.h
//  Article
//
//  Created by Dai Dongpeng on 5/25/16.
//
//

#import <JSONModel/JSONModel.h>
//#import "TTVideoApiModel.h"


typedef NS_ENUM(NSUInteger, TTVideoPasterADStyle)
{
    TTVideoPasterADStyleImage = 1, //图片
    TTVideoPasterADStyleVideo = 2, //视频
};

typedef NS_ENUM(NSUInteger, TTVideoPasterADPageType)
{
    TTVideoPasterADPageTypeAPP = 1,    // 应用下载
    TTVideoPasterADPageTypeWeb = 2,    // web
};

@class TTVideoPasterADInfoModel;
@interface TTVideoPasterADModel : NSObject

@property (nonatomic, assign)   TTVideoPasterADStyle style;//资源类型

@property (nonatomic, assign)   TTVideoPasterADPageType type;

@property (nonatomic, strong)   TTVideoPasterADInfoModel *videoPasterADInfoModel;

@end


@class TTVideoURLInfo, TTImageInfosModel, TTVideoPasterADVideoInfoModel;

@protocol TTImageInfosModel <NSObject>

@end

@interface TTVideoPasterADInfoModel : JSONModel
@property (nonatomic, strong)   NSNumber <Optional> *adID; //贴片广告ID，统计用
@property (nonatomic, copy)     NSString <Optional> *type;//web/app

@property (nonatomic, copy)     NSString <Optional> *logExtra;  //统计用

@property (nonatomic, copy)     NSString <Optional> *openURL;   //头条scheme地址/应用直达号链接
@property (nonatomic, copy)     NSString <Optional> *webURL;    //落地页地址
@property (nonatomic, copy)     NSString <Optional> *webTitle;  //落地页标题
@property (nonatomic, copy)     NSString <Optional> *appleID;   //app id （app广告）
@property (nonatomic, copy)     NSString <Optional> *appName;   //广告应用名 （app广告）
@property (nonatomic, copy)     NSString <Optional> *downloadURL;   //应用下载链接 （app广告）

@property (nonatomic, copy)     NSString <Optional> *buttonText;    //查看详情按钮文字
@property (nonatomic, strong)   NSNumber <Optional> *duration;      //贴片广告时长

@property (nonatomic, strong)   NSNumber <Optional> *enableClick; //广告其他位置是否可点 0：否 1：是

@property (nonatomic, copy)     NSArray <NSString *> <Optional> *trackURLList;
@property (nonatomic, copy)     NSArray <NSString *> <Optional> *clickTrackURLList;

@property (nonatomic, strong)   NSNumber <Optional> *preDownload; //预加载条件 1:wifi 2:4g 4:3g 8:2g 不下发暂无预加载机制

@property (nonatomic, strong)   TTVideoPasterADVideoInfoModel <Optional> *videoInfo;//视频相关

@property (nonatomic, copy)     NSArray <TTImageInfosModel, Optional> *imageList; //图片相关
@property (nonatomic, copy)     NSString <Optional> *title;      //广告title
@property (nonatomic, strong)   NSNumber <Optional> *titleTime;  //title展示时长


- (NSArray *)allURLWithtransformedURL:(BOOL)transformed;
@end

@interface TTVideoPasterADVideoInfoModel : JSONModel
@property (nonatomic, copy)     NSString <Optional> *videoID;
@property (nonatomic, copy)     NSString <Optional> *videoGroupID;

@property (nonatomic, copy)     NSArray <NSString *> <Optional> *playTrackURLList; //贴片广告视频播放事件的第三方监测链接

@property (nonatomic, copy)     NSArray <NSString *> <Optional> *playOverTrackURLList; //贴片广告视频播放结束事件的第三方监测链接

@property (nonatomic, strong)   NSNumber <Optional> *effectivePlayTime;//有效播放时长
@property (nonatomic, copy)     NSArray <NSString *> <Optional> *effectivePlayTrackURLList; //贴片广告视频播放结束事件的第三方监测链接
@end


