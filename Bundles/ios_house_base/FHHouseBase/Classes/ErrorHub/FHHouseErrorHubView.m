//
//  FHHouseErrorHubView.m
//  FHHouseBase
//
//  Created by liuyu on 2020/4/9.
//

#import "FHHouseErrorHubView.h"
#import "Masonry.h"
#import "TTRoute.h"
#import "UIDevice+BTDAdditions.h"
@interface FHHouseErrorHubView()
@property (weak, nonatomic)UIView *contentView;
@property (weak, nonatomic)UILabel *titleLab;
@property (weak, nonatomic)UILabel *subMessageLab;
@end
@implementation FHHouseErrorHubView
+(void)showErrorHubViewWithTitle:(NSString *)title content:(NSString *)content {
    
    FHHouseErrorHubView *errorHubView = [[FHHouseErrorHubView alloc]initWithFrame:CGRectMake(0, -64, [UIScreen mainScreen].bounds.size.width, 64)];
    errorHubView.title = title;
    errorHubView.content = content;
    
    UIViewController *visibleController = [errorHubView findVisibleViewController];
    [visibleController.view addSubview:errorHubView];
    [UIView animateWithDuration:0.25 animations:^{
        errorHubView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIDevice btd_isIPhoneXSeries]?84:64);
    } completion:^(BOOL finished) {
        if (@available(iOS 10.0, *)) {
            [NSTimer scheduledTimerWithTimeInterval:2 repeats:NO block:^(NSTimer * _Nonnull timer) {
                [UIView animateWithDuration:0.25 animations:^{
                    errorHubView.frame = CGRectMake(0,  [UIDevice btd_isIPhoneXSeries]?-84:-64, [UIScreen mainScreen].bounds.size.width,  [UIDevice btd_isIPhoneXSeries]?84:64);
                } completion:^(BOOL finished) {
                    [errorHubView removeFromSuperview];
                }];
            }];
        } else {
            // Fallback on earlier versions
        }
    }];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}
- (void)initUI {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self);
    }];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.equalTo(self.subMessageLab.mas_top).offset(-10);
    }];
    [self.subMessageLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-10);
    }];
     UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tapGesturRecognizer];
}

- (UIView *)contentView {
    if (!_contentView) {
        UIView *contentView = [[UIView alloc]init];
        contentView.backgroundColor = [UIColor orangeColor];
        [self addSubview:contentView];
        _contentView = contentView;
    }
    return _contentView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel *titleLab = [[UILabel alloc]init];
        titleLab.textColor = [UIColor redColor];
        titleLab.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:titleLab];
        _titleLab = titleLab;
    }
    return _titleLab;
}
- (UILabel *)subMessageLab {
    if (!_subMessageLab) {
        UILabel *subMessageLab = [[UILabel alloc]init];
        subMessageLab.textColor = [UIColor blackColor];
        subMessageLab.font = [UIFont systemFontOfSize:8];
        subMessageLab.numberOfLines = 0;
        [self.contentView addSubview:subMessageLab];
        _subMessageLab = subMessageLab;
    }
    return _subMessageLab;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLab.text = title;
}

- (void)setContent:(NSString *)content {
    _content = content;
    self.subMessageLab.text = content;
}

- (UIViewController *)getRootViewController{
    
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"The window is empty");
    return window.rootViewController;
}

- (UIViewController *)findVisibleViewController {
    
    UIViewController* currentViewController = [self getRootViewController];
    
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else {
            if ([currentViewController isKindOfClass:[UINavigationController class]]) {
                currentViewController = ((UINavigationController *)currentViewController).visibleViewController;
            } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
                currentViewController = ((UITabBarController* )currentViewController).selectedViewController;
            } else {
                break;
            }
        }
    }
    
    return currentViewController;
}

- (void)tapAction:(id)sender {
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://errrorhub_debug"]] userInfo:nil];
}
@end
