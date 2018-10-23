//
//  TTTestDelayDeallocViewController.m
//  TTAccountLoginDemo
//
//  Created by liuzuopeng on 15/06/2017.
//  Copyright © 2017 Nice2Me. All rights reserved.
//

#import "TTTestDelayDeallocViewController.h"
#import <NSTimer+TTNoRetainRef.h>



@interface TTCallbackBlockClass : NSObject

+ (void)callMeWithBlock:(void (^)())completedBlock;

@end

@implementation TTCallbackBlockClass

+ (void)callMeWithBlock:(void (^)())completedBlock
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (completedBlock) {
            completedBlock();
        }
    });
}

@end



@interface TTTestDelayDeallocViewController ()

@property (nonatomic,   copy) void (^TTDelayBlock)();

@property (nonatomic, strong) UIButton *startDelayButton;

@property (nonatomic, /* weak */strong) NSTimer *noRetainRefTimer; // 2

@end

@implementation TTTestDelayDeallocViewController

- (void)dealloc
{
    NSLog(@"dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _startDelayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _startDelayButton.frame = CGRectMake(50, 100, 200, 80);
    [_startDelayButton setTitle:@"Start Delay Test" forState:UIControlStateNormal];
    [_startDelayButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_startDelayButton addTarget:self action:@selector(actionForStartDelayDeallocButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startDelayButton];
}

- (void)actionForStartDelayDeallocButton:(id)sender
{
    self.noRetainRefTimer = [NSTimer ttNRF_scheduledTimerWithTimeInterval:1
                                                                   target:self
                                                                 selector:@selector(testTimer:)
                                                                 userInfo:nil
                                                                  repeats:YES];
    self.noRetainRefTimer.tt_countdownTime = 60;
    
    _startDelayButton.enabled = NO;
    [_startDelayButton setTitle:@"剩余60s" forState:UIControlStateNormal];
    
    self.TTDelayBlock = ^() {
        printf("Delay dealloc\n");
    };
    
    __weak typeof(self) weakSelf = self;
    [TTCallbackBlockClass callMeWithBlock:^{
        if (weakSelf.TTDelayBlock) {
            weakSelf.TTDelayBlock();
        }
    }];
}

- (void)testTimer:(NSTimer *)timer
{
    if (self.noRetainRefTimer.tt_countdownTime == 0) {
        _startDelayButton.enabled = YES;
        [_startDelayButton setTitle:@"Start Delay Test" forState:UIControlStateNormal];
        return;
    }
    
    self.noRetainRefTimer.tt_countdownTime -= 1;
    _startDelayButton.enabled = NO;
    [_startDelayButton setTitle:[NSString stringWithFormat:@"剩余%lds", (long)self.noRetainRefTimer.tt_countdownTime] forState:UIControlStateNormal];
}

@end
