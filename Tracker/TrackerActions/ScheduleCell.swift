import UIKit

final class ScheduleCell: UITableViewCell {
    static let identifier = "ScheduleCell"
    
    let titleLabel = UILabel()
    let daySwitch = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        // фон и скругления у самой ячейки, а не у contentView
        backgroundColor = .ypDayBackground
        layer.masksToBounds = true
        layer.cornerRadius = 16
        
        daySwitch.onTintColor = .ypBlue
        
        [titleLabel, daySwitch].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
