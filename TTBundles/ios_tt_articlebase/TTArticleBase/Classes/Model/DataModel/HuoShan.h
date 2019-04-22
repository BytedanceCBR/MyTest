//
//  HuoShan.h
//  
//
//  Created by Chen Hong on 16/6/6.
//
//

#import <Foundation/Foundation.h>
#import "ExploreOriginalData.h"

NS_ASSUME_NONNULL_BEGIN

@class TTImageInfosModel;

@interface HuoShan : ExploreOriginalData

@property (nullable, nonatomic, retain) NSNumber *liveId;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *viewCount;
@property (nullable, nonatomic, retain) NSString *label;
@property (nullable, nonatomic, retain) NSNumber *labelStyle;
@property (nullable, nonatomic, retain) NSDictionary *coverImageInfo; //1：1封面图
@property (nullable, nonatomic, retain) NSDictionary *middleImageInfo; //16：9封面图片
@property (nullable, nonatomic, retain) NSDictionary *nhdImageInfo; //右图
@property (nullable, nonatomic, retain) NSDictionary *userInfo;
@property (nullable, nonatomic, retain) NSDictionary *mediaInfo; //头条号
@property (nullable, nonatomic, retain) NSDictionary *shareInfo;
@property (nullable, nonatomic, retain) NSArray *filterWords;
@property (nullable, nonatomic, retain) NSArray *actionList;
@property (nullable, nonatomic, retain) NSNumber *cellFlag;

// 封面图 1:1
- (nullable TTImageInfosModel *)coverImageModel;

// 封面图 16:9
- (nullable TTImageInfosModel *)nhdImageModel;


// 右图
- (nullable TTImageInfosModel *)middleImageModel;

@end

NS_ASSUME_NONNULL_END

//#import "HuoShan+CoreDataProperties.h"
