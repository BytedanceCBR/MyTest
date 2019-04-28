//
//  HuoShanVideo.h
//  Article
//
//  Created by 王双华 on 2017/4/14.
//
//

#import "ExploreOriginalData.h"

@class TTImageInfosModel;

@interface HuoShanVideo : ExploreOriginalData

@property (nullable, nonatomic, strong) NSDictionary *originalDict;//原始数据
@property (nullable, nonatomic, strong) NSString *text;//封面标题
@property (nullable, nonatomic, strong) NSString *location;//封面上的位置信息
@property (nullable, nonatomic, strong) NSString *openURL;//没有安装火山时跳转
@property (nullable, nonatomic, strong) NSString *openHotsoonURL;//安装了火山的跳转
@property (nullable, nonatomic, strong) NSDictionary *userInfo;//用户信息
@property (nullable, nonatomic, strong) NSDictionary *videoDetailInfo;
@property (nullable, nonatomic, strong) NSArray *filterWords;
@property (nullable, nonatomic, strong) NSString *rid;

//封面图对应字段 detail_video_large_image
- (nullable TTImageInfosModel *)coverImageModel;

@end
