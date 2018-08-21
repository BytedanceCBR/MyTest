//
//  TTAccountLoginQuickRetrieveViewController.h
//  TTAccountLogin
//
//  Created by huic on 16/3/21.
//
//

#import "TTAccountLoginBaseViewController.h"



typedef
NS_ENUM(NSInteger, TTAccountLoginQuickRetrieveState) {
    TTAccountLoginQuickRetrieveStateNext   = 0, //下一步页面
    TTAccountLoginQuickRetrieveStateSubmit = 1, //提交页面
};


@interface TTAccountLoginQuickRetrieveViewController : TTAccountLoginBaseViewController

@property (nonatomic, assign) TTAccountLoginQuickRetrieveState state;

@end

