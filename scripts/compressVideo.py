#!/usr/bin/env python3

import argparse
import subprocess
import json
import os
import sys

def get_duration(input_file):
    """Gets the duration of the video in seconds using ffprobe."""
    cmd = [
        'ffprobe', '-v', 'quiet', '-print_format', 'json', 
        '-show_entries', 'format=duration', input_file
    ]
    try:
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        data = json.loads(result.stdout)
        return float(data['format']['duration'])
    except (subprocess.CalledProcessError, KeyError, ValueError) as e:
        print(f"Error: Could not read video duration. Is it a valid video file? Detail: {e}")
        sys.exit(1)

def compress_video(input_path, output_dir, target_size_mb):
    """Compresses a video to a specific target megabyte size using 2-pass encoding."""
    if not os.path.isfile(input_path):
        print(f"Error: Input file does not exist: {input_path}")
        sys.exit(1)

    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate output file path
    base_name = os.path.basename(input_path)
    name, ext = os.path.splitext(base_name)
    output_path = os.path.join(output_dir, f"{name}_compressed{ext}")

    print(f"Analyzing {input_path}...")
    duration = get_duration(input_path)
    
    # Calculate target bitrates (leaving a 5% margin for file system overhead safety)
    target_size_bits = (target_size_mb * 0.95) * 1024 * 1024 * 8
    audio_bitrate = 128000  # 128 kbps
    
    total_bitrate = target_size_bits / duration
    video_bitrate = int(total_bitrate - audio_bitrate)
    
    # Floor limit so it doesn't break on hyper-low bitrates
    if video_bitrate < 100000:
        video_bitrate = 100000
    
    print(f"Targeting size: < {target_size_mb} MB")
    print(f"Calculated video bitrate: {video_bitrate // 1000} kbps")

    try:
        # Pass 1
        print("\nRunning Pass 1/2...")
        pass1_cmd = [
            'ffmpeg', '-y', '-i', input_path, 
            '-c:v', 'libx264', '-b:v', str(video_bitrate), 
            '-pass', '1', '-an', '-f', 'null', os.devnull
        ]
        subprocess.run(pass1_cmd, check=True)

        # Pass 2
        print("\nRunning Pass 2/2...")
        pass2_cmd = [
            'ffmpeg', '-y', '-i', input_path, 
            '-c:v', 'libx264', '-b:v', str(video_bitrate), 
            '-pass', '2', '-c:a', 'aac', '-b:a', '128k', output_path
        ]
        subprocess.run(pass2_cmd, check=True)
        
        print(f"\nSuccess! Compressed video saved to: {output_path}")

    except subprocess.CalledProcessError as e:
        print(f"\nFFmpeg Error: Encoding failed. Ensure ffmpeg is installed and accessible.")
    finally:
        # Clean up FFmpeg 2-pass log files in the current running directory
        for file in ['ffmpeg2pass-0.log', 'ffmpeg2pass-0.log.mbtree']:
            if os.path.exists(file):
                os.remove(file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Compress video files down to a specific target MB size.")
    parser.add_argument("input", help="Path to the source video file")
    parser.add_argument("outdir", help="Directory where the compressed video should be saved")
    parser.add_argument("size", type=int, help="Target maximum size in Megabytes (MB)")
    
    args = parser.parse_args()
    
    compress_video(args.input, args.outdir, args.size)

