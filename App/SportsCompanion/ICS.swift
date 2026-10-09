import Foundation

/// Minimal iCalendar reader. Feeds are written for scores apps, so everything
/// that comes out of here is treated as hostile until it has been cleaned.
enum ICS {

    struct Raw {
        var summary: String
        var start: Date
        var end: Date?
        var categories: String?
    }

    // MARK: Parsing

    static func parse(_ text: String) -> [Raw] {
        var out: [Raw] = []
        var summary: String?
        var start: Date?
        var end: Date?
        var categories: String?
        var inEvent = false

        for line in unfold(text) {
            if line == "BEGIN:VEVENT" {
                inEvent = true; summary = nil; start = nil; end = nil; categories = nil
                continue
            }
            if line == "END:VEVENT" {
                if inEvent, let s = summary, let d = start {
                    out.append(Raw(summary: s, start: d, end: end, categories: categories))
                }
                inEvent = false
                continue
            }
            guard inEvent else { continue }

            let (name, params, value) = split(line)
            switch name {
            case "SUMMARY":    summary = unescape(value)
            case "CATEGORIES": categories = unescape(value)
            case "DTSTART":    start = date(value, params: params)
            case "DTEND":      end = date(value, params: params)
            default: break
            }
        }
        return out
    }

    /// A line beginning with a space or tab continues the one before it.
    private static func unfold(_ text: String) -> [String] {
        var lines: [String] = []
        for raw in text.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: "\n") {
            if let first = raw.first, first == " " || first == "\t", !lines.isEmpty {
                lines[lines.count - 1] += raw.dropFirst()
            } else {
                lines.append(raw)
            }
        }
        return lines
    }

    private static func split(_ line: String) -> (String, [String: String], String) {
        guard let colon = line.firstIndex(of: ":") else { return ("", [:], "") }
        let lhs = String(line[line.startIndex..<colon])
        let value = String(line[line.index(after: colon)...])
        let bits = lhs.components(separatedBy: ";")
        var params: [String: String] = [:]
        for bit in bits.dropFirst() {
            let kv = bit.components(separatedBy: "=")
            if kv.count == 2 { params[kv[0].uppercased()] = kv[1] }
        }
        return (bits[0].uppercased(), params, value)
    }

    private static func unescape(_ s: String) -> String {
        s.replacingOccurrences(of: "\\n", with: " ")
         .replacingOccurrences(of: "\\,", with: ",")
         .replacingOccurrences(of: "\\;", with: ";")
         .replacingOccurrences(of: "\\\\", with: "\\")
         .trimmingCharacters(in: .whitespaces)
    }

    private static func date(_ value: String, params: [String: String]) -> Date? {
        var cal = Calendar(identifier: .gregorian)
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")

        if value.hasSuffix("Z") {
            f.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
            f.timeZone = TimeZone(identifier: "UTC")
            return f.date(from: value)
        }
        if value.count == 8 {
            f.dateFormat = "yyyyMMdd"
            f.timeZone = params["TZID"].flatMap(TimeZone.init(identifier:)) ?? .current
            cal.timeZone = f.timeZone
            return f.date(from: value)
        }
        f.dateFormat = "yyyyMMdd'T'HHmmss"
        f.timeZone = params["TZID"].flatMap(TimeZone.init(identifier:)) ?? .current
        return f.date(from: value)
    }
}

// MARK: - Cleaning

extension ICS {

    /// Anything that looks like a score, anywhere in the string, is removed.
    /// This fails closed on purpose: losing part of a title is a nuisance,
    /// leaking a result ends the product.
    static func stripResults(_ text: String) -> String {
        var s = text

        // (2-2)  [2:2]  (2 – 2)  and bare 2-2 near the end
        let patterns = [
            #"\s*[\(\[]\s*\d{1,3}\s*[-–—:]\s*\d{1,3}\s*[\)\]]"#,
            #"\s*[\(\[]\s*\d{1,3}\s*[-–—:]\s*\d{1,3}\s*[,;]\s*[^\)\]]*[\)\]]"#,   // (2-2, pens)
            #"\s+\d{1,3}\s*[-–—:]\s*\d{1,3}\s*$"#,
            #"\s*[\(\[](?:aet|pens?|ot|after extra time)[\)\]]"#
        ]
        for p in patterns {
            s = s.replacingOccurrences(of: p, with: "", options: [.regularExpression, .caseInsensitive])
        }
        return s.trimmingCharacters(in: .whitespaces)
    }

    /// A trailing [CL] style tag names the competition. Returns the tag and the
    /// title without it.
    static func extractTag(_ text: String) -> (title: String, tag: String?) {
        guard let r = text.range(of: #"\s*\[[A-Za-z0-9 .\-]{1,24}\]\s*"#,
                                 options: .regularExpression) else {
            return (text.trimmingCharacters(in: .whitespaces), nil)
        }
        let tag = text[r]
            .trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
        var title = text
        title.removeSubrange(r)
        return (title.trimmingCharacters(in: .whitespaces), tag)
    }
}
