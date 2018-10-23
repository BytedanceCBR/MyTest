//
//  TTAssetView.h
//  TTAssetPickerController
//
//  Created by Wesley Smith on 5/12/12.
//  Copyright (c) 2012 Wesley D. Smith. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <UIKit/UIKit.h>

#import "SSViewBase.h"

@protocol TTAssetViewColumnDelegate;

@interface TTAssetViewColumn : SSViewBase

@property (nonatomic) NSUInteger column;
@property (nonatomic, getter=isSelected) BOOL selected;

// Extended by luohuaqing
@property (nonatomic, readonly) UIButton * selectButton;
@property (nonatomic, strong) UIImageView * selcteButtonImageView;
@property (nonatomic, weak) id<TTAssetViewColumnDelegate> delegate;

@property (nonatomic, strong, readonly)UIImage * thumbnail;
@property (nonatomic,strong,readonly)UIImageView *assetImageView;

+ (TTAssetViewColumn *)assetViewWithFrame:(CGRect)frame withImage:(UIImage *)thumbnail;

- (id)initWithFrame:(CGRect)frame withImage:(UIImage *)thumbnail;

- (void)setShouldSelectItemBlock:(BOOL(^)(NSInteger column))shouldSelectItemBlock;


// Extended by xuzichao,显示当前类型是视频类型
- (void)showVideoTypeWithTime:(NSString *)timeText videBarHidden:(BOOL)hidden;

@end

@protocol TTAssetViewColumnDelegate <NSObject>

@optional

- (void)DidTapTTAssetViewColumn:(TTAssetViewColumn *)sender;

@end
