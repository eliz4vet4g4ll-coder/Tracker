import UIKit

final class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    var daylyCouner = 0 {
        didSet {
            daysLabel.text = daysText(daylyCouner)
        }
    }
    
    var isDone: Bool = false {
        didSet {
            updatePlusButton()
        }
    }
    
    let cardView = UIView()
    let nameLabel = UILabel()
    let daysLabel = UILabel()
    let emojiLabel = UILabel()
    
    var onPlusTapped: (() -> Void)?
    let plusButton = UIButton(type: .system)
    
    var baseColor = UIColor.colorSelection5{
        didSet {
                cardView.backgroundColor = baseColor
                updatePlusButton()
            }
    }
    
    // MARK: Кнопка добавления трекера
    
    func setPlusButton(){
        plusButton.setTitle("+", for: .normal)
        plusButton.setTitleColor(.white, for: .normal)
        plusButton.backgroundColor = cardView.backgroundColor
        plusButton.layer.cornerRadius = 17
        
        plusButton.addTarget(self, action: #selector(plusButtonAction(_:)), for: .touchUpInside)
    }
    
    @objc func plusButtonAction(_ sender: UIButton) {
        onPlusTapped?()
    }
    
    private func updatePlusButton() {
        if isDone {
            // светлее + галочка
            plusButton.backgroundColor = baseColor.withAlphaComponent(0.3)
            plusButton.setTitle(nil, for: .normal)
            plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            plusButton.tintColor = .white
        } else {
            // обычная кнопка с плюсом
            plusButton.backgroundColor = baseColor
            plusButton.setImage(nil, for: .normal)
            plusButton.setTitle("+", for: .normal)
        }
    }
    
    // MARK: Настройка отображения кол-ва дней
    
    private func daysText(_ n: Int) -> String {
        let lastTwo = n % 100
        let last = n % 10
        if lastTwo >= 11 && lastTwo <= 14 { return "\(n) дней" }
        switch last {
        case 1: return "\(n) день"
        case 2...4: return "\(n) дня"
        default: return "\(n) дней"
        }
    }
    
    // MARK: показ на экране
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // окошко трекера
        cardView.backgroundColor = .colorSelection5
        cardView.layer.cornerRadius = 16
        
        // название
        nameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 2
        
        // эмодзи
        emojiLabel.font = .systemFont(ofSize: 16)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(emojiLabel)
        
        // счетчик дней
        daysLabel.text = String(daylyCouner) + " дней"
        daysLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        setPlusButton()
        
        
        [cardView, daysLabel, plusButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            
            plusButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
