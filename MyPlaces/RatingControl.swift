//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Artyom Potapov on 22.07.2022.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    var rating = 0 {
        didSet{
            updateButtonSelectionState()
        }
    }
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44, height: 44){
        didSet{
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5{
        didSet{
            setupButtons()
        }
    }
    
    //MARK: - Инициализация
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    @objc func ratingButtomTAPPED(button: UIButton){
        guard let index = ratingButtons.firstIndex(of: button) else {return}
        
        let selectedRating = index + 1
                    // считаем рейтинг выбранной звезды
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    func setupButtons(){
        
        for button in ratingButtons{
                    //этот цикл нужен для перебора и удаления сначала всех звезд из списка сабвью, а потом их же из самого stackView. А после этого звезды будут заново созданы и добавлены в следующем цикле, по настройке в интерфейсе IB, которая появилась там после использования @IBInspectable и обозревателя свойств {didSet{...}} Это нужно только для самой первой загрузки, и для отладочной работы в IB, когда я меняю число звёзд через интерфейс. Потом же, при работе программы это обнуление вызываться не будет. Тут демонстрация работы разработчика с @IBInspectable и
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
                    //load button images
        let filledStar = UIImage(systemName: "star.fill")
        let emptyStar = UIImage(systemName: "star")
        let highlightedStar = UIImage(systemName: "star.leadinghalf.filled")
        
        for _ in 0..<starCount{
            let button = UIButton()
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])

            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            button.addTarget(self, action: #selector(ratingButtomTAPPED), for: .touchUpInside)
            
            addArrangedSubview(button)
            
            ratingButtons.append(button)
        }
                    // этот вызов нужен для отображения текущего состояния звёзд в интерфейсе IB
        updateButtonSelectionState()
    }
    
    func updateButtonSelectionState(){
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
    
}
