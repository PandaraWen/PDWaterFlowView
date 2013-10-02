//
//  ViewController.m
//  PDWaterFlowView
//
//  Created by pandara on 13-9-30.
//  Copyright (c) 2013年 pandara. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

#define CELL_COUNT 50

@interface ViewController () {
    PDWaterFlowView *_waterFlowView;
    int cellCount;
}
@property (strong, nonatomic) NSMutableArray *cellHeightArray;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    cellCount = 20;
	// Do any additional setup after loading the view, typically from a nib.
    _waterFlowView = [[PDWaterFlowView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _waterFlowView.delegate = self;
    _waterFlowView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_waterFlowView];
    
    self.cellHeightArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < CELL_COUNT; i++) {
        int height = arc4random() % 10 * 100;
        while (height == 0) {
            height = arc4random() % 10 * 100;
        }
        [self.cellHeightArray addObject:[NSNumber numberWithInt:height]];
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    button.backgroundColor = [UIColor yellowColor];
    [button addTarget:self action:@selector(pressButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)pressButton
{
    cellCount = CELL_COUNT;
    [_waterFlowView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PDWaterFlowViewDelegate
- (NSInteger)numberOfCellInWaterFlowView:(PDWaterFlowView *)waterFlowView
{
    return cellCount;
}

- (NSInteger)numberOfColumnInWaterFlowView:(PDWaterFlowView *)waterFlowView
{
    return 5;
}

- (CGFloat)waterFlowView:(PDWaterFlowView *)waterFlowView highForCellAtIndex:(NSInteger)cellIndex
{
    return [[_cellHeightArray objectAtIndex:cellIndex] floatValue];
}

- (PDWaterFlowViewCell *)waterFlowView:(PDWaterFlowView *)waterFlowView cellForIndex:(NSInteger)cellIndex
{
    PDWaterFlowViewCell *cell = [waterFlowView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[PDWaterFlowViewCell alloc] initWithReuseID:@"cell"];
        cell.layer.borderColor = [UIColor blackColor].CGColor;
        cell.layer.borderWidth = 2.0f;
        NSLog(@"初始化");
    } else {
        NSLog(@"重用");
    }
    
    CGFloat cellHeight = [[self.cellHeightArray objectAtIndex:cellIndex] intValue];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    label.backgroundColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"%d %d", cellIndex, (int)(cellHeight)];
    [cell addSubview:label];
    return cell;
}

- (void)waterFlowView:(PDWaterFlowView *)waterFlowView didSelectCellAtIndex:(NSInteger)cellIndex
{
    NSLog(@"%d", cellIndex);
}

- (void)waterFlowViewPullToRefresh:(PDWaterFlowView *)waterFlowView
{
    [waterFlowView doneRefresh];
}

- (void)waterFlowViewLiftToLoadMore:(PDWaterFlowView *)waterFlowView
{
    [waterFlowView doneLoadMore];
}

@end
