// 10x primitive: duolingo/points-counter v2
import SwiftUI

@available(iOS 17.0, *)
struct PointsSpendRowConfig {
    var titleFont: Font = .system(.subheadline, design: .rounded, weight: .bold)
    var descriptionFont: Font = .system(.footnote, design: .rounded, weight: .regular)
    var descriptionColor: Color = PlayfulTokens.inkSecondary
    var priceFont: Font = .system(.subheadline, design: .rounded, weight: .heavy)
    var priceTint: Color = PlayfulTokens.accentSecondary
    /// Optional capsule behind the price. The reference shop shows a bare
    /// glyph + tinted number, so `nil` (default) renders no chip.
    var priceChipFill: Color? = nil
    /// Points glyph beside the price; match the paired `PointsCounter`.
    var currencyGlyph: Image = Image(systemName: "diamond.fill")
    /// Owned/claimed marker: quiet caps text, per the reference rows.
    var ownedText: String = "Owned"
    var ownedTint: Color = PlayfulTokens.inkSecondary
    var iconTint: Color = PlayfulTokens.purple
    /// Card chrome: each row is its own bordered card in the reference shop.
    var cardFill: Color = PlayfulTokens.surface
    var cardBorder: Color = PlayfulTokens.border
}

/// Spend-row style of the points system (absorbed shop-item-row): a bordered
/// card with an icon slot, name + description, and a trailing points-glyph
/// price. Owned items swap the price for quiet caps text; unaffordable items
/// render dimmed and inert.
@available(iOS 17.0, *)
struct PointsSpendRow: View {
    var title: String
    var description: String
    var price: Int
    var isOwned: Bool = false
    /// When false the row dims and the price chip is inert.
    var isAffordable: Bool = true
    /// Icon slot; neutral sparkle by default.
    var icon: Image = Image(systemName: "wand.and.stars")
    var config: PointsSpendRowConfig = PointsSpendRowConfig()
    var onPurchase: () -> Void = {}

    var body: some View {
        HStack(spacing: 14) {
            icon
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(config.iconTint)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(config.titleFont)
                Text(description)
                    .font(config.descriptionFont)
                    .foregroundStyle(config.descriptionColor)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 10)
            trailing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            let shape = RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard,
                                         style: .continuous)
            shape.fill(config.cardFill)
                .overlay(shape.strokeBorder(config.cardBorder, lineWidth: 2))
        }
        .opacity(isOwned || isAffordable ? 1 : 0.5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title). \(description)")
        .accessibilityValue(accessibilityValue)
    }

    @ViewBuilder private var trailing: some View {
        if isOwned {
            Text(config.ownedText)
                .font(config.priceFont)
                .textCase(.uppercase)
                .kerning(0.6)
                .foregroundStyle(config.ownedTint)
        } else {
            Button(action: onPurchase) {
                HStack(spacing: 5) {
                    config.currencyGlyph.font(.system(size: 13, weight: .bold))
                    Text("\(price)").font(config.priceFont).monospacedDigit()
                }
                .foregroundStyle(config.priceTint)
                .padding(.horizontal, config.priceChipFill == nil ? 0 : 12)
                .padding(.vertical, config.priceChipFill == nil ? 0 : 8)
                .background {
                    if let chipFill = config.priceChipFill {
                        Capsule().fill(chipFill)
                        Capsule().strokeBorder(config.priceTint.opacity(0.4), lineWidth: 1.5)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(!isAffordable)
            .accessibilityLabel("Buy for \(price)")
        }
    }

    private var accessibilityValue: String {
        if isOwned { return config.ownedText }
        return isAffordable ? "Price \(price)" : "Price \(price), not affordable"
    }
}

#Preview("Spend rows") {
    VStack(spacing: 12) {
        PointsSpendRow(title: "Streak Shield", description: "Protects your streak for one missed day.",
                       price: 200, icon: Image(systemName: "shield.fill"))
        PointsSpendRow(title: "Double Boost", description: "Earn twice the points for 15 minutes.",
                       price: 100, icon: Image(systemName: "bolt.fill"))
        PointsSpendRow(title: "Extra Outfit", description: "A fresh look for your profile.",
                       price: 500, isOwned: true)
        PointsSpendRow(title: "Mega Bundle", description: "Everything at once.", price: 5000,
                       isAffordable: false, icon: Image(systemName: "gift.fill"))
    }
    .padding(.horizontal, 20)
}
