//
//  SSExceptionHandler.m
//  Article
//
//  Created by Dianwei on 13-5-5.
//
//

#import <execinfo.h>
#import <signal.h>
#import <string.h>
#import <mach-o/loader.h>
#import <mach-o/dyld.h>
#import <mach-o/arch.h>
#import "SSExceptionHandler.h"
#import "SSCommon.h"

void myExceptionHandler(NSException* exception);
void handleSignal(int signal, siginfo_t *info, void *context);

void myExceptionHandler(NSException* exception)
{
    [SSExceptionHandler handleException:exception];
    if([SSExceptionHandler UmengHandler])
    {
        NSUncaughtExceptionHandler *umengHandler = [SSExceptionHandler UmengHandler];
        umengHandler(exception);
    }
}

static int s_fatal_signal[] = {
    SIGSEGV,
    SIGILL,
    SIGABRT,
    SIGFPE,
    SIGBUS,
    SIGPIPE,
    SIGSYS,
};


void handleSignal(int signal, siginfo_t *info, void *context)
{

    NSString *signalName = @"";
    switch (signal) {
        case SIGSEGV:
        {
            signalName = @"SIGSEGV";
        }
            break;
        case SIGILL:
        {
            signalName = @"SIGILL";
        }
            break;
        case SIGABRT:
        {
            signalName = @"SIGABRT";
        }
            break;
        case SIGFPE:
        {
            signalName = @"SIGFPE";
        }
            break;
        case SIGBUS:
        {
            signalName = @"SIGBUS";
        }
            break;
        case SIGPIPE:
        {
            signalName = @"SIGPIPE";
        }
            break;
        case SIGSYS:
        {
            signalName = @"SIGSYS";
        }
            break;
        default:
            break;
    }
    
    NSArray *backtraces = [SSExceptionHandler backtraces];
    NSLog(@"signal:%@, backtrace:%@", signalName, backtraces);
    exit(1);
    
}

@implementation SSExceptionHandler

static NSUncaughtExceptionHandler *s_umengHandler;

+ (void)setUmengHandler:(NSUncaughtExceptionHandler*)umHandlder
{
    s_umengHandler = umHandlder;
}

+ (NSUncaughtExceptionHandler*)UmengHandler
{
    return s_umengHandler;
}

+ (void)installUnCaughtExceptionHandler
{
    [SSExceptionHandler retriveParameters];
    [self installSignalHandler];
    NSSetUncaughtExceptionHandler(&myExceptionHandler);
}


+ (NSArray*)backtraces
{
    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    NSMutableArray *backtraces = [NSMutableArray arrayWithCapacity:frames];
    for(int idx = 0; idx < frames; idx ++)
    {
        [backtraces addObject:[NSString stringWithUTF8String:strs[idx]]];
    }
    
    return backtraces;
}

+ (void)installSignalHandler
{
    int number = sizeof(s_fatal_signal) / sizeof(s_fatal_signal[0]);
    for(int idx = 0; idx < number; idx ++)
    {
        struct sigaction sigAction;
        sigAction.sa_flags = SA_SIGINFO;
        sigAction.sa_sigaction = handleSignal;
        sigemptyset(&sigAction.sa_mask);
        sigaction(s_fatal_signal[idx], &sigAction, NULL);
    }
    
    
    // SIGSEGV
//    struct sigaction sigAction;
//    sigAction.sa_flags = SA_SIGINFO;
//    sigAction.sa_sigaction = handleSignal;
//    sigemptyset(&sigAction.sa_mask);
//    sigaction(SIGSEGV, &sigAction, NULL);
    
//    // SIGILL
//    struct sigaction SIGILLAction;
//    SIGILLAction.sa_flags = SA_SIGINFO;
//    SIGILLAction.sa_sigaction = handleSignal;
//    sigaction(SIGILL, &SIGILLAction, NULL);
//    
//    // SIGABRT
//    struct sigaction SIGABRTAction;
//    SIGABRTAction.sa_flags = SA_SIGINFO;
//    SIGABRTAction.sa_sigaction = handleSignal;
//    sigaction(SIGABRT, &SIGABRTAction, NULL);
//    
//    // SIGFPE, floating point exception
//    struct sigaction SIGFPEAction;
//    SIGFPEAction.sa_flags = SA_SIGINFO;
//    SIGFPEAction.sa_sigaction = handleSignal;
//    sigaction(SIGFPE, &SIGFPEAction, NULL);
//    
//    // SIGBUS, bus error
//    struct sigaction SIGBUSAction;
//    SIGBUSAction.sa_flags = SA_SIGINFO;
//    SIGBUSAction.sa_sigaction = handleSignal;
//    sigaction(SIGBUS, &SIGBUSAction, NULL);
//    
//    // SIGPIPE
//    struct sigaction SIGPIPEAction;
//    SIGPIPEAction.sa_flags = SA_SIGINFO;
//    SIGPIPEAction.sa_sigaction = handleSignal;
//    sigaction(SIGPIPE, &SIGPIPEAction, NULL);
//    
//    
//    // SIGSYS
//    struct sigaction SIGSYSAction;
//    SIGSYSAction.sa_flags = SA_SIGINFO;
//    SIGSYSAction.sa_sigaction = handleSignal;
//    sigaction(SIGSYS, &SIGSYSAction, NULL);
}

+ (void)handleException:(NSException*)exception
{
    NSLog(@"exception is handled by myself:%@", [exception callStackReturnAddresses]);
    NSLog(@"symbol stack:%@", exception.callStackSymbols);
}

static NSString *s_arch = nil;
static NSString *s_baseAddress = nil;
static NSString *s_slideAddress = nil;

+ (void)retriveParameters
{
    uint32_t count = _dyld_image_count();
    for(uint32_t idx = 0; idx < count; idx ++)
    {
        const char *dyld = _dyld_get_image_name(idx);
        int slength = strlen(dyld);
        int j;
        for(j = slength - 1; j>= 0; --j)
            if(dyld[j] == '/') break;
        
        //strndup only available in iOS 4.3
        char *cname = strndup(dyld + ++j, slength - j);
        NSString *name = [[NSString alloc] initWithCString:cname encoding:NSUTF8StringEncoding];
        NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
        if([name compare:bundleName options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            const struct mach_header *header = _dyld_get_image_header(idx);
            const NXArchInfo *info = NXGetArchInfoFromCpuType(header->cputype, header->cpusubtype);
            intptr_t slide = _dyld_get_image_vmaddr_slide(idx);
            [s_arch release];
            [s_baseAddress release];
            [s_slideAddress release];
            s_arch = [[NSString alloc] initWithCString:info->name encoding:NSUTF8StringEncoding];
            s_baseAddress = [[NSString alloc] initWithFormat:@"0x%X", (uint32_t)header];
            s_slideAddress = [[NSString alloc] initWithFormat:@"0x%X", (uint32_t)((uint32_t)header - slide)];
            break;
        }
    }
}

@end
