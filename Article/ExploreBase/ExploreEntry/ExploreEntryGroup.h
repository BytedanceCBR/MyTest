//
//  ExploreEntryGroup.h
//  Article
//
//  Created by Zhang Leonardo on 14-11-19.
//
//

#import <Foundation/Foundation.h>
#import "TTEntityBase.h"

@interface ExploreEntryGroup : TTEntityBase;

@property (nonatomic, retain) NSString * entryGroupID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) NSInteger orderIndex;
@property (nonatomic, retain) NSOrderedSet *entryList;

@end
