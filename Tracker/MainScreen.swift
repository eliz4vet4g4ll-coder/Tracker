// UI главного экрана

import UIKit
import Foundation


final class MainScreenViewController: UIViewController{
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var backgroundStar = UIImageView()
    let plusButton = UIButton()
    let treckerLabel = UILabel()
    let textLabel = UILabel()
    
    var categories: [TrackerCategory] = [] // все трекеры
    var currentDate = Date()
    var visibleCategories: [TrackerCategory] = []  // категории для выбранной даты
    var completedTrackers: [TrackerRecord] = []
    var completedTrackerIds: Set<UUID> = []   // id трекеров, выполненных в currentDate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackColor()
        setStar()
        setTreckerLabel()
        setPlusButton()
        setStarText()
        setSearchField()
        setDatePicker()
        
        setCollection()
        updatePlaceholder()
    }
    
    // MARK: функции элементов
    
    func setBackColor() {
        if traitCollection.userInterfaceStyle == .dark{
            view.backgroundColor = .ypBlack
        } else {view.backgroundColor = .ypWhite}
    }
    
    private func setStar(){
        backgroundStar = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "star")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        view.addSubview(backgroundStar)
        
        NSLayoutConstraint.activate([
                    backgroundStar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    backgroundStar.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    }
    
    private func setStarText(){
        textLabel.text = "Что будем отслеживать?"
        textLabel.textColor = .ypBlack
        textLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(textLabel)
        
        textLabel.topAnchor.constraint(equalTo: backgroundStar.bottomAnchor, constant: 8).isActive = true
        textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setTreckerLabel(){
        treckerLabel.text = "Трекеры"
        treckerLabel.textColor = .ypBlack
        treckerLabel.font = .systemFont(ofSize: 34, weight: .bold)
        
        treckerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(treckerLabel)
        
        treckerLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 44).isActive = true
        treckerLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    }
    
    private func setPlusButton(){
        plusButton.setImage(UIImage(named: "PlusBtn"), for: .normal)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(plusButton)
        
        plusButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        plusButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 6).isActive = true
        
        plusButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let addTracker = AddTrackerController()
        addTracker.modalPresentationStyle = .pageSheet
        if let sheet = addTracker.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.preferredCornerRadius = 16
            sheet.prefersGrabberVisible = false
        }
        addTracker.onTrackerCreated = { [weak self] category in
            self?.addTracker(from: category)
        }
        present(addTracker, animated: true)
    }
    
    func setSearchField(){
        let searchField = UISearchBar()
        searchField.searchBarStyle = .minimal
        searchField.placeholder = "Поиск"
        searchField.searchTextField.backgroundColor = .ypLightGray
        searchField.searchTextField.layer.cornerRadius = 30
        
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(searchField)
        
        searchField.topAnchor.constraint(equalTo: treckerLabel.bottomAnchor, constant: 7).isActive = true
        searchField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        searchField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        searchField.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    private func setDatePicker(){
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.date = Date()
        picker.preferredDatePickerStyle = .compact
        picker.backgroundColor = .ypLightGray
        
        picker.clipsToBounds = true
        picker.layer.cornerRadius = 16
        
        picker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(picker)
        
        picker.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        picker.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
    }
    
    @objc func datePickerChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateVisibleCategories()
    }
    
    // MARK: - настройка отображения по датам
    private func updateVisibleCategories() {
        updateCompletedIds()
        
        let index = (Calendar.current.component(.weekday, from: currentDate) + 5) % 7
        guard let weekday = Weekday(rawValue: index) else { return }
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { $0.schedule.contains(weekday) }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        
        collectionView.reloadData()
        updatePlaceholder()
    }
    
    private func toggleTracker(_ tracker: Tracker) {
        // нельзя отмечать будущие даты
        guard Calendar.current.startOfDay(for: currentDate) <= Date() else { return }
        
        if isCompleted(tracker) {
            // убираем отметку: создаём новый массив без этой записи
            completedTrackers = completedTrackers.filter {
                !($0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate))
            }
        } else {
            completedTrackers = completedTrackers + [TrackerRecord(trackerId: tracker.id, date: currentDate)]
        }
        
        updateCompletedIds()
        collectionView.reloadData()
    }

    private func isCompleted(_ tracker: Tracker) -> Bool {
        completedTrackerIds.contains(tracker.id)
    }
    
    // прячет и показывает заглушку
    private func updatePlaceholder() {
        let isEmpty = visibleCategories.isEmpty
        backgroundStar.isHidden = !isEmpty
        textLabel.isHidden = !isEmpty
    }
    
    // MARK: настройки коллекции
    
    private func setCollection() {
        collectionView.backgroundColor = .clear
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerHeaderView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: treckerLabel.bottomAnchor, constant: 60),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: заполняет шпаргалку для выбранного дня
    private func updateCompletedIds() {
        completedTrackerIds = Set(
            completedTrackers
                .filter { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                .map { $0.trackerId }
        )
    }
    
    // MARK: приём нового трекера
    private func addTracker(from newCategory: TrackerCategory) {
        let exists = categories.contains { $0.title == newCategory.title }
        
        if exists {
            // собираем НОВЫЙ массив: нужную категорию пересоздаём, остальные оставляем
            categories = categories.map { category in
                category.title == newCategory.title
                    ? TrackerCategory(title: category.title,
                                      trackers: category.trackers + newCategory.trackers)
                    : category
            }
        } else {
            categories = categories + [newCategory]
        }
        updateVisibleCategories()
    }
}


// MARK: - UICollectionViewDataSource

extension MainScreenViewController: UICollectionViewDataSource {
    
    // одна секция на каждую категорию
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        cell.nameLabel.text = tracker.name
        cell.emojiLabel.text = tracker.emoji
        cell.baseColor = tracker.color
        cell.isDone = isCompleted(tracker)
        cell.daylyCouner = completedTrackers.filter { $0.trackerId == tracker.id }.count
        cell.onPlusTapped = { [weak self] in
            self?.toggleTracker(tracker)
        }
        return cell
    }
    
    // заголовок секции = название категории
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerHeaderView.identifier,
                for: indexPath) as? TrackerHeaderView else {
            return UICollectionReusableView()
        }
        header.titleLabel.text = visibleCategories[indexPath.section].title
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainScreenViewController: UICollectionViewDelegateFlowLayout {
    
    // две карточки в ряд
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 16 - 16 - 9) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
}
