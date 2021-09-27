//
//  WordViewController.swift
//  Word Up
//
//  Created by Ray Wu on 5/9/21.
//

import UIKit
import SnapKit

let dictApi = "https://api.dictionaryapi.dev/api/v2/entries/"

protocol WordViewControllerDelegate {
    func onCheckedForTodayClicked(word: String, index: Int)
}

class WordViewController: UIViewController {
    let word: String
    let indexInWordList: Int
    var delegate: WordViewControllerDelegate?
    
    init(word: String, indexInWordList: Int) {
        self.word = word
        self.indexInWordList = indexInWordList
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Method is not supported")
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font =  label.font.withSize(40)
        return label
    }()
    
    let checkedButton: UIButton = {
        let button = UIButton()
        button.setTitle("Checked For Today", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(checkedWord), for: .touchUpInside)
        return button
    }()
    
    let lookUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Look up", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(lookup), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        self.view.backgroundColor = .white
        titleLabel.text = word
        view.addSubview(titleLabel)
        view.addSubview(checkedButton)
        view.addSubview(lookUpButton)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalTo(view.center)
//            make.leadingMargin.equalTo(view.snp_leadingMargin)
        }
        
        checkedButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.center)
            make.bottomMargin.equalTo(view.snp.bottomMargin).offset(-10.0)
        }
        
        lookUpButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.center)
            make.bottomMargin.equalTo(checkedButton.snp.topMargin).offset(-10.0)
        }
        
        DispatchQueue.global().async {
            
        }
    }
    
    @objc func checkedWord() {
        delegate?.onCheckedForTodayClicked(word: word, index: indexInWordList)
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func lookup() {
        if UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: word) {
            let lookupVC = UIReferenceLibraryViewController(term: word)
            self.present(lookupVC, animated: true, completion: nil)
        }
    }
}
