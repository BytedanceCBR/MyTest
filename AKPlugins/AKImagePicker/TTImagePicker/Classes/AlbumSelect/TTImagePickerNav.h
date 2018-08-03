//
//  TTImagePickerNav.h
//  Article
//
//  Created by tyh on 2017/4/19.
//
//

#import <UIKit/UIKit.h>
#import "TTImagePickerDefineHead.h"



@interface TTImagePickerNav : UIView<TTImagePickerNavProtocol>

@property(nonatomic,weak) id<TTImagePickerNavDelegate> delegate;

//用于track
@property (nonatomic,assign)TTImagePickerMode imagePickerMode;


@property (nonatomic,assign)BOOL enableSelcect;



@end

