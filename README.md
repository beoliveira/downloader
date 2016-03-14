# downloader, an exercise in minimalism and simplicity

Downloader is an app for iOS that aims to bring a missing but important functionality to iOS: Downloading things. Unfortunately, the App Store is filled with options that try to take advantage of this necessity, but that exploit it with ads and deliver a horrible experience.

Therefore the goal of this project is to create a simple app that downloads things, with the following constraints:
- App size < 10mb (could be a lot smaller but the Swift libs add a lot)
- Use only system provided fonts and UI components
- Leverage other open-source projects to avoid reimplementing things. Keep it to a minimum
- Do not implement functionality that can be available in other apps (i.e through extensions)
- Keep it simple

The goal of minimalism and simplicity also aims to make the codebase easy to update in the future.
