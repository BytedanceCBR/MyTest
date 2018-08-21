//
//  TTTestNSTimerCyRefViewController.m
//  TTAccountLoginDemo
//
//  Created by liuzuopeng on 08/06/2017.
//  Copyright © 2017 Nice2Me. All rights reserved.
//

#import "TTTestNSTimerCyRefViewController.h"
#import <NSTimer+TTNoRetainRef.h>
#import <Aspects.h>



@interface TTDeallocTimer : NSTimer

@end

@implementation TTDeallocTimer
- (void)dealloc
{
    NSLog(@"TTDeallocTimer dealloc");
}
@end



typedef void (^TTTestCycleRefBlock) ();

@interface TTTestNSTimerCyRefViewController ()

@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UIButton *startTimerButton;
@property (nonatomic, strong) UIButton *stopTimerButton;

@property (nonatomic, strong) UIButton *changeTimerTypeButton;

@property (nonatomic, strong) UIButton *testCycleRefButton;

@property (nonatomic,   weak) NSTimer *weakTimer;  // 0

@property (nonatomic, /* weak */strong) NSTimer *timerFromNoRetainRef; // 1

@property (nonatomic, /* weak */strong) NSTimer *noRetainRefTimer; // 2

@property (nonatomic, assign) NSInteger currentTimerType;

@property (nonatomic,   copy) TTTestCycleRefBlock cycleRefHandler;

@end

@implementation TTTestNSTimerCyRefViewController

+ (void)load
{
    NSString *deallocString = @"dealloc";
    [NSTimer aspect_hookSelector:NSSelectorFromString(deallocString) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info) {
        
        NSLog(@"NSTimer will dealloc");
        
        // Call original implementation.
        BOOL processTouches;
        NSInvocation *invocation = info.originalInvocation;
        [invocation invoke];
        [invocation getReturnValue:&processTouches];
        
    } error:nil];
}

- (void)dealloc
{
    NSLog(@"---dealloc---");
    
    [[self currentTimer] invalidate];
    self.timerFromNoRetainRef = nil;
    self.weakTimer = nil;
    self.noRetainRefTimer = nil;
    
    //    _cycleRefHandler = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dismissButton.frame = CGRectMake(50, 100, 200, 80);
    [self.dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [self.dismissButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.dismissButton setTitleColor:[[UIColor redColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.dismissButton addTarget:self action:@selector(actionForDidDismissButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    
    self.startTimerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startTimerButton.frame = CGRectMake(50, 200, 200, 80);
    [self.startTimerButton setTitle:@"Start Timer" forState:UIControlStateNormal];
    [self.startTimerButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.startTimerButton setTitleColor:[[UIColor redColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.startTimerButton addTarget:self action:@selector(actionForDidTapStartTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startTimerButton];
    
    
    self.stopTimerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.stopTimerButton.frame = CGRectMake(50, 300, 200, 80);
    [self.stopTimerButton setTitle:@"Stop Timer" forState:UIControlStateNormal];
    [self.stopTimerButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.stopTimerButton setTitleColor:[[UIColor redColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.stopTimerButton addTarget:self action:@selector(actionForDidTapStopTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.stopTimerButton];
    
    
    self.changeTimerTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.changeTimerTypeButton.frame = CGRectMake(50, 400, 200, 80);
    self.changeTimerTypeButton.backgroundColor = [UIColor grayColor];
    self.changeTimerTypeButton.showsTouchWhenHighlighted = YES;
    [self.changeTimerTypeButton setTitle:@"Change Timer Type" forState:UIControlStateNormal];
    [self.changeTimerTypeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.changeTimerTypeButton setTitleColor:[[UIColor redColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.changeTimerTypeButton addTarget:self action:@selector(actionForDidTapChangeTimerTypeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.changeTimerTypeButton];
    
    
    self.testCycleRefButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.testCycleRefButton.frame = CGRectMake(50, 500, 200, 80);
    self.testCycleRefButton.backgroundColor = [UIColor grayColor];
    self.testCycleRefButton.showsTouchWhenHighlighted = YES;
    [self.testCycleRefButton setTitle:@"Test Cycle Reference" forState:UIControlStateNormal];
    [self.testCycleRefButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.testCycleRefButton setTitleColor:[[UIColor redColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.testCycleRefButton addTarget:self action:@selector(actionForDidTapTestCycleRefButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.testCycleRefButton];
    
    
    {
        self.currentTimerType = 0;
    }
    
    //    _cycleRefHandler = ^() {
    //
    //        NSAssert(YES, @"You make cycle reference");
    //
    //        NSLog(@"liuzp-> %ld", self.currentTimerType);
    //
    //    };
}


- (void)actionForDidDismissButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)actionForDidTapStartTimerButton:(id)sender
{
    [[self currentTimer] invalidate];
    self.timerFromNoRetainRef = nil;
    self.weakTimer = nil;
    self.noRetainRefTimer = nil;
    
    if (self.currentTimerType == 0) {
        self.weakTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(testTimer)
                                                        userInfo:nil
                                                         repeats:YES];
        
    } else if (self.currentTimerType == 1) {
        // watchpoint set variable self->_timer
        self.timerFromNoRetainRef = [TTNoRetainRefNSTimer scheduledTimerWithTimeInterval:1
                                                                                  target:self
                                                                                selector:@selector(testTimer)
                                                                                userInfo:nil
                                                                                 repeats:YES];
    } else {
        // watchpoint set variable self->_noRetainRefTimer
        self.noRetainRefTimer = [NSTimer ttNRF_scheduledTimerWithTimeInterval:1
                                                                       target:self
                                                                     selector:@selector(testTimer)
                                                                     userInfo:nil
                                                                      repeats:YES];
    }
}

- (void)actionForDidTapStopTimerButton:(id)sender
{
    [[self currentTimer] invalidate];
    self.timerFromNoRetainRef = nil;
    self.weakTimer = nil;
    self.noRetainRefTimer = nil;
}

- (void)actionForDidTapChangeTimerTypeButton:(id)sender
{
    [[self currentTimer] invalidate];
    self.timerFromNoRetainRef = nil;
    self.weakTimer = nil;
    self.noRetainRefTimer = nil;
    
    if (self.currentTimerType == 0) {
        self.currentTimerType = 1;
    } else if (self.currentTimerType == 1) {
        self.currentTimerType = 2;
    } else {
        self.currentTimerType = 0;
    }
}


- (void)actionForDidTapTestCycleRefButton:(id)sender
{
    if (_cycleRefHandler) {
        _cycleRefHandler();
    }
}

- (void)testTimer
{
    printf("%s, CurrentTimerType = %ld\n", [NSStringFromSelector(_cmd) cStringUsingEncoding:NSUTF8StringEncoding], self.currentTimerType);
    //    NSLog(@"%@, CurrentTimerType = %ld", NSStringFromSelector(_cmd), self.currentTimerType);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSTimer *)currentTimer
{
    if (self.currentTimerType == 0) {
        return self.weakTimer;
    } else if (self.currentTimerType == 1) {
        return self.timerFromNoRetainRef;
    } else {
        return self.noRetainRefTimer;
    }
}

@end
