//
//  SidebarViewController.m
//  MU Bus Tracking
//
//  Created by Jake Gregg on 9/16/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "SidebarViewController.h"

@implementation SidebarViewController
@synthesize sidebarDelegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Put init params here...
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.sidebarDelegate respondsToSelector:@selector(lastSelectedIndexPathForSidebarViewController:)]) {
        NSIndexPath *indexPath = [self.sidebarDelegate lastSelectedIndexPathForSidebarViewController:self];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_routes count] + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 0;
    }
    cell.textLabel.textColor = [UIColor darkTextColor];
    cell.backgroundColor = [UIColor whiteColor];
    
    
    if (indexPath.row == 0)
        cell.textLabel.text = @"Favorites";
    else if (indexPath.row > 0 && indexPath.row < [_routes count]+1){
        Route *route = (Route*)_routes[indexPath.row-1];
        
        //Create Header Font & String
        NSString *headerString = [NSString stringWithFormat: @"%@\n", route.name];
        UIFont *Header = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
        NSDictionary *headerDict = [NSDictionary dictionaryWithObject: Header forKey: NSFontAttributeName];
        NSMutableAttributedString *cellString = [[NSMutableAttributedString alloc] initWithString:headerString attributes: headerDict];
        
        //Create sub information
        UIFont *subHeading = [UIFont fontWithName:@"Helvetica" size:10.0];
        NSDictionary *subHeadingDict = [NSDictionary dictionaryWithObject: subHeading forKey: NSFontAttributeName];
        NSMutableAttributedString *detailInfo = [[NSMutableAttributedString alloc] initWithString:route.longname attributes: subHeadingDict];
        [cellString appendAttributedString:detailInfo];
        cell.textLabel.attributedText = cellString;
        
        //GetSize for image creation
        CGSize headerSize = [self getCellSizesWithText:headerString andFont:Header];
        CGSize subHeadingSize = [self getCellSizesWithText:route.longname andFont:subHeading];
        CGSize cellSize = CGSizeMake(5, headerSize.height + subHeadingSize.height);

        UIImage *image = [self imageWithColor:route.color andSize:cellSize];
        cell.imageView.image = image;
    } else {
        cell.textLabel.text = @"Settings";
    }
    return cell;
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText    = @"some text which is part of cell display";
    UIFont *cellFont      = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize      = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    //int buffer  = 10;
    return labelSize.height + buffer;
}
*/

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.title;
}
#pragma mark - private methods

-(CGSize) getCellSizesWithText:(NSString *)cellText andFont:(UIFont *)cellFont {
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize cellSize      = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    return cellSize;
}

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sidebarDelegate) {
        NSString *title = [[NSString alloc]init];
        if (indexPath.row == 0)
            title= @"Favorites";
        else if (indexPath.row > 0 && indexPath.row < [_routes count]+1)
            title=((Route*)_routes[indexPath.row-1]).longname;
        else
            title=@"Settings";

        NSObject *object = [NSString stringWithFormat:title, indexPath.row];
        [self.sidebarDelegate sidebarViewController:self didSelectObject:object atIndexPath:indexPath];
    }
}

@end
