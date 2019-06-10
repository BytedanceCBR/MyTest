//
//  UIImagePickerController+TTBlocks.m
//  Article
//
//  Created by Zuopeng Liu on 7/22/16.
//
//

#import "UIImagePickerController+TTBlocks.h"
#import <objc/runtime.h>

static char completionBlockKey;
static char cancelationBlockKey;

@interface UIImagePickerController ()
<
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
>
@end

@implementation UIImagePickerController (TTBlocks)

#pragma mark - Getter methods

- (UIImagePickerControllerDidFinishBlock)completionBlock {
    return objc_getAssociatedObject(self, &completionBlockKey);
}

- (UIImagePickerControllerDidCancelBlock)cancellationBlock {
    return objc_getAssociatedObject(self, &cancelationBlockKey);
}


#pragma mark - Setter methods

- (void)setCompletionBlock:(UIImagePickerControllerDidFinishBlock)block {
    if (!block) {
        return;
    }
    
    self.delegate = self;
    objc_setAssociatedObject(self, &completionBlockKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCancellationBlock:(UIImagePickerControllerDidCancelBlock)block {
    if (!block) {
        return;
    }
    
    self.delegate = self;
    objc_setAssociatedObject(self, &cancelationBlockKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (self.completionBlock) {
        self.completionBlock(self, info);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.cancellationBlock) {
        self.cancellationBlock(self);
    }
}

//解决ios11以上系统plus机型，选取图片时，取消按钮很难点中的问题
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([UIDevice currentDevice].systemVersion.floatValue < 11) {
        return;
    }
    if ([viewController isKindOfClass:NSClassFromString(@"PUPhotoPickerHostViewController")]) {
        [viewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.frame.size.width < 42) {
                [viewController.view sendSubviewToBack:obj];
                *stop = YES;
            }
        }];
    }
}

@end
