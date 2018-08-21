//
//  TTShortVideoStayTrackManager.h
//  Article
//
//  Created by 王双华 on 2017/7/30.
//
//

#import <Foundation/Foundation.h>

@class TTCategory;

@interface TTShortVideoStayTrackManager : NSObject

@property(nonatomic, copy)NSString * enterType;                     //当前频道的进入方式flip/click

+ (TTShortVideoStayTrackManager *)shareManager;

- (void)startTrackForCategory:(TTCategory *)category enterType:(NSString *)enterType;

- (void)endTrackForCategory:(TTCategory *)category;

@end
