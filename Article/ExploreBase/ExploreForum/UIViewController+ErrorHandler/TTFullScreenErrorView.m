//
//  TTFullScreenLoadingView.m
//  Article
//
//  Created by yuxin on 4/20/15.
//
//

#import "TTFullScreenErrorView.h"

@interface TTFullScreenErrorView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorImageWidthConstraint; //错误图片宽度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorImageHeightConstraint; //错误图片高度约束

@end

@implementation TTFullScreenErrorView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//错误提示图片和文本描述根据不同的设备自动适应
- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];

	if (newSuperview) {
		CGFloat width = 152.0, height = 80.0;
		CGFloat fontSize = 15.0;

		if ([SSCommon is667Screen]) {
			width = 226.0;
			height = 119.0;
			fontSize = 17.0;
		} else if ([SSCommon is736Screen]) {
			width = 239.0;
			height = 126.0;
			fontSize = 18.0;
		}

		self.errorImageWidthConstraint.constant = width;
		self.errorImageHeightConstraint.constant = height;
		self.errorMsg.font = [UIFont systemFontOfSize:fontSize];
	}
}

- (void)setViewType:(TTFullScreenErrorViewType)viewType {
    
    _viewType = viewType;
    self.errorMsg.text = @"";
    self.actionBtn.hidden = YES;
    self.refreshButton.hidden = YES;
    switch (viewType) {
        case TTFullScreenErrorViewTypeEmpty:
            [self.errorImage setImage:[UIImage resourceImageNamed:@"not_found_loading"]];
            self.errorMsg.text = SSLocalizedString(@"在这个星球中找不到", nil);
            
            break;
            
        case TTFullScreenErrorViewTypeNoFriends:
            [self.errorImage setImage:[UIImage resourceImageNamed:@"not_login_loading"]];
            
            self.actionBtn.hidden = NO;
            [self.actionBtn setTitle:SSLocalizedString(@"添加好友", nil) forState:UIControlStateNormal];

            break;
        case TTFullScreenErrorViewTypeNoFollowers:
            [self.errorImage setImage:[UIImage resourceImageNamed:@"not_article_loading"]];
            self.errorMsg.hidden = YES;
            break;
       
        case TTFullScreenErrorViewTypeSessionExpired:
            [self.errorImage setImage:[UIImage resourceImageNamed:@"not_login_loading"]];
            self.errorMsg.text = SSLocalizedString(@"登陆认识更多朋友", nil);
            
            self.actionBtn.hidden = NO;
            [self.actionBtn setTitle:SSLocalizedString(@"马上登录", nil) forState:UIControlStateNormal];
            break;
        default:
            
            [self.errorImage setImage:[UIImage resourceImageNamed:@"not_network_loading"]];
            self.errorMsg.text = SSLocalizedString(@"网络不给力，点击屏幕重试", nil);
            self.refreshButton.hidden = NO;
            [self.refreshButton setTitle:@"" forState:UIControlStateNormal];
//            self.actionBtn.hidden = NO;
//            [self.actionBtn setTitle:SSLocalizedString(@"重试", nil) forState:UIControlStateNormal];
            break;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    BOOL inside = CGRectContainsPoint(self.actionBtn.frame, point) || CGRectContainsPoint(self.refreshButton.frame, point);
    return inside;
}
@end
