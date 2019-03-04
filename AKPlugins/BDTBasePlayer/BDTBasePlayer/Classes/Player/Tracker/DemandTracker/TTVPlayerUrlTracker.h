//
//  TTVPlayerUrlTracker.h
//  Article
//
//  Created by panxiang on 2017/6/19.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerTracker.h"
@interface TTVPlayerUrlTracker : TTVPlayerTracker
@property(nonatomic, assign)CGFloat effectivePlayTime;
@property(nonatomic, strong)NSArray *clickTrackURLs;
@property(nonatomic, strong)NSArray *playTrackUrls;
@property(nonatomic, strong)NSArray *activePlayTrackUrls;
@property(nonatomic, strong)NSArray *effectivePlayTrackUrls;
@property(nonatomic, strong)NSArray *playOverTrackUrls;
@property(nonatomic, strong)NSString *videoThirdMonitorUrl;
@end

