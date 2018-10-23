#! /bin/bash

instruments \
-t "/Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate" \
/Users/kimimaro/Library/Application Support/iPhone Simulator/5.1/Applications/179B2666-606C-4C29-9C5D-8051839AC546/NewsTest.app \
-e UIASCRIPT /Users/kimimaro/workspaces/ss_app_ios/tools/ss_test/delay_to_background.js \
