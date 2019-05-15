//
//  TTVVideoDetailNatantInfoViewModel.h
//  Article
//
//  Created by lishuangyang on 2017/5/11.
//
//

#import <Foundation/Foundation.h>
#import "TTVVideoDetailNatantInfoModelProtocol.h"
#import "TTUGCAttributedLabel.h"

extern CGFloat kVideoTitleFontSize();
extern CGFloat kVideoTitleLineHeight();
@interface TTVVideoDetailNatantInfoViewModel : NSObject

@property (nonatomic, strong)id<TTVVideoDetailNatantInfoModelProtocol> infoModel;
@property (nonatomic, strong) NSString *watchCountStr;
@property (nonatomic, strong) NSString *title;    //标题
@property (nonatomic, strong) NSString *digTitle;
@property (nonatomic, strong) NSString *buryTitle;
@property (nonatomic, copy) NSAttributedString *attributeString;      //由publish和content和abstract合成

@property(nonatomic, strong) NSDictionary *contentLabelTextAttributs;
@property(nonatomic, strong) NSDictionary *contentLabelLinkAttributes;
@property(nonatomic, strong) NSDictionary *contentLabelActiveLinkAttributes;

@property (nonatomic, copy  ) NSAttributedString *titleLabelAttributedStr;  //富文本标题
@property (nonatomic, strong) NSArray<TTUGCAttributedLabelLink*>* titleLabelLinks; //存储着链接以及range


- (instancetype)initWithInfoModel:(id<TTVVideoDetailNatantInfoModelProtocol>) model;
- (void)logShowRecommentView:(NSArray *)models;  //发送recommentView 的tracker

- (BOOL)showExtendLink;  //返回infoView 是否加载ExtendButton
- (NSString *)uniqueID;  //唯一Id：groupId／adId
- (void)digAction;
- (void)buryAction;
- (void)cancelDiggAction;
- (void)cancelBurryAction;
- (void)linkTap:(NSURL*)linkURL UIView:(UIView *)sender;
- (void)updateAttributeTitle;

@end
