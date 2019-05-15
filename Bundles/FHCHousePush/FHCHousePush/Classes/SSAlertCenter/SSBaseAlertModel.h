//
//  SSBaseAlertModel.h
//  Essay
//
//  Created by Tianhang Yu on 12-5-8.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@interface SSBaseAlertModel : JSONModel

@property (nonatomic, copy) NSString <Optional> *title;
@property (nonatomic, copy) NSString <Optional> *message;
@property (nonatomic, copy) NSString <Optional> *buttons;
@property (nonatomic, copy) NSString <Optional> *actions;

@property (nonatomic, strong) NSNumber <Optional>*delayTime;

//- (id)initWithDictionary:(NSDictionary *)data;
@end
