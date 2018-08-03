//
//  TTVideoFinishRelatedViewService.h
//  Article
//
//  Created by lishuangyang on 2017/10/17.
//

/**
 * http://i.snssdk.com/2/related/open/v1/?
 * group_id=6467035126923526669&
 * parent_rid=6467035126923526669&
 * page_type=video&
 * site_id=5000246&
 * code_id=14798012085000246&
 * installed_pkg=snssdk1128&installed_pkg=snssdk51&installed_pkg=snssdk1112&installed_pkg=snssdk32&installed_pkg=com.ss.android.article.news&
 * style=no_title
 */

#import <Foundation/Foundation.h>
#import <TTNetworkManager/TTDefaultHTTPRequestSerializer.h>

@interface TTVPlayerRelatedRequestSerializer : TTDefaultHTTPRequestSerializer

@end


typedef void(^fetchRelatedRecommondInfoCompletion)(id response,NSError *error);

@class TTVideoFinishRelatedRecommondURLRequestInfo;
@interface TTVideoFinishRelatedViewService : NSObject

- (void)fetchRelatedRecommondInfoWithRequestInfo:(TTVideoFinishRelatedRecommondURLRequestInfo *)requestInfo completion:(fetchRelatedRecommondInfoCompletion)completion;

- (void)postRelatedRecommondInfoWithPostInfo:(id)postInfo completion:(void (^)(id response,NSError *error))completion;

/**
 请求一下短链,给服务端统计下载量
 */
- (void)requestDownloadUrl:(NSString *)url completion:(void (^)(id response,NSError *error))completion;
- (BOOL)isAllInstalled;

@end

@interface TTVideoFinishRelatedRecommondURLRequestInfo : NSObject

@property (nonatomic, copy) NSString *parentRID; // 推荐聚合使用的唯一标识
@property (nonatomic, copy) NSString *groupID; // group_id
@property (nonatomic, copy) NSString *pageType; // 当前请求的页面类型 【video，article】
@property (nonatomic, copy) NSString *codeId; // 模块类型 【列表页，详情页】
@property (nonatomic, copy) NSString *siteID; // 当前app标识
@property (nonatomic, copy) NSString *style; // 类型
@property (nonatomic, copy) NSString *installedPKG; // 已经安装的头条系产品

@end

