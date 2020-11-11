//
//  FHSharePanel.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/3.
//

#import "FHSharePanel.h"
#import "FHCommonDefines.h"
#import <UIColor+Theme.h>
#import <UIFont+House.h>
#import <TTUIResponderHelper.h>
#import <UIViewAdditions.h>
#import <BDUGActivityProtocol.h>
#import <UIDevice+BTDAdditions.h>

@interface FHActivityButton : UIButton
@property (nonatomic,strong) id<BDUGActivityProtocol> activity;
@property (nonatomic,strong) UIImageView *itemImageView;
@property (nonatomic,strong) UILabel *itemTitleLabel;
@end

@implementation FHActivityButton

-(instancetype)initWithFrame:(CGRect)frame item:(id<BDUGActivityProtocol>)activity {
    if(self = [super initWithFrame:frame]) {
        self.activity = activity;
        [self refreshUI];
    }
    return self;
}

-(void)refreshUI {
    CGFloat itemImageViewWidth = 60;
    CGFloat itemImageViewTopPadding = 12;
    CGFloat itemImageViewLeftPadding = 6;
    self.itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(itemImageViewLeftPadding, itemImageViewTopPadding, itemImageViewWidth, itemImageViewWidth)];
    self.itemImageView.image = [UIImage imageNamed:self.activity.contentItem.activityImageName];
    self.itemImageView.layer.cornerRadius = itemImageViewWidth / 2;
    
    self.itemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 78, 72, 12)];
    self.itemTitleLabel.font = [UIFont themeFontRegular:10];
    self.itemTitleLabel.textColor = [UIColor colorWithHexString:@"222222"];
    self.itemTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.itemTitleLabel.text = self.activity.contentItem.contentTitle;
    
    [self addSubview:self.itemImageView];
    [self addSubview:self.itemTitleLabel];
}

@end

@interface FHSharePanel ()
@property(nonatomic,strong) UIWindow *originWindow;
@property(nonatomic,strong) UIWindow *shareWindow;
@property(nonatomic,strong) UIViewController *shareViewController;
@property(nonatomic,strong) UIView *maskView;
@property(nonatomic,strong) UIView *sharePanelView;
@property (strong, nonatomic) NSMutableArray <NSMutableArray *> *itemViews;
@end

@implementation FHSharePanel
- (instancetype)initWithItems:(NSArray<NSArray *> *)items cancelTitle:(NSString *)cancelTitle {
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
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [self.maskView addGestureRecognizer:tap];

        self.sharePanelView = [[UIView alloc] init];
        self.sharePanelView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        
        [self.shareViewController.view addSubview:self.maskView];
        [self.maskView addSubview:self.sharePanelView];
        
        self.itemViews = [[NSMutableArray alloc] init];
        [self initViewWithitems:items];
    }
    return self;
}

-(void)initViewWithitems:(NSArray<NSArray *> *)itemsArray{
    CGFloat topPadding = 10;
    CGFloat rowHorizontalEdgeInset = 16;
    CGFloat singleRowHeight = 116;
    CGFloat cancelButtonHeight = 48;
    CGFloat itemWidth = 72;
    CGFloat bottomMargin = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    CGFloat sharePanelHeight = topPadding + itemsArray.count * singleRowHeight + cancelButtonHeight + bottomMargin;
    self.sharePanelView.frame = CGRectMake(0, self.maskView.height - sharePanelHeight , self.maskView.width, sharePanelHeight);
    
    for(NSInteger i = 0; i < itemsArray.count; i++){
        NSArray *items = itemsArray[i];
        NSMutableArray *itemViewArray = [[NSMutableArray alloc] init];
        
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.frame = CGRectMake(0, i * singleRowHeight + topPadding, self.sharePanelView.width, singleRowHeight);
        scrollView.contentSize = CGSizeMake(items.count * itemWidth, singleRowHeight);
        scrollView.contentInset = UIEdgeInsetsMake(0, rowHorizontalEdgeInset, 0, rowHorizontalEdgeInset);
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.x = - rowHorizontalEdgeInset;
        scrollView.contentOffset = contentOffset;
        
        if (@available(iOS 11.0, *)) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.alwaysBounceHorizontal = YES;
        [self.sharePanelView addSubview:scrollView];
        
        for(NSInteger j = 0; j < items.count; j++){
            FHActivityButton *itemButton = [[FHActivityButton alloc] initWithFrame:CGRectMake(j * itemWidth, 0, itemWidth, singleRowHeight) item:items[j]];
            [itemButton addTarget:self action:@selector(completeWithActivity:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:itemButton];
            [itemViewArray addObject:itemButton];
        }
        [self.sharePanelView addSubview:scrollView];
        [self.itemViews addObject:itemViewArray];
        
        UIView *separateLineView = [[UIView alloc] init];
        CGFloat separateLinePadding = (i + 1 == itemsArray.count) ? 0 : 22;
        separateLineView.frame = CGRectMake(separateLinePadding, scrollView.bottom - [UIDevice btd_onePixel], self.sharePanelView.width - separateLinePadding * 2, [UIDevice btd_onePixel]);
        separateLineView.backgroundColor = [UIColor colorWithHexString:@"dddddd"];
        [self.sharePanelView addSubview:separateLineView];
    }
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.sharePanelView.height - cancelButtonHeight - bottomMargin, self.sharePanelView.width, cancelButtonHeight)];
    cancelButton.backgroundColor = [UIColor colorWithHexString:@"#f8f8f8"];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor themeBlack] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self.sharePanelView addSubview:cancelButton];
    
    UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(0, self.sharePanelView.height - bottomMargin, self.sharePanelView.width, bottomMargin)];
    blankView.backgroundColor = [UIColor colorWithHexString:@"#f8f8f8"];
    [self.sharePanelView addSubview:blankView];
}

-(void)show {
    [self.shareWindow makeKeyAndVisible];
    self.shareWindow.alpha = 0;
    self.shareWindow.hidden = NO;
    
    CGFloat bottom = self.maskView.bottom;
    self.sharePanelView.bottom = self.sharePanelView.height + bottom;

    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.shareWindow.alpha = 1;
        self.sharePanelView.bottom = bottom;
    } completion:nil];
    
    NSTimeInterval delay = 0.1,rowDelay = 0.1,colDeley = 0.025;
    for(NSInteger i = 0;i < self.itemViews.count ;i++) {
        NSArray *itemViewArray = self.itemViews[i];
        for(NSInteger j = 0;j < itemViewArray.count ; j++) {
            FHActivityButton *activityButton = itemViewArray[j];
            CGFloat top = activityButton.top;
            activityButton.top = 100;
            activityButton.alpha = 0;
           [UIView animateWithDuration:0.5 delay:delay + rowDelay * i + colDeley * j usingSpringWithDamping:0.6 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
               activityButton.top = top;
               activityButton.alpha = 1;
            } completion:nil];
        }
    }
}

-(void)completeWithActivity:(FHActivityButton *)activityButton {
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.sharePanelView.bottom = self.maskView.bottom + self.sharePanelView.height;
        self.shareWindow.alpha = 0;
    } completion:^(BOOL finished) {
        [self.originWindow makeKeyAndVisible];
        self.shareWindow.hidden = YES;
        
        if([activityButton.activity respondsToSelector:@selector(setDataSource:)]) {
            [activityButton.activity setDataSource:nil];
        }
        
        WeakSelf;
        [activityButton.activity performActivityWithCompletion:^(id<BDUGActivityProtocol> activity, NSError *error, NSString *desc) {
            StrongSelf;
            if ([self.delegate respondsToSelector:@selector(activityPanel:completedWith:error:desc:)]) {
                [self.delegate activityPanel:self completedWith:activity error:error desc:desc];
            }
        }];
    }];
}

-(void)hide {
    [self completeWithActivity:nil];
}
@end



