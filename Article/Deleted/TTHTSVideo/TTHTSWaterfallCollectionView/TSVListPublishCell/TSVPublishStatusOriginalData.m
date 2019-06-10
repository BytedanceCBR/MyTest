//
//  TSVPublishStatusOriginalData.m
//  Article
//
//  Created by 王双华 on 2017/11/24.
//

#import "TSVPublishStatusOriginalData.h"
#import "TTUGCPostCenterProtocol.h"

@interface TSVPublishStatusOriginalData()

@property (nonatomic, strong, readwrite) UIImage *coverImage;
@property (nonatomic, copy, readwrite) NSString *concernID;
@property (nonatomic, copy, readwrite) NSString *categoryID;

@property (nonatomic, assign, readwrite) TTForumPostThreadTaskStatus status;
@property (nonatomic, assign, readwrite) CGFloat uploadingProgress;
@property (nonatomic, assign, readwrite) int64_t fakeID;
@property (nonatomic, copy, readwrite) NSString *tsvActivityConcernID;
@property (nonatomic, copy, readwrite) NSString *challengeGroupID;

@end

@implementation TSVPublishStatusOriginalData

+ (NSString *)dbName
{
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"uniqueID";
}

+ (NSArray *)persistentProperties
{
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"uniqueID",
                       ];
    }
    return properties;
}

- (void)updateWithTask:(id<TSVShortVideoPostTaskProtocol>)task
{
    ///categoryID concernID fakeID coverImage不需要更新
    if (isEmptyString(self.categoryID)) {
        self.categoryID = task.categoryID;
    }
    if (isEmptyString(self.concernID)) {
        self.concernID = task.concernID;
    }
    if (self.fakeID == 0) {
        self.fakeID = task.fakeID;
    }
    if (!self.coverImage) {
        self.coverImage = task.shortVideoCoverImage;
    }
    if (isEmptyString(self.tsvActivityConcernID)) {
        self.tsvActivityConcernID = task.tsvActivityConcernID;
    }
    if (isEmptyString(self.challengeGroupID)) {
        self.challengeGroupID = task.challengeGroupID;
    }
    self.status = task.status;
    self.uploadingProgress = task.uploadProgress;
}

- (NSDictionary *)dictForJSBridge
{
    NSMutableDictionary *publishStatusDict = [NSMutableDictionary dictionary];
    [publishStatusDict setValue:[NSString stringWithFormat:@"%lld", self.fakeID] forKey:@"id"];
    [publishStatusDict setValue:self.concernID forKey:@"concern_id"];
    NSString *status;
    if (self.status == TTForumPostThreadTaskStatusPosting) {
        status = @"uploading";
    } else if (self.status == TTForumPostThreadTaskStatusFailed) {
        status = @"failed";
    } else {
        status = @"success";
    }
    [publishStatusDict setValue:status forKey:@"status"];
    NSString *uploadingProgress = [NSString stringWithFormat:@"%d%%", (int)(self.uploadingProgress * 100.0)];
    [publishStatusDict setValue:uploadingProgress forKey:@"progress"];
    NSData *imageData = UIImagePNGRepresentation(self.coverImage);
    [publishStatusDict setValue:[imageData base64EncodedStringWithOptions:0] forKey:@"image"];
    return [publishStatusDict copy];
}

@end
