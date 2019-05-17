//
//  Tracker.h
//  Base
//
//  Created by Tu Jianfeng on 6/23/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Tracker : NSObject {
    
}

+ (void)event:(NSString *)eventName label:(NSString *)labelName;

@end
