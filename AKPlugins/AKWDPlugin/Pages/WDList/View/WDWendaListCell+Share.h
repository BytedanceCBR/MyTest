//
//  WDWendaListCell+Share.h
//  Article
//
//  Created by xuzichao on 2017/6/13.
//
//

#import "WDWendaListCell.h"
#import "WDAnswerEntity.h"

@protocol TTActivityContentItemProtocol;

@interface WDWendaListCellShareHelper : NSObject

@property (nonatomic, copy, readonly) NSString *sharePlatform;

- (instancetype)initWithAnswerEntity:(WDAnswerEntity *)entity;

- (id<TTActivityContentItemProtocol>)getItemWithActivityType:(NSString *)activityTypeString;

@end
