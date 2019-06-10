//
//  WDPostAnswerTaskModel.m
//  Article
//
//  Created by 王霖 on 15/12/21.
//
//

#import "WDPostAnswerTaskModel.h"
#import "WDImagePathUploadImageModel.h"
#import <TTBaseLib/TTBaseMacro.h>
#import <objc/runtime.h>

#define IsEqualOrNil(x, y) ((!x && !y) || (x && [y isEqual:x]))
#define IsEqualStringOrNil(x, y) ((!x && !y) || (x && [y isEqualToString:x]))
#define IsEqualArrayOrNil(x, y) ((!x && !y) || (x && [y isEqualToArray:x]))

@interface WDPostAnswerTaskModel ()

@property (nonatomic, copy) NSString *qid;
@property (nonatomic, assign) BOOL isRefreshedPath;

@end

@implementation WDPostAnswerTaskModel

- (instancetype)initWithQid:(NSString *)qid
                    content:(NSString *)content
            contentRichSpan:(NSString *)contentRichSpan
                  imageList:(NSArray<WDImageObjectUploadImageModel *> *)imageList {
    self = [super init];
    if (self) {
        self.qid = qid;
        self.content = content;
        self.richSpanText = contentRichSpan;
        self.imageList = (NSArray<id<WDUploadImageModelProtocol>> *)imageList;
        self.answerType = WDPostAnswerTypePictureText;
    }
    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.qid = [aDecoder decodeObjectForKey:@"qid"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.richSpanText = [aDecoder decodeObjectForKey:@"richSpanText"];
        self.imageList = [aDecoder decodeObjectForKey:@"imageList"];
        self.answerType = [[aDecoder decodeObjectForKey:@"answerType"] unsignedIntegerValue];
        self.timeStamp = [[aDecoder decodeObjectForKey:@"timeStamp"] doubleValue];
        self.pasteTimes = [[aDecoder decodeObjectForKey:@"pasteTimes"] unsignedIntegerValue];
        self.pastLength = [[aDecoder decodeObjectForKey:@"pastLength"] unsignedIntegerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_qid forKey:@"qid"];
    [aCoder encodeObject:_content forKey:@"content"];
    [aCoder encodeObject:_richSpanText forKey:@"richSpanText"];
    [aCoder encodeObject:_imageList forKey:@"imageList"];
    [aCoder encodeObject:@(_answerType) forKey:@"answerType"];
    [aCoder encodeObject:@(_timeStamp) forKey:@"timeStamp"];
    [aCoder encodeObject:@(_pasteTimes) forKey:@"pasteTimes"];
    [aCoder encodeObject:@(_pastLength) forKey:@"pastLength"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    typeof(self) copy = [[[self class] allocWithZone:zone] init];
    copy.qid = [_qid copyWithZone:zone];
    copy.content = [_content copyWithZone:zone];
    copy.richSpanText = [_richSpanText copyWithZone:zone];
    //深复制
    copy.imageList = [_imageList copyWithZone:zone];
    copy.answerType = _answerType;
    copy.pastLength = _pastLength;
    copy.pasteTimes = _pasteTimes;
    return copy;
}

#pragma mark - Public Methods

- (void)refreshCurrentSandBoxPath
{
    if (self.answerType != WDPostAnswerTypeRichText) {
        return;
    }
    if (self.isRefreshedPath) {
        return;
    }
    
    self.isRefreshedPath = YES;
    
    //更新HTML里面的路径
    self.content = [WDPostAnswerTaskModel replaceSandBoxPath:self.content];
    
    
    //更新图片里面的路径
    for (WDImagePathUploadImageModel *imageModel in self.imageList) {
        imageModel.compressImgUri = [WDPostAnswerTaskModel replaceSandBoxPath:imageModel.compressImgUri];
    }
}

- (NSArray<NSString *> *)remoteImgUris {
    if (SSIsEmptyArray(self.imageList)) {
        return nil;
    }
    NSMutableArray<NSString *> *imageUris = [NSMutableArray arrayWithCapacity:self.imageList.count];
    for (id<WDUploadImageModelProtocol> imageModel in self.imageList) {
        if (!isEmptyString(imageModel.remoteImgUri)) {
            [imageUris addObject:imageModel.remoteImgUri];
        }
    }
    
    return [imageUris copy];
}

- (void)refreshTimeStamp
{
    self.timeStamp = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - Util

+ (NSString *)replaceSandBoxPath:(NSString *)contentText
{
    if (!contentText) {
        return nil;
    }
    
    NSString *library = @"Library";
    NSString *app = @"Application";
    
    NSArray * searchResult =  [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    NSURL * documentPath = [searchResult firstObject];
    NSString *currentSandBoxPath = documentPath.absoluteString;
    NSRange appRange = [currentSandBoxPath rangeOfString:app];
    NSRange libraryRange = [currentSandBoxPath rangeOfString:library];
    
    //新路径有误直接返回
    NSString *aimPath = [currentSandBoxPath substringWithRange:NSMakeRange(appRange.location, NSMaxRange(libraryRange) - appRange.location)];
    if (NSMaxRange(appRange) > currentSandBoxPath.length || NSMaxRange(appRange) > currentSandBoxPath.length) {
        return contentText;
    }
    
    //替换旧的，旧的里面没有路径，则直接返回
    appRange = [contentText rangeOfString:app];
    libraryRange = [contentText rangeOfString:library];
    if (NSMaxRange(appRange) > contentText.length || NSMaxRange(appRange) > contentText.length) {
        return contentText;
    }
    
    //用于替换的字符串
    NSString *oldPath = [contentText substringWithRange:NSMakeRange(appRange.location, NSMaxRange(libraryRange) - appRange.location)];
    if (oldPath) {
        contentText = [contentText stringByReplacingOccurrencesOfString:oldPath withString:aimPath];
    }
    
    return contentText;
}

#pragma mark - Setter & Getter

- (void)setAnswerType:(WDPostAnswerType)answerType {
    if (_answerType != answerType) {
        self.isMutate = YES;
    }
    _answerType = answerType;
}

- (void)setContent:(NSString *)content {
    if (!IsEqualStringOrNil(_content, content)) {
        self.isMutate = YES;
    }
    _content = [content copy];
}

- (void)setRichSpanText:(NSString *)richSpanText {
    if (!IsEqualStringOrNil(_richSpanText, richSpanText)) {
        self.isMutate = YES;
    }
    _richSpanText = [richSpanText copy];
}

- (void)setImageList:(NSArray<id<WDUploadImageModelProtocol>> *)imageList {
    if (!IsEqualArrayOrNil(_imageList, imageList)) {
        self.isMutate = YES;
    }
    _imageList = [imageList copy];
}

@end

@implementation WDPostAnswerTaskModel (DraftManager)

- (BOOL)hasLoadDraft {
    NSNumber *value = objc_getAssociatedObject(self, @selector(hasLoadDraft));
    return value.boolValue;
}

- (void)setHasLoadDraft:(BOOL)hasLoadDraft {
    objc_setAssociatedObject(self, @selector(hasLoadDraft), @(hasLoadDraft), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
