//
//  TTVideoInfoModel.m
//  Article
//
//  Created by Dai Dongpeng on 6/2/16.
//
//

#import "TTVideoInfoModel.h"
#import "NSDictionary+TTAdditions.h"

#define TTNumberToStr(n) [@(n) stringValue]

@implementation TTVideoURLInfo

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dic = @{
                          @"definition" : NSStringFromSelector(@selector(videoDefinitionType)),
                          @"vtype" : NSStringFromSelector(@selector(vType)),
                          @"vwidth" : NSStringFromSelector(@selector(vWidth)),
                          @"vheight" : NSStringFromSelector(@selector(vHeight)),
                          
                          @"main_url" : NSStringFromSelector(@selector(mainURLStr)),
                          @"backup_url_1" : NSStringFromSelector(@selector(backupURL1)),
                          @"backup_url_2" : NSStringFromSelector(@selector(backupURL2)),
                          @"backup_url_3" : NSStringFromSelector(@selector(backupURL3)),
                          };
    return [[JSONKeyMapper alloc] initWithDictionary:dic];
}

- (void)setVideoDefinitionTypeWithNSString:(NSString *)typeString
{
    if ([typeString isEqualToString:@"360p"]) {
        
        _videoDefinitionType = ExploreVideoDefinitionTypeSD;
        
    } else if ([typeString isEqualToString:@"480p"]) {
        
        _videoDefinitionType = ExploreVideoDefinitionTypeHD;
        
    } else if ([typeString isEqualToString:@"720p"]) {
        
        _videoDefinitionType = ExploreVideoDefinitionTypeFullHD;
        
    } else {
        _videoDefinitionType = ExploreVideoDefinitionTypeSD;
    }
}

- (NSString *)base64ToUTF8String:(NSString *)str
{
    @try {
        if (isEmptyString(str)) {
            return nil;
        }
        NSData *decodedData = [NSData ss_dataWithBase64EncodedString:str];
        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        if (isEmptyString(decodedString)) {
            return nil;
        }
        return decodedString;
    }
    @catch (NSException *exception) {
        return nil;
    }
}


- (void)setMainURLStrWithNSString:(NSString *)urlStr
{
    _mainURLStr = [self base64ToUTF8String:urlStr];
}

- (void)setBackupURL1WithNSString:(NSString *)urlStr
{
    _backupURL1 = [self base64ToUTF8String:urlStr];
}

- (void)setBackupURL2WithNSString:(NSString *)urlStr
{
    _backupURL2 = [self base64ToUTF8String:urlStr];
}

- (void)setBackupURL3WithNSString:(NSString *)urlStr
{
    _backupURL3 = [self base64ToUTF8String:urlStr];
}

- (NSArray *)allURLForVideoID:(NSString *)videoID
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:4];
    
    void(^addBlock)(NSString *) = ^(NSString *urlStr)
    {
        if (isEmptyString(urlStr)) {
            return ;
        }
        [array addObject:urlStr];
    };
    
    addBlock(self.mainURLStr);
    addBlock(self.backupURL1);
    addBlock(self.backupURL2);
    addBlock(self.backupURL3);
    
    return [array copy];
}

@end

@implementation TTVideoURLInfoMap

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dic = @{
                          @"video_1" : NSStringFromSelector(@selector(video1)),
                          @"video_2" : NSStringFromSelector(@selector(video2)),
                          @"video_3" : NSStringFromSelector(@selector(video3))
                          };
    return [[JSONKeyMapper alloc] initWithDictionary:dic];
}

@end

@implementation TTVideoInfoModel

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dic = @{
                          @"video_id" : NSStringFromSelector(@selector(videoID)),
                          @"user_id"  : NSStringFromSelector(@selector(userID)),
                          @"video_list" : NSStringFromSelector(@selector(videoURLInfoMap)),
                          @"video_duration" : NSStringFromSelector(@selector(videoDuration))
                          };
    return [[JSONKeyMapper alloc] initWithDictionary:dic];
}

- (NSArray *)allURLWithDefinition:(ExploreVideoDefinitionType)type
{
    NSArray *urls;
    switch (type) {
        case ExploreVideoDefinitionTypeSD:
            urls = [self.videoURLInfoMap.video1 allURLForVideoID:self.videoID];
            break;
        case ExploreVideoDefinitionTypeHD:
            urls = [self.videoURLInfoMap.video2 allURLForVideoID:self.videoID];
            break;
        case ExploreVideoDefinitionTypeFullHD:
            urls = [self.videoURLInfoMap.video3 allURLForVideoID:self.videoID];
        default:
            break;
    }
    return urls;
}

- (NSInteger)videoSizeForType:(ExploreVideoDefinitionType)type
{
    NSInteger size;
    switch (type) {
        case ExploreVideoDefinitionTypeSD:
            size = [self.videoURLInfoMap.video1.size integerValue];
            break;
        case ExploreVideoDefinitionTypeHD:
            size = [self.videoURLInfoMap.video2.size integerValue];
            break;
        case ExploreVideoDefinitionTypeFullHD:
            size = [self.videoURLInfoMap.video3.size integerValue];
            break;
        default:
            size = 0;
            break;
    }
    return size;
}

- (NSString *)definitionStrForType:(ExploreVideoDefinitionType)type
{
    NSString *str = @"";
    switch (type) {
        case ExploreVideoDefinitionTypeSD:
            str = @"360p";
            break;
        case ExploreVideoDefinitionTypeHD:
            str = @"480p";
            break;
        case ExploreVideoDefinitionTypeFullHD:
            str = @"720p";
            break;
        default:
            break;
    }
    return str;
}

- (TTVideoURLInfo *)videoInfoForType:(ExploreVideoDefinitionType)type
{
    TTVideoURLInfo *info = nil;
    switch (type) {
        case ExploreVideoDefinitionTypeSD:
            info  = self.videoURLInfoMap.video1;
            break;
        case ExploreVideoDefinitionTypeHD:
            info = self.videoURLInfoMap.video2;
            break;
        case ExploreVideoDefinitionTypeFullHD:
            info = self.videoURLInfoMap.video3;
            break;
        default:
            info = nil;
            break;
    }
    return info;
}

@end
