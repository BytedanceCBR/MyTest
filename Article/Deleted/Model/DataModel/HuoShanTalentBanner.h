//
//  HuoShanTalentBanner.h
//  Article
//
//  Created by Chen Hong on 2016/11/20.
//
//

#import "ExploreOriginalData.h"

@class TTImageInfosModel;

@interface HuoShanTalentBanner : ExploreOriginalData

@property (nullable, nonatomic, retain) NSNumber *bannerId;

@property (nullable, nonatomic, retain) NSDictionary *coverImageInfo;

@property (nullable, nonatomic, retain) NSString *schemaUrl;

- (nullable TTImageInfosModel *)coverImageModel;

@end
