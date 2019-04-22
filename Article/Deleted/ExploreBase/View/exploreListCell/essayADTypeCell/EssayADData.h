//
//  EssayADData.h
//  Article
//  主端段子频道导量
//
//  Created by chenren on 9/05/17.
//
//

#import "ExploreOriginalData.h"

typedef NS_ENUM(NSInteger, ADDataType) {
    ADDataTypeEssay,
    ADDataTypeUnknown,
};

@interface EssayADData : ExploreOriginalData

@property (nullable, nonatomic, copy) NSString *title;  //主标题
@property (nullable, nonatomic, copy) NSString *extTitle; //副标题
@property (nullable, nonatomic, copy) NSString *URL;    //广告链接
@property (nullable, nonatomic, copy) NSString *label;  //标签，比如广告、推广等等
@property (nullable, nonatomic, copy) NSString *appID;  //appID
@end
