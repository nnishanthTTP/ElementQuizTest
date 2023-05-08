//
//  ViewController.swift
//  ElementQuizTest
//
//  Created by Nidhin Nishanth on 5/6/23.
//

import UIKit

//MARK: Mode Enum
// this enum will help us separate the flash card mode and the quiz mode
enum Mode {
    case flashcard
    case quiz
}

// MARK: State Enum
// this enum will help us set up our quiz. We'll have different UI elements activated depending on whether or not the user has answered the quiz question, and at the end of the quiz, we'll reveal their score
enum State {
    case question   // 'question' state for when we'll be asking the user what the element on the screen is
    case answer     // 'answer' state for when the user has answered the question, and we tell them if they were correct or not
    case score      // 'score' state for when the user has answered all the questions, and we want to tell them their score
}

class ViewController: UIViewController, UITextFieldDelegate {

    //MARK: Outlets
    @IBOutlet var imageView: UIImageView!   // an image view to display the element images, which you can find in the student materials
    @IBOutlet var answerLabel: UILabel!     // a label to display information to the user (what element is on the screen, whether or not they answer a question correctly, etc.)
    
    @IBOutlet var modeSelector: UISegmentedControl!     // a segmented control to allow the user to switch between flash card mode and quiz mode
    @IBOutlet var textField: UITextField!   // a text field to allow the user to enter in an answer

    @IBOutlet var showAnswerButton: UIButton!   // a button to reveal the answer to the user
    @IBOutlet var nextButton: UIButton!     // a button to skip to the next element
    
    //MARK: Variables
    // an array that will store all of the elements in our quiz, we will use the fixedElementList variable to store all of our elements, and the elementList variable will be used in case we want to shuffle the elements around for our quiz, so that we aren't asking our questions in the same order every time
    let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    var elementList: [String] = []
    
    var currentElementIndex = 0
    
    var mode: Mode = .flashcard {
        didSet {    // didSet allows us to run some code everytime we change the value of our mode variable, which is an enum. Depending on its value, we'll call the appropriate function to set up that mode.
            switch mode {
            case .flashcard:
                setupFlashCards()
            case .quiz:
                setupQuiz()
            }
            updateUI()
        }
    }
    
    var state: State = .question
    
    // these two variables will be used to check how many questions we get right on our quiz
    var answerIsCorrect = false
    var correctAnswerCount = 0
    
    //MARK: viewDidLoad()
    // this function runs everytime we load our app. the only thing we'll do here is set our mode variable to flash card, which will set up the flash card mode for us (check the 'didSet' when we created our mode variable)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mode = .flashcard
    }
    
    //MARK: Actions

    @IBAction func showAnswer(_ sender: UIButton) {
        // this function will change the state of our quiz to the answer state, where the user can view their answer. We'll update the UI accordingly, so they can click on the "Show Answer" button
        state = .answer
        updateUI()
    }
    
    @IBAction func next(_ sender: UIButton) {
        // this function will display the next element. if we reach the end of our list, loop back to the start. If we're in quiz mode, we'll change the state of our quiz to score, where we'll display their quiz score
        currentElementIndex += 1
        
        if currentElementIndex == elementList.count {
            // if the current index is the same as the size of our array (meaning that we've reached the end), we'll set the index back to 0
            currentElementIndex = 0
            if mode == .quiz {
                // if we're in quiz mode and we reached the end of the array of elements, we'll let the user see their quiz score
                state = .score
                updateUI()
                return
            }
        }
        
        state = .question
        
        updateUI()
    }
    
    @IBAction func switchModes(_ sender: Any) {
        // this action is connected to the segmented control at the top of our app, which will allow the user to switch between flashcard mode and quiz mode
        if modeSelector.selectedSegmentIndex == 0 {
            mode = .flashcard
        } else {
            mode = .quiz
        }
    }
    
    //MARK: Other Functions
    func updateUI() {
        // this update UI function will change the imageView to display the new element, and depending on the mode, updateUI() will call a more specific function to update the UI for that mode.
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        
        // depending on the mode, we'll call a specific function to update that mode (and we'll pass in the element we want to use)
        switch mode {
        case .flashcard:
            updateFlashCardUI(elementName: elementName)
        case .quiz:
            updateQuizUI(elementName: elementName)
        }
    }
    
    func updateQuizUI(elementName: String) {
        // this function will update the quiz UI. We'll enable and hide some UI elements, and set new values to others (displaying the answer in the answerLabel, changing the text for the nextButton, etc.)
        
        modeSelector.selectedSegmentIndex = 1
        
        // Buttons
        showAnswerButton.isHidden = true
        if currentElementIndex == elementList.count - 1 {
            nextButton.setTitle("Show Score", for: .normal) // if we reach the end of the quiz, change the button's text to "Show Score", so our user can know they're on the last question
        } else {
            nextButton.setTitle("Next Question", for: .normal)
        }
        switch state {
        case .question, .score:
            nextButton.isEnabled = false
        case .answer:
            // we'll only allow the user to go to the next page if they've entered an answer
            nextButton.isEnabled = true
        }
        
        // Text field and keyboard
        textField.isHidden = false
        switch state {
            // we'll enable or disable the textField depending on the label
        case .question:
            textField.isEnabled = true
            textField.text = ""
            textField.becomeFirstResponder()
        case .answer:
            textField.isEnabled = false
            textField.resignFirstResponder()
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }
        
        // Answer Label
        switch state {
            // if the user enters an answer, then we'll set the label accordingly, otherwise leave it blank
        case .question, .score:
            answerLabel.text = ""
        case .answer:
            if answerIsCorrect {
                answerLabel.text = "Correct!"
            } else {
                answerLabel.text = "❌\nCorrect Answer: " + elementName
            }
        }
        
        if state == .score {
            displayScoreAlert()
        }
    }
    
    func updateFlashCardUI(elementName: String) {
        // this function will update the flash card UI. We'll enable and hide some UI elements.
        
        modeSelector.selectedSegmentIndex = 0
        
        // Buttons
        showAnswerButton.isHidden = false
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
        
        // text field and keyboard
        textField.isHidden = false
        textField.resignFirstResponder()
        
        // answer label
        if state == .answer {
            answerLabel.text = elementName
        } else {
            answerLabel.text = "?"
        }
    }
    
    func setupFlashCards() {
        // this setup function will be used to clear and re-initialize our variables, so we can start a new flash cards session
        elementList = fixedElementList
        state = .question
        currentElementIndex = 0
    }
    
    func setupQuiz() {
        // this setup function will be used to clear and re-initialize our variables, so we can start a new quiz session
        elementList = fixedElementList.shuffled()
        
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // this function related to the UITextFieldDelegate that we added to the ViewController class in line 25, this lets us control what happens when the user hits 'Enter' or 'Return' in the text field. We'll check whatever they entered in, and if it matches the current element, we'll say they got that question correct
        let textFieldContents = textField.text!
        if textFieldContents.lowercased() == elementList[currentElementIndex].lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }
        state = .answer
        
        updateUI()
        
        return true
    }
    
    func displayScoreAlert() {
        // we'll use this function to display an alert for our user when they finish the quiz. The alert will tell our user their score.
        let alert = UIAlertController(title: "Quiz Score", message: "Your score is \(correctAnswerCount) out of \(elementList.count)", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:))
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func scoreAlertDismissed(_ action: UIAlertAction) {
        // this function controls what happens when we dismiss our alert. We'll make it so that when they finish the quiz and see their score, they can go back to the flashcard mode and study again.
        mode = .flashcard
    }

}

