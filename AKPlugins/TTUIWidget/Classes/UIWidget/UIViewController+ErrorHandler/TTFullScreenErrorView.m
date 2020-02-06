//
//  TTFullScreenLoadingView.m
//  Article
//
//  Created by yuxin on 4/20/15.
//
//

#import "TTFullScreenErrorView.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import <TTBaseLib/UIImageAdditions.h>

@interface TTFullScreenErrorView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorImageWidthConstraint; //错误图片宽度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorImageHeightConstraint; //错误图片高度约束

@property (nonatomic,strong) UIView *lastCustomErrorView;
@end

@implementation TTFullScreenErrorView

- (void)awakeFromNib {
    [super awakeFromNib];

    [self.refreshButton setTitleColor:[UIColor colorWithHexString:@"#ff5869"] forState:UIControlStateNormal];
    [self.refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
    self.refreshButton.layer.cornerRadius  = 15;
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    if (!font) {
        font = [UIFont systemFontOfSize:14];
    }
    self.refreshButton.titleLabel.font = font;
    self.refreshButton.layer.borderColor = [[UIColor colorWithHexString:@"#ff5869"]CGColor];
    self.refreshButton.layer.borderWidth = 1;
    [self.refreshButton setBackgroundImage:[UIImage imageWithUIColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.refreshButton setBackgroundImage:[UIImage imageWithUIColor:[[UIColor colorWithHexString:@"#ff5869"] colorWithAlphaComponent:0.1]] forState:UIControlStateHighlighted];
    self.refreshButton.layer.masksToBounds = YES;
}
//错误提示图片和文本描述根据不同的设备自动适应
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        CGFloat width = 152.0, height = 80.0;
        CGFloat fontSize = 14.0;
        
        //        if ([TTDeviceHelper is667Screen]) {
        //            width = 226.0;
        //            height = 119.0;
        //            fontSize = 17.0;
        //        } else if ([TTDeviceHelper is736Screen]) {
        //            width = 239.0;
        //            height = 126.0;
        //            fontSize = 18.0;
        //        }
        
        //        self.errorImageWidthConstraint.constant = width;
        //        self.errorImageHeightConstraint.constant = height;
        self.errorMsg.font = [UIFont systemFontOfSize:fontSize];
    }
}

- (void)setViewType:(TTFullScreenErrorViewType)viewType {
    
    _viewType = viewType;
    self.errorMsg.text = @"";
    self.errorSubMsg.text = @"";
    self.actionBtn.hidden = YES;
    self.refreshButton.hidden = YES;
    self.addConcernButton.hidden = YES;
    self.errorMsg.hidden = NO;
    self.errorSubMsg.hidden = NO;
    self.errorImage.hidden = NO;
    //重置error图片
    [self.errorImage setImage:nil];
    [self.lastCustomErrorView removeFromSuperview];
    switch (viewType) {
        case TTFullScreenErrorViewTypeEmpty: {
            [self.errorImage setImage:[UIImage themedImageNamed:@"not_found_loading"]];
            self.errorMsg.text = NSLocalizedString(@"在这个星球中找不到", nil);
            //判断是否设置了自定义的文案和图片
            if (_customEmptyErrorMsgBlock) {
                self.errorMsg.text = _customEmptyErrorMsgBlock();
            }
            if (_customEmptyErrorImageNameBlock) {
                [self.errorImage setImage:[UIImage themedImageNamed:_customEmptyErrorImageNameBlock()]];
            }
            break;
        }
        case TTFullScreenErrorViewTypeNoFriends: {
            [self.errorImage setImage:[UIImage themedImageNamed:@"not_login_loading"]];
            self.errorMsg.text = NSLocalizedString(@"你还没有关注任何人", nil);
            self.actionBtn.hidden = YES;
            [self.actionBtn setTitle:NSLocalizedString(@"添加好友", nil) forState:UIControlStateNormal];
            break;
        }
        case TTFullScreenErrorViewTypeOtherNoFriends: {
            [self.errorImage setImage:[UIImage themedImageNamed:@"not_login_loading"]];
            self.errorMsg.text = NSLocalizedString(@"TA还没有关注任何人", nil);
            break;
        }
        case TTFullScreenErrorViewTypeNoInterests: {
            [self.errorImage setImage:[UIImage themedImageNamed:@"not_login_loading"]];
            self.errorMsg.text = NSLocalizedString(@"你还没有兴趣", nil);
            self.actionBtn.hidden = YES;
            [self.actionBtn setTitle:NSLocalizedString(@"添加兴趣", nil) forState:UIControlStateNormal];
            break;
        }
        case TTFullScreenErrorViewTypeOtherNoInterests: {
            [self.errorImage setImage:[UIImage themedImageNamed:@"not_login_loading"]];
            self.errorMsg.text = NSLocalizedString(@"TA还没有兴趣", nil);
            break;
        }
        case TTFullScreenErrorViewTypeNoFollowers: {
            [self.errorImage setImage:[UIImage themedImageNamed:@"not_login_loading"]];
            self.errorMsg.text = NSLocalizedString(@"你还没有粉丝", nil);
            break;
        }
        case TTFullScreenErrorViewTypeOtherNoFollowers: {
            [self.errorImage setImage:[UIImage themedImageNamed:@"not_login_loading"]];
            self.errorMsg.text = NSLocalizedString(@"TA还没有粉丝", nil);
            break;
        }
        case TTFullScreenErrorViewTypeNoVisitor: {
            [self.errorImage setImage:[UIImage themedImageNamed:@"not_login_loading"]];
            self.errorMsg.text = NSLocalizedString(@"还没有人访问过你", nil);
            break;
        }
        case TTFullScreenErrorViewTypeSessionExpired: {
            [self.errorImage setImage:[UIImage themedImageNamed:@"not_login_loading"]];
            self.errorMsg.text = NSLocalizedString(@"登录认识更多朋友", nil);
            self.actionBtn.hidden = NO;
            [self.actionBtn setTitle:NSLocalizedString(@"马上登录", nil) forState:UIControlStateNormal];
            break;
        }
        case TTFullScreenErrorViewTypeBlacklistEmpty: {
            [self.errorImage setImage:[UIImage themedImageNamed:@"not_blacklist_loading"]];
            self.errorMsg.text = NSLocalizedString(@"黑名单为空", nil);
            self.actionBtn.hidden = YES;
            break;
        }
        case TTFullScreenErrorViewTypeLocationServiceDisabled: {
            [self.errorImage setImage:[UIImage themedImageNamed:@"not_location_loading"]];
            self.errorMsg.text = NSLocalizedString(@"定位服务不可用", nil);
            self.errorSubMsg.text = NSLocalizedString(@"开启定位，添加你的位置（设置>隐私>定位服务>开启幸福里定位服务",nil);
            self.actionBtn.hidden = NO;
            [self.actionBtn setTitle:NSLocalizedString(@"开启服务", nil) forState:UIControlStateNormal];
            break;
        }
        case TTFullScreenErrorViewTypeLocationServiceError: {
            [self.errorImage setImage:[UIImage themedImageNamed:@"not_location_loading"]];
            self.errorMsg.text = NSLocalizedString(@"定位信息获取失败\n请手动选择你所在的城市", nil);
            self.actionBtn.hidden = NO;
            [self.actionBtn setTitle:NSLocalizedString(@"选择城市", nil) forState:UIControlStateNormal];
            break;
        }
        case TTFullScreenErrorViewTypeDeleted: {
            [self.errorImage setImage:[UIImage themedImageNamed:@"delete_article_loading"]];
            self.errorMsg.text = NSLocalizedString(@"该内容已删除", nil);
            self.actionBtn.hidden = YES;
            break;
        }
        case TTFullScreenErrorViewTypeFollowEmpty: {
            self.actionBtn.hidden = YES;
            self.addConcernButton.hidden = NO;
            [self.addConcernButton setTitle:NSLocalizedString(@"添加关注的图放在这", nil) forState:UIControlStateNormal];
            self.errorMsg.text = NSLocalizedString(@"添加关注的文字放在这", nil);
            break;
        }
        case TTFullScreenErrorViewTypeCustomView:{
            //完全自定义，用子视图覆盖
            self.errorMsg.hidden = YES;
            self.errorSubMsg.hidden = YES;
            self.errorImage.hidden = YES;
            if (_customFullScreenErrorViewBlock) {
                UIView *tmpView = _customFullScreenErrorViewBlock();
                tmpView.frame = self.bounds;
                [self addSubview:tmpView];
                self.lastCustomErrorView = tmpView;
            }
            break;
        }
        default: {
            self.errorMsg.text = NSLocalizedString(@"网络异常，请检查网络连接", nil);
            [self.errorImage setImage:[UIImage themedImageNamed:@"group-4"]];
            self.refreshButton.hidden = NO;
            break;
        }
    }
}

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//
//    BOOL inside = CGRectContainsPoint(self.actionBtn.frame, point) || CGRectContainsPoint(self.refreshButton.frame, point);
//    return inside;
//}
@end
