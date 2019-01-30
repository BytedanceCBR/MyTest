//
//  main.m
//  Article
//
//  Created by Hu Dianwei on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#ifndef DEBUG

#import <dlfcn.h>
#import <sys/types.h>

void disable_gdb(void);

typedef int(*ptrace_ptr_t) (int _request , pid_t _pid , caddr_t _addr , int _data);

#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif

void disable_gdb(void)
{
    void * handle = dlopen(0, RTLD_GLOBAL|RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH,0,0,0);
    dlclose(handle);
}

#endif


int main(int argc, char *argv[])
{
    @autoreleasepool {
#ifndef DEBUG
        //release 下禁止被吸附
        disable_gdb();
#endif
        
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
