//
//  FHSharePanel.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/3.
//

#import "FHSharePanel.h"
#import "FHShareActivity.h"
#import "FHCommonDefines.h"
#import <UIColor+Theme.h>
#import <UIFont+House.h>
#import <TTUIResponderHelper.h>
#import <UIViewAdditions.h>
@interface FHSharePanel ()
@property(nonatomic,strong) UIWindow *originWindow;
@property(nonatomic,strong) UIWindow *shareWindow;
@property(nonatomic,strong) UIViewController *shareViewController;
@property(nonatomic,strong) UIView *maskView;
@property(nonatomic,strong) UIView *sharePanelView;
@property(nonatomic,strong) NSMutableArray<NSMutableArray *> *itemViews;
@end

@implementation FHSharePanel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.originWindow = [UIApplication sharedApplication].keyWindow;
        CGRect windowFrame = [UIApplication sharedApplication].keyWindow.bounds;
        
        self.shareViewController = [[UIViewController alloc] init];
        self.shareViewController.view.frame = windowFrame;
        
        self.shareWindow = [[UIWindow alloc] initWithFrame:windowFrame];
        self.shareWindow.windowLevel = UIWindowLevelNormal;
        self.shareWindow.backgroundColor = [UIColor clearColor];
        self.shareWindow.hidden = YES;
        self.shareWindow.rootViewController = self.shareViewController;
        
        self.maskView = [[UIView alloc] initWithFrame:windowFrame];
        self.maskView.backgroundColor = [UIColor colorWithHexString:@"#0000000" alpha:0.3];
        self.maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.itemViews = [[NSMutableArray alloc] init];
        self.sharePanelView = [[UIView alloc] init];
        
        [self.shareViewController.view addSubview:self.maskView];
        [self.maskView addSubview:self.sharePanelView];
    }
    return self;
}

-(void)showWithitems:(NSArray<NSArray *> *)itemsArray{
//    [self.itemViews removeAllObjects];
    CGFloat topPadding = 10;
    CGFloat singleRowHeight = 116;
    CGFloat cancelButtonHeight = 48;
    CGFloat itemWidth = 72;
    CGFloat bottomMargin = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    CGFloat sharePanelHeight = topPadding + items.count * singleRowHeight + cancelButtonHeight + bottomMargin;
    self.sharePanelView.frame = CGRectMake(0, self.maskView.height - sharePanelHeight , self.maskView.width, sharePanelHeight);
    
    for(NSInteger i = 0; i < itemsArray.count; i++){
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.contentInset = UIEdgeInsetsMake(0, 16, 0, 16);
        scrollView.frame = CGRectMake(0, i * singleRowHeight + topPadding, self.sharePanelView.width, singleRowHeight);
        [self.sharePanelView addSubview:scrollView];
        NSArray *items = itemsArray[i];
        for(NSInteger j = 0; j < items.count; j++){
            FHActivityButton *itemButton = [FHActivityButton alloc] initWithFrame:CGRectMake(j * itemWidth, 0, itemWidth, singleRowHeight);
        }
    }
    

}

-(void)show {
    [self.shareWindow makeKeyAndVisible];
    self.shareWindow.alpha = 0;
    self.shareWindow.hidden = NO;
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.shareWindow.alpha = 1;
    } completion:nil];
    
}

-(void)hideWithActivity:(FHShareActivity *)activity {
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.shareWindow.alpha = 0;
    } completion:^(BOOL finished) {
        [self.originWindow makeKeyAndVisible];
        self.shareWindow.hidden = YES;
    }];
}

@end


@interface FHActivityButton ()
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) FHShareActivity *activity;
@end

@implementation FHActivityButton

-(instancetype)initWithFrame:(CGRect)frame item:(FHShareActivity *)activity indexPath:(NSIndexPath *)indexPath {
    if(self = [super initWithFrame:frame]) {
        self.indexPath = indexPath;
        self.activity = activity;
        [self initView];
    }
    return self;
}

-(void)initView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.activity.activityImageName]];

}

@end
