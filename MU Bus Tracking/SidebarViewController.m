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
@synthesize routeColor;
@synthesize respData = _respData;

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
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"U%d", indexPath.row];
    cell.textLabel.textColor = [UIColor redColor];
    cell.backgroundColor = [UIColor clearColor];
    
    UIImage *image;
    switch (indexPath.row) {
        case 0:
            image = [UIImage imageNamed:@"bus_orange.png"];
            break;
        case 1:
            image = [UIImage imageNamed:@"bus_red.png"];
            break;
        case 2:
            image = [UIImage imageNamed:@"bus_purple1.png"];
            break;
        case 3:
            image = [UIImage imageNamed:@"bus_green.png"];
            break;
        case 4:
            image = [UIImage imageNamed:@"bus_yellow.png"];
            break;
        case 5:
            image = [UIImage imageNamed:@"bus_blue.png"];
            break;
        default:
            image = [UIImage imageNamed:@"bus_red.png"];
            break;
    }
    cell.imageView.image = image;

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.title;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sidebarDelegate) {
        NSObject *object = [NSString stringWithFormat:@"U%d", indexPath.row];
        [self.sidebarDelegate sidebarViewController:self didSelectObject:object atIndexPath:indexPath];
    }
}


@end
