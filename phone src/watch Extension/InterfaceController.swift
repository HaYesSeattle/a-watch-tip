//
//  InterfaceController.swift
//  tip-calc2 Extension
//
//  Created by beth hayes on 1/28/16.
//  Copyright © 2016 abraxas creative. All rights reserved.
//

import WatchKit
import Foundation


class IntegerPickerItem: WKPickerItem {
    
    let intValue: Int
    
    init(intValue: Int) {
        self.intValue = intValue
        super.init()
        self.title = "\(intValue)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class CentsPickerItem: IntegerPickerItem {
    
    override init(intValue: Int) {
        super.init(intValue: intValue)
        self.title = String(format: "%02d", intValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class TipAndSplitCalculator {
    
    var billDollars: Int
    var billCents: Int
    var tipPercent: Int
    var numSplitting: Int
    
    init(billDollars: Int, billCents: Int, tipPercent: Int, numSplitting: Int) {
        self.billDollars = billDollars
        self.billCents = billCents
        self.tipPercent = tipPercent
        self.numSplitting = numSplitting
    }
    
    var billAmount: Double {
        return Double(self.billDollars) + Double(self.billCents) * 0.01
    }
    
    var tipAmount: Double {
        return self.billAmount * Double(self.tipPercent) * 0.01
    }
    
    var totalPerPerson: Double {
        return (self.billAmount + self.tipAmount) / Double(self.numSplitting)
    }
}


class InterfaceController: WKInterfaceController {
    
    // Define variables for tracking the current index of the pickers we want to persist values for.
    var billDollarsPickerIndex: Int
    var billCentsPickerIndex: Int
    var tipPercentPickerIndex: Int
    
    var calculator: TipAndSplitCalculator
    
    let billDollarsPickerItems = Array(0...999).map({IntegerPickerItem(intValue: $0)})
    let billCentsPickerItems = Array(0...99).map({CentsPickerItem(intValue: $0)})
    let tipPercentPickerItems = Array(0...50).map({IntegerPickerItem(intValue: $0)})
    let numSplittingPickerItems = Array(1...9).map({IntegerPickerItem(intValue: $0)})
    
    @IBOutlet var billDollarsPickerOutlet: WKInterfacePicker!
    @IBOutlet var billCentsPickerOutlet: WKInterfacePicker!
    @IBOutlet var tipPercentPickerOutlet: WKInterfacePicker!
    @IBOutlet var numSplittingPickerOutlet: WKInterfacePicker!
    
    @IBOutlet var tipAmoutLabelOutlet: WKInterfaceLabel!
    @IBOutlet var totalPerPersonLabelOutlet: WKInterfaceLabel!
    
    func updateAmountLabels() {
        // TODO: internationalize currency symbols and periods/commas?
        tipAmoutLabelOutlet.setText(String(format: "$%.2f", calculator.tipAmount))
        totalPerPersonLabelOutlet.setText(String(format: "$%.2f", calculator.totalPerPerson))
    }
    
    @IBAction func billDollarsPickerAction(index: Int) {
        calculator.billDollars = billDollarsPickerItems[index].intValue
        updateAmountLabels()
        billDollarsPickerIndex = index
    }
    
    @IBAction func billCentsPickerAction(index: Int) {
        calculator.billCents = billCentsPickerItems[index].intValue
        updateAmountLabels()
        billCentsPickerIndex = index
    }
    
    @IBAction func tipPercentPickerAction(index: Int) {
        calculator.tipPercent = tipPercentPickerItems[index].intValue
        updateAmountLabels()
        tipPercentPickerIndex = index
    }
    
    @IBAction func numSplittingPickerAction(index: Int) {
        calculator.numSplitting = numSplittingPickerItems[index].intValue
        updateAmountLabels()
    }
    
    override init() {
        
        // Read in the persistent data.
        let defaults = NSUserDefaults.standardUserDefaults()
        billDollarsPickerIndex = defaults.integerForKey("billDollarsPickerIndex")
        billCentsPickerIndex = defaults.integerForKey("billCentsPickerIndex")
        tipPercentPickerIndex = defaults.integerForKey("tipPercentPickerIndex")
        
        // Initialize the calculator, using the persistent data to index the picker items.
        calculator = TipAndSplitCalculator(
            billDollars: billDollarsPickerItems[billDollarsPickerIndex].intValue,
            billCents: billCentsPickerItems[billCentsPickerIndex].intValue,
            tipPercent: tipPercentPickerItems[tipPercentPickerIndex].intValue,
            numSplitting: numSplittingPickerItems[0].intValue  // Always defaults to 1 person
        )
        
        super.init()
    }
    
    override func awakeWithContext(context: AnyObject?) {
        // Configure interface objects here.
        super.awakeWithContext(context)
        
        billDollarsPickerOutlet.setItems(billDollarsPickerItems)
        billCentsPickerOutlet.setItems(billCentsPickerItems)
        tipPercentPickerOutlet.setItems(tipPercentPickerItems)
        numSplittingPickerOutlet.setItems(numSplittingPickerItems)
        
        // Set the initial indicies using the persistent data.
        billDollarsPickerOutlet.setSelectedItemIndex(billDollarsPickerIndex)
        billCentsPickerOutlet.setSelectedItemIndex(billCentsPickerIndex)
        tipPercentPickerOutlet.setSelectedItemIndex(tipPercentPickerIndex)
        numSplittingPickerOutlet.setSelectedItemIndex(0)  // Always defaults to 1 person
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        // Store the new values of the persistent data.
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(billDollarsPickerIndex, forKey: "billDollarsPickerIndex")
        defaults.setInteger(billCentsPickerIndex, forKey: "billCentsPickerIndex")
        defaults.setInteger(tipPercentPickerIndex, forKey: "tipPercentPickerIndex")
    }
}
