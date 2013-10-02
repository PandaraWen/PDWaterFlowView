//
//  PDWaterFlowView.m
//  PDWaterFlowView
//
//  Created by pandara on 13-9-30.
//  Copyright (c) 2013年 pandara. All rights reserved.
//

#import "PDWaterFlowView.h"

#define PRELOAD_INSET 10
#define LIFT_HIGH 30 //上提加载更多的判定距离

@implementation PDWaterFlowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        _reuseQueue = [[NSMutableArray alloc] init];
        
//        _columnIndexs = [[NSMutableArray alloc] init];
        _allCellInfos = [[NSMutableArray alloc] init];
        
        _columns = [[NSMutableArray alloc] init];
        
        //下拉刷新水滴
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
//        _slimeView.upInset = 44;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor blackColor];
        _slimeView.slime.skinColor = [UIColor whiteColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor blackColor];
        
        [_scrollView addSubview:_slimeView];
        
        _juhuaView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return self;
}

//返回当前列到显示的cell为止的高度
- (CGFloat)getHeightForColumn:(int)column
{
    if ([[_columns objectAtIndex:column] count] == 0) {
        return 0;
    }
    
    PDWaterFlowView *lastCell = [[_columns objectAtIndex:column] lastObject];
    CGFloat height = lastCell.frame.origin.y + lastCell.frame.size.height;
    return height;
}

//根据到当前显示cell为止的colum高度
- (int)getShortestColumn
{
    int shortestColumn = 0;
    CGFloat shortestHeight = [self getHeightForColumn:0];
    
    for (int i = 1; i < [_columns count]; i++) {
        CGFloat columnHeight = [self getHeightForColumn:i];
        if (columnHeight < shortestHeight) {
            shortestHeight = columnHeight;
            shortestColumn = i;
        }
    }
    
    return shortestColumn;
}

//返回根据到当前显示cell为止的所有column的最小的高度
- (CGFloat)getShortestColumnHeight
{
    CGFloat shortestHeight = [self getHeightForColumn:0];
    
    for (int i = 1; i < [_columns count]; i++) {
        CGFloat columnHeight = [self getHeightForColumn:i];
        if (columnHeight < shortestHeight) {
            shortestHeight = columnHeight;
        }
    }
    
    return shortestHeight;
}

//判断是否应该向最短列添加cell
- (BOOL)shouldAddCell
{
    int shortestColumn = [self getShortestColumn];
    int lastCellIndexInColumn = [self getLastCellIndexInColumn:shortestColumn];
    //如果shortestColumn列显示的最后一个cell是应该显示cell的最后一个  返回no
    if (lastCellIndexInColumn + 1 >= [[_allCellInfos objectAtIndex:shortestColumn] count]) {
        return NO;
    }
    
    if ([self getShortestColumnHeight] < _scrollView.contentOffset.y + _scrollView.frame.size.height + PRELOAD_INSET) {
        return YES;
    }
    
    return NO;
}

//取最凹的列index
- (int)getSunkestColumn
{
    int sunkestColumn = 0;
    CGFloat sunkestY = [[[_columns objectAtIndex:0] objectAtIndex:0] frame].origin.y;
    for (int i = 1; i < [_columns count]; i++) {
        PDWaterFlowViewCell *cell = [[_columns objectAtIndex:i] objectAtIndex:0];
        if (cell.frame.origin.y > sunkestY) {
            sunkestY = cell.frame.origin.y;
            sunkestColumn = i;
        }
    }
    
    return sunkestColumn;
}

//取最凹列中当前显示的第一个cell的Y值
- (CGFloat)getSunkestY
{
    CGFloat sunkestY = 0;
    for (NSMutableArray *column in _columns) {
        PDWaterFlowViewCell *cell = [column objectAtIndex:0];
        if (cell.frame.origin.y > sunkestY) {
            sunkestY = cell.frame.origin.y;
        }
    }
    
    return sunkestY;
}

//取指定列中当前显示的最后一个cell在该列中的index
- (int)getLastCellIndexInColumn:(int)column
{
    if ([[_columns objectAtIndex:column] count] == 0) {
        return -1;
    }
    return [[[_columns objectAtIndex:column] lastObject] getIndexInColumn];
}

//取指定列中当前显示的第一个cell在该列中的index
- (int)getFirstCellIndexInColumn:(int)column
{
    return [[[_columns objectAtIndex:column] objectAtIndex:0] getIndexInColumn];
}

//判断是否应该向最凹列中load cell
- (BOOL)shouldLoadCell
{
    CGFloat sunkestY = [self getSunkestY];
    if (sunkestY == 0) {
        return NO;
    }
    
    if (sunkestY > _scrollView.contentOffset.y - PRELOAD_INSET) {
        return YES;
    }
    
    return NO;
}

//向指定列末尾添加cell
- (void)addCell:(PDWaterFlowViewCell *)cell toColumn:(int)column
{
    int cellIndexInColumn;
    if ([[_columns objectAtIndex:column] count] != 0) {
        cellIndexInColumn = [[[_columns objectAtIndex:column] lastObject] getIndexInColumn] + 1;
    } else {
        cellIndexInColumn = 0;
    }
    [cell setIndexInColumn:cellIndexInColumn];
    
    struct WaterFlowCellInfo cellInfo;
    [[[_allCellInfos objectAtIndex:column] objectAtIndex:cellIndexInColumn] getValue:&cellInfo];
    CGRect cellFrame = cellInfo.cellFrame;
    cell.frame = cellFrame;
    
    [_scrollView addSubview:cell];
    [[_columns objectAtIndex:column] addObject:cell];
    
    if (cell.delegate == nil) {
        cell.delegate = self;
    }
}

//向指定列首部添加cell
- (void)loadCell:(PDWaterFlowViewCell *)cell toColumn:(int)column
{
    int cellIndexInColumn = [[[_columns objectAtIndex:column] objectAtIndex:0] getIndexInColumn] - 1;
    [cell setIndexInColumn:cellIndexInColumn];
    
//    CGFloat firstCellY = [[[_columns objectAtIndex:column] objectAtIndex:0] frame].origin.y;
    
    struct WaterFlowCellInfo cellInfo;
    [[[_allCellInfos objectAtIndex:column] objectAtIndex:cellIndexInColumn] getValue:&cellInfo];
    cell.frame = cellInfo.cellFrame;
//    CGFloat columnWidth = self.frame.size.width / _columnNum;
//    CGRect cellFrame = cell.frame;
//    cellFrame.origin.x = column *columnWidth;
//    cellFrame.origin.y = firstCellY - cellFrame.size.height;
//    cellFrame.size.width = columnWidth;
//    cell.frame = cellFrame;
    
    [_scrollView addSubview:cell];
    [[_columns objectAtIndex:column] insertObject:cell atIndex:0];
    
    if (cell.delegate == nil) {
        cell.delegate = self;
    }
}

//初始化waterFlow的显示
- (void)setData
{
    if (self.delegate == nil) {
        return;
    }
    NSInteger cellNum = [self.delegate numberOfCellInWaterFlowView:self];
    _columnNum = [self.delegate numberOfColumnInWaterFlowView:self];
    CGFloat columnWidth = _scrollView.frame.size.width / _columnNum;
    
    for (int i = 0; i < _columnNum; i++) {
        NSMutableArray *everyColumn = [[NSMutableArray alloc] init];
        [_columns addObject:everyColumn];
        
//        NSMutableArray *columnIndexArray = [[NSMutableArray alloc] init];
//        [_columnIndexs addObject:columnIndexArray];
        NSMutableArray *everyColumnCellInfos = [[NSMutableArray alloc] init];
        [_allCellInfos addObject:everyColumnCellInfos];
    }
    
    if (_columnNum == 0) {
        return;
    }
    
    
    //根据cell的高度分配cell
    NSMutableArray *columnHeightArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < _columnNum; i++) {
        [columnHeightArray addObject:[NSNumber numberWithFloat:0]];
    }
    
    for (int i = 0; i < cellNum; i++) {
        int shortestColumn = 0;
        CGFloat shortestHeight = [[columnHeightArray objectAtIndex:0] floatValue];
        for (int j = 1; j < [columnHeightArray count]; j++) {
            if ([[columnHeightArray objectAtIndex:j] floatValue] < shortestHeight) {
                shortestHeight = [[columnHeightArray objectAtIndex:j] floatValue];
                shortestColumn = j;
            }
        }
        
        //设置cell的信息数组 allCellInfos
        CGFloat cellHeight = [self.delegate waterFlowView:self highForCellAtIndex:i];
        CGRect cellFrame = CGRectMake(shortestColumn * columnWidth, [[columnHeightArray objectAtIndex:shortestColumn] floatValue], columnWidth, cellHeight);
        struct WaterFlowCellInfo cellInfo = {cellFrame, i};
        NSValue *cellInfoValue = [NSValue valueWithBytes:&cellInfo objCType:@encode(struct WaterFlowCellInfo)];
        [[_allCellInfos objectAtIndex:shortestColumn] addObject:cellInfoValue];
        
        //保存每列高度
        CGFloat columnHeight = [[columnHeightArray objectAtIndex:shortestColumn] floatValue] + cellHeight;
        [columnHeightArray replaceObjectAtIndex:shortestColumn withObject:[NSNumber numberWithFloat:columnHeight]];
    }
    

    while ([self shouldAddCell]) {

        int shortestColumn = [self getShortestColumn];
        int addCellIndexInAll;
        
        //根据scrollView的contentOffset设置应该显示出来的cell
        //对于任意一列，即使没有cell应该显示，最后一个cell也应该放到正确位置，确保符合条件的情况下有cell的列有最少一个cell
        NSMutableArray *columnCellInfos = [_allCellInfos objectAtIndex:shortestColumn];
        if ([[_columns objectAtIndex:shortestColumn] count] == 0) {
            
            for (int i = 0; i < [columnCellInfos count]; i++) {
                
                struct WaterFlowCellInfo cellInfo;
                [[columnCellInfos objectAtIndex:i] getValue:&cellInfo];
                CGRect cellFrame = cellInfo.cellFrame;
                addCellIndexInAll = cellInfo.cellIndex;
                
                if (cellFrame.origin.y + cellFrame.size.height > _scrollView.contentOffset.y) {
                    break;
                }
            }
        } else {
            int addCellIndexInColumn = [self getLastCellIndexInColumn:shortestColumn] + 1;
            struct WaterFlowCellInfo cellInfo;
            [[columnCellInfos objectAtIndex:addCellIndexInColumn] getValue:&cellInfo];
            addCellIndexInAll = cellInfo.cellIndex;
        }
        
        PDWaterFlowViewCell *cell = [self.delegate waterFlowView:self cellForIndex:addCellIndexInAll];
        [cell setIndexInAll:addCellIndexInAll];
        [self addCell:cell toColumn:shortestColumn];
    }

    
    //根据最大的column高度设置scrollView高度
    CGFloat maxCellHeight = [[columnHeightArray objectAtIndex:0] floatValue];
    for (int i = 1; i < [columnHeightArray count]; i++) {
        if (maxCellHeight < [[columnHeightArray objectAtIndex:i] floatValue]) {
            maxCellHeight = [[columnHeightArray objectAtIndex:i] floatValue];
        }
    }
    CGFloat contentHeight = MAX(maxCellHeight, _scrollView.frame.size.height + 1);
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, contentHeight);
}

- (void)reloadData
{
    //取下所有cell放进重用队列
    for (NSMutableArray *column in _columns) {
        for (PDWaterFlowViewCell *cell in column) {
            [cell removeFromSuperview];
            [_reuseQueue addObject:cell];
        }
    }
    
    _columns = [[NSMutableArray alloc] init];
    //清除保留的cell信息
    _allCellInfos = [[NSMutableArray alloc] init];
    
    [self setData];
}

//从队列中返回可重用cell
- (PDWaterFlowViewCell *)dequeueReusableCellWithIdentifier:(NSString *)reuseID
{
    PDWaterFlowViewCell *cell;
    for (int i = 0; i < [_reuseQueue count]; i++) {
        cell = [_reuseQueue objectAtIndex:i];
        if ([cell.reuseID isEqualToString:reuseID]) {
            [_reuseQueue removeObject:cell];
            return cell;
        }
    }
    
    return nil;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self setData];
//    if (![_slimeView superview]) {
//        [_scrollView addSubview:_slimeView];
//    }
}

- (void)doneRefresh
{
    [_slimeView endRefresh];
}

- (void)doneLoadMore
{
    [_juhuaView stopAnimating];
    [_juhuaView removeFromSuperview];
    
    CGSize contentSize = _scrollView.contentSize;
    contentSize.height -= LIFT_HIGH;
    [UIView animateWithDuration:0.3f animations:^{
        _scrollView.contentSize = contentSize;
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_slimeView scrollViewDidScroll];
    
    //需要add新cell吗
    if ([self shouldAddCell]) {//可用while？
        int shortestColumn = [self getShortestColumn];
        int cellInfoIndex = [self getLastCellIndexInColumn:shortestColumn] + 1;
        struct WaterFlowCellInfo cellInfo;
        [[[_allCellInfos objectAtIndex:shortestColumn] objectAtIndex:cellInfoIndex] getValue:&cellInfo];
        
        PDWaterFlowViewCell *cell = [self.delegate waterFlowView:self cellForIndex:cellInfo.cellIndex];
        [cell setIndexInAll:cellInfo.cellIndex];
        [self addCell:cell toColumn:shortestColumn];
//        NSLog(@"add 了一个新cell：%d", _currentIndexInTotal);
    }
    
    //需要load旧cell吗
    if ([self shouldLoadCell]) {
        int sunkestColumn = [self getSunkestColumn];
        PDWaterFlowViewCell *firstCell = [[_columns objectAtIndex:sunkestColumn] objectAtIndex:0];
        int cellInfoIndex = [firstCell getIndexInColumn] - 1;
        
        if (cellInfoIndex >= 0) {//会否为假？
            struct WaterFlowCellInfo cellInfo;
            [[[_allCellInfos objectAtIndex:sunkestColumn] objectAtIndex:cellInfoIndex] getValue:&cellInfo];
            PDWaterFlowViewCell *cell = [self.delegate waterFlowView:self cellForIndex:cellInfo.cellIndex];
            [cell setIndexInAll:cellInfo.cellIndex];
            [self loadCell:cell toColumn:sunkestColumn];
//            NSLog(@"load 了一个旧cell:%d", loadCellIndex);
        }
    }
    
    //收集可重用的cell 检查首尾两个cell，不可见则收集
    for (NSMutableArray *column in _columns) {
        if ([column count] == 1) {
            continue;
        }
        PDWaterFlowViewCell *cell = [column objectAtIndex:0];
        if (cell.frame.origin.y + cell.frame.size.height < _scrollView.contentOffset.y - PRELOAD_INSET) {
            [cell removeFromSuperview];
            [column removeObject:cell];
            [_reuseQueue addObject:cell];
            
        }
        
        if ([column count] == 1) {
            continue;
        }
        cell = [column lastObject];
        if (cell.frame.origin.y > _scrollView.contentOffset.y + _scrollView.frame.size.height + PRELOAD_INSET) {
            [cell removeFromSuperview];
            [column removeObject:cell];
            [_reuseQueue addObject:cell];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_slimeView scrollViewDidEndDraging];
    
    if (decelerate) {
        //上提加载更多
        if ((_scrollView.contentOffset.y + _scrollView.frame.size.height) - _scrollView.contentSize.height > LIFT_HIGH) {
            CGRect juhuaFrame = _juhuaView.frame;
            juhuaFrame.origin.x = (_scrollView.frame.size.width - juhuaFrame.size.width)/2;
            juhuaFrame.origin.y = _scrollView.contentSize.height + 5;
            _juhuaView.frame = juhuaFrame;
            [_juhuaView startAnimating];
            [_scrollView addSubview:_juhuaView];
            
            CGSize contentSize = _scrollView.contentSize;
            contentSize.height += LIFT_HIGH;
            [UIView animateWithDuration:0.3f animations:^{
                _scrollView.contentSize = contentSize;
            }];
            
            if ([self.delegate respondsToSelector:@selector(waterFlowViewLiftToLoadMore:)]) {
                [self.delegate waterFlowViewLiftToLoadMore:self];
            }
        }
    }
}

#pragma mark - PDWaterFlowViewCellDelegate
- (void)selectCellWithCellIndex:(NSInteger)cellIndex
{
    if ([self.delegate respondsToSelector:@selector(waterFlowView:didSelectCellAtIndex:)]) {
        [self.delegate waterFlowView:self didSelectCellAtIndex:cellIndex];
    }
}

#pragma mark - SRRefreshDelegate
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    if ([self.delegate respondsToSelector:@selector(waterFlowViewPullToRefresh:)]) {
        [self.delegate waterFlowViewPullToRefresh:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
