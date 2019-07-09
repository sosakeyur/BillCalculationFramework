//
//  RegisterViewModel.swift
//  POS
//
//  Created by Admin on 6/29/19.
//  Copyright © 2019 Keyur Sosa. All rights reserved.
//

import BillCalculationFramework
import Foundation

protocol RegisterDelegate {
    func updateTotals()
}

class RegisterViewModel {
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    var delegate: RegisterDelegate?
    
    var currentActiveTaxes = {
        taxes.filter { $0.isEnabled == true }.map { $0.amount }
    }
    
    var currentActiveDiscouts = {
        discounts.filter { $0.isEnabled == true }.map { $0.amount }
    }
    
    var orderItems: [Item] = []
    
    func orderTitle(in section: Int) -> String? {
        return "Bill"
    }
    
    func numberOfOrderItems(in section: Int) -> Int {
        return orderItems.count
    }
    
    func labelForOrderItem(at indexPath: IndexPath) -> String? {
        let item = orderItems[indexPath.row]
        
        if item.isTaxExempt {
            return "\(item.name) (No Tax)"
        } else {
            return item.name
        }
    }
    
    func orderItemPrice(at indexPath: IndexPath) -> String? {
        let price = orderItems[indexPath.row].price
        return formatter.string(from: price)
    }
}

// Menu tableview.
extension RegisterViewModel {
    func menuCategoryTitle(in section: Int) -> String? {
        return categories[section].name
    }
    
    func numberOfMenuCategories() -> Int {
        return categories.count
    }
    
    func numberOfMenuItems(in section: Int) -> Int {
        return categories[section].items.count
    }
    
    func menuItemName(at indexPath: IndexPath) -> String? {
        return categories[indexPath.section].items[indexPath.row].name
    }
    
    func menuItemPrice(at indexPath: IndexPath) -> String? {
        let price = categories[indexPath.section].items[indexPath.row].price
        return formatter.string(from: price)
    }
}

//// Perform operations.
extension RegisterViewModel {
    func addItemToOrder(at indexPath: IndexPath) -> IndexPath {
        let item = categories[indexPath.section].items[indexPath.row]
        orderItems.append(item)
        
        
        BillCalculationFramework.addItem(
            billItem: BillItemModel(
                itemName: item.name,
                itemAlcholCategory: item.category == "Alcohol" ? true : false,
                price: item.price,
                applicableTax: currentActiveTaxes(),
                isTaxExempt: item.isTaxExempt,
                applicableDiscounts: currentActiveDiscouts()
            )
        )
        delegate?.updateTotals()
        return IndexPath(row: orderItems.count - 1, section: 0)
    }
    
    func removeItemFromOrder(at indexPath: IndexPath) {
        BillCalculationFramework.removeItem(fromIndex: indexPath.row, noTax: orderItems[indexPath.row].isTaxExempt)
        delegate?.updateTotals()
        orderItems.remove(at: indexPath.row)
    }
    
    func toggleTaxForOrderItem(at indexPath: IndexPath) {
        orderItems[indexPath.row].isTaxExempt = !orderItems[indexPath.row].isTaxExempt
        BillCalculationFramework.removeAndAddTaxFromItem(fromIndex: indexPath.row, noTax: orderItems[indexPath.row].isTaxExempt)
        delegate?.updateTotals()
    }
    
    func updateDiscountAmount() {
        BillCalculationFramework.removeAndAddDiscountFromItem(discounts: currentActiveDiscouts())
        delegate?.updateTotals()
    }
}
