//
//  NSObject+TTDataAdapter.h
//  CSDoubleBindModel
//
//  Created by SongChai on 2017/5/4.
//  Copyright © 2017年 SongChai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTDataAdapter.h"

@interface TTTimeScheduleModel : NSObject
@property(nonatomic, assign) NSTimeInterval currentTimeInterval;
@end

@interface NSObject (TTDataAdapter)

- (void) setTTDataAdapter:(TTDataAdapter*) adapter;
- (TTDataAdapter*) TTDataAdapter;


- (void) setTimeScheduleModel:(TTTimeScheduleModel*) adapter;
- (TTTimeScheduleModel*) timeScheduleModel;
@end
