//
//  TTViewController.m
//  TTAccountLogin
//
//  Created by Nice2Me on 05/26/2017.
//  Copyright (c) 2017 Nice2Me. All rights reserved.
//

#import "TTViewController.h"
#import <objc/runtime.h>
#import "TTTestNSTimerCyRefViewController.h"



@protocol TTCenterProtocol <NSObject>
@optional
- (void)printMe;
@end

@interface TTProtocolCenter : NSObject
+ (instancetype)sharedProCenter;

- (id<TTCenterProtocol>)addProtocol:(id<TTCenterProtocol>)delegate;
- (void)removeProtocol:(id<TTCenterProtocol>)delegate;

- (void)dumpAllPrint;
@end

@interface TTProtocolCenter ()
@property (nonatomic, strong) NSHashTable<NSObject<TTCenterProtocol> *> *delegates;
@end

@implementation TTProtocolCenter

+ (instancetype)sharedProCenter
{
    static TTProtocolCenter *sharedInst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [self new];
    });
    return sharedInst;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (id<TTCenterProtocol>)addProtocol:(id<TTCenterProtocol>)delegate
{
    if (!delegate) return nil;
    
    if (![delegate conformsToProtocol:@protocol(TTCenterProtocol)]) {
        BOOL success = class_addProtocol([delegate class], @protocol(TTCenterProtocol));
        if (success) {
            [self.delegates addObject:delegate];
            return delegate;
        }
        return nil;
    }
    
    [self.delegates addObject:delegate];
    
    return delegate;
}

- (void)removeProtocol:(id<TTCenterProtocol>)delegate
{
    if (!delegate) return;
    [self.delegates removeObject:delegate];
}


- (void)dumpAllPrint
{
    NSArray<id<TTCenterProtocol>> *referredDelegates = [self.delegates allObjects];
    for (id<TTCenterProtocol> delegate in referredDelegates) {
        if ([delegate respondsToSelector:@selector(printMe)]) {
            [delegate printMe];
        }
    }
}
@end


#define TTGetProtocolCenterDelegate(delegate) [[TTProtocolCenter sharedProCenter] addProtocol:(id<TTCenterProtocol>)delegate]
#define TTRemoveProtocolCenterDelegate(delegate) [[TTProtocolCenter sharedProCenter] removeProtocol:(id<TTCenterProtocol>)delegate]


@interface TTOnceDelegateImp : NSObject
<
TTCenterProtocol
>
@end

@implementation TTOnceDelegateImp
- (void)printMe
{
    NSLog(@"Class: <%@>, SEL: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}
@end



@interface TTViewController () {
    NSString *_strongString;
    NSString *_kvcString;
}
@property (nonatomic, strong) NSString *strongString;
@property (nonatomic,   copy) NSString *copiedString;

@property (nonatomic, strong) NSArray *strongArray;
@property (nonatomic,   copy) NSArray *copiedArray;

@property (nonatomic, strong) NSMutableArray *strongMutArray;
@property (nonatomic,   copy) NSMutableArray *copiedMutArray;
@end

@implementation TTViewController

@synthesize strongString;

- (instancetype)init
{
    if ((self = [super init])) {
        
    }
    return self;
}

- (void)dealloc
{
    TTRemoveProtocolCenterDelegate(self);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    TTGetProtocolCenterDelegate(self);
}

- (IBAction)dumpAll:(id)sender
{
    [[TTProtocolCenter sharedProCenter] dumpAllPrint];
}

- (IBAction)addDelegateRepeatedEvent:(id)sender
{
    TTGetProtocolCenterDelegate(self);
}

- (IBAction)addNewDelegateEvent:(id)sender
{
    TTOnceDelegateImp *onceDel = [TTOnceDelegateImp new];
    
    TTGetProtocolCenterDelegate(onceDel);
}

- (IBAction)addNewDelegateAndDumpEvent:(id)sender
{
    TTOnceDelegateImp *onceDel = [TTOnceDelegateImp new];
    
    TTGetProtocolCenterDelegate(onceDel);
    
    [self dumpAll:nil];
}

- (void)printMe
{
    NSLog(@"PrintMe");
}

- (IBAction)testNSTimer:(id)sender
{
    TTTestNSTimerCyRefViewController *testNSTimerVC = [TTTestNSTimerCyRefViewController new];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:testNSTimerVC];
    
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

- (IBAction)testCopyAndStrong:(id)sender
{
    NSString *string = @"liuzp";
    NSArray  *array  = @[@"liuzp", @"liuzp1"];
    NSMutableArray *mutArray = [@[@"liuzp", @"liuzp1"] mutableCopy];
    
    self.strongString = string;
    self.copiedString = string;
    
    self.strongArray = array;
    self.copiedArray = array;
    
    self.strongMutArray = mutArray;
    self.copiedMutArray = mutArray;
    
    NSLog(@"original string: <address: %p>, <content: %@>", string, string);
    NSLog(@"strong   string: <address: %p>, <content: %@>", _strongString, _strongString);
    NSLog(@"copied   string: <address: %p>, <content: %@>", _copiedString, _copiedString);
    
    
    NSLog(@"original array: <address: %p>, <content: %@>", array, array);
    NSLog(@"strong   array: <address: %p>, <content: %@>", _strongArray, _strongArray);
    NSLog(@"copied   array: <address: %p>, <content: %@>", _copiedArray, _copiedArray);
    
    
    NSLog(@"original mutArray: <address: %p>, <content: %@>", mutArray, mutArray);
    NSLog(@"strong   mutArray: <address: %p>, <content: %@>", _strongMutArray, _strongMutArray);
    NSLog(@"copied   mutArray: <address: %p>, <content: %@>", _copiedMutArray, _copiedMutArray);
    
    [self setValue:@"instance var1" forKey:@"kvcString"];
    [self setValue:@"instance var2" forKey:@"_kvcString"];
    
    // Dead Lock
    NSLog(@"1");
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"2");
    });
    NSLog(@"3");
}

@end
