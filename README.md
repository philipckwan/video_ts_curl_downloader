# video_ts_curl_downloader
This is a shell based tool using curl to loop download video in .ts format.  
Then, you can combine them to become one single .ts file.  
Also, support loop download images in .jpg format.  


Features
-

Some of the common websites streams videos by splitting it into multiple smaller files.<br/>
The files are usually in .ts format.<br/>
Given one who understand a little bit about how to view the source of loading a webpage, and in this case, streaming videos by multiple .ts files, he can leverage this tool to loop download the whole video.

Currently, this tool is proven to work at the following site(s):<br/>
https://gimy.app/<br/>

Preparation before running the tool
-

You need to first click into the page where the video is streaming.<br/>
Then, open the browser Developer Tool.<br/>
At the "Network" tab, you will notice multiple .ts files are being downloaded.<br/>
Right click on any one of the .ts file, then choose "Copy" -> "Copy as cURL" in order to get the full "curl" command line example.<br/>
Then, open ts_curl_downloader.sh using a text editor, or preferably code editor such as VSCode.<br/>
Find the example line that constructs the curl argument:<br/>
curl 'https://abcde.com/video'$j'.ts' \
and replace it with the curl arguments copied from the Developer Tool.<br/>
Update the url part where it loops, replace it with '$j' so that this tool can loop download it.<br/><br/>
Be aware of the last line:<br/>
  --compressed<br/>
you should remove it and just use the default, as it has the '\\' character at the end so that it can continue on with the rest of the command lines:<br/>
  --compressed \\
<br/>
Save the file and move on to the next step to run the command line.<br/>

Command Arguments
-

./ts_curl_downloader.sh <start index> <end index> curl|cat|clear <number padding><br/>

This is an example of a run of the tool:<br/>

```
$ ./ts_curl_downloader.sh 0 347 curl 0
...
do_curl: 1.0;
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  524k  100  524k    0     0   337k      0  0:00:01  0:00:01 --:--:--  339k
0/347 done
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  561k  100  561k    0     0   367k      0  0:00:01  0:00:01 --:--:--  369k
1/347 done
...
```

In this case, the video should go from 0.ts to 347.ts. <br/>
With the "curl" command, it will be downloading the files using "curl".<br/>
The last argument "0" means that the source file does not pad '0' to the URL.<br/><br/>

After the download is completed, you should see files "0.ts" to "347.ts" in your folder.<br/>
You may quick check a file by opening it to see if it is downloaded.<br/>
you may run this command to combine all the ts files into one single file.<br/>

```
$ ./ts_curl_downloader.sh 0 347 cat 0
...
do_cat: 1.0;
...
```

In this case, the "cat" argument specify the tool to combine files from "0.ts" to "347.ts".<br/>
The resulting file will be named "out.ts".<br/>



