//
//  TTSearchHomeSugModel.h
//  Article
//
//  Created by 王双华 on 16/12/21.
//
//

#import <JSONModel/JSONModel.h>

@class TTSearchHomeSugItem;


@interface TTSearchHomeSugModel : JSONModel

@property (nonatomic, strong) TTSearchHomeSugItem <Optional> * data;

@end

@interface TTSearchWeatherModel : JSONModel

@property (nonatomic, strong) NSString <Optional> *weather_icon_id;
@property (nonatomic, strong) NSNumber <Optional> *current_time;
@property (nonatomic, strong) NSNumber <Optional> *current_temperature;
@property (nonatomic, strong) NSString <Optional> *current_condition;
@property (nonatomic, strong) NSString <Optional> *city_name;

@end

@interface TTSearchHomeSugItem: JSONModel

@property (nonatomic, strong) NSNumber <Optional> *callPerRefresh;
@property (nonatomic, strong) NSString <Optional> *homePageSearchSuggest;
@property (nonatomic, strong) NSNumber <Optional> *weather_refresh_interval;
@property (nonatomic, strong) TTSearchWeatherModel <Optional> *weather;

@end
