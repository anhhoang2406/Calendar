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
@property (nonatomic) UIView *headerViewBG;

@end

@implementation MGCDayPlannerViewController

- (MGCDayPlannerView*)dayPlannerView
{
    for (UIView *i in self.view.subviews){
        if([i isKindOfClass:[MGCDayPlannerView class]]){
            return i;
        }
    }
    return [[MGCDayPlannerView alloc]initWithFrame:CGRectZero];;
}

- (CAGradientLayer *)applyGradient:(NSArray*)colours {
    
    NSArray *gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colours;
    gradientLayer.locations = gradientLocations;
    
    return gradientLayer;
}

- (void) updateHeaderView: (CGFloat)width {
    if (_headerViewBG != NULL) {
        for (CALayer* layer in _headerViewBG.layer.sublayers) {
            if ([layer isKindOfClass:CAGradientLayer.class]) {
                layer.frame = _headerViewBG.frame;
                [self updateFocusIfNeeded];
                return;
            }
        }
        UIColor *topColor = [UIColor colorWithRed:38.0/255.0 green:201.0/255.0 blue:255.0/255.0 alpha:1];
        UIColor *bottomColor = [UIColor colorWithRed:35.0/255.0 green:180.0/255.0 blue:228.0/255.0 alpha:1];
        CAGradientLayer *backgroundLayer = [self applyGradient:[NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil]];
        backgroundLayer.frame = _headerView.frame;
        _headerViewBG.backgroundColor = UIColor.grayColor;
        [_headerViewBG.layer insertSublayer:backgroundLayer atIndex:0];
    }
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
    
    _headerViewBG = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 100))];
    UIColor *topColor = [UIColor colorWithRed:38.0/255.0 green:201.0/255.0 blue:255.0/255.0 alpha:1];
    UIColor *bottomColor = [UIColor colorWithRed:35.0/255.0 green:180.0/255.0 blue:228.0/255.0 alpha:1];
    CAGradientLayer *backgroundLayer = [self applyGradient:[NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil]];
    backgroundLayer.frame = _headerViewBG.frame;
    _headerViewBG.backgroundColor = UIColor.grayColor;
    [_headerViewBG.layer insertSublayer:backgroundLayer atIndex:0];
    [view insertSubview:_headerViewBG belowSubview:dayPlannerView];
    
    _currentMonthLabel = [[UILabel alloc] init];
    UIButton *nextButton = [[UIButton alloc] init];
    UIButton *prevButton = [[UIButton alloc] init];
    [nextButton setImage:[[UIImage imageNamed:@"arrow-next"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [prevButton setImage:[[UIImage imageNamed:@"arrow-prev"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    nextButton.tintColor = UIColor.whiteColor;
    prevButton.tintColor = UIColor.whiteColor;
    [view insertSubview:_currentMonthLabel aboveSubview:dayPlannerView];
    [view insertSubview:nextButton aboveSubview:dayPlannerView];
    [view insertSubview:prevButton aboveSubview:dayPlannerView];
    [nextButton addTarget:self action:@selector(actionPressNextPage) forControlEvents:UIControlEventTouchUpInside];
    [prevButton addTarget:self action:@selector(actionPressPrevPage) forControlEvents:UIControlEventTouchUpInside];
    
    [super setView:view];
    
    [_headerViewBG setTranslatesAutoresizingMaskIntoConstraints:false];
    [[_headerViewBG.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor constant:0] setActive:true];
    [[_headerViewBG.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:0] setActive:true];
    [[_headerViewBG.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:0] setActive:true];
    [[_headerViewBG.heightAnchor constraintEqualToConstant:100] setActive:true];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSArray *arrLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *lang = @"";
    if (arrLang.firstObject != nil) {
        lang = arrLang.firstObject;
    }
    if ([lang isEqualToString:@"ja"]) {
        dateFormatter.dateFormat = self.formateDate ?: @"yyyy年MM月d日";
    } else {
        dateFormatter.dateFormat = self.formateDate ?: @"dd MMM yyyy, EEEE";
    }
    
    NSString *sDay = [dateFormatter stringFromDate:[NSDate date]];
    _currentMonthLabel.numberOfLines = 2;
    _currentMonthLabel.textAlignment = NSTextAlignmentCenter;
    _currentMonthLabel.text = [sDay uppercaseString];
    _currentMonthLabel.font = [UIFont fontWithName:@"Montserrat" size:20] ?: [UIFont boldSystemFontOfSize:20];
    _currentMonthLabel.textColor = UIColor.whiteColor;
    [_currentMonthLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_currentMonthLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:8] setActive:YES];
    [[_currentMonthLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0] setActive:YES];
    [nextButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[nextButton.leftAnchor constraintEqualToAnchor:_currentMonthLabel.rightAnchor constant:15] setActive:YES];
    [[nextButton.topAnchor constraintEqualToAnchor:_currentMonthLabel.topAnchor constant:0] setActive:YES];
    [[nextButton.bottomAnchor constraintEqualToAnchor:_currentMonthLabel.bottomAnchor constant:0] setActive:YES];
    [[nextButton.widthAnchor constraintEqualToConstant:30] setActive:YES];
    [prevButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[prevButton.rightAnchor constraintEqualToAnchor:_currentMonthLabel.leftAnchor constant:-15] setActive:YES];
    [[prevButton.topAnchor constraintEqualToAnchor:_currentMonthLabel.topAnchor constant:0] setActive:YES];
    [[prevButton.widthAnchor constraintEqualToConstant:30] setActive:YES];
    [[prevButton.bottomAnchor constraintEqualToAnchor:_currentMonthLabel.bottomAnchor constant:0] setActive:YES];
    
    
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
    [self updateCurrentMonth:view];
}

- (void)dayPlannerView:(MGCDayPlannerView *)view didScroll:(MGCDayPlannerScrollType)scrollType {
    
}

- (void) updateCurrentMonth:(MGCDayPlannerView *)view {
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [NSDateFormatter new];
    }
    NSDate *startDate = [[view visibleDays] start];
    NSDateComponents* comps = [NSDateComponents new];
    comps.day = 1;
    NSDate *endDate = [startDate dateByAddingTimeInterval:6*24*60*60];
    
    NSArray *arrLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *lang = @"";
    if (arrLang.firstObject != nil) {
        lang = arrLang.firstObject;
    }
    if (_isShowWeekOfDate) {
        if ([lang isEqualToString:@"ja"]) {
            dateFormatter.dateFormat = @"MM";
        } else {
            dateFormatter.dateFormat = @"MMM";
        }
        NSString *strStartMonth = [dateFormatter stringFromDate:startDate];
        NSString *strEndMonth = [dateFormatter stringFromDate:endDate];
        dateFormatter.dateFormat = @"d";
        NSString *strStartday = [dateFormatter stringFromDate:startDate];
        NSString *strEndDay = [dateFormatter stringFromDate:endDate];
        dateFormatter.dateFormat = @"yyyy";
        NSString *strStartYear = [dateFormatter stringFromDate:startDate];
        NSString *strEndYear = [dateFormatter stringFromDate:endDate];
        
        if ([strStartYear isEqualToString:strEndYear]) {
            if ([strStartMonth isEqualToString:strEndMonth]) {
                if ([lang isEqualToString:@"ja"]) {
                    _currentMonthLabel.text = [NSString stringWithFormat:@"%@年%@月%@日～%@日", strStartYear, strStartMonth, strStartday, strEndDay];
                } else {
                    _currentMonthLabel.text = [NSString stringWithFormat:@"%@ %@ - %@, %@", strStartMonth, strStartday, strEndDay, strStartYear];
                }
            } else {
                if ([lang isEqualToString:@"ja"]) {
                    _currentMonthLabel.text = [NSString stringWithFormat:@"%@年%@月%@日～%@月%@日", strStartYear, strStartMonth, strStartday, strEndMonth, strEndDay];
                } else {
                    _currentMonthLabel.text = [NSString stringWithFormat:@"%@ %@ - %@ %@, %@", strStartMonth, strStartday, strEndMonth, strEndDay, strStartYear];
                }
            }
        } else {
            if ([lang isEqualToString:@"ja"]) {
                _currentMonthLabel.text = [NSString stringWithFormat:@"%@年%@月%@日～%@年%@月%@日", strStartYear, strStartMonth, strStartday, strEndYear, strEndMonth, strEndDay];
            } else {
                _currentMonthLabel.text = [NSString stringWithFormat:@"%@ %@ %@ - %@ %@ %@", strStartYear, strStartMonth, strStartday, strEndYear, strEndMonth, strEndDay];
            }
        }
        
    } else {
        for (NSLayoutConstraint *cons in self.view.constraints) {
            if (cons.firstAttribute == NSLayoutAttributeTop && cons.firstItem == _currentMonthLabel) {
                cons.constant = 30;
            }
        }
        if ([lang isEqualToString:@"ja"]) {
            dateFormatter.dateFormat = @"yyyy年MM月d日";
        } else {
            dateFormatter.dateFormat = @"MMM d, yyyy";
        }
        NSString *strDate = [dateFormatter stringFromDate:startDate];
        dateFormatter.dateFormat = @"EEE";
        NSString *strDayOfWeed = [dateFormatter stringFromDate:startDate];
        if ([lang isEqualToString:@"ja"]) {
            if ([[strDayOfWeed lowercaseString] isEqualToString:@"mon"]) {
                strDayOfWeed = @"月";
            } else if ([[strDayOfWeed lowercaseString] isEqualToString:@"tue"]) {
                strDayOfWeed = @"火";
            } else if ([[strDayOfWeed lowercaseString] isEqualToString:@"wed"]) {
                strDayOfWeed = @"水";
            } else if ([[strDayOfWeed lowercaseString] isEqualToString:@"thu"]) {
                strDayOfWeed = @"木";
            } else if ([[strDayOfWeed lowercaseString] isEqualToString:@"fri"]) {
                strDayOfWeed = @"金";
            } else if ([[strDayOfWeed lowercaseString] isEqualToString:@"sat"]) {
                strDayOfWeed = @"土";
            } else if ([[strDayOfWeed lowercaseString] isEqualToString:@"sun"]) {
                strDayOfWeed = @"日";
            }
        } else {
            dateFormatter.dateFormat = @"EEEE";
            strDayOfWeed = [dateFormatter stringFromDate:startDate];
        }
        NSString *str = [NSString stringWithFormat:@"%@\n%@", strDate, strDayOfWeed];
        NSDictionary *attribs = @{NSForegroundColorAttributeName:UIColor.whiteColor,
                                  NSFontAttributeName: ([UIFont fontWithName:@"TUV Montserrat" size:16] ?: [UIFont systemFontOfSize:16])
                                  };
                                @{
                                  NSForegroundColorAttributeName: [UIColor colorWithRed:255.0/255.0 green:245.0/255.0 blue:93.0/255.0 alpha:1],
                                  NSFontAttributeName: _currentMonthLabel.font
                                  };
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:str
                                               attributes:attribs];
        NSRange dayTextRange = [str rangeOfString:strDate];
        [attributedText setAttributes:@{
                                        NSForegroundColorAttributeName: [UIColor colorWithRed:255.0/255.0 green:245.0/255.0 blue:93.0/255.0 alpha:1],
                                        NSFontAttributeName: _currentMonthLabel.font
                                        }
                                range:dayTextRange];
        
        _currentMonthLabel.attributedText = attributedText;
    }
}

- (void) actionPressNextPage {
    [[self dayPlannerView] pageForwardAnimated:YES date:nil];
}

- (void) actionPressPrevPage {
    [[self dayPlannerView] pageBackwardsAnimated:YES date:nil];
}

@end
