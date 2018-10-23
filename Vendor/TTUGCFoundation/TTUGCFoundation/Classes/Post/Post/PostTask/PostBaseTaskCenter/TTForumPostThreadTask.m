//
//  TTForumPostThreadTask.m
//  Article
//
//  Created by 王霖 on 3/16/16.
//
//

#import "TTForumPostThreadTask.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <TTAccountBusiness.h>
#import "ALAssetsLibrary+TTImagePicker.h"
#import "TTUGCImageCompressHelper.h"
#import "SDWebImageManager.h"
#import "SDWebImageAdapter.h"
#import "ExploreOrderedData_Enums.h"
#import "TTKitchenMgr.h"
#import "TTUGCBacktraceLogger.h"
//#import "TTPostVideoRedpackDelegate.h"
#import "FRPostThreadDefine.h"
#import "ExploreOrderedData.h"
#import "FRUploadImageModel.h"
#import "TTForumUploadVideoModel.h"


#define kTTForumPostThreadTask @"TTForumPostThreadTask"

const CGFloat TTForumPostVideoThreadTaskBeforeUploadImageProgress = 0.90f;
const CGFloat TTForumPostVideoThreadTaskBeforeUploadVideoProgress = 0.05f;
const CGFloat TTForumPostVideoThreadTaskBeforePostThreadProgress = 0.95f;

@interface TTForumPostThreadTask()

@property(nonatomic, strong, readwrite)NSString *taskID;
@property(nonatomic, assign, readwrite)TTForumPostThreadTaskType taskType;

@end

@implementation TTForumPostThreadTask

// FIXME: TEST CODE
- (void)setIsPosting:(BOOL)isPosting {
    _isPosting = isPosting;
}

- (void)setFinishError:(NSError *)finishError {
    _finishError = finishError;
}

- (instancetype)init {
    return [self initWithTaskType:TTForumPostThreadTaskTypeThread];
}

- (instancetype)initWithTaskType:(TTForumPostThreadTaskType)taskType {
    self = [super init];
    if (self) {
        self.retryCount = 0;
        self.finishError = nil;
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        int64_t intNow = (int64_t)(now * 1000);
        self.taskID = [NSString stringWithFormat:@"%@%lli", kTTForumPostThreadTask, intNow];
        self.fakeThreadId = intNow;
        self.taskType = taskType;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        id obj = [aDecoder decodeObjectForKey:@"finishError"];
        if (obj) {
            self.finishError = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
        }
        self.taskType = [aDecoder decodeIntegerForKey:@"taskType"];
        self.taskID = [aDecoder decodeObjectForKey:@"taskID"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.contentRichSpans = [aDecoder decodeObjectForKey:@"contentRichSpans"];
        self.mentionUser = [aDecoder decodeObjectForKey:@"mentionUser"];
        self.coverUrl = [aDecoder decodeObjectForKey:@"coverUrl"];
        self.mentionConcern = [aDecoder decodeObjectForKey:@"mentionConcern"];
        self.create_time = [aDecoder decodeInt64ForKey:@"create_time"];
        self.userID = [aDecoder decodeObjectForKey:@"userID"];
        self.fakeThreadId = [aDecoder decodeInt64ForKey:@"fakeThreadId"];
        self.concernID = [aDecoder decodeObjectForKey:@"concernID"];
        self.categoryID = [aDecoder decodeObjectForKey:@"categoryID"];
        self.forward = [aDecoder decodeIntegerForKey:@"forward"];
        self.source = [aDecoder decodeIntForKey:@"source"];
        self.retryCount = [aDecoder decodeIntForKey:@"retryCount"];
        self.latitude = [aDecoder decodeFloatForKey:@"latitude"];
        self.longitude = [aDecoder decodeFloatForKey:@"longitude"];
        self.city = [aDecoder decodeObjectForKey:@"city"];
        self.detail_pos = [aDecoder decodeObjectForKey:@"detail_pos"];
        self.locationType = [aDecoder decodeIntForKey:@"locationType"];
        self.locationAddress = [aDecoder decodeObjectForKey:@"locationAddress"];
        
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.titleRichSpan = [aDecoder decodeObjectForKey:@"titleRichSpan"];
        self.phone = [aDecoder decodeObjectForKey:@"phone"];
        self.fromWhere = [aDecoder decodeIntegerForKey:@"fromWhere"];
        self.score = [aDecoder decodeFloatForKey:@"score"];
        self.refer = [aDecoder decodeIntegerForKey:@"refer"];
        self.postUGCEnterFrom = [aDecoder decodeIntegerForKey:@"postUGCEnterFrom"];
        self.extraTrack = [aDecoder decodeObjectForKey:@"extraTrack"];
        self.video = [aDecoder decodeObjectForKey:@"video"];
        
        self.repostType = [aDecoder decodeIntegerForKey:@"repostType"];
        self.fw_id = [aDecoder decodeObjectForKey:@"fw_id"];
        self.fw_id_type = [aDecoder decodeIntegerForKey:@"fw_id_type"];
        self.opt_id = [aDecoder decodeObjectForKey:@"opt_id"];
        self.opt_id_type = [aDecoder decodeIntegerForKey:@"opt_id_type"];
        self.fw_user_id = [aDecoder decodeObjectForKey:@"fw_user_id"];
        self.repostTitle = [aDecoder decodeObjectForKey:@"repostTitle"];
        self.repostSchema = [aDecoder decodeObjectForKey:@"repostSchema"];
        self.repostToComment = [aDecoder decodeBoolForKey:@"repostToComment"];
        self.repostTaskType = [aDecoder decodeObjectForKey:@"repostTaskType"];

        self.errorPosition = [aDecoder decodeIntegerForKey:@"errorPosition"];
        self.challengeGroupID = [aDecoder decodeObjectForKey:@"challengeGroupID"];
        self.requestRedPacketType = [aDecoder decodeIntegerForKey:@"requestRedPacketType"];
        
        @try {
            NSArray * datas = [aDecoder decodeObjectForKey:@"images"];
            NSMutableArray * ary = [NSMutableArray arrayWithCapacity:10];
            for (NSData * data in datas) {
                FRUploadImageModel * model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [ary addObject:model];
            }
            self.images = [ary copy];
            
        }
        @catch (NSException *exception) {
            self.images = nil;
        }
        @finally {
            
        }
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_taskType forKey:@"taskType"];
    [aCoder encodeObject:_taskID forKey:@"taskID"];
    [aCoder encodeObject:_content forKey:@"content"];
    [aCoder encodeObject:_contentRichSpans forKey:@"contentRichSpans"];
    [aCoder encodeObject:_mentionUser forKey:@"mentionUser"];
    [aCoder encodeObject:_coverUrl forKey:@"coverUrl"];
    [aCoder encodeObject:_mentionConcern forKey:@"mentionConcern"];
    [aCoder encodeInt64:_create_time forKey:@"create_time"];
    [aCoder encodeObject:_concernID forKey:@"concernID"];
    [aCoder encodeObject:_userID forKey:@"userID"];
    [aCoder encodeObject:_categoryID forKey:@"categoryID"];
    [aCoder encodeInt64:_fakeThreadId forKey:@"fakeThreadId"];
    [aCoder encodeInteger:_forward forKey:@"forward"];
    [aCoder encodeInt:_source forKey:@"source"];
    [aCoder encodeInt:_retryCount forKey:@"retryCount"];
    [aCoder encodeFloat:_latitude forKey:@"latitude"];
    [aCoder encodeFloat:_longitude forKey:@"longitude"];
    [aCoder encodeObject:_city forKey:@"city"];
    [aCoder encodeObject:_detail_pos forKey:@"detail_pos"];
    [aCoder encodeInt:_locationType forKey:@"locationType"];
    [aCoder encodeObject:_locationAddress forKey:@"locationAddress"];
    
    if (_title) {
        [aCoder encodeObject:_title forKey:@"title"];
    }
    [aCoder encodeObject:_titleRichSpan forKey:@"titleRichSpan"];
    if (_phone) {
        [aCoder encodeObject:_phone forKey:@"phone"];
    }
    [aCoder encodeInteger:_fromWhere forKey:@"fromWhere"];
    [aCoder encodeFloat:_score forKey:@"score"];
    [aCoder encodeInteger:_refer forKey:@"refer"];
    [aCoder encodeInteger:_postUGCEnterFrom forKey:@"postUGCEnterFrom"];
    [aCoder encodeObject:_extraTrack forKey:@"extraTrack"];
    [aCoder encodeObject:_video forKey:@"video"];
    
    if (_video && _video.coverImage && _video.coverImage && _video.coverImage.thumbnailImg && !isEmptyString(_video.coverImage.fakeUrl)) {
        [[SDWebImageAdapter sharedAdapter] saveImageToCache:_video.coverImage.thumbnailImg forURL:[NSURL URLWithString:_video.coverImage.fakeUrl]];
    }
    
    [aCoder encodeInteger:_repostType forKey:@"repostType"];
    [aCoder encodeObject:_fw_id forKey:@"fw_id"];
    [aCoder encodeInteger:_fw_id_type forKey:@"fw_id_type"];
    [aCoder encodeObject:_opt_id forKey:@"opt_id"];
    [aCoder encodeInteger:_opt_id_type forKey:@"opt_id_type"];
    [aCoder encodeObject:_fw_user_id forKey:@"fw_user_id"];
    [aCoder encodeInteger:_errorPosition forKey:@"errorPosition"];
    [aCoder encodeObject:_repostTitle forKey:@"repostTitle"];
    [aCoder encodeObject:_repostSchema forKey:@"repostSchema"];
    [aCoder encodeBool:_repostToComment forKey:@"repostToComment"];
    [aCoder encodeInteger:_repostTaskType forKey:@"repostTaskType"];
    [aCoder encodeObject:_challengeGroupID forKey:@"challengeGroupID"];
    [aCoder encodeInteger:_requestRedPacketType forKey:@"requestRedPacketType"];

    if (_finishError) {
        id obj = [NSKeyedArchiver archivedDataWithRootObject:_finishError];
        [aCoder encodeObject:obj forKey:@"finishError"];
    }
    
    @try {
        NSMutableArray * models = [NSMutableArray arrayWithCapacity:10];
        for (FRUploadImageModel * imgModel in _images) {
            NSData * data  = [NSKeyedArchiver archivedDataWithRootObject:imgModel];
            if (data) {
                [models addObject:data];
            }
        }
        if ([models count] > 0) {
            [aCoder encodeObject:models forKey:@"images"];
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

- (NSDictionary *)extraTrackForVideoPublishDone {
    if (self.taskType == TTForumPostThreadTaskTypeVideo) {
        NSMutableSet *currentKeys = [NSMutableSet setWithArray:[self.extraTrack allKeys]];
        NSSet *allKeys = [NSSet setWithArray:@[@"entrance",
                                               @"hashtag_name",
                                               @"at_user_id",
                                               @"concern_id",
                                               @"shoot_entrance",
                                               @"tab_name",
                                               @"category_name",
                                               @"publish_video_type",
                                               @"shoot_time",
                                               @"video_time_original",
                                               @"is_title",
                                               @"theme_id",
                                               @"music",
                                               @"pk_gid",
                                               ]];
        [currentKeys intersectSet:allKeys];
        NSDictionary *extraTrack = [self.extraTrack dictionaryWithValuesForKeys:[currentKeys allObjects]];
        return extraTrack;
    }
    return nil;
}

- (NSDictionary *)extraTrackForVideo {
    
    NSMutableSet *currentKeys = [NSMutableSet setWithArray:[self.extraTrack allKeys]];
    NSSet *allKeys = [NSSet setWithArray:@[@"shoot_entrance",
                                           @"tab_name",
                                           @"category_name",
                                           @"publish_video_type"
                                           ]];
    [currentKeys intersectSet:allKeys];
    NSDictionary *extraTrack = [self.extraTrack dictionaryWithValuesForKeys:[currentKeys allObjects]];
    if (self.taskType == TTForumPostThreadTaskTypeVideo) {
        NSMutableDictionary *muExtraTrack = [extraTrack mutableCopy];
        [muExtraTrack setValue:@(self.video.videoSourceType) forKey:@"publish_video_type"];
        if (self.finishError) {
            //为等待wifi需求预留参数
            [muExtraTrack setValue:@"others" forKey:@"fail_reason"];
        }
        return [muExtraTrack copy];
    }
    return nil;
}

- (void)addTaskImages:(nullable NSArray<TTForumPostImageCacheTask*> *)taskImages thumbImages:(nullable NSArray<UIImage*> *)thumbImages{
    NSMutableArray<FRUploadImageModel *> * images = (NSMutableArray<FRUploadImageModel*> *)[NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < [taskImages count]; i ++) {
        TTForumPostImageCacheTask* task = [taskImages objectAtIndex:i];
        UIImage* thumbImage = nil;
        if (thumbImages.count > i) {
            thumbImage = thumbImages[i];
        }
        FRUploadImageModel * model = [[FRUploadImageModel alloc] initWithCacheTask:task thumbnail:thumbImage];
        model.fakeUrl = [FRUploadImageModel fakeUrl:self.taskID index:i];
        [images addObject:model];
    }
    self.images = images;
}

- (UIImage *)convertImage:(UIImage *)sourceImage
{
    UIGraphicsBeginImageContext(sourceImage.size);
    [sourceImage drawInRect:CGRectMake( 0, 0, sourceImage.size.width, sourceImage.size.height)];
    
    UIImage *targetImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return targetImage;
}

- (BOOL)saveToDisk {
    return [[self class] persistentToDiskWithTask:self];
}

- (BOOL)removeFromDisk {
    return [[self class] removeTaskFromDiskByTaskID:self.taskID concernID:self.concernID];
}

- (void)compressVideoCoverImage {

}

- (BOOL)needUploadImg {
    for (FRUploadImageModel * model in _images) {
        if (isEmptyString(model.webURI)) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)needUploadVideoCover {
    if (!self.video.coverImage) {
        return NO;
    }
    if (isEmptyString(self.video.coverImage.webURI)) {
        return YES;
    }
    return NO;
}

- (BOOL)needUploadVideo {
    if (!self.video) {
        return NO;
    }
    if (!self.video.isUploaded) {
        return YES;
    }
    return NO;
}

- (NSArray<FRUploadImageModel*> *)needUploadImgModels {
    NSMutableArray<FRUploadImageModel*> * ary = (NSMutableArray <FRUploadImageModel*> *)[NSMutableArray arrayWithCapacity:10];
    for (FRUploadImageModel * model in _images) {
        if (isEmptyString(model.webURI)) {
            [ary addObject:model];
        }
    }
    return ary;
}

+ (NSDictionary *)fakeThreadDictionary:(TTForumPostThreadTask *)task {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@(YES) forKey:@"isFake"];//帖子是本地构造的假帖子
    [dic setValue:@(YES) forKey:@"isPosting"];//帖子正在发送
    [dic setValue:task.concernID forKey:@"concernID"];
    [dic setValue:task.title forKey:@"title"];
    [dic setValue:task.content forKey:@"content"];
    [dic setValue:task.contentRichSpans forKey:@"contentRichSpanJSONString"];
    [dic setValue:[NSNumber numberWithLongLong:task.fakeThreadId] forKey:@"thread_id"];
    //添加uniqueID（primary key）
    [dic setValue:[NSNumber numberWithLongLong:task.fakeThreadId] forKey:@"uniqueID"];
    [dic setValue:@(1) forKey:@"ui_type"];//发帖默认文章样式
    [dic setValue:@(TTInnerUIFlagSinglePicSmall | TTInnerUIFlagDoublePicSmall | TTInnerUIFlagTreblePicSmall) forKey:@"inner_ui_flag"];
    [dic setValue:@(ExploreOrderedDataCellTypeThread) forKey:@"cell_type"];
    [dic setValue:[NSNumber numberWithLongLong:task.create_time] forKey:@"create_time"];
    [dic setValue:@(task.score).stringValue forKey:@"score"];
    
    SSMyUserModel *userModel = [[TTAccountManager sharedManager] myUser];
    NSMutableDictionary *user = [NSMutableDictionary dictionary];
    [user setValue:userModel.userDescription forKey:@"desc"];
    [user setValue:userModel.avatarURLString forKey:@"avatar_url"];
    [user setValue:userModel.ID forKey:@"user_id"];
    [user setValue:userModel.userAuthInfo forKey:@"user_auth_info"];
    [user setValue:userModel.name forKey:@"screen_name"];
    [dic setValue:user forKey:@"user"];
    
    if (task.latitude != 0 && task.longitude != 0 && (!isEmptyString(task.city) || !isEmptyString(task.detail_pos))) {
        NSMutableDictionary * position = [NSMutableDictionary dictionary];
        [position setValue:@(task.latitude) forKey:@"latitude"];
        [position setValue:@(task.longitude) forKey:@"longitude"];
        NSMutableString * positionName = [NSMutableString string];
        if (!isEmptyString(task.city)) {
            [positionName appendString:task.city];
            if (!isEmptyString(task.detail_pos)) {
                [positionName appendString:[NSString stringWithFormat:@" %@",task.detail_pos]];
            }
        }else {
            [positionName appendString:task.detail_pos];
        }
        [position setValue:positionName.copy forKey:@"position"];
        [dic setValue:position forKey:@"position"];
    }
    
    if (task.images.count > 0) {
        NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:task.images.count];
        [task.images enumerateObjectsUsingBlock:^(FRUploadImageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImage * showImg = obj.thumbnailImg;
            NSString * fakeURL = obj.fakeUrl;
            if (isEmptyString(fakeURL)) {
                return;
            }
            [[SDWebImageAdapter sharedAdapter] saveImageToCache:showImg forURL:[NSURL URLWithString:fakeURL]];
            NSMutableDictionary *imgDic = [NSMutableDictionary dictionaryWithCapacity:6];
            [imgDic setValue:fakeURL forKey:@"url"];
            [imgDic setValue:fakeURL forKey:@"uri"];
            [imgDic setValue:@[@{@"url":fakeURL}] forKey:@"url_list"];
            [imgDic setValue:@(1) forKey:@"type"];
            [imgDic setValue:@(showImg.size.width) forKey:@"width"];
            [imgDic setValue:@(showImg.size.height) forKey:@"height"];
            [imgs addObject:imgDic];
        }];
        [dic setValue:imgs forKey:@"large_image_list"];
        [dic setValue:imgs forKey:@"thumb_image_list"];
        [dic setValue:imgs forKey:@"ugc_cut_image_list"];
    }
    
    return dic.copy;
}

- (TTForumPostThreadTaskStatus)status {
    if (self.isPosting) {
        if (self.finishError) {
            return TTForumPostThreadTaskStatusFailed;
        }
        else {
            return TTForumPostThreadTaskStatusPosting;
        }
    }
    else {
        return TTForumPostThreadTaskStatusSucceed;
    }
}

+ (BOOL)persistentToDiskWithTask:(TTForumPostThreadTask *)task {
    if (isEmptyString(task.taskID) || isEmptyString(task.concernID)) {
        return NO;
    }
    if (isEmptyString(task.userID)) {
        return NO;
    }
    @synchronized(self) {
        BOOL result = NO;
        @try {
            NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString * dictionaryPath = [[docsPath stringByAppendingPathComponent:kTTForumPostThreadTask] stringByAppendingPathComponent:task.userID];
            BOOL isDirectory = NO;
            NSError * createDireError = nil;
            if (![[NSFileManager defaultManager] fileExistsAtPath:dictionaryPath isDirectory:&isDirectory]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:&createDireError];
            }
            
            dictionaryPath = [dictionaryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", task.concernID]];
            isDirectory = NO;
            createDireError = nil;
            if (![[NSFileManager defaultManager] fileExistsAtPath:dictionaryPath isDirectory:&isDirectory]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:&createDireError];
            }
            
            NSString *filename = [dictionaryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", task.taskID]];
            
            result = [NSKeyedArchiver archiveRootObject:task toFile:filename];
            
        }
        @catch (NSException *exception) {
            result = NO;
        }
        @finally {
            
        }
        return result;
    }
}

+ (void)fetchTaskFromDiskByTaskID:(NSString *)taskID concernID:(NSString *)cid completion:(void(^)(TTForumPostThreadTask *task))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TTForumPostThreadTask *task = [self fetchTaskFromDiskByTaskID:taskID concernID:cid];
#if DEBUG
        task.debug_currentMethod = [TTUGCBacktraceLogger ttugc_backtraceOfCurrentThread];
#endif
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(task);
            });
        }
    });
}

+ (TTForumPostThreadTask *)fetchTaskFromDiskByTaskID:(NSString *)taskID concernID:(NSString *)cid {
    if (isEmptyString(taskID) || isEmptyString(cid)) {
        return nil;
    }
    if (isEmptyString([TTAccountManager userID])) {
        return nil;
    }
    @synchronized(self) {
        NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * dictionaryPath = [[[docsPath stringByAppendingPathComponent:kTTForumPostThreadTask] stringByAppendingPathComponent:[TTAccountManager userID]] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", cid]];
        NSString *filename = [dictionaryPath stringByAppendingPathComponent:taskID];
        id cached = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
        if (cached && [cached isKindOfClass:[self class]]) {
#if DEBUG || INHOUSE
            ((TTForumPostThreadTask *)cached).debug_currentMethod = @"";
#endif
            return cached;
        }
        return nil;
    }
}

+ (nullable NSArray <TTForumPostThreadTask *> *)fetchTasksFromDiskForConcernID:(nonnull NSString *)concernID {
    if (isEmptyString(concernID)) {
        return nil;
    }
    if (isEmptyString([TTAccountManager userID])) {
        return nil;
    }
    @synchronized (self) {
        NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * dictionaryPath = [[[docsPath stringByAppendingPathComponent:kTTForumPostThreadTask] stringByAppendingPathComponent:[TTAccountManager userID]] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", concernID]];
        NSFileManager* fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:dictionaryPath isDirectory:nil]) {
            return nil;
        }
        NSDirectoryEnumerator* en = [fm enumeratorAtPath:dictionaryPath];
        NSString* file = nil;
        NSMutableArray <TTForumPostThreadTask *> *tasks = [[NSMutableArray alloc] init];
        while (file = [en nextObject]) {
            NSString *filename = [dictionaryPath stringByAppendingPathComponent:file];
            id cached = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
            if (cached && [cached isKindOfClass:[self class]]) {
#if DEBUG || INHOUSE
                ((TTForumPostThreadTask *)cached).debug_currentMethod = @"";
#endif
                [tasks addObject:cached];
            }
        }
        return tasks;
    }
}

+ (BOOL)removeTaskFromDiskByTaskID:(NSString *)taskID concernID:(NSString *)cid {
    if (isEmptyString(taskID) || isEmptyString(cid)) {
        return NO;
    }
    if (isEmptyString([TTAccountManager userID])) {
        return NO;
    }
    @synchronized(self) {
        NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * dictionaryPath = [[[docsPath stringByAppendingPathComponent:kTTForumPostThreadTask] stringByAppendingPathComponent:[TTAccountManager userID]] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", cid]];
        NSString *filename = [dictionaryPath stringByAppendingPathComponent:taskID];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:nil]) {
            return [[NSFileManager defaultManager] removeItemAtPath:filename error:nil];
        }
        return NO;
    }
}

+ (void)removeAllDiskTask {
    @synchronized(self) {
        @try {
            NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString * dictionaryPath = [docsPath stringByAppendingPathComponent:kTTForumPostThreadTask];
            NSFileManager* fm = [NSFileManager defaultManager];
            if (![fm fileExistsAtPath:dictionaryPath isDirectory:nil]) {
                return;
            }
            NSDirectoryEnumerator* en = [fm enumeratorAtPath:dictionaryPath];
            NSError* err = nil;
            BOOL res;
            
            NSString* file;
            while (file = [en nextObject]) {
                res = [fm removeItemAtPath:[dictionaryPath stringByAppendingPathComponent:file] error:&err];
                if (!res && err) {
                    NSLog(@"oops: %@", err);
                }
            }
            
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
}

+ (NSString *)taskInDiskPosition {
    if (isEmptyString([TTAccountManager userID])) {
        return nil;
    }
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * dictionaryPath = [[docsPath stringByAppendingPathComponent:[TTAccountManager userID]] stringByAppendingPathComponent:kTTForumPostThreadTask];
    return dictionaryPath;
}

+ (NSString *)taskIDFromFakeThreadID:(int64_t)fakeThreadId {
    return [NSString stringWithFormat:@"%@%lli", kTTForumPostThreadTask, fakeThreadId];
}

- (void)setUploadProgress:(CGFloat)uploadProgress {
    
    LOGD(@"======xsq %@ updateTo %f", self.title, uploadProgress);
    
    _uploadProgress = uploadProgress;
    if (self.progressBlock) {
        self.progressBlock(_uploadProgress);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumThreadProgressUpdateNotification object:self];
}

+ (TTRepostOperationItemType) repostOperationItemTypeFromOptType:(FRUGCTypeCode)optIdType {
    TTRepostOperationItemType result = TTRepostOperationItemTypeNone;
    switch (optIdType) {
        case FRUGCTypeCodeCOMMENT:
             result = TTRepostOperationItemTypeComment;
            break;
        case FRUGCTypeCodeTHREAD:
             result = TTRepostOperationItemTypeThread;
            break;
        case FRUGCTypeCodeREPLY:
             result = TTRepostOperationItemTypeReply;
            break;
        case FRUGCTypeCodeITEM:
             result = TTRepostOperationItemTypeArticle;
            break;
        case FRUGCTypeCodeGROUP:
             result = TTRepostOperationItemTypeArticle;
            break;
        case FRUGCTypeCodeUGC_VIDEO:
             result = TTRepostOperationItemTypeShortVideo;
            break;
        case FRUGCTypeCodeANSWER:
             result = TTRepostOperationItemTypeWendaAnswer;
            break;
        case FRUGCTypeCodeQUESTION:
            result = TTRepostOperationItemTypeWendaAnswer;
            break;
        default:
            break;
    }
    return result;
}
@end

@implementation TTForumPostThreadTask (ShortVideoProtocol)

- (int64_t)fakeID {
    return self.fakeThreadId;
}

- (UIImage *)shortVideoCoverImage {
    return self.video.coverImage.thumbnailImg;
}

- (BOOL)isShortVideo {
    if (self.taskType == TTForumPostThreadTaskTypeVideo && (self.video.videoSourceType == TTPostVideoSourceShortVideoFromCamera || self.video.videoSourceType == TTPostVideoSourceShortVideoFromAlbum || self.video.videoSourceType == TTPostVideoSourceShortVideoFromUGCVideo)) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldInsertToShortVideoTab {
    if ([self.concernID isEqualToString:kTTShortVideoConcernID]) {
        return YES;
    }
    return NO;
}

- (BOOL)isFromConcernHomepage {
    return (self.postUGCEnterFrom == TTPostUGCEnterFromConcernHomepage);
}

- (NSString *)tsvActivityConcernID {
    if (![self isShortVideo]) {
        return nil;
    }
    NSArray *mentionConcerns = [self.mentionConcern componentsSeparatedByString:@","];
    if ([mentionConcerns count] > 0) {
        return [mentionConcerns firstObject];
    }
    return nil;
}

- (BOOL)shouldShowRedPacket {
//    return [TTPostVideoRedpackDelegate shouldShowRedPack:self];
    return NO;
}

@end
