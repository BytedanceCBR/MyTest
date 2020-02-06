//
//  TTWrongWordsReportViewController.h
//  TTUIWidget
//
//  Created by chenbb6 on 2019/10/24.
//

#import <UIKit/UIKit.h>
#import <TTThemed/SSThemed.h>
#import "TTWrongWordsReportModel.h"

NS_ASSUME_NONNULL_BEGIN

@class TTWrongWordsReportViewController;

@protocol TTWrongWordsReportViewControllerDelegate <NSObject>

@optional
- (void)wrongWordsReportViewControllerDidClickedConfirmButton:(TTWrongWordsReportViewController *)controller;
- (void)wrongWordsReportViewControllerDidClickedCancelButton:(TTWrongWordsReportViewController *)controller;
- (void)wrongWordsReportViewControllerTextFieldDidChange:(NSString *)text;

@end

@interface TTWrongWordsReportViewController : UIViewController

@property (nonatomic, weak) id <TTWrongWordsReportViewControllerDelegate> delegate;

@property (nonatomic,strong) SSThemedView *backView;
@property (nonatomic,strong) SSThemedView *wrapperView;

- (instancetype)initWithTips:(NSString *)tips;

- (void)configWithTips:(NSString *)tips;

@end

NS_ASSUME_NONNULL_END
