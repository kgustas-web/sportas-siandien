import SwiftUI

struct EventRow: View {
    let event: Event
    var now: Date
    /// Sessions inside an expanded occasion sit tighter and carry no metadata.
    var compact: Bool = false

    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .subheadline) private var timeWidth: CGFloat = 52
    @ScaledMetric(relativeTo: .subheadline) private var gutter: CGFloat = 16

    private var stacked: Bool { typeSize >= .accessibility1 }
    private var live: Bool { event.state(at: now) == .live }

    /// Something happening now always speaks up, whatever it is.
    private var weight: Prominence { live ? .surfaced : event.prominence }

    var body: some View {
        Group {
            if stacked {
                VStack(alignment: .leading, spacing: 4) { timeText; content }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: gutter) {
                    timeText.frame(width: timeWidth, alignment: .leading)
                    content
                }
            }
        }
        .padding(.vertical, compact ? 2 : 0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(a11yLabel)
    }

    private var timeText: some View {
        Text(event.timeLabel)
            .font(.subheadline)
            .monospacedDigit()
            .foregroundStyle(weight == .quiet ? .tertiary : .secondary)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(event.title)
                    .font(titleFont)
                    .foregroundStyle(weight == .quiet ? .secondary : .primary)
                if live {
                    Spacer(minLength: 0)
                    LiveTag()
                }
            }

            if let reason = event.reason {
                Text(reason)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .padding(.top, 3)
            }

            if let note = event.note {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 5)
            }

            if !compact, let meta = metaLine {
                Text(meta)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
        }
    }

    /// Hierarchy is carried by type alone — no badges, no colour, no icons.
    private var titleFont: Font {
        if compact { return .subheadline }
        switch weight {
        case .surfaced: return .headline          // 17 semibold
        case .normal:   return .body              // 17 regular
        case .quiet:    return .subheadline       // 15 regular, secondary
        }
    }

    private var metaLine: String? {
        var parts = [event.competition]
        if let a = event.availability(at: now) {
            parts.append(event.expiryNote(at: now).map { "\(a) · \($0)" } ?? a)
        } else if let c = event.channel {
            parts.append(c)
        }
        return parts.joined(separator: " · ")
    }

    private var a11yLabel: String {
        var bits = [event.timeLabel, event.title]
        if live { bits.append("on now") }
        if let r = event.reason { bits.append(r) }
        if let m = metaLine { bits.append(m) }
        return bits.joined(separator: ", ")
    }
}

/// A live event needs to read at a glance without shouting, and without a score.
struct LiveTag: View {
    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(.tint).frame(width: 6, height: 6)
            Text("On now")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .accessibilityHidden(true)
    }
}
