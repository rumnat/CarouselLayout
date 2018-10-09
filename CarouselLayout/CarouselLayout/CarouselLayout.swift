//
//  CarouselLayout.swift
//  CarouselLayout
//
//  Created by Anton Muratov on 10/9/18.
//  Copyright © 2018 Anton Muratov. All rights reserved.
//

import UIKit

class CarouselLayout: UICollectionViewFlowLayout {
    private var cachedItemsAttributes: [IndexPath : UICollectionViewLayoutAttributes] = [:]
    
    var spacing: CGFloat = 30.0
    var spacingWhenFocused: CGFloat = 60.0
    
    // MARK: - Lifecycle
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if newBounds.size != collectionView?.bounds.size { cachedItemsAttributes.removeAll() }
        return true
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        if context.invalidateDataSourceCounts { cachedItemsAttributes.removeAll() }
        super.invalidateLayout(with: context)
    }
    
    override var collectionViewContentSize: CGSize {
        let leftmostEdge = cachedItemsAttributes.values.map { $0.frame.minX }.min() ?? 0
        let rightmostEdge = cachedItemsAttributes.values.map { $0.frame.maxX }.max() ?? 0
        return CGSize(width: rightmostEdge - leftmostEdge, height: itemSize.height)
    }
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        updateInsets()
        collectionView.decelerationRate = .fast
        
        guard cachedItemsAttributes.isEmpty else { return }
        
        let itemsCount = collectionView.numberOfItems(inSection: 0)
        for item in 0..<itemsCount {
            let indexPath = IndexPath(row: item, section: 0)
            cachedItemsAttributes[indexPath] = createAttributesForItem(at: indexPath)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = cachedItemsAttributes[indexPath] else { return nil }
        return shiftedAttributes(from: attributes)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedItemsAttributes
            .map { $0.value }
            .filter { $0.frame.intersects(rect) }
            .map { shiftedAttributes(from: $0) }
    }
    
    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        
        let midX: CGFloat = collectionView.bounds.size.width / 2
        guard let closestAttributes = findClosestAttributes(toX: proposedContentOffset.x + midX) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        
        return CGPoint(x: closestAttributes.center.x - midX, y: proposedContentOffset.y)
    }
    
    // MARK: - Private
    
    private func createAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else { return nil }
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame.size = itemSize
        attributes.frame.origin.x = CGFloat(indexPath.item) * (itemSize.width + spacing)
        attributes.frame.origin.y = (collectionView.bounds.height - itemSize.height) / 2
        return attributes
    }
    
    private func updateInsets() {
        guard let collectionView = collectionView else { return }
        
        let inset = (collectionView.bounds.size.width - itemSize.width) / 2
        collectionView.contentInset.left = inset
        collectionView.contentInset.right = inset
    }
    
    private func findClosestAttributes(toX xPosition: CGFloat) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else { return nil }
        
        let searchRect = CGRect(
            x: xPosition - collectionView.bounds.width,
            y: collectionView.bounds.minY,
            width: collectionView.bounds.width * 2,
            height: collectionView.bounds.height
        )
        
        return layoutAttributesForElements(in: searchRect)?.min { abs($0.center.x - xPosition) < abs($1.center.x - xPosition) }
    }
    
    private var continousFocusedIndex: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let offset = collectionView.bounds.width / 2 + collectionView.contentOffset.x - itemSize.width / 2
        return offset / (itemSize.width + spacing)
    }
    
    private func shiftedAttributes(from attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let attributes = attributes.copy() as? UICollectionViewLayoutAttributes else { fatalError("Couldn't copy attributes") }
        let roundedFocusedIndex = round(continousFocusedIndex)
        guard attributes.indexPath.item != Int(roundedFocusedIndex) else { return attributes }
        let shiftArea = (roundedFocusedIndex - 0.5)...(roundedFocusedIndex + 0.5)
        let distanceToClosestIdentityPoint = min(abs(continousFocusedIndex - shiftArea.lowerBound), abs(continousFocusedIndex - shiftArea.upperBound))
        let normalizedShiftFactor = distanceToClosestIdentityPoint * 2
        let translation = (spacingWhenFocused - spacing) * normalizedShiftFactor
        let translationDirection: CGFloat = attributes.indexPath.item < Int(roundedFocusedIndex) ? -1 : 1
        attributes.transform = CGAffineTransform(translationX: translationDirection * translation, y: 0)
        return attributes
    }
}
