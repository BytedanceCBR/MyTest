//
//  TTVMovieDelegateData.h
//  Article
//
//  Created by panxiang on 2017/5/7.
//
//

#import <Foundation/Foundation.h>
@class TTGroupModel;
@protocol TTVMovieDelegateData <NSObject>
- (NSInteger)ttv_videoDuration;
- (NSInteger)ttv_videoWatchCount;
- (BOOL)ttv_isPreloadVideoEnabled;
- (NSString *)ttv_videoLocalURL;
- (BOOL)ttv_couldAutoPlay;
- (TTGroupModel *)ttv_groupModel;
@end
