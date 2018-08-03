//
//  TTImagePickerBackGestureView.h
//  Article
//
//  Created by tyh on 2017/4/18.
//
//

#import <UIKit/UIKit.h>
#import "TTImagePickerDefineHead.h"
@class TTImagePickerBackGestureCollectionView;

@protocol TTImagePickerBackGestureViewDelegate <NSObject>

@optional
- (void)ttImagePickerBackGestureViewdidScrollScale:(float)scale;
- (void)ttImagePickerBackGestureViewdidFinnish;
- (void)ttImagePickerBackGestureViewdidCancel;

@end


typedef enum : NSUInteger {
    BackGestureDirectionDisabledNone,
    BackGestureDirectionDisabledRight,
    BackGestureDirectionDisabledDown,
    BackGestureDirectionDisabledAll
} BackGestureDirectionDisabled;

@interface TTImagePickerBackGestureView : UIView

@property (nonatomic,strong)TTImagePickerBackGestureCollectionView *collectionView;

//用来track
@property (nonatomic,assign)TTImagePickerMode imagePickerMode;

//不支持的方向
@property (nonatomic,assign)BackGestureDirectionDisabled disableDirection;

@property (nonatomic,weak)id<TTImagePickerBackGestureViewDelegate> delegate;

@end


@interface TTImagePickerBackGestureCollectionView : UICollectionView



@end
