# Using Halcon to Achieve Velocity Recognition

## Environment

#### Halcon

HALCON HDevelop 18.11 Steady (64-bit) with Free License

#### Matlab

MATLAB R2019a

## Usage

| Filename       | Description            | DEtail                                                       |
| -------------- | ---------------------- | ------------------------------------------------------------ |
| demo.hdev      | halcon source file,    | used to extract the position of your target                  |
| main_medfilt.m | matlab main scrip file | analyze the position of your target, output results in graphs |
| main_butter.m  | matlab main scrip file | analyze the position of your target, output results in graphs |

#### Using halcon to generate position data from images

`demo.hdev` consists the image processing code，which run on the `Halcon` environment. Make sure images are put into the `images` folder at the same level of  `demo.hdev`.

A sample image:

![velocity_cognition_sample_pic](https://raw.githubusercontent.com/lvliangxiong/images-bed/master/images/velocity-recognition-sample-pic.gif)

To compute the velocity of the target requires a few pictures, which consumes much space, so here I just give you a sample picture.

Main principle of this image processing code is to recognize the target by color threshold, then compute its contour center and orientation. Final results will outputted as a `Points.dat` file in the `images` folder. 

The `demo.hdev` run on the `Halcon`  is like this:

![demo](https://raw.githubusercontent.com/lvliangxiong/images-bed/master/images/halcon-velocity-recognition.gif)

#### Using Matlab to compute velocity

With positions, compute velocity can be an easy stuff. But the main obstacle lies in that the positions obtained are really noisy-filled data. This can be very severe especially when at an high image shot rate (frames). 

To handle this, two approaches based on a mean-median filter and Butterworth filter respectively are implemented in Matlab, detail in `main_medfilt.m` and `main_butter.m`.

Sample results are shown below:

![velocity & acceleration](https://raw.githubusercontent.com/lvliangxiong/images-bed/master/images/velocity%20%26%20acceleration.jpg)

As you can see, the raw result is terrible, but after filtering, it seems much better. For sure, appropriate filter parameters should find by yourself.

