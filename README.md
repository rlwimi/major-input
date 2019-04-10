![MajorInput icon](./MajorInput/Assets.xcassets/AppIcon.appiconset/iTunesArtwork@2x-60@3x.png)

# Major Input

a novel iPad UI for reading WWDC session transcripts alongside the video/presentation context

![Tour GIF](Resources/screenshots/tour.gif)

## Getting Started

Build Major Input yourself with Xcode 10.2 to your iPad running iOS 11 or higher, which of course requires use of your own developer account. Major Input will also run on the iPad simulator, but the UX is not designed for this purpose.

Note that sessions and transcripts from 2017 and earlier are bundled in the build, and 2018 sessions will remain missing until the content is more dynamically sourced.

1. *Get the code*

    Clone the repo, or download a zip, depending on how you want to get future updates.
1. *Install dependencies*
    ```
    cd <$SRCROOT>
    carthage bootstrap --no-build --no-use-binaries
    pod install
    ```
1. *Configure code signing*

    Select the MajorInput project in the Project Navigator. For both Targets, MajorInput and MajorInputTests, select your own Development Team in the General tab's Signing section Team picker.

1. *Build and run*

    Build the MajorInput scheme.

## Usage

Select a session, wait for the video to download if it hasn't already, and consume it. The blue transformer to the right of the text aligns the sync point between the transcript text and the video time, as does the small blue triangle in the filmstrip.

#### Session selection:

* Tap a session or its `DOWNLOAD` button to download the session.
* Tap `CANCEL` during a download to cancel the download.
* Tap `DELETE` to remove the downloaded video from the filesystem.
* Tap a session with a downloaded video to consume the session.

#### Session consumption:

* Drag either the transformer, the transcript, or the filmstrip to scrub the video.
* Tap a caption in the transcript to scroll that caption to the transformer.
* After dragging the transformer, you'll see a blue line indicating the transformer's anchor point. Tap the transformer to scroll it and the transcript back to the anchor point.
* Tap-and-drag the transformer to move its anchor point.
* Double tap the transformer to play/pause the video.
* Tap the video to show the linear video scrubber and back button.

#### Putting it all together

* Look at the filmstrip to quickly spot the video frame that provides the best presentation context for the transcript lines you're about to read.
* Use the transformer to scrub the video to that frame, then read the transcript.
* Tap the transformer to scroll things back to the anchor point (assuming it's still near the top).
* Wash, rinse, repeat.
