//
//  VideoLocalFavoriteManager.h
//  Video
//
//  Created by 于 天航 on 12-8-9.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "LocalFavoriteManager.h"

@interface VideoLocalFavoriteManager : LocalFavoriteManager

+ (VideoLocalFavoriteManager *)sharedManager;

+ (NSUInteger)favoritesCount;

@end
