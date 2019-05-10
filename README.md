# meetworth-release
The release version of Meetworth, an android application that helps you meetup with your friends.

# Local Setup
To create apk or appbundle file locally:
1. Clone this git repository
2. Make sure you have [Flutter](https://flutter.dev/docs/get-started/install) in your local environment, this project uses Flutter dev channel
3. Run this command  in ./meetworth directory:
    ```
    $ flutter packages get
    ```
4. Build apk:
    ```
    $ flutter build apk
    ```
5. Connect your device and run:
    ```
    $ flutter install
    ```
**Note:**
Java KeyStore file is not provided, you may have to create your own key
