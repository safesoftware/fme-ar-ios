//
//  AssetTableViewController.swift
//  FMEAR
//
//  Created by Angus Lau on 2018-03-02.
//  Copyright © 2018 Safe Software Inc. All rights reserved.
//

import UIKit

protocol AssetViewControllerDelegate: class {
    func assetViewControllerDelegate(_: AssetViewController, didSelectAsset asset: Asset)
    func assetViewControllerDelegate(_: AssetViewController, didDeselectAsset asset: Asset)
}

//class AssetTableViewCell : UITableViewCell {
//
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        configureView()
//    }
//
//    required init(coder aDecoder: NSCoder) {
//        super.init?(coder: aDecoder)
//        configureView()
//    }
//
//    func configureView() {
//        // add and configure subviews here
//    }
//}

class AssetViewController: UITableViewController {

    weak var delegate: AssetViewControllerDelegate?
    var assets = [Asset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.tableView.allowsSelection = true
        self.tableView.allowsMultipleSelection = true
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "assetTableCell")
        
        for (row, asset) in assets.enumerated() {
            if asset.selected {
                let indexPath = IndexPath(row: row, section: 0)
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assets.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return "\(assets.count) Assets"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "assetTableCell", for: indexPath)

//        cell.selectionStyle = .none
        
        // Configure the cell...
        if (assets.count > indexPath.row) {
            cell.textLabel?.text =  "\(assets[indexPath.row].name)"
        } else {
            cell.textLabel?.text = "Asset \(indexPath.row)"
        }

//        if (deselectedAssets.contains(indexPath.row)) {
//            cell.isSelected = false
//        } else {
//            cell.isSelected = true
//        }

        //cell.setSelected(true, animated: false)
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if (deselectedAssets.contains(indexPath.row)) {
//            //cell.accessoryType = .none
//            cell.setSelected(false, animated: false)
//        } else {
//            //cell.accessoryType = .checkmark
//            cell.setSelected(true, animated: false)
//        }
//    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            cell.accessoryType = .checkmark
//            cell.isHighlighted = false
            assets[indexPath.row].selected = true
//            deselectedAssets.remove(indexPath.row)
//        }
        
        if delegate != nil {
            delegate?.assetViewControllerDelegate(self, didSelectAsset: assets[indexPath.row])
        }
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            cell.accessoryType = .none
//            cell.isHighlighted = false
            assets[indexPath.row].selected = false
//            deselectedAssets.insert(indexPath.row)
//        }

        if delegate != nil {
            delegate?.assetViewControllerDelegate(self, didDeselectAsset: assets[indexPath.row])
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
