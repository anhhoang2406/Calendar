//
//  MGCDayColumnCell.m
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

#import "MGCDayColumnCell.h"

//Hoang update dotSize 4 -> 5
static const CGFloat dotSize = 5;


@interface MGCDayColumnCell ()

@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) CALayer *leftBorder;

@end


@implementation MGCDayColumnCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
		_markColor = [UIColor blackColor];
		_dotColor = [UIColor blueColor];
        _separatorColor = [UIColor lightGrayColor];
		_headerHeight = 50;
		
		_dayOfWeekLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_dayOfWeekLabel.numberOfLines = 1;
		_dayOfWeekLabel.adjustsFontSizeToFitWidth = YES;
		_dayOfWeekLabel.minimumScaleFactor = .7;
        [_dayOfWeekLabel sizeToFit];
		[self.contentView addSubview:_dayOfWeekLabel];
        
        _dayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dayLabel.numberOfLines = 0;
        _dayLabel.adjustsFontSizeToFitWidth = YES;
        _dayLabel.minimumScaleFactor = .7;
        [_dayLabel sizeToFit];
        _selectedView = [[UIView alloc] init];
        _selectedView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:245.0/255.0 blue:93.0/255.0 alpha:1];
        _selectedView.layer.cornerRadius = 5;
        [self.contentView insertSubview:_selectedView belowSubview:_dayOfWeekLabel];
        CGRect frame = _dayLabel.frame;
        frame.origin.y = _dayOfWeekLabel.frame.size.height;
        [_dayLabel setFrame:frame];
        [self.contentView addSubview:_dayLabel];
		
		_dotLayer = [CAShapeLayer layer];
		CGPathRef dotPath = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, dotSize, dotSize), NULL);
		_dotLayer.path = dotPath;
		_dotLayer.bounds = CGPathGetBoundingBox(dotPath);
		CGPathRelease(dotPath);
		_dotLayer.fillColor = _markColor.CGColor;
		_dotLayer.hidden = YES;
		[self.contentView.layer addSublayer:_dotLayer];
		
		_leftBorder = [CALayer layer];
		[self.contentView.layer addSublayer:_leftBorder];
	}
    return self;
}

- (void)setActivityIndicatorVisible:(BOOL)visible
{
    if (!visible) {
        [self.activityIndicatorView stopAnimating];
    }
    else if (self.headerHeight > 0) {
        if (!self.activityIndicatorView) {
            self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.activityIndicatorView.color = [UIColor blackColor];
            self.activityIndicatorView.transform = CGAffineTransformMakeScale(0.6, 0.6);
            [self.contentView addSubview:self.activityIndicatorView];
        }
        [self.activityIndicatorView startAnimating];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.accessoryTypes = MGCDayColumnCellAccessoryNone;
    self.markColor = [UIColor blackColor];
    [self setActivityIndicatorVisible:NO];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //Toan edited
    static CGFloat kSpace = 5;
    static CGFloat kPaddingBottom = 10;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (self.headerHeight != 0) {
        CGSize headerSize = CGSizeMake(self.contentView.bounds.size.width, self.headerHeight);
        CGSize labelSize = CGSizeMake(headerSize.width - 2*kSpace, headerSize.height - (2*dotSize + 2*kSpace));
        self.dayOfWeekLabel.frame = (CGRect) { 2, 12, labelSize.width, 20 };
        self.dayLabel.frame = (CGRect) { 2, 29, labelSize.width, 20 };
        self.selectedView.frame = (CGRect) { 2, 10, labelSize.width + 1, 40 };
        
        self.dotLayer.position = CGPointMake(self.contentView.center.x, headerSize.height - 1.2 * dotSize - kPaddingBottom);
        self.dotLayer.fillColor = self.dotColor.CGColor;
        self.activityIndicatorView.center = CGPointMake(self.contentView.center.x, headerSize.height - 1.2 * dotSize);
    }
    
//    self.dotLayer.hidden = !(self.accessoryTypes & MGCDayColumnCellAccessoryDot) || self.headerHeight == 0;
    //self.dayLabel.hidden = (self.headerHeight == 0);
    
    // border
    CGRect borderFrame = CGRectZero;
    if (self.accessoryTypes & MGCDayColumnCellAccessoryBorder) {
        borderFrame = CGRectMake(0, self.headerHeight, 1./[UIScreen mainScreen].scale, self.contentView.bounds.size.height-self.headerHeight);
    }
    else if (self.accessoryTypes & MGCDayColumnCellAccessorySeparator) {
        borderFrame = CGRectMake(0, 0, 2./[UIScreen mainScreen].scale, self.contentView.bounds.size.height);
    }
    
    self.leftBorder.frame = borderFrame;
    self.leftBorder.borderColor = self.separatorColor.CGColor;
    self.leftBorder.borderWidth = borderFrame.size.width / 2.;
    
    [CATransaction commit];

}

- (void)setAccessoryTypes:(MGCDayColumnCellAccessoryType)accessoryTypes
{
    _accessoryTypes = accessoryTypes;
    [self setNeedsLayout];
}

@end
