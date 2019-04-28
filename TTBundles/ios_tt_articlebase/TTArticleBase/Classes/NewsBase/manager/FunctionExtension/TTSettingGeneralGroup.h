//
//  TTSettingGeneralGroup.h
//  Article
//
//  Created by Dianwei on 14-9-26.
//
//

#import <Foundation/Foundation.h>

@class TTSettingGeneralEntry;

@interface TTSettingGeneralGroup : NSObject<NSCoding>

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSMutableArray<TTSettingGeneralEntry *> *items;
@property (nonatomic, assign) BOOL shouldBeDisplayed;

@end
