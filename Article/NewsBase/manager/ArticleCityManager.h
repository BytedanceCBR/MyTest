//
//  ArticleCityManager.h
//  Article
//
//  Created by Kimimaro on 13-6-13.
//
//  每次启动后第一次进入城市列表时会同时请求服务器的城市信息，
//  城市信息返回之后再次刷新城市列表，
//  之后每次进入城市列表都直接从内存中读取数据
//

#import <Foundation/Foundation.h>


@class ArticleCityManager;
@protocol ArticleCityManagerDelegate <NSObject>
@optional
- (void)cityManager:(ArticleCityManager *)manager updateFinishedResult:(NSDictionary *)result error:(NSError *)error;
@end


@interface ArticleCityManager : NSObject

@property (nonatomic, weak) id<ArticleCityManagerDelegate> delegate;
@property (nonatomic, retain, readonly) NSArray *groupedCities;

+ (ArticleCityManager *)sharedManager;

@end
