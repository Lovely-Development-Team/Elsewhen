//
//  IntentViewController.swift
//  Discord Helper IntentsUI
//
//  Created by David on 10/09/2021.
//

import IntentsUI

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling {
    @IBOutlet weak var topSpacer: NSLayoutConstraint!
    @IBOutlet weak var humanFormatLabel: UILabel!
    @IBOutlet weak var discordFormatSpacer: NSLayoutConstraint!
    @IBOutlet weak var discordFormatLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        // Do configuration here, including preparing views and calculating a desired size for presentation.
        let intent = interaction.intent
        switch intent {
        case is ConvertTimeIntent:
            guard let intentResponse = interaction.intentResponse as? ConvertTimeIntentResponse else {
                      completion(false, parameters, self.desiredSize)
                      return
                  }
            guard intentResponse.code == .success else {
                guard intentResponse.code == .noDate else {
                    completion(false, parameters, self.desiredSize)
                    return
                }
                humanFormatLabel.text = "No date provided"
                discordFormatLabel.removeFromSuperview()
                completion(false, parameters, discordFormatLabel.sizeThatFits(desiredSize))
                return
            }
            guard let humanFormat = intentResponse.humanFormat,
                  let discordFormat = intentResponse.discordFormat else {
                      completion(false, parameters, self.desiredSize)
                      return
                  }
            humanFormatLabel.text = humanFormat
            discordFormatLabel.text = discordFormat
            let humanFormatLabelSizeThatFits = humanFormatLabel.sizeThatFits(desiredSize)
            let discordFormatLabelSizeThatFits = discordFormatLabel.sizeThatFits(desiredSize)
            // Spacing from the top of the view
            let topSpacerHeight = topSpacer.constant
            // Spacing of the first ("human format") label
            let humanFormatLabelHeight = humanFormatLabelSizeThatFits.height
            // Space between the two labels
            let spacerHeight = discordFormatSpacer.constant
            // Spacing of the second ("discord format") label
            let discordFormatLabelHeight = discordFormatLabelSizeThatFits.height
            // At a bit of padding for some space at the bottom
            let heightPadding = CGFloat(4)
            let desiredHeight = topSpacerHeight + humanFormatLabelHeight + discordFormatLabelHeight + spacerHeight + heightPadding
            let desiredWidth = humanFormatLabelSizeThatFits.width + discordFormatLabelSizeThatFits.width
            completion(true, parameters, CGSize(width: desiredWidth, height: desiredHeight))
        default:
            completion(false, parameters, self.desiredSize)
        }
    }
    
    var desiredSize: CGSize {
        return self.extensionContext!.hostedViewMaximumAllowedSize
    }
    
}
