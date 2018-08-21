//
//  TTIMMessageInputViewController.h
//  EyeU
//
//  Created by matrixzk on 10/23/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TTIMMessageInputViewDelegate <NSObject>

@optional
- (void)ttimMessageInputViewTextDidBeginEditing:(UITextView *)textView;
- (void)ttimMessageInputViewTextDidChange:(UITextView *)textView;
- (void)ttimMessageInputViewTextDidSend:(NSString *)text;
- (void)ttimMessageInputViewAlbumPhotosDidPicked:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isOriginPhoto;
- (void)ttimMessageInputViewCameraDidBackWithURL:(NSURL *)pathURL isVideo:(BOOL)isVideo previewImage:(UIImage *)previewImage;

@end

@interface TTIMMessageInputViewController : NSObject

+ (instancetype)setupMessageInputViewWithParentViewController:(UIViewController *)parentVC associateTableView:(UITableView *)tableView delegate:(id<TTIMMessageInputViewDelegate>)delegate;

- (void)layoutSubview;
- (NSString *)currentInputtingText;
- (void)callOutMsgInputViewWithText:(NSString *)text;
- (void)dismissMessageInputView;
+ (CGFloat)heightOfMsgInputView;

@end
