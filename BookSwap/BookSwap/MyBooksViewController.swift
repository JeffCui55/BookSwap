//
//  MyBooksViewController.swift
//  BookSwap
//
//  Created by Jeffery Cui on 4/5/17.
//  Copyright © 2017 Jeffery Cui. All rights reserved.
//

import UIKit

class MyBooksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.dataSource = self
        tableView?.delegate = self
        
        // Set a header for the table view
        let header = UIView(frame: CGRect(x: 0, y: 0, width: (tableView?.frame.width)!, height: 100))
        header.backgroundColor = .red
        tableView?.tableHeaderView = header
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyBooksTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "MyBookCell") as! MyBooksTableViewCell!
      
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
