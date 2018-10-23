//
//  SSVideoPlayerManager.m
//  Article
//
//  Created by Zhang Leonardo on 12-12-31.
//
//

#import "SSVideoManager.h"
#import "CommonURLSetting.h"
#import "SSOperation.h"
#import "SSCommonLogic.h"
#import "InstallIDManager.h"
#import "TTDeviceHelper.h"
 
#import "TTInfoHelper.h"


@interface SSVideoManager ()
@property (nonatomic, retain) SSHttpOperation *feedbackOperation;
@property (nonatomic, retain) SSHttpOperation *loadVideoOperation;
@end

@implementation SSVideoManager

- (void)dealloc
{
    [self cancelAndClearDelegate];
}

- (void)cancelAndClearDelegate {
    self.delegate = nil;
    [_loadVideoOperation cancelAndClearDelegate];
    self.loadVideoOperation = nil;
    [_feedbackOperation cancelAndClearDelegate];
    self.feedbackOperation = nil;
}

+ (SSVideoManager *)sharedManager
{
    static SSVideoManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

#pragma mark - load video

- (void)loadVideoDataWithURL:(NSString *)playURL
{
//    NSString *url = [CommonURLSetting loadVideoURLString];
    
    // 直接使用html中的play_url来请求，不需要本地构造
    NSString *url = [playURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = @{@"platform" : [TTDeviceHelper platformName]};

    [_loadVideoOperation cancelAndClearDelegate];
    self.loadVideoOperation = [SSHttpOperation httpOperationWithURLString:url
                                                             getParameter:params];
    [_loadVideoOperation setFinishTarget:self selector:@selector(loadVideoOperation:result:error:userInfo:)];
    [SSOperationManager addOperation:_loadVideoOperation];
}

- (void)loadVideoOperation:(SSHttpOperation *)operation result:(NSDictionary *)result error:(NSError *)error userInfo:(NSDictionary *)userInfo
{
    SSVideoModel *tModel = nil;
    if(!error) {
        tModel = [[SSVideoModel alloc] initWithDictionary:[result objectForKey:@"result"]];
    }

    if(_delegate && [_delegate respondsToSelector:@selector(ssVideoPlayerManager:didLoadVideoModel:error:)]) {
        [_delegate ssVideoPlayerManager:self didLoadVideoModel:tModel error:error];
    }
}

#pragma mark - feedback

- (void)videoPlayFailedFeedback:(SSVideoModel *)videoModel playInfo:(SSVideoModelPlayInfo *)info
{
    //NSUInteger failType = 1;
    [self videoFailedFeedback:videoModel playInfo:info];
}

//- (void)videoDownloadFailedFeedback:(SSVideoModel *)videoModel
//{
//    NSUInteger failType = 0;
//    [self videoFailedFeedback:videoModel failType:failType];
//}

- (void)videoFailedFeedback:(SSVideoModel *)video playInfo:(SSVideoModelPlayInfo *)info
{
    NSString *urlString = [CommonURLSetting videoFeedbackURLStringForArticle];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    if (video.videoID) {
        [params setObject:video.videoID forKey:@"article_video_id"];
    }
    if (info.videoFormat) {
        [params setObject:info.videoFormat forKey:@"format"];
    }
    if (info.fromSite) {
        [params setObject:info.fromSite forKey:@"site"];
    }
    if (info.playURL) {
        [params setObject:info.playURL forKey:@"url"];
    }    
    [params setObject:[TTDeviceHelper platformName] forKey:@"device_platform"];
    [params setObject:[TTInfoHelper getCurrentChannel] forKey:@"channel"];
    [params setObject:[TTInfoHelper versionName] forKey:@"version_code"];
    [params setObject:[TTInfoHelper appName] forKey:@"app_name"];
    [params setValue:[TTInfoHelper ssAppID] forKey:@"aid"];
    [params setObject:[NSString stringWithFormat:@"%d", [TTDeviceHelper getDeviceType]] forKey:@"device_type"];
    [params setObject:[NSString stringWithFormat:@"%f", [TTInfoHelper OSVersionNumber]] forKey:@"os_version"];
    [params setValue:[[InstallIDManager sharedManager] deviceID] forKey:@"device_id"];
    [params setObject:[TTInfoHelper openUDID] forKey:@"openudid"];
    [params setObject:[TTInfoHelper connectMethodName] forKey:@"access"];
    [params setObject:[[InstallIDManager sharedManager] installID] forKey:@"iid"];
    
    [_feedbackOperation cancelAndClearDelegate];
    self.feedbackOperation = nil;
    self.feedbackOperation = [SSHttpOperation httpOperationWithURLString:urlString getParameter:nil postParameter:params];
    [_feedbackOperation setFinishTarget:self selector:@selector(operation:result:error:userInfo:)];
    [SSOperationManager addOperation:_feedbackOperation];
}


- (void)operation:(SSHttpOperation*)operation result:(NSDictionary*)result error:(NSError*)tError userInfo:(id)userInfo
{
    if (operation == _feedbackOperation) {
        if (tError) {
            SSLog(@"feedback error!");
        }
    }
}
@end
