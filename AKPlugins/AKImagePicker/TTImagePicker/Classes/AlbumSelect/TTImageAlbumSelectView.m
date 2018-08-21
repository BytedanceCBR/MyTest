//
//  TTImageAlbumSelectView.m
//  Article
//
//  Created by xuzichao on 2017/4/11.
//
//

#import "TTImageAlbumSelectView.h"
#import "TTImagePickerDefineHead.h"
#import "TTAlbumModel.h"
#import "TTImagePickerManager.h"
#import "UIViewAdditions.h"

#pragma mark --  内部cell

NSString * const TTImageAlbumSelectTableCellKey = @"TTImageAlbumSelectTableCell";

@interface TTImageAlbumSelectTableCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imagePreview;
@property (nonatomic, strong) UIImageView *selectedHook;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) TTAlbumModel *model;
@property (nonatomic, weak)TTImageAlbumSelectView *fatherView;


@end

@implementation TTImageAlbumSelectTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
   self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        
        self.imagePreview = [[UIImageView alloc] init];
        self.imagePreview.width = TTPadding(57);
        self.imagePreview.height = TTPadding(57);
        self.imagePreview.image = [UIImage imageNamed:@"ImgPic_Camera_Icon"];
        self.imagePreview.contentMode = UIViewContentModeScaleAspectFill;
        self.imagePreview.clipsToBounds = YES;
        self.imagePreview.layer.borderWidth  = [TTDeviceHelper ssOnePixel];
        self.imagePreview.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
        [self addSubview:self.imagePreview];
        
        self.selectedHook = [[SSThemedImageView alloc] init];
        self.selectedHook.width = TTPadding(24);
        self.selectedHook.height = TTPadding(24);
        self.selectedHook.image = [UIImage imageNamed:@"ImgPic_current"];
        self.selectedHook.hidden = YES;
        self.selectedHook.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.selectedHook];
        
        self.nameLabel = [[SSThemedLabel alloc] init];
        self.nameLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        self.nameLabel.font = TTFont(17);
        [self addSubview:self.nameLabel];
        
        self.countLabel = [[SSThemedLabel alloc] init];
        self.countLabel.textColor =  [UIColor tt_themedColorForKey:kColorText1];
        self.countLabel.font = TTFont(14);
        [self addSubview:self.countLabel];
        
        UITapGestureRecognizer *contentViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(albumAction)];
        [self.contentView addGestureRecognizer:contentViewTap];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([TTDeviceHelper isPadDevice]) {
        [self refreshUI];
    }
    
}

- (void)albumAction
{
    [self.fatherView didSelectItemWithCell:self];

}

- (void)refreshUI
{
    self.imagePreview.left = TTPadding(10);
    self.imagePreview.centerY = self.height/2;
    
    self.nameLabel.left = self.imagePreview.right + TTPadding(15);
    self.nameLabel.top = self.imagePreview.top + TTPadding(8);
    
    self.countLabel.left = self.imagePreview.right + TTPadding(15);
    self.countLabel.top = self.nameLabel.bottom + TTPadding(10);
    
    self.selectedHook.right = self.width - TTPadding(10);
    self.selectedHook.centerY = self.height/2;
}

- (void)refresData:(TTAlbumModel *)model
{
    self.model = model;
    
    TTAssetModel *assetModel = self.model.models.count > 0 ? self.model.models.firstObject : nil;
    if (assetModel) {
        [[TTImagePickerManager manager] getPhotoWithAsset:assetModel.asset photoWidth:self.imagePreview.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded){
            self.imagePreview.image = photo;
        } progressHandler:nil ];
    }
    
    self.nameLabel.text = model.name;
    [self.nameLabel sizeToFit];
    self.nameLabel.height = TTFontSize(17);
    
    self.countLabel.text = [NSString stringWithFormat:@"%@",@(model.count)];
    [self.countLabel sizeToFit];
    self.countLabel.height = TTFontSize(14);
    

    
    [self refreshUI];
}


@end


#pragma mark --  TTImageAlbumSelectView

@interface TTImageAlbumSelectView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong)NSIndexPath *lastIndex;
@property (nonatomic, assign) BOOL isShow;

@end

@implementation TTImageAlbumSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lastIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        [self _initViews];
    }
    return self;
}


- (void)_initViews
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - 152) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    [self addSubview:self.tableView];
    [self.tableView registerClass:[TTImageAlbumSelectTableCell class] forCellReuseIdentifier:TTImageAlbumSelectTableCellKey];

    self.maskView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height - 152, self.width, 152)];
    [self addSubview:self.maskView];
    
}

- (void)showAlbum
{
    self.isShow = YES;
    self.hidden = NO;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.tableView.height = 1;
    
    [UIView animateWithDuration:.35 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:1 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.tableView.height = self.height - 152;

    } completion:^(BOOL finished) {
        if (self.isShow) {
            self.hidden = NO;
        }else{
            self.hidden = YES;
        }
       
        
    }];
    
    [UIView animateWithDuration:.35 animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    }];
    
    if (self.lastIndex.row != 0) {
        [self.tableView scrollToRowAtIndexPath:self.lastIndex atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
   
}


- (void)hideAlbum
{
    self.isShow = NO;

    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    
    [UIView animateWithDuration:.25 animations:^{
        self.tableView.height = 1;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    } completion:^(BOOL finished) {
        if (self.isShow) {
            self.hidden = NO;
        }else{
            self.hidden = YES;
        }
    }];
    
}


- (void)setModels:(NSArray<TTAlbumModel *> *)models
{
    _models = models;
    [self.tableView reloadData];
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.models.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTImageAlbumSelectTableCell *cell = [tableView dequeueReusableCellWithIdentifier:TTImageAlbumSelectTableCellKey forIndexPath:indexPath];
    cell.fatherView = self;
    if (indexPath.row == self.lastIndex.row) {
        cell.selectedHook.hidden = NO;
    }else{
        cell.selectedHook.hidden = YES;
    }
    [cell refresData:self.models[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (indexPath.row == self.lastIndex.row) {
//        return;
//    }
//    if (self.delegate && [self.delegate respondsToSelector:@selector(ttImageAlbumSelectViewDidSelect:)]) {
//        [self.delegate ttImageAlbumSelectViewDidSelect:self.models[indexPath.row]];
//    }
//    TTImageAlbumSelectTableCell *lastCell = [tableView cellForRowAtIndexPath:self.lastIndex];
//    lastCell.selectedHook.hidden = YES;
//    
//    TTImageAlbumSelectTableCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
//    currentCell.selectedHook.hidden = NO;
//
//    self.lastIndex = indexPath;
//}


//so trick
- (void)didSelectItemWithCell:(UICollectionViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (indexPath.row == self.lastIndex.row) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttImageAlbumSelectViewDidSelect:)]) {
        [self.delegate ttImageAlbumSelectViewDidSelect:self.models[indexPath.row]];
    }
    TTImageAlbumSelectTableCell *lastCell = [_tableView cellForRowAtIndexPath:self.lastIndex];
    lastCell.selectedHook.hidden = YES;
    
    TTImageAlbumSelectTableCell *currentCell = [_tableView cellForRowAtIndexPath:indexPath];
    currentCell.selectedHook.hidden = NO;
    
    self.lastIndex = indexPath;
}




@end
