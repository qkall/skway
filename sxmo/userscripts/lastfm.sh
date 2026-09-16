#!/usr/bin/env python3
# title="$icon_mus Last.FM Scraper"
# sxmo userscript: lastfm-links (wofi version)

import urllib.request
import urllib.parse
import subprocess
import re
import sys
import json

def notify(msg):
    subprocess.run(["notify-send", "Last.FM Scraper", msg])

def wofi_menu(options, prompt):
    proc = subprocess.run(
        ["wofi", "--show", "dmenu", "--prompt", prompt],
        input="\n".join(options), text=True, stdout=subprocess.PIPE
    )
    return proc.stdout.strip()

def main():
    library_url = "https://www.last.fm/user/<insert username>/library"

    try:
        req = urllib.request.Request(library_url, headers={"User-Agent": "Mozilla/5.0 (X11; Linux x86_64)"})
        html = urllib.request.urlopen(req, timeout=5).read().decode('utf-8')
    except Exception as e:
        notify("Failed to reach Last.fm profile page.")
        sys.exit(1)

    artist_match = re.search(r'class="chartlist-artist"[^>]*>\s*<a[^>]*>([^<]+)</a>', html)
    track_match = re.search(r'class="chartlist-name"[^>]*>\s*<a[^>]*>([^<]+)</a>', html)

    if not artist_match or not track_match:
        notify("Could not parse recent track from HTML page.")
        sys.exit(1)

    artist = artist_match.group(1).strip()
    title = track_match.group(1).strip()

    query = f"{artist} {title}"
    encoded_q = urllib.parse.quote_plus(query)

    yt_url = f"https://www.youtube.com/results?search_query={encoded_q}"
    lfm_artist = urllib.parse.quote_plus(artist)
    lfm_track = urllib.parse.quote_plus(title)
    lastfm_url = f"https://www.last.fm/music/{lfm_artist}/_/{lfm_track}"
    qobuz_url = f"https://www.qobuz.com/us-en/search?q={encoded_q}"

    try:
        itunes_api = f"https://itunes.apple.com/search?term={encoded_q}&entity=song&limit=1"
        req = urllib.request.Request(itunes_api, headers={"User-Agent": "Mozilla/5.0"})
        res = urllib.request.urlopen(req, timeout=3).read().decode("utf-8")
        itunes_data = json.loads(res)
        
        if itunes_data.get("resultCount", 0) > 0:
            itunes_track_url = itunes_data["results"][0]["trackViewUrl"]
            odesli_api = f"https://api.song.link/v1-alpha.1/links?url={urllib.parse.quote_plus(itunes_track_url)}"
            req2 = urllib.request.Request(odesli_api, headers={"User-Agent": "Mozilla/5.0"})
            res2 = urllib.request.urlopen(req2, timeout=3).read().decode("utf-8")
            odesli_data = json.loads(res2)
            
            links = odesli_data.get("linksByPlatform", {})
            if "qobuz" in links:
                qobuz_url = links["qobuz"]["url"]
    except Exception:
        pass

    def shorten(u):
        try:
            api = "https://da.gd/s?url=" + urllib.parse.quote_plus(u)
            req = urllib.request.Request(api, headers={"User-Agent": "curl/7.0"})
            res = urllib.request.urlopen(req, timeout=3).read().decode("utf-8").strip()
            return res if res.startswith("https://da.gd/") else u
        except:
            return u

    short_yt = shorten(yt_url)
    short_lfm = shorten(lastfm_url)
    short_qobuz = shorten(qobuz_url)

    qobuz_text = f'Check out the track "{title}" by {artist} on Qobuz!: {short_qobuz}'
    yt_text = f'Check out the track "{title}" by {artist} on YouTube: {short_yt}'
    all_text = f'"{title}" by {artist}. Qobuz: {short_qobuz} | YT: {short_yt} | Last.fm: {short_lfm}'

    options = ["Copy Qobuz Link", "Copy YouTube Link", "Copy All Links"]
    action = wofi_menu(options, f"Found: {artist} - {title}")

    clipboard_text = ""
    if action == "Copy Qobuz Link":
        clipboard_text = qobuz_text
    elif action == "Copy YouTube Link":
        clipboard_text = yt_text
    elif action == "Copy All Links":
        clipboard_text = all_text

    if clipboard_text:
        try:
            subprocess.run(["wl-copy"], input=clipboard_text, text=True, check=True)
        except Exception:
            subprocess.run(["xclip", "-selection", "clipboard"], input=clipboard_text, text=True)
        notify("Copied to clipboard!")

if __name__ == "__main__":
    main()
