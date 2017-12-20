
#!/bin/sh
file=$1
#取得媒体文件名，其实可以使用basename命令取得
file_name=`echo ${file} | awk -F '.' '{ print $1}'`
#创建最终存放路径
mkdir -p /mnt/media/app/${file_name}
#转码，目标分辨率为480X270的flv文件
ffmpeg -i $1 -acodec libmp3lame -ar 44100 -ab 32k -vcodec libx264 -b 250k -i_qfactor 0.71 -maxrate 800k -bufsize 96k -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -aspect 16:9 -s 480X270 /mnt/media/app/${file_name}/${file_name}-src.flv
cd /mnt/media/app/${file_name}
#给flv文件增加关键帧
yamdi -i ${file_name}-src.flv -o ${file_name}.flv
#转成ts文件以供切片
ffmpeg -y -i ${file_name}.flv -f mpegts -c:v copy -c:a copy -vbsf h264_mp4toannexb ${file_name}.ts
#切片
ffmpeg -i ${file_name}.ts -c copy -map 0 -f segment -segment_list fa.m3u8 -segment_time 10 ${file_name}-fa-%03d.ts
#修改m3u8文件
sed -i '/'"${file_name}"'/ s/^/http\:\/\/118.72.252.199\/hls\/'"${file_name}"'\//g' fa.m3u8
#完成后删除临时文件
rm -fr ${file_name}.flv ${file_name}-src.flv ${file_name}.ts
