//
//  UIImagePickerController+TTBlocks.h
//  Article
//
//  Created by Zuopeng Liu on 7/22/16.
//
//

#import <UIKit/UIKit.h>


typedef void (^UIImagePickerControllerDidFinishBlock)(UIImagePickerController *picker, NSDictionary *info);
typedef void (^UIImagePickerControllerDidCancelBlock)(UIImagePickerController *picker);


/**
 A category class adding block support to UIImagePickerController, replacing delegation implementation.
 */
@interface UIImagePickerController (TTBlocks)
/** A block to be executed whenever the user picks a new photo. Use this block to replace delegate method imagePickerController:didFinishPickingPhotoWithInfo: */
@property (nonatomic, strong) UIImagePickerControllerDidFinishBlock completionBlock;
/** A block to be executed whenever the user cancels the pick operation. Use this block to replace delegate method imagePickerControllerDidCancel: */
@property (nonatomic, strong) UIImagePickerControllerDidCancelBlock cancellationBlock;

@end