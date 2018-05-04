//
//  MGCDayPlannerViewController.m
//  Graphical Calendars Library for iOS
//
//  Distributed under the MIT License
//  Get the latest version from here:
//
//	https://github.com/jumartin/Calendar
//
//  Copyright (c) 2014-2015 Julien Martin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "MGCDayPlannerViewController.h"
#import "MGCDateRange.h"
#import "MGCCalendarHeaderView.h"
#import "Constant.h"

@interface MGCDayPlannerViewController ()

@property (nonatomic, copy) NSDate *firstVisibleDayForRotation;

@end

@implementation MGCDayPlannerViewController

- (MGCDayPlannerView*)dayPlannerView
{
    return (MGCDayPlannerView*)self.view.subviews.lastObject;
}

- (CAGradientLayer *)applyGradient:(NSArray*)colours {
    
    NSArray *gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colours;
    gradientLayer.locations = gradientLocations;
    
    return gradientLayer;
}

- (void)setDayPlannerView:(MGCDayPlannerView*)dayPlannerView
{
//    [super setView:dayPlannerView];
//
//    if (!dayPlannerView.dataSource)
//        dayPlannerView.dataSource = self;
//
//    if (!dayPlannerView.delegate)
//        dayPlannerView.delegate = self;
    
    //Hoang Change modle of View
    UIView *view = [[UIView alloc] initWithFrame:(CGRectZero)];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = UIColor.whiteColor;
    [view addSubview:dayPlannerView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 100))];
    UIColor *topColor = [UIColor colorWithRed:38.0/255.0 green:201.0/255.0 blue:255.0/255.0 alpha:1];
    UIColor *bottomColor = [UIColor colorWithRed:35.0/255.0 green:180.0/255.0 blue:228.0/255.0 alpha:1];
    CAGradientLayer *backgroundLayer = [self applyGradient:[NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil]];
    backgroundLayer.frame = headerView.frame;
    headerView.backgroundColor = UIColor.grayColor;
    [headerView.layer insertSublayer:backgroundLayer atIndex:0];
    [view insertSubview:headerView belowSubview:dayPlannerView];
    
    _currentMonthLabel = [[UILabel alloc] init];
    [view insertSubview:_currentMonthLabel aboveSubview:headerView];
    
    [super setView:view];
    
    [headerView setTranslatesAutoresizingMaskIntoConstraints:false];
    [[headerView.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor constant:0] setActive:true];
    [[headerView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:0] setActive:true];
    [[headerView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:0] setActive:true];
    [[headerView.heightAnchor constraintEqualToConstant:100] setActive:true];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = self.formateDate ?: @"dd MMM YYYY, EEEE";
    NSString *sDay = [dateFormatter stringFromDate:[NSDate date]];
    _currentMonthLabel.text = [sDay uppercaseString];
    _currentMonthLabel.font = [UIFont fontWithName:@"Montserrat" size:15] ?: [UIFont boldSystemFontOfSize:15];
    _currentMonthLabel.textColor = UIColor.whiteColor;
    [_currentMonthLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_currentMonthLabel.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor constant:8] setActive:YES];
    [[_currentMonthLabel.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:58] setActive:YES];
    [[_currentMonthLabel.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:10] setActive:YES];
    
    [dayPlannerView setTranslatesAutoresizingMaskIntoConstraints:false];
    [[dayPlannerView.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor constant:30] setActive:true];
    [[dayPlannerView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:0] setActive:true];
    [[dayPlannerView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:0] setActive:true];
    [[dayPlannerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0] setActive:true];
    
    if (!dayPlannerView.dataSource)
    dayPlannerView.dataSource = self;
    
    if (!dayPlannerView.delegate)
    dayPlannerView.delegate = self;
}

#pragma mark - UIViewController

- (void)loadView
{
    //Hoang edit loadview
//    MGCDayPlannerView *dayPlannerView = [[MGCDayPlannerView alloc]initWithFrame:CGRectZero];
//    dayPlannerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
//    self.dayPlannerView = dayPlannerView;
//    self.dayPlannerView.autoresizesSubviews = YES;
    
    MGCDayPlannerView *dayPlannerView = [[MGCDayPlannerView alloc]initWithFrame:CGRectZero];
    dayPlannerView.backgroundColor = UIColor.clearColor;
    self.dayPlannerView = dayPlannerView;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if (!self.headerView && self.showsWeekHeaderView) {
        self.dayPlannerView.numberOfVisibleDays = 1;
        self.dayPlannerView.dayHeaderHeight = 70;
        self.dayPlannerView.visibleDays.start = [NSDate date];
        [self setupHeaderView];
    }
}

- (void)setupHeaderView{
    self.headerView = [[MGCCalendarHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.dayPlannerView.frame.size.width, self.dayPlannerView.dayHeaderHeight) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init] andDayPlannerView:self.dayPlannerView];
    
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [self.view addSubview:self.headerView];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        if (self.headerView) {
            //force to scroll to a correct position after rotation
            [self.headerView didMoveToSuperview];
        }
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MGCDayPlannerViewDataSource

- (NSInteger)dayPlannerView:(MGCDayPlannerView *)view numberOfEventsOfType:(MGCEventType)type atDate:(NSDate *)date
{
	return 0;
}

- (MGCEventView*)dayPlannerView:(MGCDayPlannerView*)view viewForEventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date
{
	NSLog(@"dayPlannerView:viewForEventOfType:atIndex:date: has to implemented in MGCDayPlannerViewController subclasses.");
	return nil;
}

- (MGCDateRange*)dayPlannerView:(MGCDayPlannerView*)view dateRangeForEventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date
{
	NSLog(@"dayPlannerView:dateRangeForEventOfType:atIndex:date: has to implemented in MGCDayPlannerViewController subclasses.");
	return nil;
}

#pragma mark - MGCDayPlannerViewDelegate

- (void)dayPlannerView:(MGCDayPlannerView*)view willStartMovingCellForEventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date
{
}

- (void)dayPlannerView:(MGCDayPlannerView*)view didMoveEventToDate:(NSDate*)date type:(MGCEventType)type
{
}

//when the user interacts with the bottom part move the header part
- (void)dayPlannerView:(MGCDayPlannerView*)view didEndScrolling:(MGCDayPlannerScrollType)scrollType
{
    [self.headerView selectDate:view.visibleDays.start];
}

@end
