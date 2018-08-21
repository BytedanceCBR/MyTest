//
//  DebugUmengIndicator.m
//  Article
//
//  Created by Dianwei on 14-6-10.
//
//

#import "DebugUmengIndicator.h"
#import "ArticleListNotifyBarView.h"


static int const kTimerInterval = .5f;
static NSString *const  kDisplayUmengIsOnStorageKey =   @"kDisplayUmengIsOnStorageKey";

@interface DebugUmengIndicator(){
    BOOL _startDisplay;
}
@property(nonatomic, retain)NSMutableArray *strings;
@property(nonatomic, retain)NSTimer *timer;
@property(nonatomic, retain)ArticleListNotifyBarView *indicatorView;
@property(nonatomic, retain)UIWindow *window;
@end

@implementation DebugUmengIndicator

- (void)dealloc
{
    self.strings = nil;
    [_timer invalidate];
    self.timer = nil;
    self.indicatorView = nil;
}

static DebugUmengIndicator *s_indicator;
+ (instancetype)sharedIndicator
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_indicator = [[DebugUmengIndicator alloc] init];
    });
    
    return s_indicator;
}

- (instancetype)init
{
    
    self = [super init];
    if(self)
    {
        self.strings = [NSMutableArray arrayWithCapacity:10];
    }
    
    return self;
}

- (void)timer:(NSTimer*)timer
{
    if(!_indicatorView.isHidden)
    {
        return;
    }
    
    NSString *str = nil;
    @synchronized(self)
    {
        if(_strings.count > 0)
        {
            str = [_strings firstObject];
            [_strings removeObjectAtIndex:0];
        }
    }
    
    if(str != nil)
    {
        if(_indicatorView)
        {
            _window.hidden = NO;
            
            [_indicatorView showMessage:str actionButtonTitle:NSLocalizedString(@"关闭", nil) delayHide:NO duration:0 bgButtonClickAction:^(UIButton *button) {
                
            } actionButtonClickBlock:^(UIButton *button) {
                [_indicatorView hideImmediately];
            } didHideBlock:^(ArticleListNotifyBarView *barView) {
                _window.hidden = YES;
            }];
            
//            [_indicatorView showMessage:str actionButtonTitle:nil delayHide:YES duration:1 bgButtonClickAction:^(UIButton *button) {
//            } actionButtonClickBlock:^(UIButton *button) {
//            } didHideBlock:^(ArticleListNotifyBarView *barView) {
//                
//            }];
        }
        
        
    }
}


- (void)addDisplayString:(NSString*)string
{
    if(_startDisplay)
    {
        @synchronized(self)
        {
            [_strings addObject:string];
        }
        
        if(![_timer isValid])
        {
            [self startTimer];
        }
    }
}


- (void)startTimer
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(timer:) userInfo:nil repeats:YES];
    });
    
}

- (void)startDisplay
{
    _startDisplay = YES;
    if(!_window)
    {
        self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, SSScreenWidth, 20)];
    }
    
    _window.windowLevel = UIWindowLevelStatusBar + 1;
    _window.hidden = YES;
    
    if(!_indicatorView)
    {
        self.indicatorView = [[ArticleListNotifyBarView alloc] initWithFrame:_window.bounds];
    }
    
    [_window addSubview:_indicatorView];
    
    
    
}

- (void)stopDisplay
{
    [_timer invalidate];
    [_strings removeAllObjects];
    self.window = nil;
    self.indicatorView = nil;
}

+ (BOOL)displayUmengISOn
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDisplayUmengIsOnStorageKey];
}

+ (void)setDisplayUmengIsOn:(BOOL)set
{
    [[NSUserDefaults standardUserDefaults] setBool:set forKey:kDisplayUmengIsOnStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
