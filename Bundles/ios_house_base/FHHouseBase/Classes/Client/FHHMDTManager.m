//
//  FHHMDTManager.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/9/19.
//

#import "FHHMDTManager.h"
#import "HMDTTMonitor.h"

@interface FHHMDTManager ()

@end

@implementation FHHMDTManager

+ (instancetype)sharedInstance
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (void)videoFirstFrameReport:(NSString *)category {
    if(self.videoCreateTime > 0){
        NSTimeInterval duration = ([[NSDate date] timeIntervalSince1970] - self.videoCreateTime) * 1000;
        NSDictionary* metric = @{
                                 @"duration": @(duration),
                                 };
        
        NSMutableDictionary *categoryDic = [NSMutableDictionary dictionary];
        if(category){
            categoryDic[@"category_name"] = category;
        }
        
        [[HMDTTMonitor defaultManager] hmdTrackService:@"f_video_detail_first_render_time"
                                                metric:metric
                                              category:categoryDic
                                                 extra:nil];
        
        //上报完成重置数据
        self.videoCreateTime = 0;
    }
}

- (void)shortVideoFirstFrameReport:(NSString *)category {
    if(self.shortVideoCreateTime > 0){
        NSTimeInterval duration = ([[NSDate date] timeIntervalSince1970] - self.shortVideoCreateTime) * 1000;
        NSDictionary* metric = @{
                                 @"duration": @(duration),
                                 };
        
        NSMutableDictionary *categoryDic = [NSMutableDictionary dictionary];
        if(category){
            categoryDic[@"category_name"] = category;
        }
        
        [[HMDTTMonitor defaultManager] hmdTrackService:@"f_short_video_detail_first_render_time"
                                                metric:metric
                                              category:categoryDic
                                                 extra:nil];
        
        //上报完成重置数据
        self.shortVideoCreateTime = 0;
    }
}

@end
