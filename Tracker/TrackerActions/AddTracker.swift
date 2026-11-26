import UIKit

final class AddTrackerController: UIViewController {
    var onTrackerCreated: ((TrackerCategory) -> Void)?

    @objc private func createTapped() {
        guard let categoryTitle = selectedCategory else { return }
        
        let tracker = Tracker(name: trackerName,
                              color: .colorSelection5,
                              emoji: "😪",
                              schedule: selectedDays)
        let category = TrackerCategory(title: categoryTitle, trackers: [tracker])
        
        onTrackerCreated?(category)
        dismiss(animated: true)
    }
    
    private var selectedCategory: String?
    private var selectedDays = Set<Weekday>()

    private var scheduleText: String? {
        if selectedDays.isEmpty { return nil }
        if selectedDays.count == Weekday.allCases.count { return "Каждый день" }
        return Weekday.allCases
            .filter { selectedDays.contains($0) }
            .map { $0.shortTitle }
            .joined(separator: ", ")
    }
    private let titleLabel = UITextField()
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    private let stackView = UIStackView()
    
    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewFlowLayout())
    
    private let options = ["Категория", "Расписание"]
    private var trackerName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTitle()
        setupButtons()
        setupCollection()
    }
    
    // MARK: - Настройка элементов
    
    private func setupTitle() {
        titleLabel.text = "Новая привычка"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupButtons() {
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.ypWhite, for: .normal)
        createButton.backgroundColor = .ypGray
        createButton.layer.cornerRadius = 16
        createButton.isEnabled = false
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupCollection() {
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        collectionView.alwaysBounceVertical = true
        collectionView.register(TextFieldCell.self, forCellWithReuseIdentifier: TextFieldCell.identifier)
        collectionView.register(OptionCell.self, forCellWithReuseIdentifier: OptionCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -16)
        ])
    }
    
    // MARK: - Действия
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func nameChanged(_ sender: UITextField) {
        trackerName = sender.text ?? ""
        let isFilled = !trackerName.isEmpty && selectedCategory != nil && !selectedDays.isEmpty
        createButton.isEnabled = isFilled
        createButton.backgroundColor = isFilled ? .black : .ypGray
    }
}

// MARK: - UICollectionViewDataSource

extension AddTrackerController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TextFieldCell.identifier,
                for: indexPath) as? TextFieldCell else {
                return UICollectionViewCell()
            }
            cell.textField.text = trackerName
            cell.textField.addTarget(self, action: #selector(nameChanged(_:)), for: .editingChanged)
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OptionCell.identifier,
            for: indexPath) as? OptionCell else {
            return UICollectionViewCell()
        }
        
        cell.titleLabel.text = options[indexPath.row]
        
        let subtitle = indexPath.row == 0 ? selectedCategory : scheduleText
        cell.subtitleLabel.text = subtitle
        cell.subtitleLabel.isHidden = (subtitle == nil)
        
        let isLast = indexPath.row == options.count - 1
        cell.separator.isHidden = isLast
        cell.contentView.layer.maskedCorners = isLast
            ? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            : [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AddTrackerController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: 75)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // действия при нажатии кнопок
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard indexPath.section == 1 else { return }

        switch indexPath.row {
        case 0:
            let vc = CategoryViewController()
            vc.onCategorySelected = { [weak self] name in
                self?.selectedCategory = name
                self?.collectionView.reloadData()
            }
            present(vc, animated: true)
        case 1:
            let vc = ScheduleViewController()
            vc.onDone = { [weak self] days in
                print("пришло:", days)                 // <- для проверки
                self?.selectedDays = days
                self?.collectionView.reloadData()
            }
            present(vc, animated: true)
        default:
            break
        }
    }
}
