//
//  FRMovieEntity.h
//  Article
//
//  Created by 王霖 on 16/8/4.
//
//

#import <JSONModel/JSONModel.h>

@interface FRMovieEntity : JSONModel

@property (nonatomic, copy) NSString * name; //电影名
@property (nonatomic, copy) NSString * englishName; //电影英文名
@property (nonatomic, copy) NSString * type; //电影类型
@property (nonatomic, copy) NSString * areaInfo; //上映地区
@property (nonatomic, copy) NSString * actors; //演员列表
@property (nonatomic, copy) NSString * rate; //电影评分
@property (nonatomic, strong) NSNumber * days; //电影还有几天上映
@property (nonatomic, copy) NSString * imageUrl; //海报url
@property (nonatomic, copy) NSString * movieID; //电影ID
@property (nonatomic, copy) NSString <Optional> * uniqueID; //有视频返回视频ID，没有返回0
@property (nonatomic, copy) NSString <Optional> * groupFlags;
@property (nonatomic, copy) NSString <Optional> *purchaseUrl; //购票页面的URL
@property (nonatomic, strong) NSNumber <Optional> *rateUserCount; //评过分的人数
@property (nonatomic, copy) NSString * produceArea; //制片地区
@property (nonatomic, copy) NSString * releaseArea; //上映地区
@property (nonatomic, copy) NSString * releaseDate; //上映时间
@property (nonatomic, copy) NSString * duration; //时长
@property (nonatomic, copy) NSString * directorsStr; //导演
@property (nonatomic, copy) NSString * actorsStr; // 演员

@end
