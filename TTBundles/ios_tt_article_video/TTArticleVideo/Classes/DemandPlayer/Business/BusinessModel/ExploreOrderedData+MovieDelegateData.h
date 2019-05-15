//
//  ExploreOrderedData+MovieDelegateData.h
//  Article
//
//  Created by panxiang on 2017/5/7.
//
//

#import "ExploreOrderedData+TTBusiness.h"
#import "TTVMovieDelegateData.h"
@interface ExploreOrderedData (MovieDelegateData)
- (NSInteger)ttv_videoDuration;
- (BOOL)ttv_isPreloadVideoEnabled;
- (NSString *)ttv_videoLocalURL;
- (BOOL)ttv_couldAutoPlay;
- (TTGroupModel *)ttv_groupModel;
@end
