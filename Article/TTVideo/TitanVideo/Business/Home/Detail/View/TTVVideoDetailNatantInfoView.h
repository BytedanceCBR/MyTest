//
//  TTVVideoDetailInfoView.h
//  Article
//
//  Created by lishuangyang on 2017/5/17.
//
//

#import "SSThemed.h"
#import "TTVVideoDetailNatantInfoModel.h"
#import "TTVVideoDetailNatantInfoViewModel.h"
#import "TTVVideoInformationSyncProtocol.h"
#define kVideoDetailItemCommonEdgeMargin (([TTDeviceHelper isPadDevice]) ? 20 : 15)

@interface TTVideoAttributedLabel :TTUGCAttributedLabel

@end

/*协议用于外部吊起ExtendLink 和 父View布局*/
@protocol TTVVideoDetailNatantInfoViewDelegate <NSObject>

@optional
- (void)extendLinkButton:(UIButton *)button;
- (void)reLayOutSubViews:(BOOL) animation;

@end

@interface TTVVideoDetailNatantInfoView : SSThemedView

@property (nonatomic, strong)TTVVideoDetailNatantInfoViewModel * viewModel;
@property (nonatomic, assign) BOOL intensifyAuthor;    //与PGC一起进行布局
@property (nonatomic, assign) BOOL showShareView;    //是否展示shareview
@property (nonatomic, assign) BOOL showCardView;    //是否展示汽车卡片
@property (nonatomic, weak) id<TTVVideoDetailNatantInfoViewDelegate> delegate;
@property (nonatomic, weak) id<TTVVideoDetailToolbarActionProtocol> shareManager;
- (instancetype)initWithWidth:(CGFloat)width  andinfoModel:(TTVVideoDetailNatantInfoModel *)infoModel;
- (void)showBottomLine;
- (void)updateActionButtons;

@end
