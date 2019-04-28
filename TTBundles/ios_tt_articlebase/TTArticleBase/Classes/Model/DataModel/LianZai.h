//
//  LianZai.h
//  
//
//  Created by 邱鑫玥 on 16/7/18.
//
//

#import <Foundation/Foundation.h>
#import "ExploreOriginalData.h"

NS_ASSUME_NONNULL_BEGIN

@class TTImageInfosModel;

@interface LianZai : ExploreOriginalData

@property (nullable, nonatomic, retain) NSString *abstract;
@property (nullable, nonatomic, retain) NSArray *actionList;
@property (nullable, nonatomic, retain) NSArray *chapterList;
@property (nullable, nonatomic, retain) NSDictionary * coverImageInfo;
@property (nullable, nonatomic, retain) NSArray *filterWords;
@property (nullable, nonatomic, retain) NSDictionary *mediaInfo;
@property (nullable, nonatomic, retain) NSString *openURL;
@property (nullable, nonatomic, retain) NSNumber *serialID;
@property (nullable, nonatomic, retain) NSNumber *serialType;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSString *sourceOpenURL;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *serialStyle;
@property (nullable, nonatomic, retain) NSString *showMoreText;

- (nullable TTImageInfosModel*)coverImageModel;

- (nullable NSString *)newestTitle;

- (nullable NSString *)newestInfo;

- (nullable NSString *)readedTitle;

- (nullable NSString *)readedInfo;



@end

NS_ASSUME_NONNULL_END

