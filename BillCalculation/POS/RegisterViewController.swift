//
//  RegisterViewController.swift
//  POS
//
//  Created by Admin on 2019-04-23.
//  Copyright © 2019 Keyur Sosa. All rights reserved.
//

import BillCalculationFramework
import UIKit
class RegisterViewController: UIViewController {
    let cellIdentifier = "Cell"
    
    @IBOutlet var menuTableView: UITableView!
    @IBOutlet var orderTableView: UITableView!
    
    @IBOutlet var subtotalLabel: UILabel!
    @IBOutlet var discountsLabel: UILabel!
    @IBOutlet var taxLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    
    let viewModel = RegisterViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        menuTableView.dataSource = self
        orderTableView.dataSource = self
        menuTableView.delegate = self
        orderTableView.delegate = self
    }
    
    @IBAction func showTaxes() {
        let vc = UINavigationController(rootViewController: TaxViewController(style: .grouped))
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func showDiscounts() {
        let vc = UINavigationController(rootViewController: DiscountViewController(style: .grouped))
        let discount = vc.viewControllers[0] as! DiscountViewController
        discount.delegate = self
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
    }
}

extension RegisterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == menuTableView {
            return viewModel.menuCategoryTitle(in: section)
            
        } else if tableView == orderTableView {
            return viewModel.orderTitle(in: section)
        }
        
        fatalError()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == menuTableView {
            return viewModel.numberOfMenuCategories()
        } else if tableView == orderTableView {
            return 1
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == menuTableView {
            return viewModel.numberOfMenuItems(in: section)
            
        } else if tableView == orderTableView {
            return viewModel.numberOfOrderItems(in: section)
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        
        if tableView == menuTableView {
            cell.textLabel?.text = viewModel.menuItemName(at: indexPath)
            cell.detailTextLabel?.text = viewModel.menuItemPrice(at: indexPath)
            
        } else if tableView == orderTableView {
            cell.textLabel?.text = viewModel.labelForOrderItem(at: indexPath)
            cell.detailTextLabel?.text = viewModel.orderItemPrice(at: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == menuTableView {
            let indexPaths = [viewModel.addItemToOrder(at: indexPath)]
            orderTableView.insertRows(at: indexPaths, with: .automatic)
            tableView.deselectRow(at: indexPath, animated: true)
            // calculate bill totals
            
        } else if tableView == orderTableView {
            viewModel.toggleTaxForOrderItem(at: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView == menuTableView {
            return .none
        } else if tableView == orderTableView {
            return .delete
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == orderTableView, editingStyle == .delete {
            viewModel.removeItemFromOrder(at: indexPath)
            orderTableView.deleteRows(at: [indexPath], with: .automatic)
            // calculate bill totals
        }
    }
}

extension RegisterViewController: RegisterDelegate, DiscountViewControllerDelagte {
    func updateTotals() {
        subtotalLabel.text = stringValue(value: BillCalculationFramework.totalBill)
        discountsLabel.text = stringValue(value: BillCalculationFramework.totalDiscount)
        taxLabel.text = stringValue(value: BillCalculationFramework.totalTax)
        totalLabel.text = stringValue(value: BillCalculationFramework.total)
    }
    
    func stringValue(value: NSDecimalNumber) -> String? {
        return viewModel.formatter.string(from: value)
    }
    
    func updateDiscounts() {
        viewModel.updateDiscountAmount()
    }
}
