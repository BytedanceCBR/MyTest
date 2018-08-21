//
//  TTLiveMessageSender.m
//  Article
//
//  Created by matrixzk on 9/22/16.
//
//

#import "TTLiveMessageSender.h"

#import "TTLiveMessage.h"
#import "TTNetworkManager.h"
#import "TTIndicatorView.h"
#import "TTTrackerWrapper.h"
#import "UIImageAdditions.h"


#import "TTLiveVideoUploadOperation.h"

@interface TTLiveMessageSender ()
@property (nonatomic, weak) TTLiveMessage *message;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation TTLiveMessageSender

#ifdef DEBUG
- (void)dealloc
{
    LOGD(@">>>>>>>>> TTLiveMessageSender Dealloced !!!");
}
#endif

- (void)sendMessage:(TTLiveMessage *)message
{
    message.msgSender = self;
    self.message = message;
    
    message.networkState = TTLiveMessageNetworkStateLoading;
    
    switch (message.msgType) {
        case TTLiveMessageTypeText:
            [self postInfoOfMessage:message];
            break;
            
        case TTLiveMessageTypeImage:
            [self uploadImage:message.tempLocalSelectedImage];
            break;
            
        case TTLiveMessageTypeAudio:
            [self uploadAudioWithPath:message.localAmrAudioURL.path];
            break;
            
        case TTLiveMessageTypeVideo:
            [self uploadVideoWithPath:message.localSelectedVideoURL.path];
            break;
            
        default:
            break;
    }
}


#pragma mark - Upload Image

- (void)uploadImage:(UIImage *)image
{
    NSMutableDictionary * postParameter = [NSMutableDictionary dictionaryWithCapacity:10];
    [postParameter setValue:[TTSandBoxHelper appName] forKey:@"app_name"];
    [postParameter setValue:@(0) forKey:@"watermark"];
    [postParameter setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *imgData = [image imageDataWithMaxSize:CGSizeMake(NSIntegerMax, NSIntegerMax) maxDataSize:NSIntegerMax];
        if (imgData == nil) {
            imgData = UIImageJPEGRepresentation(image, 1.f);
        }
        
        [[TTNetworkManager shareInstance] uploadWithURL:[CommonURLSetting uploadImageString] parameters:postParameter constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
            [formData appendPartWithFileData:imgData name:@"image" fileName:@"image.jpeg" mimeType:@"image"];
        } progress:nil needcommonParams:YES callback:^(NSError *error, id jsonObj) {
            
            void(^handleError)(void) = ^{
                self.message.networkState = TTLiveMessageNetworkStateFaild;
                // event track
                [self eventTrackWithEvent:@"liveshot" label:@"photo_upload_fail"];
            };
            
            if (error) {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setValue:@(error.code) forKey:@"error_code"];
                [[TTMonitor shareManager] trackService:@"ttlive_photo_upload" status:1 extra:dic];
                handleError();
                return;
            }
            
            NSString *imgURI = [[jsonObj tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"web_uri"];
            if (isEmptyString(imgURI)) {
                handleError();
                return;
            }
            
            self.message.mediaFileSourceId = imgURI;
            [self postInfoOfMessage:self.message];
        }];
    });
}


#pragma mark - Upload Audio

- (void)uploadAudioWithPath:(NSString *)path
{
    void(^handleError)(void) = ^{
        self.message.networkState = TTLiveMessageNetworkStateFaild;
        // event track
        [self eventTrackWithEvent:@"liveaudio" label:@"audio_upload_fail"];
    };
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
        handleError();
        return;
    }
    
    // 获取音频上传url
    NSString *urlStr = [NSString stringWithFormat:@"%@/upload_audio_url/", [CommonURLSetting liveTalkURLString]];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:urlStr params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj){
        
        if (error) {
            handleError();
            return ;
        }
        
        NSString *uploadURLStr;
        // TODO: 验证下 json 的结构，有两种可能吗？
        NSDictionary *dataDict = [jsonObj tt_dictionaryValueForKey:@"data"];
        id urlObj = [dataDict tt_objectForKey:@"url"];
        if ([urlObj isKindOfClass:[NSArray class]]) {
            uploadURLStr = [(NSArray *)urlObj firstObject];
        } else if ([urlObj isKindOfClass:[NSString class]]) {
            uploadURLStr = urlObj;
        }
        
        NSData *audioData = [[NSData alloc] initWithContentsOfFile:path];
        NSString *audioId = [dataDict tt_stringValueForKey:@"id"];
        if (isEmptyString(uploadURLStr) || !audioData || isEmptyString(audioId)) {
            handleError();
            return;
        }
        
        // 上传音频data
        [[TTNetworkManager shareInstance] uploadWithURL:uploadURLStr parameters:nil constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
            [formData appendPartWithFileData:audioData  name:@"file" fileName:@"audio" mimeType:@"amr"];
        } progress:nil needcommonParams:YES callback:^(NSError *error, id jsonObj) {
            
            if (error) {
                handleError();
                return;
            }
            
            self.message.mediaFileSourceId = audioId;
            [self postInfoOfMessage:self.message];
        }];
    }];
}


#pragma mark - Upload Video

- (void)uploadVideoWithPath:(NSString *)path
{
    void(^handleError)(void) = ^{
        self.message.networkState = TTLiveMessageNetworkStateFaild;
        // event track
        [self eventTrackWithEvent:@"liveshot" label:@"video_upload_fail"];
    };
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
        handleError();
        return;
    }
    
    TTLiveVideoUploadOperation *uploadOperation = [[TTLiveVideoUploadOperation alloc] initWithVideoPath:path progress:^(CGFloat progress) {
        self.message.loadingProgress = @(progress * 0.95);
    } completed:^(NSString *videoId, NSError *error) {
        if (error || isEmptyString(videoId)) {
            handleError();
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:@(error.code) forKey:@"error_code"];
            [[TTMonitor shareManager] trackService:@"ttlive_audio_upload" status:1 extra:dic];
            return;
        }
        self.message.mediaFileSourceId = videoId;
        [self postInfoOfMessage:self.message];
    }];
    
    self.operationQueue = [NSOperationQueue new];
    self.operationQueue.maxConcurrentOperationCount = 1;
    [self.operationQueue addOperation:uploadOperation];
}

- (void)cancelVideoUpload
{
    [self.operationQueue cancelAllOperations];
}


#pragma mark - Post Msg Info

- (void)postInfoOfMessage:(TTLiveMessage *)message
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/talk/",[CommonURLSetting liveTalkURLString]];
    NSDictionary *params = [self params4RequestWithMessage:message];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:urlStr params:params method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        if (error) {
            
            // change state
            message.networkState = TTLiveMessageNetworkStateFaild;
            
            NSString *tips = [jsonObj tt_stringValueForKey:@"tips"];
            if (!isEmptyString(tips)) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tips indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            }
            
            // event track
            [self evnetTrack4MsgInfoPostWithResultSuccess:NO];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:@(error.code) forKey:@"error_code"];
            [[TTMonitor shareManager] trackService:@"ttlive_message_upload" status:1 extra:dic];
            return;
        }
        
        NSNumber *msgId = [[jsonObj tt_dictionaryValueForKey:@"data"] tt_objectForKey:@"msg_id"];
        if (!msgId) {
            
            // change state
            message.networkState = TTLiveMessageNetworkStateFaild;
            // event track
            [self evnetTrack4MsgInfoPostWithResultSuccess:NO];
            
            return;
        }
        
        message.msgId = msgId;
        message.networkState = TTLiveMessageNetworkStateSuccess;
        message.loadingProgress = @(1);
        
        if (TTLiveMessageTypeImage == message.msgType) {
            message.tempLocalSelectedImage = nil;
        }
        
        // event track
        [self evnetTrack4MsgInfoPostWithResultSuccess:YES];
    }];
}

- (NSDictionary *)params4RequestWithMessage:(TTLiveMessage *)message
{
    NSMutableDictionary *contentInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    switch (message.msgType) {
        case TTLiveMessageTypeText:
            [contentInfo setValue:message.msgText forKey:@"text"];
            break;
            
        case TTLiveMessageTypeImage:
            [contentInfo setValue:@[message.mediaFileSourceId ?: @""] forKey:@"picture"];
            break;
            
        case TTLiveMessageTypeAudio:
            [contentInfo setValue:@[message.mediaFileSourceId ?: @""] forKey:@"audio"];
            break;
            
        case TTLiveMessageTypeVideo:
            [contentInfo setValue:@[message.mediaFileSourceId ?: @""] forKey:@"video"];
            break;
            
        default:
            break;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:3];
    [params setValue:self.eventTrackParams[@"value"] forKey:@"live_id"]; // required
    [params setValue:@(message.msgType) forKey:@"content_type"];
    if (message.replyedMessage) {
        [params setValue:message.replyedMessage.msgId forKey:@"reply"];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contentInfo options:NSJSONWritingPrettyPrinted error:nil];
    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [params setValue:jsonString forKey:@"content"];
    }
    
    return params;
}


#pragma mark - Event Track

- (void)eventTrackWithEvent:(NSString *)event label:(NSString *)label
{
    if (isEmptyString(event) || isEmptyString(label)) {
        return;
    }
    
    wrapperTrackEventWithCustomKeys(event, label, nil, nil, self.eventTrackParams);
}

- (void)evnetTrack4MsgInfoPostWithResultSuccess:(BOOL)success
{
    NSString *event, *label;
    
    switch (self.message.msgType) {
        case TTLiveMessageTypeText:
            event = @"livetext";
            if (self.message.replyedMessage) {
                label = success ? @"reply_success" : @"reply_fail";
            } else {
                label = success ? @"write_success" : @"write_fail";
            }
            break;
            
        case TTLiveMessageTypeImage:
            event = @"liveshot";
            label = success ? @"photo_sent_success" : @"photo_sent_fail";
            break;
            
        case TTLiveMessageTypeVideo:
            event = @"liveshot";
            label = success ? @"video_sent_success" : @"video_sent_fail";
            break;
            
        case TTLiveMessageTypeAudio:
            event = @"liveaudio";
            label = success ? @"audio_sent_success" : @"audio_sent_fail";
            break;
            
        default:
            break;
    }
    
    [self eventTrackWithEvent:event label:label];
}

@end
