//
//  FHFloorPanCorePermitCell.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/4/23.
//

#import "FHFloorPanCorePermitCell.h"
#import "TTBaseMacro.h"
#import "TTPhotoScrollViewController.h"

@interface FHFloorPanCorePermitCell()<TTPhotoScrollViewControllerDelegate>

@property (nonatomic , strong) UIView *containerView;
@property (nonatomic , strong) NSMutableArray *imageList;

@end

@implementation FHFloorPanCorePermitCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageList = [NSMutableArray new];
        [self.contentView addSubview:self.containerView];
        [self initConstraints];
    }
    return self;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.layer.cornerRadius = 10;
        _containerView.layer.masksToBounds = YES;
    }
    return _containerView;
}

-(void)initConstraints
{
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.bottom.mas_equalTo(0);
    }];
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHFloorPanCorePermitCellModel class]]) {
        CGFloat diff = 11.0 / 6;    //根据系统默认行高重新计算布局
        NSInteger imageIndex = 0;
        FHFloorPanCorePermitCellModel *model = (FHFloorPanCorePermitCellModel *)data;
        UIView *previouseView = nil;
        
        for (NSInteger i = 0; i < [model.list count]; i++) {
            UIView *itemContenView = [UIView new];
            itemContenView.backgroundColor = [UIColor clearColor];
            FHFloorPanCorePermitCellItemModel *itemModel = model.list[i];
            UILabel *nameLabel = [UILabel new];
            nameLabel.numberOfLines = 0;
            nameLabel.font = [UIFont themeFontRegular:14];
            nameLabel.textColor = RGB(0xae, 0xad, 0xad);
            nameLabel.text = itemModel.permitName;
            
            [itemContenView addSubview:nameLabel];
            
            [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(31);
                make.width.mas_equalTo(70);
                make.top.mas_equalTo(0);
            }];
            UILabel *valueLabel = [UILabel new];
            valueLabel.numberOfLines = 0;
            valueLabel.font = [UIFont themeFontMedium:14];
            valueLabel.textColor = [UIColor themeGray2];
            valueLabel.text = itemModel.permitValue;
            [itemContenView addSubview:valueLabel];
            
            [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(nameLabel.mas_right).offset(14);
                make.top.equalTo(nameLabel);
                make.right.equalTo(itemContenView).offset(-31);
                make.bottom.equalTo(itemContenView);
            }];
            
            if (i % 3 == 0 && itemModel.image.url.length > 0) {
                valueLabel.tag = imageIndex;
                imageIndex++;
                [self.imageList addObject:itemModel.image];
                valueLabel.textColor = [UIColor colorWithHexStr:@"ff9629"];
                valueLabel.userInteractionEnabled = YES;
                [valueLabel addGestureRecognizer:({
                      UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
                      gesture;
                })];
            }
            [self.contentView addSubview:itemContenView];
            
            [itemContenView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (previouseView) {
                    if (i % 3 == 0 && i >= 3) {
                        make.top.equalTo(previouseView.mas_bottom).offset(20 - diff * 2);
                    }
                    else {
                        make.top.equalTo(previouseView.mas_bottom).offset(18 - diff * 2);
                    }
                }else
                {
                    make.top.equalTo(self.contentView).offset(29 - diff);
                }
                if (i == [model.list count] - 1) {
                    make.bottom.equalTo(self.contentView).offset(-29 + diff);
                }
                make.left.right.equalTo(self.contentView);
            }];
            previouseView = itemContenView;
            if (i % 3 == 2 && i != [model.list count] - 1) {
                UIView *grayline = [[UIView alloc] init];
                grayline.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
                [self.contentView addSubview:grayline];
                [grayline mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(34);
                    make.right.mas_equalTo(-34);
                    make.height.mas_equalTo(0.5);
                    make.top.equalTo(previouseView.mas_bottom).offset(20);
                }];
                previouseView = grayline;
            }
        }
    }
}

- (void)click:(UITapGestureRecognizer *)gesture {
    __weak typeof(self) weakSelf = self;
    TTPhotoScrollViewController *vc = [[TTPhotoScrollViewController alloc] init];
    vc.dragToCloseDisabled = YES;
    vc.mode = PhotosScrollViewSupportDownloadMode;
    vc.startWithIndex = gesture.view.tag;
    
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:_imageList.count];
    for (FHDetailNewCoreDetailDataPermitListImageModel *image in _imageList) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setValue:image.uri forKey:kTTImageURIKey];
        [dict setValue:image.url forKey:TTImageInfosModelURL];
        [dict setValue:image.width forKey:kTTImageWidthKey];
        [dict setValue:image.height forKey:kTTImageHeightKey];
        NSMutableArray *urlList = [[NSMutableArray alloc] initWithCapacity:image.urlList.count];
        for (NSString *url in image.urlList) {
            if (!isEmptyString(url)) {
                [urlList addObject:@{TTImageInfosModelURL : url}];
            }
        }
        [dict setValue:urlList forKey:kTTImageURLListKey];
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:dict];
        model.imageType = TTImageTypeLarge;
        [models addObject:model];
    }
    vc.imageInfosModels = models;
    [vc setStartWithIndex:gesture.view.tag];
    UIImage *placeholder = [UIImage imageNamed:@"default_image"];
    NSMutableArray *placeholders = [[NSMutableArray alloc] initWithCapacity:_imageList.count];
    for (NSInteger i = 0 ; i < _imageList.count; i++) {
        [placeholders addObject:placeholder];
    }
    vc.placeholders = placeholders;
    [vc presentPhotoScrollView];
    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.imageList removeAllObjects];
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    [self.contentView addSubview:self.containerView];
    [self initConstraints];
}

@end

@implementation FHFloorPanCorePermitCellItemModel

@end

@implementation FHFloorPanCorePermitCellModel

@end
