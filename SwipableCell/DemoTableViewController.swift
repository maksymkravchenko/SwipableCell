//
//  DemoTableViewController.swift
//  SwipableCell
//
//  Created by Max Kravchenko on 1/11/15.
//  Copyright (c) 2015 Max Kravchenko. All rights reserved.
//

import UIKit

class DemoTableViewController: UITableViewController, SwipableCellTableViewCellDelegate {
    
    @IBAction func butt1Action(sender: AnyObject) {
        println("button 1 clicked")
    }
    @IBAction func butt2Action(sender: AnyObject) {
        println("button 2 clicked")
    }
    
    //MARK: SwipableCellTableViewCellDelegate
    func swipeCellDidStartSwiping(cell: SwipableCell) {
        for currentCell in self.tableView.visibleCells(){
            if let theCell = currentCell as? DemoCell {
                if theCell != cell && theCell.isSwiped {
                    theCell.resetConstraints(false)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let id = "Cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(id, forIndexPath: indexPath) as? DemoCell
        if cell == nil {
            cell = DemoCell()
        }
        cell?.delegate = self
        
        cell?.demoText?.text = "Cell # \(indexPath.row)"
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76
    }
}

