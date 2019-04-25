//
//  TTFullScreenLoadingView.h
//  Article
//
//  Created by yuxin on 4/20/15.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "UIViewController+Refresh_ErrorHandler.h"

@interface TTFullScreenErrorView : SSThemedView

@property (nonatomic,strong) IBOutlet SSThemedLabel * errorMsg;
@property (nonatomic,strong) IBOutlet SSThemedImageView * errorImage;
@property (nonatomic,strong) IBOutlet SSThemedButton * actionBtn;
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;

@property (nonatomic,assign) TTFullScreenErrorViewType viewType;

@end
