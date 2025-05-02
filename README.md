<a id="readme-top"></a>

<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="MusicPlayer/Resources/readmeLogo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="left">README to</h3>


  
</div>

<h1 align="center">MusicPlayer</h1>

### Group Members:Yuao Ai, Pengfei Liu, Zhao Wang  



![](MusicPlayer/Resources/readmeIcon.png)

<!-- ABOUT THE PROJECT -->
## About The Project




#### Perform the following: 
Introduce it


### Acknowledgements and References



<!-- GETTING STARTED -->
## Getting Started

This is a guide of how to build my project locally.


### Prerequisites

##### Add Firebase SDK. 
1. In Xcode, with your app project open, navigate to File > Add packages.  

2. When prompted, enter the Firebase iOS SDK repository URL:<https://github.com/firebase/firebase-ios-sdk>.    

3. Select the SDK version that you want to use.
We recommend using the default (latest) SDK version, but you can use an older version, if needed.




##### Add Deepseek SDK
Follow the last step but use link: <https://github.com/tornikegomareli/DeepSwiftSeek.git>

###  Environment Variables Setup

1. Open your project in Xcode.  
2. In the menu bar, select **Product > Scheme > Edit Scheme…** (or press `⌘<`).
3. In the scheme editor:
   - Select **Run** in the left-hand panel.
   - Click the **Arguments** tab.
   - Under **Environment Variables**, click the **+** button.

4. Add a new environment variable:
   - **Name:** `DEEPSEEK_API_KEY`  
   - **Value:** `your_api_key`.  
 You can find these two values in `Config.xcconfig`

*This step is important*.  







### Run

_Below is an example of how you can instruct your audience on installing and setting up your app. This template doesn't rely on any external dependencies or services._

1. Download dataset at [Yelp Dataset](https://www.yelp.com/dataset) and put it in `dataset/` 
2.  Enjoy!
<p align="right">(<a href="#readme-top">back to top</a>)</p>

  
## Directory Structure

| Folder (MusicPlayer/) | Contents                                                                | 
|-----------------------|-------------------------------------------------------------------------|
| Views/                | Views that define the app's user interface                              | 
| ViewModels/           | Observable Object classes that handle view logic and bind data to views |
| Models/               | Connect to Datavase, and access data                                    |
| Resources/            | App resources like: tones, pictures                                     |
| Utils/                | Some helper classes                                                     
| AppEnter.swift        | App's entry                                                             
| MainView.swift        | Main view                                                               

## Contact

Aya -  yai104@syr.edu.  
Pengfei -   
Zhao -



