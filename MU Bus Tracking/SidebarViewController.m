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
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row == 0)
        cell.textLabel.text = @"All Routes";
    else
        cell.textLabel.text = ((Route*)_routes[indexPath.row-1]).longname;
    
    UIImage *image;
    
    switch (indexPath.row) {
        case 0:
            break;
        case 1:
            image = [UIImage imageNamed:@"bus_orange.png"];
            break;
        case 2:
            image = [UIImage imageNamed:@"bus_red.png"];
            break;
        case 3:
            image = [UIImage imageNamed:@"bus_purple1.png"];
            break;
        case 4:
            image = [UIImage imageNamed:@"bus_green.png"];
            break;
        case 5:
            image = [UIImage imageNamed:@"bus_yellow.png"];
            break;
        case 6:
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
        NSString *title = [[NSString alloc]init];
        if (indexPath.row == 0)
            title= @"myMetro";
        else
            title=((Route*)_routes[indexPath.row-1]).longname;

        NSObject *object = [NSString stringWithFormat:title, indexPath.row];
        [self.sidebarDelegate sidebarViewController:self didSelectObject:object atIndexPath:indexPath];
    }
}

@end
