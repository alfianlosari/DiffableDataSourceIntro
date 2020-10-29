//
//  CharacterListViewController.swift
//  CharactersGrid
//
//  Created by Alfian Losari on 10/11/20.
//

import Combine
import UIKit
import SwiftUI

typealias SectionCharactersTuple = (section: Section, characters: [Character])

class CharacterListViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var segmentedControl = UISegmentedControl(
        items: Universe.allCases.map { $0.title }
    )
    var backingStore: [SectionCharactersTuple]

    private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Character>!
    private var headerRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!
    
    private lazy var listLayout: UICollectionViewLayout = {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.headerMode = .supplementary
        return UICollectionViewCompositionalLayout.list(using: listConfig)
    }()
        
    init(sectionedCharacters: [SectionCharactersTuple] = Universe.ff7r.sectionedStubs) {
        self.backingStore = sectionedCharacters
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSegmentedControl()
        setupBaritems()
    }
    
    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        navigationItem.titleView = segmentedControl
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    private func setupBaritems() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "shuffle"), style: .plain, target: self, action: #selector(shuffleTapped)),
            UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise.circle"), style: .plain, target: self, action: #selector(resetTapped))
        ]
    }
    
    private func setupCollectionView() {
        collectionView = .init(frame: view.bounds, collectionViewLayout: listLayout)
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        
        cellRegistration = UICollectionView.CellRegistration(
            handler: { (cell: UICollectionViewListCell, _, character: Character) in
                var content = cell.defaultContentConfiguration()
                content.text = character.name
                content.secondaryText = character.job
                content.image = UIImage(named: character.imageName)
                content.imageProperties.maximumSize = .init(width: 60, height: 60)
                content.imageProperties.cornerRadius = 30
                cell.contentConfiguration = content
            })
        
        headerRegistration = UICollectionView.SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader, handler: { [weak self] (header: UICollectionViewListCell, _, indexPath) in
            guard let self = self else { return }
            let (section, characters) = self.backingStore[indexPath.section]
            var content = header.defaultContentConfiguration()
            content.text = section.headerTitleText(count: characters.count)
            header.contentConfiguration = content
        })
        
        collectionView.dataSource = self
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        backingStore = sender.selectedUniverse.sectionedStubs
        collectionView.reloadData()
    }
    
    @objc private func shuffleTapped(_ sender: Any) {
       // TODO: Implement Shuffle Array for backing store
    }
    
    @objc private func resetTapped(_ sender: Any) {
        // TODO: Reset backing store to initial state
    }
        
    required init?(coder: NSCoder) {
        fatalError("Please initialize programaticaly instead of using Storyboard/XiB")
    }

}

extension CharacterListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        backingStore.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        backingStore[section].characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let character = backingStore[indexPath.section].characters[indexPath.item]
        let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: character)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        return headerView
    }
    
}

struct CharacterListViewControllerRepresentable: UIViewControllerRepresentable {
    
    let sectionedCharacters: [SectionCharactersTuple]
    
    func makeUIViewController(context: Context) -> some UIViewController {
        UINavigationController(rootViewController: CharacterListViewController(sectionedCharacters: sectionedCharacters))
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
}

struct CharacterList_Previews: PreviewProvider {
    
    static var previews: some View {
        CharacterListViewControllerRepresentable(sectionedCharacters: Universe.ff7r.sectionedStubs)
            .edgesIgnoringSafeArea(.vertical)
    }
    
}
