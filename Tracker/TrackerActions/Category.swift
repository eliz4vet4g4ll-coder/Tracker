import UIKit

final class CategoryViewController: UIViewController{
    var onCategorySelected: ((String) -> Void)?
    
    let textLabel = UILabel()
    let addCategoryButton = UIButton()
    var star = UIImageView()
    var centerText = UILabel()
    
    let tableView = UITableView()
    var categories: [String] = []

    func setTextLAbel(){
        textLabel.text = "Категория"
        textLabel.font = .systemFont(ofSize: 16, weight: .medium)
        textLabel.textColor = .label
        textLabel.numberOfLines = 0
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
        
        textLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 13).isActive = true
        textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func setAddCategoryButton(){
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.setTitleColor(.ypWhite, for: .normal)
        addCategoryButton.backgroundColor = .ypBlack
        addCategoryButton.layer.cornerRadius = 16
        
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
       addCategoryButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
    }

    @objc private func addButtonTapped(_ sender: UIButton) {
        let newCategory = AddCategoryViewController()
        newCategory.modalPresentationStyle = .pageSheet
        if let sheet = newCategory.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.preferredCornerRadius = 16
            sheet.prefersGrabberVisible = false
        }
        
        // получаем название новой категории
        newCategory.onCategoryAdded = { [weak self] name in
            guard let self = self else { return }
            self.categories.append(name)
            self.tableView.reloadData()
            self.updatePlaceholder()
        }
        
        present(newCategory, animated: true)
    }
    
    private func setStar(){
        star = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "star")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        view.addSubview(star)
        
        NSLayoutConstraint.activate([
            star.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 232),
            star.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
    }
    
    func setSenterText(){
        centerText.numberOfLines = 0
        centerText.text = "Привычки и события можно\nобъединить по смыслу"
        centerText.textColor = .ypBlack
        centerText.font = .systemFont(ofSize: 12, weight: .medium)
        centerText.textAlignment = .center
        
        centerText.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(centerText)
        
        centerText.topAnchor.constraint(equalTo: star.bottomAnchor, constant: 8).isActive = true
        centerText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func setTableView() {
            tableView.backgroundColor = .clear
            tableView.rowHeight = 75
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            tableView.dataSource = self
            tableView.delegate = self
            
            tableView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tableView)
            
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 38),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16)
            ])
        }
    
    func updatePlaceholder() {
            let isEmpty = categories.isEmpty
            star.isHidden = !isEmpty
            centerText.isHidden = !isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setTextLAbel()
        setAddCategoryButton()
        setStar()
        setSenterText()
        setTableView()
        updatePlaceholder()
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row]
        cell.backgroundColor = .ypDayBackground
        cell.layer.cornerRadius = 16
        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onCategorySelected?(categories[indexPath.row])
        dismiss(animated: true)
    }
}
