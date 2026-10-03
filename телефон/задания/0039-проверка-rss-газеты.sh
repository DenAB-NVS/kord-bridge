#!/data/data/com.termux/files/usr/bin/bash
# Только метаданные открытых RSS: статус, количество и последняя дата.
echo '=== 0039 RSS ГАЗЕТЫ ==='
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 - 2>/dev/null' <<'PY'
from concurrent.futures import ThreadPoolExecutor
from urllib.request import Request,urlopen
from urllib.error import HTTPError,URLError
from xml.etree import ElementTree as ET
from email.utils import parsedate_to_datetime
from datetime import datetime
feeds=[('HUGGINGFACE','https://huggingface.co/blog/feed.xml'),('DEEPMIND','https://deepmind.google/blog/rss.xml'),('MIT_NEWS','https://news.mit.edu/rss/feed')]
def check(item):
 name,url=item
 try:
  with urlopen(Request(url,headers={'User-Agent':'Mozilla/5.0 KordGazeta-SourceCheck/0.1'}),timeout=10) as r:
   data=r.read(600000)
   if r.status!=200:return name+' HTTP '+str(r.status)
  root=ET.fromstring(data)
  items=root.findall('.//item')
  if not items:items=root.findall('.//{*}entry')
  dates=[]
  for x in items:
   s=x.findtext('pubDate') or x.findtext('{*}published') or x.findtext('{*}updated')
   if not s:continue
   try:dates.append(parsedate_to_datetime(s).date().isoformat())
   except ValueError:
    try:dates.append(datetime.fromisoformat(s.replace('Z','+00:00')).date().isoformat())
    except ValueError:pass
  return name+' HTTP 200 ITEMS '+str(len(items))+' DATED '+str(len(dates))+' LATEST_UTC_DAY '+(max(dates) if dates else 'unknown')
 except HTTPError as e:return name+' HTTP '+str(e.code)
 except URLError as e:return name+' NETWORK_ERROR '+type(e.reason).__name__
 except Exception as e:return name+' ERROR '+type(e).__name__
with ThreadPoolExecutor(max_workers=3) as pool:
 for result in pool.map(check,feeds):print(result)
PY
echo '=== КОНЕЦ 0039 ==='
