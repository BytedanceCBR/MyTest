//
//  TTAssetView.m
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

#import "TTAssetViewColumn.h"
#import "TTAssetWrapper.h"
#import "SSThemed.h"
#import "UIViewAdditions.h"

@interface TTAssetViewColumn ()
{
    UILabel *_gifLabel;
}

@property (nonatomic, strong) BOOL (^shouldSelectItem)(NSInteger column);
@property (nonatomic, strong, readwrite)UIImage * thumbnail;

// Extended by xuzichao
@property (nonatomic,strong) SSThemedView *videoBarView;
@property (nonatomic,strong) UILabel *videoTimeLabel;

@end


@implementation TTAssetViewColumn

@synthesize column = _column;
@synthesize selected = _selected;
@synthesize selectButton = _selectButton;
@synthesize selcteButtonImageView = _selcteButtonImageView;


#pragma mark - Initialization

// #define ASSET_VIEW_FRAME CGRectMake(0, 0, 75, 75)

+ (TTAssetViewColumn *)assetViewWithFrame:(CGRect)frame withImage:(UIImage *)thumbnail;
{
    TTAssetViewColumn *assetView = [[TTAssetViewColumn alloc] initWithFrame:frame withImage:thumbnail];
    
    return assetView;
}

- (id)initWithFrame:(CGRect)frame withImage:(UIImage *)thumbnail;
{
    if ((self = [super initWithFrame:frame])) {
        self.thumbnail = thumbnail;
        // Setup a tap gesture.
        // luohuaqing: for image preview
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapAction:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        // Add the photo thumbnail.
        _assetImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _assetImageView.contentMode = UIViewContentModeScaleAspectFill;
        _assetImageView.clipsToBounds = YES;
        [self addSubview:_assetImageView];
        
        self.selectButton.frame = CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height / 2);
        [self.selectButton addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.selectButton];
        
        //显示是否是video类型 add by xuzichao
        self.videoBarView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.frame.size.height*4/5, self.frame.size.width, self.frame.size.height/5)];
        self.videoBarView.backgroundColorThemeKey = kColorBackground9;
        self.videoBarView.hidden = YES;
        [self addSubview:self.videoBarView];
        
        self.videoTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.videoBarView.width - 5, self.videoBarView.height)];
        self.videoTimeLabel.font = [UIFont systemFontOfSize:12];
        self.videoTimeLabel.textColor = [UIColor whiteColor];
        self.videoTimeLabel.textAlignment = NSTextAlignmentRight;
        self.videoTimeLabel.text = @"00:00";
        [self.videoBarView addSubview:self.videoTimeLabel];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatroom_small_video"]];
        imageView.frame = CGRectMake(4, 2, self.videoBarView.bounds.size.height - 4, self.videoBarView.bounds.size.height - 4);
        [self.videoBarView addSubview:imageView];
        
        
        _gifLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.width - 44 -2, self.height - 20 -2, 44, 20)];
        _gifLabel.layer.cornerRadius = 10;
        _gifLabel.layer.masksToBounds = YES;
        _gifLabel.font = [UIFont systemFontOfSize:10];
        _gifLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _gifLabel.textColor = [UIColor tt_themedColorForKey:kColorText12];
        _gifLabel.text = @"GIF";
        if (thumbnail.images && thumbnail.images.count > 0) {
            _gifLabel.hidden = NO;
            _assetImageView.image = [thumbnail.images firstObject];
        }else{
            _gifLabel.hidden = YES;
            _assetImageView.image = thumbnail;

        }
        _gifLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_gifLabel];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)setShouldSelectItemBlock:(BOOL(^)(NSInteger column))shouldSelectItemBlock
{
    self.shouldSelectItem = shouldSelectItemBlock;
}

#pragma mark - Setters/Getters

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected) {
        
        // KVO compliant notifications.
        [self willChangeValueForKey:@"isSelected"];
        _selected = selected;
        [self didChangeValueForKey:@"isSelected"];
    }
}

- (UIButton *)selectButton
{
    if (!_selectButton)
    {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.backgroundColor = [UIColor clearColor];
    }
    
    return _selectButton;
}


- (void)setSelcteButtonImageView:(UIImageView *)selcteButtonImageView
{
    if (_selcteButtonImageView)
    {
        [_selcteButtonImageView removeFromSuperview];
    }
    
    _selcteButtonImageView = selcteButtonImageView;
    CGRect frame = _selcteButtonImageView.frame;
    frame.origin.x = self.selectButton.frame.size.width  - frame.size.width;
    frame.origin.y = 0;
    _selcteButtonImageView.frame = frame;
    [self.selectButton addSubview:_selcteButtonImageView];
}

#pragma mark - Actions
/*
- (void)userDidTapAction:(UITapGestureRecognizer *)sender
{   
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        // Set the selection state.
        BOOL canSelect = YES;
        if (self.shouldSelectItem)
            canSelect = self.shouldSelectItem(self.column);
        
        self.selected = (canSelect && (self.selected == NO));
    }
}
*/

- (void)userDidTapAction:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(DidTapTTAssetViewColumn:)])
        {
            [self.delegate DidTapTTAssetViewColumn:self];
        }
    }
}

- (void)selectButtonClicked:(id)sender
{
    // Set the selection state.
    BOOL canSelect = YES;
    if (self.shouldSelectItem)
        canSelect = self.shouldSelectItem(self.column);
    
    self.selected = (canSelect && (self.selected == NO));
}

- (void)showVideoTypeWithTime:(NSString *)timeText videBarHidden:(BOOL)hidden;
{
    self.videoBarView.hidden = hidden;
    self.videoTimeLabel.text = timeText;
}

@end
