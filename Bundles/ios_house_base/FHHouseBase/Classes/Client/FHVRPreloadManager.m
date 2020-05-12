//
//  FHVRPreloadManager.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/30.
//

#import "FHVRPreloadManager.h"
#import <SDWebImage/SDWebImageManager.h>
#import <IESGeckoKit/IESGeckoKit.h>
#import "FHMainApi.h"
#import "TTHttpTask.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import "FHUtils.h"

@interface FHVRPreloadManager()
@property(nonatomic,strong)TTHttpTask *vrImageTask;
@end

@implementation FHVRPreloadManager

+(instancetype)sharedInstance
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}



- (void)startCacheVRImage:(NSArray*)imageArray{
    
    [imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *imageStr = obj;
        
        if([imageStr isKindOfClass:[NSString class]] && [imageStr containsString:@".jpg"]){
//            NSRange imageUrlRangeTest = [imageStr rangeOfString:@"/f100-image/"];
//            NSString *imageNameTest = [imageStr substringFromIndex:imageUrlRangeTest.location + imageUrlRangeTest.length];
//            NSString *imageStrTest = [NSString stringWithFormat:@"%@/%@%@",@"https://sf1-ttcdn-tos.pstatp.com/img/f100-image",imageNameTest,@"~1024x0.jpg"];
//            imageStr = imageStrTest;
        }else{
            return ;
        }
      
        NSURL *urlImageLoader = [NSURL URLWithString:obj];
        NSString *imageRootPath = [IESGeckoKit rootDirForAccessKey:[FHVRPreloadManager getGeckoKey] channel:kFHVrImagePreLoadChannel];
        NSRange imageUrlRange = [imageStr rangeOfString:@"/img/"];
        if (imageUrlRange.location == 0) {
            return;
        }
        if (imageStr.length > (imageUrlRange.location + imageUrlRange.length)) {
            NSString *imageName = [imageStr substringFromIndex:imageUrlRange.location + imageUrlRange.length];
             NSString *imageFileS = [NSString stringWithFormat:@"%@/%@",imageRootPath,imageName];
             
             NSArray <NSString *>*arrayString = [imageName componentsSeparatedByString:@"/"];
             
            if (arrayString) {
                NSString *dirStr = [NSString stringWithFormat:@"%@/%@",imageRootPath,arrayString.firstObject];
                      
                if (![[NSFileManager defaultManager] fileExistsAtPath:dirStr]) {
                            [[NSFileManager defaultManager] createDirectoryAtPath:dirStr withIntermediateDirectories:YES attributes:nil error:nil];
                }
                
                if (urlImageLoader) {
                    [[SDWebImageManager sharedManager] loadImageWithURL:urlImageLoader options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                        
                              } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                        [data writeToFile:imageFileS atomically:YES];
                              }];
                    }
                }
            }
    }];
}

/**
 查找子字符串在父字符串中的所有位置
 @param content 父字符串
 @param tab 子字符串
 @return 返回位置数组
 */

- (NSMutableArray*)calculateSubStringCount:(NSString *)content str:(NSString *)tab {
    int location = 0;
    NSMutableArray *locationArr = [NSMutableArray new];
    NSRange range = [content rangeOfString:tab];
    if (range.location == NSNotFound){
        return locationArr;
    }
    //声明一个临时字符串,记录截取之后的字符串
    NSString * subStr = content;
    while (range.location != NSNotFound) {
        if (location == 0) {
            location += range.location;
        } else {
            location += range.location + tab.length;
        }
        //记录位置
        NSNumber *number = [NSNumber numberWithUnsignedInteger:location];
        [locationArr addObject:number];
        //每次记录之后,把找到的字串截取掉
        subStr = [subStr substringFromIndex:range.location + range.length];
        NSLog(@"subStr %@",subStr);
        range = [subStr rangeOfString:tab];
        NSLog(@"rang %@",NSStringFromRange(range));
    }
    return locationArr;
}


+ (NSString *)getGeckoKey
{
    if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNEL_NAME"] isEqualToString:@"local_test"]) {
        return @"adc27f2b35fb3337a4cb1ea86d05db7a";
    }else
    {
        return @"7838c7618ea608a0f8ad6b04255b97b9";
    }
}

- (void)requestForSimilarHouseId:(NSString *)houseId{
    if (self.vrImageTask) {
        [self.vrImageTask cancel];
        self.vrImageTask = nil;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param setValue:houseId forKey:@"house_id"];
    self.vrImageTask = [FHMainApi getRequest:@"/f100/api/vr/info" query:nil params:param completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        NSDictionary *dataDict = [result tt_objectForKey:@"data"];
        if ([dataDict isKindOfClass:[NSDictionary class]]) {
            NSDictionary *vrDataDict = [dataDict tt_objectForKey:@"Data"];
            NSString *vrDataStr = [vrDataDict tt_objectForKey:@"VrData"];
            NSDictionary *vrStrDataDict = [FHUtils dictionaryWithJsonString:vrDataStr];
            if (vrStrDataDict) {
                NSString *defaultId = [vrStrDataDict tt_objectForKey:@"Default_hotSpotId"];
                NSArray *vrImageArra = [vrStrDataDict tt_objectForKey:@"HotSpots"];
               __block NSDictionary *imagesDict = nil;
                [vrImageArra enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        NSString *idStr = obj[@"ID"];
                        if ([idStr isKindOfClass:[NSString class]]) {
                            if ([idStr isEqualToString:defaultId]) {
                                imagesDict = obj;
                            }
                        }
                    }
                }];
                
                NSArray *imageUrls = imagesDict[@"TileImageUrl"];
                [self startCacheVRImage:imageUrls];
            }
        }

    }];
}

@end
