#!/data/data/com.termux/files/usr/bin/bash
# Только HTTP-коды/типы ответа; не сохранять и не печатать содержимое страниц.
echo '=== 0038 ИСТОЧНИКИ ГАЗЕТЫ ==='
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 - 2>/dev/null' <<'PY'
from concurrent.futures import ThreadPoolExecutor
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError
sources = [
 ('OPENAI','https://openai.com/news/'),
 ('ANTHROPIC','https://www.anthropic.com/news'),
 ('GOOGLE_RESEARCH','https://research.google/blog/'),
 ('HUGGINGFACE','https://huggingface.co/blog'),
 ('MIT_AI','https://news.mit.edu/topic/artificial-intelligence2'),
]
def check(item):
 name,url=item
 try:
  req=Request(url,headers={'User-Agent':'Mozilla/5.0 (compatible; KordGazeta-SourceCheck/0.1)'})
  with urlopen(req,timeout=8) as r:
   content_type=r.headers.get_content_type()
   sample=r.read(4096)
   return name+' STATUS '+str(r.status)+' TYPE '+content_type+' BYTES '+str(len(sample))
 except HTTPError as e: return name+' HTTP_ERROR '+str(e.code)
 except URLError as e: return name+' NETWORK_ERROR '+type(e.reason).__name__
 except Exception as e: return name+' ERROR '+type(e).__name__
with ThreadPoolExecutor(max_workers=5) as pool:
 for result in pool.map(check,sources): print(result)
PY
echo '=== КОНЕЦ 0038 ==='
