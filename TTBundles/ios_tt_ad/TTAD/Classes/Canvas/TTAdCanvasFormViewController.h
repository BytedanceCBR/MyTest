//
//  TTAdCanvasFormViewController.h
//  Article
//
//  Created by carl on 2017/11/12.
//

#import <UIKit/UIKit.h>
#import "TTAdAppointAlertView.h"

@interface TTAdAppointAlertScriptModel : TTAdAppointAlertModel
@property (nonatomic, copy) NSString *javascriptString;
@end

@interface TTAdCanvasFormViewController : UIViewController
@property (nonatomic, strong) TTAdAppointAlertScriptModel *model;
@end
