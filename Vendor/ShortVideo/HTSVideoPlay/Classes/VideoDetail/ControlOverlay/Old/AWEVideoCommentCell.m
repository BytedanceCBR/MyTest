//
//  HTSVideoCommentCell.m
//  LiveStreaming
//
//  Created by willorfang on 16/7/11.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import "AWEVideoCommentCell.h"
#import "AWEVideoPlayAccountBridge.h"
#import "HTSVideoPlayTrackerBridge.h"
#import "AWEVideoDetailManager.h"
#import "BTDResponder.h"
#import "UIImageView+WebCache.h"
#import "TTDeviceHelper.h"
#import <TTBaseLib/UIButton+TTAdditions.h>
#import "UIViewAdditions.h"
#import <TTThemeConst.h>
#import <Masonry/Masonry.h>
#import <UIImage+TTThemeExtension.h>
#import "TTAsyncCornerImageView+VerifyIcon.h"
#import "NSDictionary+TTAdditions.h"
#import "NSStringAdditions.h"

@interface AWEVideoCommentCell () <UIGestureRecognizerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AWECommentModel *commentModel;
@property (nonatomic, strong) NSNumber *videoId;
@property (nonatomic, strong) NSNumber *authorId;

@property (nonatomic, strong) TTAsyncCornerImageView *thumbView;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *likeButton;

@end

@implementation AWEVideoCommentCell

+ (CGFloat)heightForTableView:(UITableView *)tableView withCommentModel:(AWECommentModel *)model
{
    // 添加replyPrefix
    NSString *commentText;
    if (model.replyToComment) {
        NSString *username = model.replyToComment.userName;
        commentText = [NSString stringWithFormat:@"@%@：%@", username, model.text];
    } else {
        commentText = model.text;
    }
    CGSize textSize = [commentText boundingRectWithSize:CGSizeMake(CGRectGetWidth(tableView.bounds) - 60 - 15, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0]} context:nil].size;
    CGFloat height = 37; // comment label top
    height += textSize.height; // comment label height
    height += 8.0 + 16.5 + 14.0; // comment label to bottom height
    return ceil(height);
}

+ (NSDateFormatter *)dataFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm"];
    });
    return formatter;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.thumbView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36) allowCorner:YES];
        self.thumbView.placeholderName = @"hts_vp_head_icon";
        self.thumbView.cornerRadius = 18;
        self.thumbView.borderWidth = 0;
        self.thumbView.userInteractionEnabled = YES;
        
        [self addSubview:self.thumbView];
        [self.thumbView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(14);
            make.left.equalTo(self).offset(15);
            make.width.height.equalTo(@36);
        }];
        
        self.userLabel = [UILabel new];
        self.userLabel.text = nil;
        self.userLabel.font = [UIFont systemFontOfSize:14.0];
        self.userLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
        [self addSubview:self.userLabel];
        [self.userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.thumbView.mas_top);
            make.left.equalTo(self.thumbView.mas_right).offset(9);
        }];

        self.commentLabel = [UILabel new];
        self.commentLabel.text = nil;
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.font = [UIFont systemFontOfSize:17.0];
        self.commentLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        [self addSubview:self.commentLabel];
        [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.userLabel.mas_bottom).offset(8);
            make.left.equalTo(@60);
            make.right.equalTo(self.mas_right).offset(-15);
        }];
        
        self.timeLabel = [UILabel new];
        self.timeLabel.text = nil;
        self.timeLabel.font = [UIFont systemFontOfSize:12.0];
        self.timeLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        [self addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.commentLabel.mas_bottom).offset(8);
            make.left.equalTo(self.commentLabel.mas_left);
        }];
        
        self.likeButton = [UIButton new];
        [self.likeButton setTitleColor:[UIColor tt_themedColorForKey:kColorText13] forState:UIControlStateNormal];
        [self.likeButton setTitleColor:[UIColor tt_themedColorForKey:kColorText4] forState:UIControlStateSelected];
        [self.likeButton setTitle:@"赞" forState:UIControlStateNormal];
        [self.likeButton setTitle:@"赞" forState:UIControlStateSelected];
        self.likeButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        self.likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [self.likeButton setImage:[UIImage themedImageNamed:@"hts_vp_comment_like"] forState:UIControlStateNormal];
        [self.likeButton setImage:[UIImage themedImageNamed:@"hts_vp_comment_like_h"] forState:UIControlStateSelected];
        [self.likeButton addTarget:self action:@selector(likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        UIEdgeInsets insets = self.likeButton.titleEdgeInsets;
        self.likeButton.titleEdgeInsets = UIEdgeInsetsMake(4, insets.left, insets.bottom, insets.right);
        [self addSubview:self.likeButton];
        
        self.deleteButton = [UIButton new];
        [self.deleteButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
        [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [self.deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteButton sizeToFit];
        [self addSubview:self.deleteButton];
        
        //event
        
        // add by zjing 去掉小视频评论头像点击
//        UITapGestureRecognizer *avartarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped)];
//        [self.thumbView addGestureRecognizer:avartarTap];

        self.userLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nameTapped)];
        [self.userLabel addGestureRecognizer:nameTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
        [self.contentView addGestureRecognizer:longPress];
        
        [self.likeButton setHitTestEdgeInsets:UIEdgeInsetsMake(-15, -15, -15, -15)];
    }
    
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.likeButton sizeToFit];
    // 由于sizeToFit没有将EdagesInset考虑进来，造成文字截断，尝试用UIButton也有同样的问题
    CGSize size = self.likeButton.frame.size;
    size.width += 6;
    self.likeButton.size = size;
    [self.userLabel sizeToFit];
    
    self.userLabel.top = self.thumbView.top;
    self.userLabel.left = self.thumbView.right + 9.0;
    self.commentLabel.top = self.userLabel.bottom + 4;
    self.commentLabel.left = 60;
    self.commentLabel.width = self.contentView.width - 60 - 15;
    CGSize textSize = [self.commentLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.contentView.bounds) - 60 - 15, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0]} context:nil].size;
    self.commentLabel.height = textSize.height;
    self.timeLabel.top = self.commentLabel.bottom + 8;
    self.likeButton.top = self.thumbView.top;
    self.likeButton.width += 2;
    self.likeButton.right = CGRectGetWidth(self.bounds) - 15.0;
    
    self.deleteButton.centerY = self.timeLabel.centerY;
    self.deleteButton.right = self.likeButton.right;
}

- (void)configCellWithCommentModel:(AWECommentModel *)model
                           videoId:(NSString *)videoId
                          authorId:(NSString *)authorId
{
    self.commentModel = model;
    self.videoId = @([videoId longLongValue]);
    self.authorId = @([authorId longLongValue]);
    self.userLabel.text = model.userName;
    
    // 自己发的评论不支持回复
    if ([AWEVideoPlayAccountBridge isCurrentLoginUser:[model.userId stringValue]]) {
        self.timeLabel.text = [self _formattedTimeString:model.createTime];
        self.deleteButton.hidden = NO;
    } else {
        self.timeLabel.text = [[self _formattedTimeString:model.createTime] stringByAppendingString:@" · 回复"];
        self.deleteButton.hidden = YES;
    }
   
    // 添加replyPrefix
    if (model.replyToComment) {
        NSString *username = model.replyToComment.userName;
        self.commentLabel.text = [NSString stringWithFormat:@"@%@：%@", username, model.text];
    } else {
        self.commentLabel.text = model.text;
    }
    
    self.likeButton.selected = model.userDigg;
    NSNumber *diggCount = @(model.diggCount.unsignedIntegerValue);
    [self.likeButton setTitle:[self showStringFromNumber:diggCount] forState:UIControlStateNormal];
    [self.likeButton setTitle:[self showStringFromNumber:diggCount] forState:UIControlStateSelected];
    
    [self.thumbView tt_setImageWithURLString:(model.userProfileImageUrl?:@"")];
    [self.thumbView setupVerifyViewForLength:36 adaptationSizeBlock:^CGSize(CGSize standardSize) {
        return [TTVerifyIconHelper tt_newSize:standardSize];
    }];
    [self.thumbView showOrHideVerifyViewWithVerifyInfo:self.commentModel.userAuthInfo decoratorInfo:self.commentModel.userDecoration sureQueryWithID:NO userID:nil disableNightCover:NO];
    [self setNeedsLayout];
}

- (void)refreshCellWithDiggModel:(AWECommentModel *)model cancelDigg:(BOOL)cancelDigg
{
    if (!self.likeButton.selected && model.userDigg) {
        [self.class motionInView:self.likeButton.imageView image:[UIImage imageNamed:@"hts_add_all_dynamic"] offsetPoint:CGPointMake(4.0, -9.0)];
        
        self.likeButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        self.likeButton.imageView.contentMode = UIViewContentModeCenter;
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.likeButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
            strongSelf.likeButton.alpha = 0;
        } completion:^(BOOL finished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.likeButton.selected = YES;
            strongSelf.likeButton.alpha = 0;
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.likeButton.imageView.transform = CGAffineTransformMakeScale(1.f,1.f);
                strongSelf.likeButton.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        }];
    }
    
    self.likeButton.selected = model.userDigg;
    [self.likeButton setTitle:[self showStringFromNumber:model.diggCount] forState:UIControlStateNormal];
    [self.likeButton setTitle:[self showStringFromNumber:model.diggCount] forState:UIControlStateSelected];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

+ (void)motionInView:(UIView *)targetView image:(UIImage *)img offsetPoint:(CGPoint)offset
{
    UIView *motionView = [[UIImageView alloc] initWithImage:img];
    motionView.center = CGPointMake(targetView.frame.size.width/2 + offset.x, targetView.frame.size.height/8 + offset.y);
    UIView *topmostView = [UIApplication sharedApplication].keyWindow;
    if (!topmostView) {
        UIViewController *topmostController = [BTDResponder topViewControllerForView:nil];
        topmostView = topmostController.view;
    }
    motionView.center = [topmostView convertPoint:motionView.center fromView:targetView];
    [topmostView addSubview:motionView];
    
    motionView.alpha = 0.f;
    motionView.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
        motionView.alpha = 1.f;
        motionView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            motionView.alpha = 0.f;
            motionView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        } completion:^(BOOL finished) {
            [motionView removeFromSuperview];
        }];
    }];
}

- (void)nameTapped
{
    if ([self.delegate respondsToSelector:@selector(commentCell:didClickUserNameWithModel:)]) {
        [self.delegate commentCell:self didClickUserNameWithModel:self.commentModel];
    }
}

- (void)avatarTapped
{
    if ([self.delegate respondsToSelector:@selector(commentCell:didClickUserWithModel:)]) {
        [self.delegate commentCell:self didClickUserWithModel:self.commentModel];
    }
}

- (void)deleteButtonTapped
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    BOOL isCommentAuthor = [AWEVideoPlayAccountBridge isCurrentLoginUser:[self.commentModel.userId stringValue]];
    
    //头条里只有自己可以删自己评论
    WeakSelf;
    if (isCommentAuthor) {
        StrongSelf;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"确认删除这条评论？" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([self.delegate respondsToSelector:@selector(commentCell:didClickDeleteWithModel:)]) {
                [self.delegate commentCell:self didClickDeleteWithModel:self.commentModel];
            }
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [[BTDResponder topViewControllerForView:self] presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)likeButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(commentCell:didClickLikeWithModel:)]) {
        [self.delegate commentCell:self didClickLikeWithModel:self.commentModel];
    }
}

- (void)cellLongPress:(UILongPressGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        __weak typeof(self) weakSelf = self;
        if ([TTDeviceHelper OSVersionNumber] >= 8.0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            BOOL isCommentAuthor = [AWEVideoPlayAccountBridge isCurrentLoginUser:[self.commentModel.userId stringValue]];
        
            //头条里只有自己可以删自己评论
            if (isCommentAuthor) {
                [alert addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"确认删除这条评论？" preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;

                        if ([strongSelf.delegate respondsToSelector:@selector(commentCell:didClickDeleteWithModel:)]) {
                            [strongSelf.delegate commentCell:strongSelf didClickDeleteWithModel:strongSelf.commentModel];
                        }
                    }]];
                    
                    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }]];
                    
                    [[BTDResponder topViewControllerForView:self] presentViewController:alertController animated:YES completion:nil];
                }]];
            }
            
            if (!isCommentAuthor) {
                [alert addAction:[UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                   
                    if ([strongSelf.delegate respondsToSelector:@selector(commentCell:didClickReportWithModel:)]) {
                        [strongSelf.delegate commentCell:strongSelf didClickReportWithModel:strongSelf.commentModel];
                    }
                }]];
            }
            
            //Cancel
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
            }]];
            
            [[BTDResponder topViewControllerForView:self] presentViewController:alert animated:YES completion:nil];
        } else {
            BOOL isCommentAuthor = [AWEVideoPlayAccountBridge isCurrentLoginUser:[self.commentModel.userId stringValue]];
            
            if (isCommentAuthor) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除", nil];
                [actionSheet showInView:[BTDResponder topViewControllerForView:self].view];
            }
            
            if (!isCommentAuthor) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报", nil];
                [actionSheet showInView:[BTDResponder topViewControllerForView:self].view];
            }
        }
    }
}

- (NSString *)_formattedTimeString:(NSNumber *)time
{
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSInteger interval = currentTime - [time integerValue];
    if (interval < 60) {
        return @"刚刚";
    } else if (interval < 60 * 60) {
        return [NSString stringWithFormat:@"%ld分钟前", (long)interval / 60];
    } else if (interval < 24 * 60 * 60) {
        return [NSString stringWithFormat:@"%ld小时前", (long)interval / (60 * 60)];
    } else {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[time integerValue]];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        return [dateFormatter stringFromDate:date];
    }
}

- (NSString *)showStringFromNumber:(NSNumber *)num
{
    if ([num integerValue] == 0 || !num) {
        return @"赞";
    } else if ([num integerValue] >= 10000) {
        return [NSString stringWithFormat:@"%ldK", (long)([num integerValue] / 1000)];
    } else {
        return [num stringValue];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"删除"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"确认删除这条评论？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [alert show];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if ([self.delegate respondsToSelector:@selector(commentCell:didClickDeleteWithModel:)]) {
            [self.delegate commentCell:self didClickDeleteWithModel:self.commentModel];
        }
    }
}

@end
