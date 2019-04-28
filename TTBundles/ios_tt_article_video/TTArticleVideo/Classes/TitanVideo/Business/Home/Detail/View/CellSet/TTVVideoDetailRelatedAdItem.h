//
//  TTVVideoDetailRelatedAdItem.h
//  Article
//
//  Created by pei yun on 2017/5/25.
//
//

#import "TTVDetailRelatedTableViewItem.h"
#import "TTImageView.h"
#import "TTAdVideoRelateAdModel.h"
#import "TTVDetailRelatedADInfoDataProtocol.h"

@interface TTVVideoDetailRelatedAdItem : TTVDetailRelatedTableViewItem

@property (nonatomic, strong, nonnull) id<TTVDetailRelatedADInfoDataProtocol> relatedADInfo;

@end

@interface TTVVideoDetailRelatedAdCell : TTVDetailRelatedTableViewCell

@property(nonatomic, strong, nullable)SSThemedLabel *titleLabel;
@property(nonatomic, strong, nullable)TTImageView *picImageView;
@property(nonatomic, strong, nullable)UILabel *fromLabel;

@property(nonatomic, strong, nullable)SSThemedLabel *albumLogo;

@property (nonatomic, strong, nullable)SSThemedButton* actionButton;
@property (nonatomic, strong, nullable)SSThemedButton* downloadIcon;

@end
