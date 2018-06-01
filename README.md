## VHS tapes digitazing script.
Simple bash script that invokes [FFMPEG](https://www.ffmpeg.org/) with parameters well suited for converting my old VHS tapes.
### My Equipment
1. Laptop with Ubuntu 18.04
2. [USBTV007 EasyCAP](https://linuxtv.org/wiki/index.php/Easycap#USBTV007_EasyCAP)
3. VHS player

## Usage
Video converting script.
```bash
bash -- convert.sh -h
````
Script for trimming unneeded footage at the begging and end of a video file.
```bash
bash -- truncate.sh -h
```
Interactive launcher for scripts above
```bash
bash -- launcher.sh [-l LANG] [-d DIR]
```
Available options:
- `LANG` - display language *ru* or *en*
- `DIR` - directory which will be used to save captured video stream or to read video stream for cutting.
