//
//  TTImagePreviewBottomView.h
//  Article
//
//  Created by tyh on 2017/4/27.
//
//

#import <UIKit/UIKit.h>

@interface TTImagePreviewBottomView : UIView

//选中
@property (nonatomic,copy)dispatch_block_t selectAction;

@property(nonatomic,getter=isSelected) BOOL selected;

@property (nonatomic,strong)UIImageView *backImg;

@end
