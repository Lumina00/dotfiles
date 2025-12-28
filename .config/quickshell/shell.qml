//@ pragma ShellId shell

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "bar" as Bar
//import "notifications" as Notifs

ShellRoot {
	Process {
		command: ["mkdir", "-p", ShellGlobals.rtpath]
		running: true
	}


//	Notifs.NotificationOverlay {
//		screen: Quickshell.screens.find(s => s.name == "DP-1")
//	}

	Variants {
		model: Quickshell.screens

		Scope {
			property var modelData

			Bar.Bar {
				screen: modelData
			}

			PanelWindow {
				id: window

				screen: modelData

				exclusionMode: ExclusionMode.Ignore
//				WlrLayershell.layer: WlrLayer.Background
				WlrLayershell.namespace: "shell:background"

				anchors {
					top: true
					bottom: true
					left: true
					right: true
				}

			}
		}
	}
}
