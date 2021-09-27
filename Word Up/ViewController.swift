//
//  ViewController.swift
//  Word Up
//
//  Created by Ray Wu on 1/18/21.
//

import UIKit
import SnapKit
import os.log

let cellIdentifier = "WordCell"

class ViewController: UIViewController {

    
    let tableView: UITableView = UITableView(frame: .zero)
    var wordDict = ["Apple", "Banana", "Cantaloupe", "DragonFruit", "Elderberry", "Feijoa", "Grape", "Honeydew", "Imbe"]
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
//        viewModel.addWord(WordRecord(content: "apple", added: Date())).sink { record in
//            os_log("tear down stream")
//        }.cancel()
        
        viewModel.queryToday().sink { words in
            if !words.isEmpty {
                os_log("Query words: \(words[0].content)")
            }
        }.cancel()
    }
}


extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let index = indexPath.row
        if editingStyle == .delete {
            wordDict.remove(at: index)
        }
        tableView.deleteRows(at: [indexPath], with: .bottom)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Checked For Today"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let word = wordDict[indexPath.row]
        let wordViewController = WordViewController(word: word, indexInWordList: indexPath.row)
        wordViewController.delegate = self
        navigationController?.pushViewController(wordViewController, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(frame: .infinite)
        let index = indexPath.row
        cell.textLabel?.text = wordDict[index]
        return cell
    }
}

extension ViewController: WordViewControllerDelegate {
    func onCheckedForTodayClicked(word: String, index: Int) {
        print("Dict is removing: \(word)")
        self.wordDict.remove(at: index)
        tableView.reloadData()
    }
}

