//
//  TTNewPanelControllerItem.h
//  Article
//
//  Created by chenjiesheng on 2017/2/10.
//
//

// TODO: ugly code

#import <TTPanelControllerItem.h>

typedef void(^TTNewPanelButtonClick)(UIButton *);

@interface TTNewPanelControllerItem : TTPanelControllerItem

@property (nonatomic, copy)TTNewPanelButtonClick selectedButtonClick;
@end

