//
//  TTVLastRead.h
//  Article
//
//  Created by pei yun on 2017/4/7.
//
//

#import <Foundation/Foundation.h>

@interface TTVLastRead : NSObject <NSCoding>

@property (nonatomic, strong) NSDate *refreshDate;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, strong) NSNumber *showRefresh;

@property (nonatomic, strong) NSNumber *orderIndex;

@end
