//
//  TTDetailWebContainerDebugger.m
//  TTWebViewBundle
//
//  Created by muhuai on 2017/10/17.
//  Copyright © 2017年 muhuai. All rights reserved.
//

#import "TTDetailWebContainerDebugger.h"

@implementation TTDetailWebContainerDebugger
static BOOL vConsoleEnable;
static NSString *vConsoleJS;

+ (void)vConsoleEnable:(BOOL)enable {
    vConsoleEnable = enable;
}

+ (BOOL)isvConsoleEnable {
    return vConsoleEnable;
}

+ (void)injectvConsoleIfNeed:(id<TTRexxarEngine>)engine {
    if (!vConsoleEnable) {
        return;
    }
    
    if (!vConsoleJS.length) {
        vConsoleJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vconsole" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    }
    [engine ttr_evaluateJavaScript:vConsoleJS completionHandler:nil];
}

+ (void)triggervConsoleIfNeed:(id<TTRexxarEngine>)engine {
    if (!vConsoleEnable) {
        return;
    }
    [engine ttr_evaluateJavaScript:@"var vConsole = document.querySelector('#__vconsole');"
     @"if(vConsole) {"
         @"if(vConsole.style.display === 'block'){"
             @"vConsole.style.display = 'none';"
         @"} else {"
             @"vConsole.style.display = 'block';"
         @"}"
     @"}" completionHandler:nil];
}
@end
