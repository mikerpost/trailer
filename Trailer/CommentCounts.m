
static NSDictionary *_commentCountAttributes, *_commentAlertAttributes;
static NSNumberFormatter *formatter;
static CGColorRef _redFill, _grayFill;

@interface CommentCounts ()
{
	NSInteger _unreadCount, _totalCount;
}
@end

@implementation CommentCounts

+ (void)initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = [[NSNumberFormatter alloc] init];
		formatter.numberStyle = NSNumberFormatterDecimalStyle;

		NSMutableParagraphStyle *pCenter = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		pCenter.alignment = NSCenterTextAlignment;

		_commentCountAttributes = @{
									NSFontAttributeName:[NSFont fontWithName:@"Helvetica Neue" size:11.0],
									NSForegroundColorAttributeName:[NSColor colorWithWhite:0.4 alpha:1.0],
									NSParagraphStyleAttributeName:pCenter,
									};
		_commentAlertAttributes = @{
									NSFontAttributeName:[NSFont fontWithName:@"Helvetica Neue" size:8.0],
									NSForegroundColorAttributeName:[NSColor whiteColor],
									NSParagraphStyleAttributeName:pCenter,
									};
		_redFill = CGColorCreateCopy([NSColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0].CGColor);
		_grayFill = CGColorCreateCopy([NSColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor);
	});
}

- (id)initWithFrame:(NSRect)frame unreadCount:(NSInteger)unreadCount totalCount:(NSInteger)totalCount
{
    self = [super initWithFrame:frame];
    if (self) {
		_unreadCount = unreadCount;
		_totalCount = totalCount;
    }
    return self;
}

typedef enum {
	kRoundedCornerNone = 0,
	kRoundedCornerTopLeft = 1,
	kRoundedCornerTopRight = 2,
	kRoundedCornerBottomLeft = 4,
	kRoundedCornerBottomRight = 8
} RoundedCorners;

#define BASE_BADGE_SIZE 21.0
#define SMALL_BADGE_SIZE 14.0

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];

	if(_totalCount)
	{
		CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];

		NSString *countString = [formatter stringFromNumber:@(_totalCount)];

		CGFloat width = MAX(BASE_BADGE_SIZE,[countString sizeWithAttributes:_commentCountAttributes].width+10.0);
		CGFloat height = BASE_BADGE_SIZE;
		CGFloat bottom = (self.bounds.size.height-height)*0.5;
		CGFloat left = (self.bounds.size.width-width)*0.5;

		CGRect countRect = CGRectMake(left, bottom, width, height);
		[self drawRoundRect:countRect
				  withColor:_grayFill
					corners:kRoundedCornerTopLeft|kRoundedCornerBottomLeft|kRoundedCornerBottomRight|kRoundedCornerTopRight
					 radius:3.0
				  inContext:context];

		countRect = CGRectOffset(countRect, 0, -2.0);
		[countString drawInRect:countRect withAttributes:_commentCountAttributes];

		if(_unreadCount)
		{
			bottom += height;
			//left += width;

			countString = [formatter stringFromNumber:@(_unreadCount)];
			width = MAX(SMALL_BADGE_SIZE,[countString sizeWithAttributes:_commentAlertAttributes].width+6.0);;
			height = SMALL_BADGE_SIZE;

			left -= width * 0.5;
			bottom -= (height * 0.5)+1.0;

			CGRect countRect = CGRectMake(left, bottom, width, height);
			[self drawRoundRect:countRect
					  withColor:_redFill
						corners:kRoundedCornerTopLeft|kRoundedCornerBottomLeft|kRoundedCornerBottomRight|kRoundedCornerTopRight
						 radius:SMALL_BADGE_SIZE*0.5
					  inContext:context];

			countRect = CGRectOffset(countRect, 0, 1.0);
			[countString drawInRect:countRect withAttributes:_commentAlertAttributes];
		}
	}
}

- (void)drawRoundRect:(CGRect)rect withColor:(CGColorRef)color corners:(RoundedCorners)corners radius:(CGFloat)radius inContext:(CGContextRef)context
{
	CGRect innerRect = CGRectInset(rect, radius, radius);

	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;

    CGFloat inside_left = innerRect.origin.x;
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;

	CGContextBeginPath(context);

    if(corners & kRoundedCornerTopLeft)
    {
        CGContextMoveToPoint(context, innerRect.origin.x, outside_top);
    }
    else
    {
        CGContextMoveToPoint(context, outside_left, outside_top);
    }

    if(corners & kRoundedCornerTopRight)
    {
        CGContextAddLineToPoint(context, inside_right, outside_top);
        CGContextAddArcToPoint(context, outside_right, outside_top, outside_right, inside_top, radius);
    }
    else
    {
        CGContextAddLineToPoint(context, outside_right, outside_top);
    }

    if(corners & kRoundedCornerBottomRight)
    {
        CGContextAddLineToPoint(context, outside_right, inside_bottom);
        CGContextAddArcToPoint(context,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
    }
    else
    {
        CGContextAddLineToPoint(context, outside_right, outside_bottom);
    }

    if(corners & kRoundedCornerBottomLeft)
    {
        CGContextAddLineToPoint(context, inside_left, outside_bottom);
        CGContextAddArcToPoint(context,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
    }
    else
    {
        CGContextAddLineToPoint(context, outside_left, outside_bottom);
    }

    if(corners & kRoundedCornerTopLeft)
    {
        CGContextAddLineToPoint(context, outside_left, inside_top);
        CGContextAddArcToPoint(context,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
    }
    else
    {
        CGContextAddLineToPoint(context, outside_left, outside_top);
    }

    CGContextSetFillColorWithColor(context, color);
    CGContextFillPath(context);
}

@end
