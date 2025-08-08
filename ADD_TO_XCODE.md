# Files to Add to Xcode Project

The following new files need to be added to the Xcode project:

## Models Group
- `Rachel/Models/Theme.swift`

## Managers Group
- `Rachel/Managers/IAPManager.swift`

## Views/Components Group
- `Rachel/Views/Components/ThemedBackground.swift`
- `Rachel/Views/Components/ThemedCardBack.swift`

## Views/Screens Group
- `Rachel/Views/Screens/ThemeSelectionView.swift`

## How to Add Files to Xcode:
1. Open `Rachel.xcodeproj` in Xcode
2. Right-click on the appropriate group in the project navigator
3. Select "Add Files to Rachel..."
4. Navigate to and select each file
5. Make sure "Copy items if needed" is unchecked (files are already in place)
6. Make sure "Rachel" target is checked
7. Click "Add"

Once these files are added, the build errors should be resolved.