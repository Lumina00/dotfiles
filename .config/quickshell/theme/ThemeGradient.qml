pragma Singleton
import QtQuick

// ─────────────────────────────────────────────
// ThemeGradient — 공유 그라데이션 테마 싱글톤
// ─────────────────────────────────────────────
// 두 가지 그라데이션 계열:
//   light — 밝은 핑크 → 흰핑크 (슬라이더, 프로그레스 바)
//   dark  — 진한 마젠타 → 퍼플 (아이콘 배경, 버튼)
//
// 사용법:
//   Rectangle { gradient: ThemeGradient.light.horizontal }
//   Rectangle { gradient: ThemeGradient.dark.horizontal }
//   Text { color: ThemeGradient.light.start }
// ─────────────────────────────────────────────

QtObject {
    id: root

    // ══════════════════════════════════════════
    // Light 계열 — 밝은 핑크 그라데이션
    // 슬라이더, 프로그레스 바, Theme 버튼 등
    // ══════════════════════════════════════════
    readonly property QtObject light: QtObject {
        readonly property color start: "#F9C8E8"   // 연한 핑크
        readonly property color mid:   "#F2A5D7"   // 밝은 핑크
        readonly property color end:   "#E8D5F0"   // 라벤더/흰핑크

        readonly property Gradient horizontal: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: light.start }
            GradientStop { position: 0.5; color: light.mid }
            GradientStop { position: 1.0; color: light.end }
        }

        readonly property Gradient vertical: Gradient {
            GradientStop { position: 0.0; color: light.start }
            GradientStop { position: 0.5; color: light.mid }
            GradientStop { position: 1.0; color: light.end }
        }

        readonly property Gradient soft: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: light.start }
            GradientStop { position: 1.0; color: light.end }
        }

        readonly property Gradient reversed: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: light.end }
            GradientStop { position: 0.5; color: light.mid }
            GradientStop { position: 1.0; color: light.start }
        }
    }

    // ══════════════════════════════════════════
    // Dark 계열 — 진한 마젠타/퍼플 그라데이션
    // 아이콘 배경, 원형 버튼, 강조 요소 등
    // ══════════════════════════════════════════
    readonly property QtObject dark: QtObject {
        readonly property color start: "#D06CC0"   // 진한 핑크
        readonly property color mid:   "#A845B5"   // 마젠타
        readonly property color end:   "#7B28A8"   // 딥 퍼플

        readonly property Gradient horizontal: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: dark.start }
            GradientStop { position: 0.5; color: dark.mid }
            GradientStop { position: 1.0; color: dark.end }
        }

        readonly property Gradient vertical: Gradient {
            GradientStop { position: 0.0; color: dark.start }
            GradientStop { position: 0.5; color: dark.mid }
            GradientStop { position: 1.0; color: dark.end }
        }

        readonly property Gradient soft: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: dark.start }
            GradientStop { position: 1.0; color: dark.end }
        }

        readonly property Gradient reversed: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: dark.end }
            GradientStop { position: 0.5; color: dark.mid }
            GradientStop { position: 1.0; color: dark.start }
        }

        // 아이콘/버튼 배경용 (반투명)
        readonly property Gradient iconBg: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(dark.start.r, dark.start.g, dark.start.b, 0.35) }
            GradientStop { position: 1.0; color: Qt.rgba(dark.end.r, dark.end.g, dark.end.b, 0.35) }
        }
    }

    // ══════════════════════════════════════════
    // 공통 — 배경 및 텍스트 색상
    // ══════════════════════════════════════════
    readonly property color bgDark:        "#1A1020"
    readonly property color bgCard:        "#2A1830"
    readonly property color bgSurface:     "#3A2040"

    readonly property color textPrimary:   "#FFFFFF"
    readonly property color textSecondary: "#B0A0B8"

    // ── 글로우/하이라이트용 (매우 투명) ──
    readonly property Gradient glow: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0; color: Qt.rgba(light.mid.r, light.mid.g, light.mid.b, 0.15) }
        GradientStop { position: 0.5; color: Qt.rgba(dark.mid.r, dark.mid.g, dark.mid.b, 0.10) }
        GradientStop { position: 1.0; color: "transparent" }
    }
}
