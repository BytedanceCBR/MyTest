//
//  TTPostThreadTask.m
//  Article
//
//  Created by 王霖 on 3/16/16.
//
//

#import "TTPostThreadTask.h"
#import "TTPostThreadDefine.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <TTImagePicker/ALAssetsLibrary+TTImagePicker.h>
#import <TTUGCFoundation/TTUGCImageCompressHelper.h>
#import <SDWebImage/SDWebImageManager.h>
#import <BDWebImage/SDWebImageAdapter.h>
#import <TTKitchen/TTKitchen.h>
#import <ios_house_im/FRUploadImageModel.h>
//#import <TTServiceProtocols/TTAccountProvider.h>
#import <TTServiceKit/TTServiceCenter.h>
#import <TTBaseLib/TTBaseMacro.h>
//#import <BDMobileRuntime/BDMobileRuntime.h>
//#import <TTRegistry/TTRegistryDefines.h>
#import "TTAccount.h"

#define kTTPostThreadTask @"TTPostThreadTask"

const CGFloat TTForumPostVideoThreadTaskBeforeUploadImageProgress = 0.90f;
const CGFloat TTForumPostVideoThreadTaskBeforeUploadVideoProgress = 0.05f;
const CGFloat TTForumPostVideoThreadTaskBeforePostThreadProgress = 0.95f;

@interface TTPostThreadTask()

@end

@implementation TTPostThreadTask

- (void)setIsPosting:(BOOL)isPosting {
    _isPosting = isPosting;
}

- (void)setFinishError:(NSError *)finishError {
    _finishError = finishError;
}

- (instancetype)init {
    return [self initWithTaskType:TTPostTaskTypeThread];
}

- (instancetype)initWithTaskType:(TTPostTaskType)taskType {
    self = [super initWithTaskType:taskType];
    if (self) {
        self.retryCount = 0;
        self.finishError = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
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
        self.selectedRange = [[aDecoder decodeObjectForKey:@"selectedRange"] rangeValue];
        
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.titleRichSpan = [aDecoder decodeObjectForKey:@"titleRichSpan"];
        self.phone = [aDecoder decodeObjectForKey:@"phone"];
        self.fromWhere = [aDecoder decodeIntegerForKey:@"fromWhere"];
        self.score = [aDecoder decodeFloatForKey:@"score"];
        self.refer = [aDecoder decodeIntegerForKey:@"refer"];
        self.postUGCEnterFrom = [aDecoder decodeIntegerForKey:@"postUGCEnterFrom"];
        self.insertMixCardID = [aDecoder decodeInt64ForKey:@"insertMixCardID"];
        self.relatedForumSubjectID = [aDecoder decodeObjectForKey:@"relatedForumSubjectID"];
        self.extraTrack = [aDecoder decodeObjectForKey:@"extraTrack"];
        
        self.repostType = [aDecoder decodeIntegerForKey:@"repostType"];
        self.fw_id = [aDecoder decodeObjectForKey:@"fw_id"];
        self.fw_id_type = [aDecoder decodeIntegerForKey:@"fw_id_type"];
        self.opt_id = [aDecoder decodeObjectForKey:@"opt_id"];
        self.opt_id_type = [aDecoder decodeIntegerForKey:@"opt_id_type"];
        self.fw_user_id = [aDecoder decodeObjectForKey:@"fw_user_id"];
        self.repostTitle = [aDecoder decodeObjectForKey:@"repostTitle"];
        self.repostSchema = [aDecoder decodeObjectForKey:@"repostSchema"];
        self.repostToComment = [aDecoder decodeBoolForKey:@"repostToComment"];
        self.repostTaskType = [aDecoder decodeIntegerForKey:@"repostTaskType"];
        self.fw_native_schema = [aDecoder decodeObjectForKey:@"fw_native_schema"];
        self.fw_share_url = [aDecoder decodeObjectForKey:@"fw_share_url"];
        self.communityID = [aDecoder decodeObjectForKey:@"communityID"];
        self.businessPayload = [aDecoder decodeObjectForKey:@"businessPayload"];
        self.errorPosition = [aDecoder decodeIntegerForKey:@"errorPosition"];
        self.postID = [aDecoder decodeObjectForKey:@"postID"];
        self.promotionID = [aDecoder decodeObjectForKey:@"promotionID"];
        self.sdkParams = [aDecoder decodeObjectForKey:@"sdkParams"];
        self.social_group_id = [aDecoder decodeObjectForKey:@"social_group_id"];
        self.bindType = [aDecoder decodeObjectForKey:@"bind_type"];
        self.uploadProgress = [aDecoder decodeFloatForKey:@"uploadProgress"];
        
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
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:self.taskType forKey:@"taskType"];
    [aCoder encodeObject:self.taskID forKey:@"taskID"];
    [aCoder encodeObject:_content forKey:@"content"];
    [aCoder encodeObject:_contentRichSpans forKey:@"contentRichSpans"];
    [aCoder encodeObject:_mentionUser forKey:@"mentionUser"];
    [aCoder encodeObject:_coverUrl forKey:@"coverUrl"];
    [aCoder encodeObject:_mentionConcern forKey:@"mentionConcern"];
    [aCoder encodeInt64:_create_time forKey:@"create_time"];
    [aCoder encodeObject:self.concernID forKey:@"concernID"];
    [aCoder encodeObject:self.userID forKey:@"userID"];
    [aCoder encodeObject:_categoryID forKey:@"categoryID"];
    [aCoder encodeInt64:self.fakeThreadId forKey:@"fakeThreadId"];
    [aCoder encodeInteger:_forward forKey:@"forward"];
    [aCoder encodeInt:_source forKey:@"source"];
    [aCoder encodeInt:_retryCount forKey:@"retryCount"];
    [aCoder encodeFloat:_latitude forKey:@"latitude"];
    [aCoder encodeFloat:_longitude forKey:@"longitude"];
    [aCoder encodeObject:_city forKey:@"city"];
    [aCoder encodeObject:_detail_pos forKey:@"detail_pos"];
    [aCoder encodeInt:_locationType forKey:@"locationType"];
    [aCoder encodeObject:_locationAddress forKey:@"locationAddress"];
    [aCoder encodeObject:[NSValue valueWithRange:_selectedRange] forKey:@"selectedRange"];
    [aCoder encodeFloat:_uploadProgress forKey:@"uploadProgress"];
    
    if (_postID) {
        [aCoder encodeObject:_postID forKey:@"postID"];
    }
    if (_title) {
        [aCoder encodeObject:_title forKey:@"title"];
    }
    [aCoder encodeObject:_titleRichSpan forKey:@"titleRichSpan"];
    if (_phone) {
        [aCoder encodeObject:_phone forKey:@"phone"];
    }
    if (_sdkParams) {
        [aCoder encodeObject:_sdkParams forKey:@"sdkParams"];
    }
    if (self.social_group_id.length > 0) {
        [aCoder encodeObject:_social_group_id forKey:@"social_group_id"];
    }
    [aCoder encodeInteger:_bindType forKey:@"bind_type"];
    [aCoder encodeInteger:_fromWhere forKey:@"fromWhere"];
    [aCoder encodeFloat:_score forKey:@"score"];
    [aCoder encodeInteger:_refer forKey:@"refer"];
    [aCoder encodeInteger:_postUGCEnterFrom forKey:@"postUGCEnterFrom"];
    [aCoder encodeInt64:_insertMixCardID forKey:@"insertMixCardID"];
    [aCoder encodeObject:_relatedForumSubjectID forKey:@"relatedForumSubjectID"];
    [aCoder encodeObject:_extraTrack forKey:@"extraTrack"];
    
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
    [aCoder encodeObject:_fw_native_schema forKey:@"fw_native_schema"];
    [aCoder encodeObject:_fw_share_url forKey:@"fw_share_url"];
    [aCoder encodeObject:_communityID forKey:@"communityID"];
    [aCoder encodeObject:_businessPayload forKey:@"businessPayload"];
    [aCoder encodeObject:_promotionID forKey:@"promotionID"];

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

- (void)addTaskImages:(nullable NSArray<TTUGCImageCompressTask*> *)taskImages thumbImages:(nullable NSArray<UIImage*> *)thumbImages{
    NSMutableArray<FRUploadImageModel *> * images = (NSMutableArray<FRUploadImageModel*> *)[NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < [taskImages count]; i ++) {
        TTUGCImageCompressTask* task = [taskImages objectAtIndex:i];
        UIImage* thumbImage = nil;
        if (thumbImages.count > i) {
            thumbImage = thumbImages[i];
        }
        FRUploadImageModel * model = [[FRUploadImageModel alloc] initWithCacheTask:task thumbnail:thumbImage];
        model.webURI = task.assetModel.imageURI;
        model.imageOriginWidth = task.assetModel.width;
        model.imageOriginHeight = task.assetModel.height;
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

- (BOOL)needUploadImg {
    for (FRUploadImageModel * model in _images) {
        if (isEmptyString(model.webURI)) {
            return YES;
        }
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

- (TTPostTaskStatus)status {
    if (self.isPosting) {
        if (self.finishError) {
            return TTPostTaskStatusFailed;
        }
        else {
            return TTPostTaskStatusPosting;
        }
    }
    else {
        return TTPostTaskStatusSucceed;
    }
}

+ (NSString *)taskInDiskPosition {
    NSString *userID = [[[TTAccount sharedAccount] userIdString] copy];
    // NSString *userID = [[BDContextGet() findServiceByName:TTAccountProviderServiceName] userID];
    if (isEmptyString(userID)) {
        return nil;
    }
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * dictionaryPath = [[docsPath stringByAppendingPathComponent:userID] stringByAppendingPathComponent:kTTPostThreadTask];
    return dictionaryPath;
}

- (void)setUploadProgress:(CGFloat)uploadProgress {
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

@implementation TTPostThreadTask(UI)

- (UIImage *)coverImage {
    return [[[self images] lastObject] thumbnailImg];
}

- (NSString *)musicID
{
    return nil;
}
@end

