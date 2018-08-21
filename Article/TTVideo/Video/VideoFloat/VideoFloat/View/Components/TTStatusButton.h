//
//  TTStatusButton.h
//  Article
//
//  Created by panxiang on 16/7/11.
//
//

#import <UIKit/UIKit.h>
#import "TTVideoFloatProtocol.h"

@interface TTStatusButton : UIButton
@property (nonatomic, weak ,nullable) NSObject<TTStatusButtonDelegate> *delegate;
@end
