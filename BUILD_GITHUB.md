# XITFORGE GitHub build

This repository already contains `JASONXIT.xcodeproj`, so the workflow builds that existing project directly. It does not assume `XITFORGE.xcodeproj` exists.

1. Push the contents of this folder to GitHub.
2. Open **Actions → Build XITFORGE iOS**.
3. Choose **Run workflow**.
4. Download the `XITFORGE-unsigned-IPA` artifact.

The visible app name is XITFORGE; the internal Xcode project and scheme remain JASONXIT for compatibility with the included project file.
