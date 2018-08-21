//
//  FantasyCardData.h
//  Article
//
//  Created by chenren on 1/02/18.
//
//

#import "ExploreOriginalData.h"

@interface FantasyCardData : ExploreOriginalData

@property (nullable, nonatomic, copy) NSString *imageURL;
@property (nonatomic, assign) long long startTime;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *content;
@property (nullable, nonatomic, copy) NSString *bigWords;
@property (nullable, nonatomic, copy) NSString *bigWordsTail;

@property (nullable, nonatomic, copy) NSString *buttonText;
@property (nullable, nonatomic, copy) NSString *jumpURL;

@end
