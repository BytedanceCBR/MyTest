//
//  ExploreMovieViewModel+ConvertFromTTVFeedItem.h
//  Article
//
//  Created by pei yun on 2017/4/3.
//
//

#import "ExploreMovieViewModel.h"

@class TTVFeedItem;
@interface ExploreMovieViewModel (ConvertFromTTVFeedItem)

+ (nullable ExploreMovieViewModel *)viewModelWithVideoFeed:(nullable TTVFeedItem *)orderedData categoryID:(NSString *_Nullable)categoryID;

@end
