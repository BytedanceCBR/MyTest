//
//  TTPGCResourceManager.h
//  Article
//
//  Created by liaozhijie on 2017/8/3.
//
//

#ifndef TTPGCResourceManager_h
#define TTPGCResourceManager_h

#define kPGCEditorFolder @"pgc-editor"
#define kPGCEditorHtmlFile @"pgc-editor.html"
#define kPGCEditorZipFileName @"pgc-editor.zip"
#define kPGCEditorHtmlUserDefaultKey @"kPGCEditorHtmlUserDefaultKey"

@interface TTPGCResourceManager : NSObject

// 下载文件
- (void)download:(NSString * _Nonnull)urlString
             md5:(NSString * _Nullable)md5
     zipFilename:(NSString * _Nonnull)zipFilename
     unzipFolder:(NSString * _Nonnull)unzipFolder
 completeHandler:(void (^_Nullable)(NSError * _Nullable error, BOOL verifiyError))completeHandler;

// 判断文件是否存在
- (BOOL)exist:(NSString * _Nonnull)file;

// 加载webview内容，如果本地有缓存，则加载本地，否则加载回退线上url
- (void)loadWebContent:(UIWebView * _Nonnull)webview
                folder:(NSString * _Nonnull)folder
              fileName:(NSString * _Nonnull)fileName
           fallbackUrl:(NSString * _Nonnull)fallbackUrl
            onDownload:(void(^_Nullable)())onDownload;

// 更新资源如果资源过期
- (void)updateResourceIfNeeded:(NSString *_Nullable)key
                           url:(NSString *_Nonnull)url
                       version:(NSString *_Nonnull)version
                           md5:(NSString *_Nonnull)md5
                   zipFilename:(NSString *_Nonnull)zipFilename
                   unzipFolder:(NSString *_Nonnull)unzipFolder
             completionHandler:(void(^_Nullable)(BOOL success))completionHandler;

// 判断是否应该更新
- (BOOL)shouleUpdate:(NSString *_Nonnull)key
             version:(NSString *_Nonnull)version;

@end

#endif /* TTPGCResourceManager_h */
