//
//  TTVMoviePlayerControlFinishAdEntity.h
//  Article
//
//  Created by panxiang on 2017/7/20.
//
//

#import <Foundation/Foundation.h>
#import "TTVAdActionButtonCommand.h"

@class TTADEventTrackerEntity;
@interface TTVMoviePlayerControlFinishAdEntity : NSObject
@property (nonatomic, strong) TTADEventTrackerEntity *trackerEntity;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *webUrl;
@property (nonatomic, copy) NSString *actionTitle;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *openURL;
@property (nonatomic, strong) id <TTVAdActionButtonCommandProtocol> ttv_command;
@property (nonatomic, strong) NSDictionary* raw_ad_data;

+ (TTVMoviePlayerControlFinishAdEntity *)entityWithData:(TTVFeedItem *)data;
@end
