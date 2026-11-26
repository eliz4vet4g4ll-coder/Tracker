import UIKit

final class OptionCell: UICollectionViewCell {
    static let identifier = "OptionCell"
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()      // серая подпись: выбранная категория / дни
    let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
    let separator = UIView()
    private let textStack = UIStackView()
    
    override var isHighlighted: Bool {
        didSet { contentView.alpha = isHighlighted ? 0.6 : 1 }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor.systemGray6
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 16
        
        titleLabel.font = .systemFont(ofSize: 17)
        subtitleLabel.font = .systemFont(ofSize: 17)
        subtitleLabel.textColor = .systemGray
        
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)
        
        arrow.tintColor = .systemGray
        separator.backgroundColor = .systemGray3
        
        [textStack, arrow, separator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            arrow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrow.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
