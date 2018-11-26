//
//  FHWebviewController.h
//  Article
//
//  Created by 张元科 on 2018/11/26.
//

#import <UIKit/UIKit.h>
#import <TTRWebViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHWebviewViewController : TTRWebViewController

@property(nonatomic , copy) NSString *url;
@property(nonatomic, strong) NSMutableDictionary *dic;

@end

NS_ASSUME_NONNULL_END
