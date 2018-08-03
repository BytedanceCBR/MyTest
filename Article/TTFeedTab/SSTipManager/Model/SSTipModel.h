//
//  SSTipModel.h
//  Article
//
//  Created by Yu Tianhang on 12-12-23.
//
//  列表页刷新显示浮动tip（浮动tip） 和 信息流广告（内嵌tip） 的基础类
//  
//

#import <Foundation/Foundation.h>
#import "PBModelHeader.h"

typedef enum SSTipModelActionType{
    SSTipModelActionTypeNone = 0,                   //没有动作
    SSTipModelActionTypeOpenApp,                    //直接打开APP
    SSTipModelActionTypeWebView,                    //用WebView打开
    SSTipModelActionTypeDownload,                   //直接下载
    SSTipModelActionTypeAlertWebOrDownload          //弹窗询问（网页体验 or 下载）
} SSTipModelActionType;


#define kSSTipModelDisplayTemplatePlaceholder @"%s"

@interface SSTipModel : NSObject

@property (nonatomic, copy) NSString *downloadURL;
@property (nonatomic, copy) NSString *webURL;
@property (nonatomic, copy) NSString *displayInfo;
@property (nonatomic, strong) NSNumber *displayDuration; // s
@property (nonatomic, copy) NSString *type;   // float ad only
@property (nonatomic, copy) NSString *openURL;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, strong) NSArray<NSString *> *trackURLs;
@property (nonatomic, strong) NSNumber *adID;           // 广告ID，用于统计
@property (nonatomic, copy) NSString *logExtra;
@property (nonatomic, copy) NSString *appleID;
@property (nonatomic, copy) NSString *displayTemplate;

- (instancetype)initWithDictionary:(NSDictionary *)data;
- (instancetype)initWithTips:(TTVRefreshTips *)tips;

/*
 *  根据不同的label发送广告相关的统计事件
 */
- (void)sendTrackEventWithLabel:(NSString *)label;
- (void)sendV3TrackWithLabel:(NSString *)label params:(NSDictionary *)extra;
@end
