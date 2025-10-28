## Task Description

 - Write a solution using Docker + Ansible
 - The Solution should spin up a Linux host which will show the newest/last frame from the given stream
 - Stream URL: https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4
 - For web hosting NGINX can be used, and for stream processing ffmpeg docker image can be used
 - The frame should be shown at the index level
 - NGINX Configuration should not affect the availability of the solution
 - If I got everything right should be this image


![Bird pooping](./last_frame.jpg)

## Testing in My Environment

First I will run the ffmpeg command locally found in ffmpeg-lastframe.sh to obtain the image and test the ffmpeg script.


## Building a Dockerfile based on ffmpeg official image which will do the same 
Commands to build and run the image for ffmpeg:
```{bash}
mkdir output
```

```{bash}
docker build -t my-ffmpeg:2 .
```


```{bash}
docker run -v $(pwd)/output:/output my-ffmpeg:2 .
```

