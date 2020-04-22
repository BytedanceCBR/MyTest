//
//  ArticleJSManager.h
//  Article
//
//  Created by 邓刚 on 14-3-26.
//
//

#import <Foundation/Foundation.h>

#define kIOSAssetFolderName  @"ios_asset"     // 资源存放目录
#define kIphoneJsZipFileName @"iphone.zip"    // 下载到的zip包会被拷贝至资源存放目录，名字叫这个
#define kIphoneJsFilePath    @"js/iphone.js"  // 约定的文件存在路径，用于合法性检查
#define kV55Folder           @"v55"           // 5.5改版增加的目录，用于AB测试
#define kV60Folder           @"v60"           // 6.0新增目录, 用于存放全局共享页面的资源

typedef void (^ArticleJSManagerLoadResourcesCallback)(NSString *path, NSError *error);
@interface ArticleJSManager : NSObject

+ (ArticleJSManager *)shareInstance;

/*
 * 前端h5模板数据，Settings下发数据 f_article_h5_config
 */
@property (nonatomic, strong)     NSDictionary       *feArticleH5Config;

/*
 * @bried 处理settings API返回的相关字段
 *
 * @params assetsUrl     JS下载地址
 */
+ (void)downloadAssetsWithUrl:(NSString *)assetsUrl;

/**
 * @bried 清除下载的js资源，使用内置资源
 */
- (void)clearJSFromWeb;

/*
 * @bried 是否应当使用下载版本
 */
- (BOOL)shouldUseJSFromWebWithSubRootPath:(NSString *)jsSubRootPath;



/**
 加载JS资源, 成功后会执行callback
 
 callback会在主线程调用

 @param callback 需要执行的callback
 */
- (void)startLoadJSResourcesIfNeed:(ArticleJSManagerLoadResourcesCallback)callback;
/*
 * @bried 获取下载版本的js文件
 */
//- (NSString* )getLibJSFromWeb;
//- (NSString* )getJSFromWeb;
//- (NSString *)getCSSFromWeb;

/**
 * @bried 下载包的资源目录
 */
- (NSString *)packageFolderPath;

@end
