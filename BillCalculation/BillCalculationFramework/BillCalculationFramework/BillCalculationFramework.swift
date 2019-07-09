//
//  BillCalculationFramework.swift
//  BillCalculationFramework
//
//  Created by Admin on 7/4/19.
//  Copyright © 2019 Keyur Sosa. All rights reserved.
//

import Foundation

open class BillCalculationFramework {
    public static var totalBill: NSDecimalNumber = 0.0
    public static var totalDiscount: NSDecimalNumber = 0.0
    public static var totalTax: NSDecimalNumber = 0.0
    public static var total: NSDecimalNumber = 0.0
    
    static var bill = BillItemsModel(billItems: [])
    
    public static func addItem(billItem: BillItemModel) {
        totalBill = totalBill.adding(billItem.price)
        totalTax = totalTax.adding(calculateTaxes(on: billItem.price, taxArray: billItem.applicableTax, isAlcholItem: billItem.itemAlcholCategory))
        totalDiscount = calculateDiscounts(on: totalBill, discountArray: billItem.applicableDiscounts)
        total = totalBill.adding(totalTax).subtracting(totalDiscount)
        bill.billItems.append(billItem)
    }
    
    public static func removeItem(fromIndex index: Int, noTax: Bool) {
        let billItem = bill.billItems[index]
        totalBill = totalBill.subtracting(billItem.price)
        if noTax == false {
            totalTax = totalTax.subtracting(calculateTaxes(on: billItem.price, taxArray: billItem.applicableTax, isAlcholItem: billItem.itemAlcholCategory))
        } else {
            totalTax = 0.00
        }
        totalDiscount = totalDiscount.subtracting(calculateDiscounts(on: totalBill, discountArray: billItem.applicableDiscounts))
        total = totalBill.adding(totalTax).subtracting(totalDiscount)
        bill.billItems.remove(at: index)
    }
    
    public static func removeAndAddTaxFromItem(fromIndex index: Int, noTax: Bool) {
        let billItem = bill.billItems[index]
        if noTax == true {
            totalTax = totalTax.subtracting(calculateTaxes(on: billItem.price, taxArray: billItem.applicableTax, isAlcholItem: billItem.itemAlcholCategory))
        } else {
            totalTax = totalTax.adding(calculateTaxes(on: billItem.price, taxArray: billItem.applicableTax, isAlcholItem: billItem.itemAlcholCategory))
        }
        total = totalBill.adding(totalTax).subtracting(totalDiscount)
    }
    
    public static func removeAndAddDiscountFromItem(discounts: [Double]) {
        totalDiscount = calculateDiscounts(on: totalBill, discountArray: discounts)
        total = totalBill.adding(totalTax).subtracting(totalDiscount)
    }
}

extension BillCalculationFramework {
    static func calculateTaxes(on price: NSDecimalNumber, taxArray: [Double], isAlcholItem: Bool) -> NSDecimalNumber {
        var taxAmount: NSDecimalNumber = 0.00
        if taxArray.count == 0 {
            taxAmount = taxAmount.adding(price.noTax)
        } else {
            for tax in taxArray {
                switch tax {
                case 0.05: taxAmount = taxAmount.adding(price.fivePercentTax)
                case 0.08: taxAmount = taxAmount.adding(price.eightPercentTax)
                case 0.10: do {
                    if isAlcholItem == true {
                        taxAmount = taxAmount.adding(price.tenPercentTax)
                    }
                }
                default: taxAmount = 0.00
                }
            }
        }
        return taxAmount
    }
    
    static func calculateDiscounts(on price: NSDecimalNumber, discountArray: [Double]) -> NSDecimalNumber {
        if price == 0.00 {
            return 0.00
        }
        var discountAmount: NSDecimalNumber = 0.00
        if discountArray.count == 0 {
            return discountAmount
        } else {
            for tax in discountArray {
                switch tax {
                case 5.00: discountAmount = 5.00
                case 0.10: discountAmount = discountAmount.adding(price.tenPercentDiscount)
                case 0.20: discountAmount = discountAmount.adding(price.twentyPercentDiscount)
                default: discountAmount = 0.00
                }
            }
        }
        if discountAmount.decimalValue <= 0 {
            discountAmount = 0.00
        }
        return discountAmount
    }
}

extension NSDecimalNumber {
    var fivePercentTax: NSDecimalNumber {
        return multiplying(by: 0.05)
    }
    
    var eightPercentTax: NSDecimalNumber {
        return multiplying(by: 0.08)
    }
    
    var tenPercentTax: NSDecimalNumber {
        return multiplying(by: 0.10)
    }
    
    var noTax: NSDecimalNumber {
        return multiplying(by: 0.00)
    }
}

extension NSDecimalNumber {
    var fiveDollarDiscount: NSDecimalNumber {
        return 5.0
    }
    
    var tenPercentDiscount: NSDecimalNumber {
        return dividing(by: 10.0)
    }
    
    var twentyPercentDiscount: NSDecimalNumber {
        return dividing(by: 20.0)
    }
    
    var noDiscount: NSDecimalNumber {
        return dividing(by: 0.00)
    }
}

struct BillItemsModel {
    var billItems: [BillItemModel]
}

public struct BillItemModel {
    let itemName: String
    let itemAlcholCategory: Bool
    let price: NSDecimalNumber
    let applicableTax: [Double]
    let isTaxExempt: Bool
    let applicableDiscounts: [Double]
    
    public init(itemName: String,
                itemAlcholCategory: Bool,
                price: NSDecimalNumber,
                applicableTax: [Double],
                isTaxExempt: Bool,
                applicableDiscounts: [Double]) {
        self.itemName = itemName
        self.itemAlcholCategory = itemAlcholCategory
        self.price = price
        self.applicableTax = applicableTax
        self.isTaxExempt = isTaxExempt
        self.applicableDiscounts = applicableDiscounts
    }
}
