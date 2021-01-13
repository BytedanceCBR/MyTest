//
//  FHOneTouchBackManager.m
//  FHHouseBase
//
//  Created by bytedance on 2021/1/6.
//

#import "FHOneTouchBackManager.h"
#import "ByteDanceKit.h"
#import "UIImage+TTThemeExtension.h"
#import "FHUserTracker.h"
#import "UIViewController+Tree.h"

@interface FHOneTouchBackManager()

@property(nonatomic, strong )NSMutableDictionary *params;
@property(nonatomic, strong )UIButton *button;
@property(nonatomic, strong )NSURL *backUrl;
@property(nonatomic, strong )NSMutableDictionary *tracerDic ;

@end

@implementation FHOneTouchBackManager


+ (instancetype)sharedInstance
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FHOneTouchBackManager alloc] init];
    });
    return manager;
}

- (void)setButtonWithUrl:(NSURL *)url{
    
    self.params = [url btd_queryItemsWithDecoding].mutableCopy;
    
    NSURL *backUrl = [NSURL URLWithString:[self.params.copy btd_stringValueForKey:@"backurl" default:@""]];
    
    if(![[UIApplication sharedApplication] canOpenURL:backUrl]){
        return ;
    }else if(![self.params.copy btd_stringValueForKey:@"btn_name"]){
        self.params[@"btn_name"] = [self getbtnNameWithUrl:[self.params.copy btd_stringValueForKey:@"backurl" default:@""]];
    }
    
    self.backUrl = backUrl;
    NSString *title = [NSString stringWithFormat:@"%@ ",[self.params.copy btd_stringValueForKey:@"btn_name" default:@""]];
    self.button.frame = CGRectMake(0, [self activeVC].view.bounds.size.height*4/5, (title.length) * 12 + 8, 21);
    [self.button setImage:[UIImage themedImageNamed:@"arrow_down_black_line"] forState:UIControlStateNormal];
    self.button.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.3];
    [self.button setTitle:title forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
    [self.button addTarget: self action: @selector(liveApp) forControlEvents: UIControlEventTouchDown];
    [self setmask];
    [[self activeVC].view addSubview:self.button];
    [[self activeVC].view bringSubviewToFront:self.button];
    self.tracerDic = [[self.params btd_stringValueForKey:@"ext_growth"] btd_jsonDictionary].mutableCopy;
    self.tracerDic[@"button_name"] = @"return_button";
    
    [FHUserTracker writeEvent:@"botton_show" params:self.tracerDic];
}

- (UIButton *)button{
    if(!_button){
        _button = [[UIButton alloc ] init];
    }
    return _button;
}

- (void)setmask{
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.button.bounds byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(20, 20)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];

    maskLayer.frame = self.button.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.button.layer.mask = maskLayer;
}

- (void)liveApp{
    [self.button removeFromSuperview];
    self.tracerDic[@"click_position"] = @"return_button";
    [self.tracerDic removeObjectForKey:@"button_name"];
    [FHUserTracker writeEvent:@"click_options" params:self.tracerDic];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:self.backUrl options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:self.backUrl];
    }
}

-(NSString *)getbtnNameWithUrl:(NSString *)url{
    if([url hasPrefix:@"snssdk141://"]){
        return @"返回今日头条";
    }else if([url hasPrefix:@"snssdk35://"]){
        return @"返回今日头条Lite";
    }else if([url hasPrefix:@"snssdk1128://"]){
        return @"返回抖音";
    }else if([url hasPrefix:@"snssdk32://"]){
        return @"返回西瓜视频";
    }else if([url hasPrefix:@"snssdk1112://"]){
        return @"返回火山小视频";
    }else{
        return  @"返回";
    }
}

//获取当前屏幕显示的 View Controller
- (UIViewController *)activeVC
{
   return  [[UIViewController new] hmd_topViewController];
}

- (void)updateButton{
    [[self activeVC].view bringSubviewToFront:self.button];
}

@end
