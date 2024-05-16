//
//  ViewController.swift
//  Combine Examples
//
//  Created by Anh Dinh on 5/13/24.
//

import UIKit
import Combine

class MyCustomTableView: UITableViewCell {
    static let identifier = "MyCustomTableView"
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Button of cell", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    
    // <String, Never>
    // String is what we want to send when tapping on Button
    // Never indicates that this action never gets an error
    let action = PassthroughSubject<String, Never>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            button.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapButton() {
        // What we are doing is replacing Delegate Pattern by Combine
        // Seding the String every time the button tapped
        action.send("Button is tapped!!!!!")
    }
}

class ViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(MyCustomTableView.self,
                       forCellReuseIdentifier: MyCustomTableView.identifier)
        return table
    }()
    
    // Whenever a func return a Future, we need to hang on to it
    // Create a variable to do it
    // Subscriber?
    var observers: [AnyCancellable] = []

    var models: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        
        APICaller.shared.fetchData()
            .receive(on: DispatchQueue.main) // happens on Main thread
            .sink(receiveCompletion: { completion in
                // This completion block is the status of completion of publisher.
                // It lets us know if the Future func finishes or gets error.
                switch completion {
                case .finished:
                    print("Finished Future Func")
                case .failure(let error):
                    print("DEBUG ERROR \(error.localizedDescription)")
                }
        }, receiveValue: { [weak self] value in
            // "value" is the returned of the Future func
            self?.models = value
            self?.tableView.reloadData()
        }).store(in: &observers)
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyCustomTableView.identifier, for: indexPath) as? MyCustomTableView else {
            return UITableViewCell()
        }
        
        // Trigger action when button is tapped,
        // just like delegate pattern
        //
        // we only use the completion with "receiveValue"
        // because in cell, we define the action with "Never"
        // which indicates that it never gets error so we don't
        // have to handle error
        cell.action.sink { string in
            print("String of tapping button: \(string)")
        }.store(in: &observers)
        return cell
    }
}
