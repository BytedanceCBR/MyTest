//
//  TTlayoutLoopInnerPicView.m
//  Article
//
//  Created by 曹清然 on 2017/6/20.
//
//

#import "TTlayoutLoopInnerPicView.h"
#import "TTBusinessManager.h"
#import "TTLayoutLoopPicCollectionViewCell.h"
#import "Article.h"
#import "ExploreArticleCellViewConsts.h"
#import "SSADEventTracker.h"

@interface TTlayoutLoopInnerPicView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>

@property (nonatomic,strong) UICollectionView *loopCollectionView;

@property (nonatomic,assign) CGSize perPicItemSize;

@property (nonatomic,strong) ExploreOrderedData *orderdata;

@property (nonatomic, strong) NSArray *picModels;

@property (nonatomic,weak)ExploreCellBase *baseCell;

@property (nonatomic,weak)UITableView *tableView;

@property (nonatomic,strong)NSMutableDictionary *imageShowStatusDic;

@end

@implementation TTlayoutLoopInnerPicView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.picModels = nil;
        self.orderdata = nil;
        self.perPicItemSize = CGSizeZero;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.itemSize = CGSizeZero;
        flowLayout.headerReferenceSize = CGSizeMake(kCellLeftPadding, 0);
        flowLayout.footerReferenceSize = CGSizeMake(kCellRightPadding, 0);
        _loopCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _loopCollectionView.pagingEnabled = NO;
        _loopCollectionView.bounces = YES;
        _loopCollectionView.showsHorizontalScrollIndicator = NO;
        _loopCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        _loopCollectionView.delegate = self;
//        _loopCollectionView.dataSource = self;
        _loopCollectionView.scrollsToTop = NO;
        [_loopCollectionView registerClass:[TTLayoutLoopPicCollectionViewCell class] forCellWithReuseIdentifier:@"TTLayoutLoopPicCollectionViewCell"];
        [_loopCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        
        self.backgroundColor = [UIColor clearColor];
        _loopCollectionView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_loopCollectionView];
        self.imageShowStatusDic = nil;
    }
    
    return self;
    
}



-(void)updatePicViewWithData:(ExploreOrderedData *)orderData WithPerPicSize:(CGSize)perPicSize WithbaseCell:(ExploreCellBase *)baseCell WithTabelView:(UITableView *)tableView{
    
    if (!orderData) {
        return;
    }
    Article *article = [orderData article];
    if (!article) {
        return;
    }
    
    NSArray *pics = article.listGroupImgDicts;
    
    NSMutableArray *innerPicModels = [[NSMutableArray alloc] init];
    [pics enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj && [obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *picDic = (NSDictionary *)obj;
            TTImageInfosModel *pic = [[TTImageInfosModel alloc] initWithDictionary:picDic];
            if (pic) {
                [innerPicModels addObject:pic];
            }
            
        }
    }];
    
    self.picModels = [innerPicModels copy];
    self.perPicItemSize = perPicSize;
    self.orderdata = orderData;
    
    NSMutableDictionary *picShowStatusDic = [[NSMutableDictionary alloc] init];
    for (NSInteger i = 0; i < self.picModels.count; i++) {
        NSString *index = [NSString stringWithFormat:@"%@",@(i)];
        [picShowStatusDic setValue:@(0) forKey:index];
    }
    
    if (!SSIsEmptyDictionary(picShowStatusDic)) {
        self.imageShowStatusDic = [picShowStatusDic mutableCopy];
    }
    
    self.baseCell = baseCell;
    self.tableView = tableView;
    
    self.loopCollectionView.delegate = self;
    self.loopCollectionView.dataSource = self;
    
    [self.loopCollectionView reloadData];
    self.loopCollectionView.contentOffset = self.orderdata.PicCollecionViewOffset;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (hidden) {
        self.loopCollectionView.delegate = nil;
        self.loopCollectionView.dataSource = nil;
    } else {
        self.loopCollectionView.delegate = self;
        self.loopCollectionView.dataSource = self;
    }
}

#pragma mark --  datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (!SSIsEmptyArray(self.picModels)) {
        return [self.picModels count];
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < self.picModels.count) {
        
        TTImageInfosModel *picModel = [self.picModels objectAtIndex:indexPath.row];
        if (picModel && [picModel isKindOfClass:[TTImageInfosModel class]]) {
            
            TTLayoutLoopPicCollectionViewCell *picCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTLayoutLoopPicCollectionViewCell" forIndexPath:indexPath];
            
            if (picCell) {
                [picCell configureWithModel:picModel];
                return picCell;
            }
        }
    }
    
    
    
    UICollectionViewCell *errorCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    
    errorCell = errorCell ? errorCell : [[UICollectionViewCell alloc] init];
    
    return errorCell;
}

#pragma mark --  flowlayout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.perPicItemSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return KCellLoopPicInnerPadding;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(kCellLeftPadding, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(kCellRightPadding, 0);
}

#pragma mark --  delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < self.picModels.count) {
        
        if (self.tableView && self.baseCell && self.tableView.delegate) {
            
            NSIndexPath *baseCellIndexPath = [self.tableView indexPathForCell:self.baseCell];
            if (baseCellIndexPath) {
                
                [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:baseCellIndexPath];
                
                
                NSMutableDictionary *extraData = [NSMutableDictionary dictionary];
                
                NSMutableDictionary *indexInfo = [NSMutableDictionary dictionary];
                [indexInfo setValue:@(indexPath.row + 1) forKey:@"image_position"];
                
                NSError *error;
                NSData *data = [NSJSONSerialization dataWithJSONObject:indexInfo options:0 error:&error];
                NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                extraData[@"ad_extra_data"] = json;
                
                 [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderdata label:@"click_image" eventName:@"embeded_ad" extra:extraData duration:0];
            }
            
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath && indexPath.row < self.picModels.count) {
        
        if (self.orderdata) {
            
            NSString *indexString = [NSString stringWithFormat:@"%@",@(indexPath.row)];
            if(!isEmptyString(indexString)){
                
                id picShowStatus = [self.imageShowStatusDic objectForKey:indexString];
                if(picShowStatus && [picShowStatus respondsToSelector:@selector(integerValue)] && [picShowStatus integerValue] == 0){
                    NSMutableDictionary *extraData = [NSMutableDictionary dictionary];
                    
                    NSMutableDictionary *indexInfo = [NSMutableDictionary dictionary];
                    [indexInfo setValue:@(indexPath.row + 1) forKey:@"image_position"];
                    
                    NSError *error;
                    NSData *data = [NSJSONSerialization dataWithJSONObject:indexInfo options:0 error:&error];
                    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    extraData[@"ad_extra_data"] = json;
                    CGRect videoRect = [self.baseCell convertRect:self.frame toView:[UIApplication sharedApplication].keyWindow];
                    if (CGRectContainsRect(self.tableView.frame, videoRect)) {
                        [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderdata label:@"image_show" eventName:@"embeded_ad" extra:extraData duration:0];
                    }
                    
                }
                
                [self.imageShowStatusDic setValue:@(1) forKey:indexString];
            }
            
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    

}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    self.orderdata.PicCollecionViewOffset = scrollView.contentOffset;
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (!decelerate) {
         self.orderdata.PicCollecionViewOffset = scrollView.contentOffset;
    }
    
}


@end
