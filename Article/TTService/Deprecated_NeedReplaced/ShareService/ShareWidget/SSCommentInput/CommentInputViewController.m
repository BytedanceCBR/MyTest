//
//  CommentInputViewController.m
//  Article
//
//  Created by Dianwei on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//  used by phone

#import "CommentInputViewController.h"
#import "TTDeviceHelper.h"

#import <TTAccountBusiness.h>



@interface CommentInputViewController ()<SSCommentInputViewDelegate>

@end

@implementation CommentInputViewController

- (void)dealloc
{
    self.delegate = nil;
    self.commentInputView.delegate = nil;
    self.commentInputView = nil;
}

- (id)init
{
    return [self initWithMaxWordsCount:kMaxCommentLength];
}

- (instancetype)initWithMaxWordsCount:(NSInteger)maxWordsCount
{
    self = [super init];
    if (self) {
        NSInteger shouldDesignateMaxWords = maxWordsCount > kMaxCommentLength ? kMaxCommentLength : maxWordsCount;
        [self initCommentInputViewWithDesignateMaxWords:shouldDesignateMaxWords];
    }
    return self;
}

- (void)initCommentInputViewWithDesignateMaxWords:(NSInteger)maxWordsCount
{
    if (!_commentInputView) {
        self.commentInputView = [[SSCommentInputView alloc] initWithFrame:self.view.bounds];
        self.commentInputView.designatedMaxWordsCount = maxWordsCount;
        _commentInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
        _commentInputView.delegate = self;
        [self.view addSubview:_commentInputView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //    self.commentInputView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"发送", nil) style:UIBarButtonItemStylePlain target:self action:@selector(sendButtonClicked)];
    
    /*
     * init函数中已经将CommentInputView初始化，此处注释掉
     */
    
    //    [self initCommentInputView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString * titleStr = nil;
    id className = [SSCommentInputViewBase userAccountClassForCommentInputViewType:self.commentInputView.inputViewType];
    if (className == nil) {
        titleStr = sDefaultTitle;
    }
    else {
        titleStr = [NSString stringWithFormat:@"%@%@", sShareTo, [className platformDisplayName]];
    }
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:NSLocalizedString(titleStr, nil)];
    [_commentInputView willAppear];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_commentInputView didAppear];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_commentInputView didDisappear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_commentInputView didAppear];
}

- (void)loadView
{
    self.view = [[SSViewBase alloc] initWithFrame:CGRectMake(0, 0, [TTUIResponderHelper applicationSize].width, [TTUIResponderHelper applicationSize].height)];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [(SSViewBase*)self.view reloadThemeUI];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([TTDeviceHelper isPadDevice]) {
        return UIInterfaceOrientationMaskAll;
    }
    else {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

#pragma mark -- cancel and send button clicked
- (void)cancelButtonClicked{
    [self.commentInputView backButtonClicked];
}

- (void)sendButtonClicked{
    [self.commentInputView sendButtonClicked];
}

#pragma mark -- SSCommentInputViewDelegate
- (void)commentInputView:(SSCommentInputView *)inputView responsedReceived:(NSNotification *)notification
{
    
    if (_delegate && [_delegate respondsToSelector:@selector(commentInputViewController:responsedReceived:)]) {
        [_delegate commentInputViewController:self responsedReceived:notification];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)commentInputViewCancelled:(SSCommentInputView *)controller
{
    if (_delegate && [_delegate respondsToSelector:@selector(commentInputViewControllerCancelled:)]) {
        [_delegate commentInputViewControllerCancelled:self];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (BOOL)commentInputViewWillSendMsg:(SSCommentInputView *)controller
{
    if (_delegate && [_delegate respondsToSelector:@selector(commentInputViewControllerWillSendMsg:)]) {
        return [_delegate commentInputViewControllerWillSendMsg:self];
    }
    else {
        return YES;
    }
}

@end
