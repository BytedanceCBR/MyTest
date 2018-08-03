//
//  VideoLocalFavoriteManager.m
//  Video
//
//  Created by 于 天航 on 12-8-9.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoLocalFavoriteManager.h"
#import "OrderedVideoData.h"
#import "VideoData.h"

@implementation VideoLocalFavoriteManager

static VideoLocalFavoriteManager* _sharedManager = nil;

+ (VideoLocalFavoriteManager *)sharedManager
{
    @synchronized (self) {
        if (_sharedManager == nil) {
            _sharedManager = [[VideoLocalFavoriteManager alloc] init];
        }   
        return _sharedManager;
    }
}

+ (NSUInteger)favoritesCount
{
    NSError *error = nil;
    NSArray *results = [[SSModelManager sharedManager] entitiesWithQuery:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                           [NSNumber numberWithInt:DataSortTypeFavorite], @"sortType",
                                                                           nil]
                                                       entityDescription:[OrderedVideoData entityDescription]
                                                                   error:&error];
    
    NSUInteger ret = 0;
    if (!error) {
        ret = [results count];
    }
    
    return ret;
}

- (ListDataType)listDataType
{
    return ListDataTypeVideo;
}

- (Class)orderedDataClass
{
    return [OrderedVideoData class];
}

@end
