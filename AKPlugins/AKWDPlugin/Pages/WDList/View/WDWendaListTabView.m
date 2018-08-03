//
//  WDWendaListTabView.m
//  Article
//
//  Created by xuzichao on 2017/3/13.
//
//

#import "WDWendaListTabView.h"
#import "WDListViewModel.h"
#import "WDQuestionEntity.h"
#import "WDUIHelper.h"
#import "TTRoute.h"
#import "TTAlphaThemedButton.h"
#import "UIButton+TTAdditions.h"
#import "TTImageView.h"
#import <KVOController/NSObject+FBKVOController.h>
#import <TTUIWidget/TTIndicatorView.h>

@interface WDWendaListTabView ()

@property (nonatomic, strong) WDListViewModel *listViewModel;
@property (nonatomic, strong) TTAlphaThemedButton *sendBtn;
@property (nonatomic, strong) SSThemedView *line;

@property (nonatomic, strong) NSMutableArray *buttonList;

@end

@implementation WDWendaListTabView

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel
{
    self = [super initWithFrame:frame];
    if (self) {
        _listViewModel = viewModel;

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.line];
        [self addSubview:self.sendBtn];
        self.buttonList = [NSMutableArray array];
        
        [self.sendBtn.KVOController observe:self.listViewModel keyPath:NSStringFromSelector(@selector(canAnswer)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            NSNumber *newValue = [change objectForKey:NSKeyValueChangeNewKey];
            NSNumber *oldValue = [change objectForKey:NSKeyValueChangeOldKey];
            if (![newValue isEqual:oldValue]) {
                TTAlphaThemedButton *sendButton = observer;
                sendButton.backgroundColorThemeKey = [newValue boolValue] ? kColorBackground7 : kColorBackground7Highlighted;
            }
        }];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.line.width = self.width;
    self.line.left = 0;
    self.line.top = 0;
    
    self.sendBtn.right = self.width;
    self.sendBtn.top = 0;
    self.sendBtn.height = 44;
}

- (void)themeChanged:(NSNotification *)notification
{
    [self refresh];
}

- (void)refresh
{
    if (!self.listViewModel.tabModelArray || self.listViewModel.tabModelArray.count == 0) {
        return;
    }
    
    //删除原来的
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    [self.buttonList removeAllObjects];
    
    //新建
    [self addSubview:self.line];
    [self addSubview:self.sendBtn];
    
    NSInteger btnCount = self.listViewModel.tabModelArray.count;
    if (btnCount > 2) {
        btnCount = 2;
    }

    CGFloat left = 0;
    CGFloat btnWidth = ceilf(self.width / 3.0);
    for (NSInteger i=0; i<btnCount ; i++) {
        
        WDModuleStructModel *model = [self.listViewModel.tabModelArray objectAtIndex:i];
        
        if (!isEmptyString(model.text)) {
            
            SSThemedLabel *label = [[SSThemedLabel alloc] init];
            CGFloat fontSize = 14;
            label.font = [UIFont systemFontOfSize:fontSize];
            label.textColorThemeKey = kColorText1;
            label.text = model.text;
            [label sizeToFit];
            CGFloat imageWidth = 20;
            TTImageView *imageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageWidth)];
            imageView.userInteractionEnabled = NO;
            imageView.backgroundColor = [UIColor clearColor];
            imageView.enableNightCover = NO;
            if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
                [imageView setImageWithURLString:model.day_icon_url];
            }
            else {
                [imageView setImageWithURLString:model.night_icon_url];
            }
            
            TTAlphaThemedButton *btn = [[TTAlphaThemedButton alloc] init];
            btn.top = 0;
            btn.left = left;
            btn.height = 44;
            btn.width = btnWidth;
            btn.tag = [self.listViewModel.tabModelArray indexOfObject:model];
            
            typeof(btn) __weak weakBtn = btn;
            WeakSelf;
            [btn addTarget:self withActionBlock:^{
                StrongSelf;
                if (!isEmptyString(model.schema)) {
                    NSString *schema = model.schema;
                    if ([model.text isEqualToString:@"提问"]) {
                        schema = [schema stringByAppendingString:@"&source=question_click_ask_question"];
                    }
                    [[TTRoute sharedRoute] openURLByViewController:[TTStringHelper URLWithURLString:schema] userInfo:nil];
                }
                [self sendTrackForBtn:weakBtn];
                
            } forControlEvent:UIControlEventTouchUpInside];
            
            [btn addSubview:label];
            [btn addSubview:imageView];
            
            imageView.left = (i == 0) ? 14 : 20;
            imageView.centerY = btn.height/2;
            label.left = imageView.right + 3;
            label.centerY = btn.height/2;
            
            [self.buttonList addObject:btn];
            [self addSubview:btn];
            
            left += btnWidth;
            btnWidth = self.width - btnWidth - btnWidth;
        }
    }
}

- (void)sendTrackForBtn:(TTAlphaThemedButton *)btn
{
    if (btn.tag >=0 && btn.tag < self.listViewModel.tabModelArray.count) {
        
        WDModuleStructModel *model = self.listViewModel.tabModelArray[btn.tag];

        if (model.icon_type == WDIconTypeCHANNEL) {
            
            [TTTracker ttTrackEventWithCustomKeys:@"channel_detail" label:@"enter_question_and_answer" value:self.listViewModel.qID source:nil extraDic:self.listViewModel.gdExtJson];
        }
        else if (model.icon_type == WDIconTypeQUESTION_POST) {
            
            [TTTracker ttTrackEventWithCustomKeys:@"question" label:@"click_ask_question" value:self.listViewModel.qID source:nil extraDic:self.listViewModel.gdExtJson];
        }
        else if (model.icon_type == WDIconTypeINVITED) {
            ttTrackEventWithCustomKeys(@"question", @"invite", nil, nil, self.listViewModel.gdExtJson);
        }
        
    }
}

- (TTAlphaThemedButton *)sendBtn
{
    if (!_sendBtn) {
        TTAlphaThemedButton *sendBtn = [[TTAlphaThemedButton alloc] init];
        sendBtn.width = ceilf(self.width / 3.0);
        sendBtn.height = 44;
        sendBtn.titleColorThemeKey = kColorText12;
        sendBtn.backgroundColorThemeKey = self.listViewModel.canAnswer ? kColorBackground7 : kColorBackground7Highlighted;
        NSString *title = self.listViewModel.canGetRedPacket ? @"回答得红包" : @"回答";
        [sendBtn setTitle:title forState:UIControlStateNormal];
        sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:WDFontSize(16)];
        WeakSelf;
        [sendBtn addTarget:self withActionBlock:^{
            StrongSelf;
            if (!self.listViewModel.canAnswer) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"问题关闭，请到合并后的问题回答" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                return;
            }

            NSString *schema = self.listViewModel.questionEntity.postAnswerSchema;
            if ([NSURL URLWithString:schema]) {
                schema = [schema stringByAppendingString:@"&source=question_click_write_answer"];
                [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:schema] userInfo:nil];
            }
            
            NSMutableDictionary *dict = [self.listViewModel.gdExtJson mutableCopy];
            [dict setValue:self.listViewModel.questionEntity.niceAnsCount forKey:@"ext_value"];
            [WDListViewModel trackEvent:kWDWendaListViewControllerUMEventName label:@"click_write_answer" gdExtJson:[dict copy]];
            
        } forControlEvent:UIControlEventTouchUpInside];
        _sendBtn = sendBtn;
    }
    
    return _sendBtn;
}

- (SSThemedView *)line
{
    if (!_line) {
        SSThemedView *line = [[SSThemedView alloc] init];
        line.height = [TTDeviceHelper ssOnePixel];
        line.width = self.width;
        line.top = 0;
        line.left = 0;
        line.backgroundColorThemeKey = kColorLine1;
        
        _line = line;
    }
    
    return _line;
}


@end
