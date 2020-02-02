import os
import requests
import re
import json
from threading import Thread
from concurrent.futures import ThreadPoolExecutor

base_url = "https://www.pearvideo.com/"
file_path = "/FYPlayer/FYPlayer/video_list.json"

# 获取首页信息
def get_index():
    res = requests.get(base_url, headers={
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
        "User-Agent": "Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1"
    })
    return res.text
# 解析首页
def parse_index(text):
    urls = re.findall(r'<a href="(.*?)" class="vervideo-lilink actplay"', text)
    urls = [base_url + item for item in urls]
    return urls

def get_detail_info(text):
    res = requests.get(text)
    return res.text

def parse_detail(text):
    video_url = re.search(r'srcUrl="(.*?.mp4)"', text).group(1)
    title = re.search(r'<h1 class="video-tt">(.*?)</h1>', text).group(1)
    summary = re.search(r'<div class="summary">(.*?)</div>', text).group(1)
    source = re.search(r'<p class="copy-right-clare">(.*?)</p>', text).group(1)
    date = re.search(r'<div class="date">(.*?)</div>', text).group(1)
    # 通过alt辨别封面图
    imageRe = '<img class="img" src="(.*?)" alt=\"%s\">' % title
    image_url = re.search(imageRe, text).group(1)
    return {"title": title, "video_url": video_url, "image_url": image_url, "summary": summary, "source": source, "date": date}
# 为main开启线程
pool = ThreadPoolExecutor(5)

if __name__ == "__main__":
    index_data = get_index()
    detail_urls = parse_index(index_data)
    json_content = []

    for item in detail_urls[:30]:
        detail = get_detail_info(item)
        info = parse_detail(detail)
        json_content.append(info)
    
    result = json.dumps(json_content,indent=4,ensure_ascii=False)
    with open(file_path, "w", encoding="utf-8") as file:
        file.write(result)
