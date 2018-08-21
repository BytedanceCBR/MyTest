//
//  main.m
//  Article
//
//  Created by Hu Dianwei on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
#ifdef  DEBUG
        @try {
#endif
//            return UIApplicationMain(argc, argv, NSStringFromClass([SSTestApplication class]), NSStringFromClass([AppDelegate class]));
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
            
#ifdef DEBUG
        }
        @catch (NSException *exception) {
            SSLog(@"ex:%@, stack:%@", exception, [exception callStackSymbols]);
            @throw exception; 
        }
        @finally {
            
        }
#endif

    }
}
