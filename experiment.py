import pandas as pd
import re
import os
import sys
import multiprocessing as mp
import time

releasy_path = os.path.join('..','..','dev','releasy')
# releasy_path = os.path.join('..','..','..','dev','releasy2')

repo_path = os.path.abspath(os.path.join('..','..','repos'))
# repo_path = os.path.abspath(os.path.join('..','..','..','repos2'))

threads = 10
#threads = 4

releasy_module = os.path.abspath(releasy_path)
sys.path.insert(0, releasy_module)
    
import releasy
from releasy.miner_git import GitVcs
from releasy.miner import TagReleaseMiner, TimeVersionReleaseSorter, PathCommitMiner, RangeCommitMiner, TimeCommitMiner, TimeNaiveCommitMiner, VersionReleaseMatcher, VersionReleaseSorter, TimeReleaseSorter, VersionWoPreReleaseMatcher

def analyze_project(name, lang, suffix_exception_catalog, release_exception_catalog):
    try:
        start = time.time()
        path = os.path.abspath(os.path.join(repo_path,name))
        if name in suffix_exception_catalog:
            suffix_exception = suffix_exception_catalog[name]
        else:
            suffix_exception = None
        if name in release_exception_catalog:
            release_exceptions = release_exception_catalog[name]
        else:
            release_exceptions = None
        
        vcs = GitVcs(path)
        release_matcher = VersionWoPreReleaseMatcher(suffix_exception=suffix_exception, 
                                                     release_exceptions=release_exceptions)
        release_miner = TagReleaseMiner(vcs, release_matcher)
        releases = release_miner.mine_releases()

        version_sorter = TimeVersionReleaseSorter()
        releases_wbase = version_sorter.sort(releases)

        path_miner = PathCommitMiner(vcs, releases)
        range_miner = RangeCommitMiner(vcs, releases_wbase)
        time_miner = TimeCommitMiner(vcs, releases_wbase)
        time_naive_miner = TimeNaiveCommitMiner(vcs, releases_wbase)
    
        path_release_set = path_miner.mine_commits()
        range_release_set = range_miner.mine_commits()
        time_release_set = time_miner.mine_commits()
        time_naive_release_set = time_naive_miner.mine_commits()
        
        stats = []
        for release in releases:
            if f"{name}@{release.name}" not in release_exception_catalog:
                path_commits = set(path_release_set[release.name].commits)
                range_commits = set(range_release_set[release.name].commits)
                time_commits = set(time_release_set[release.name].commits)
                # time_naive_commits = set(time_naive_release_set[release.name].commits)
            
                path_base_releases = [release.name.value for release in (path_release_set[release.name].base_releases or [])]
                range_base_releases = [release.name.value for release in (range_release_set[release.name].base_releases or [])]
                time_base_releases = [release.name.value for release in (time_release_set[release.name].base_releases or [])]
                # time_naive_base_releases = [release.name.value for release in (time_naive_release_set[release.name].base_releases or [])]

                stats.append({
                    "project": name,
                    "name": release.name.value,
                    "version": release.name.version,
                    "semantic_version": release.name.semantic_version,
                    "prefix": release.name.prefix,
                    "suffix": release.name.suffix,
                    "lang": lang,
                    "head": str(release.head.id),
                    "time": release.time,
                    "committers": len(path_release_set[release.name].committers),
                    "commits": len(path_commits),
                    "merges": len(path_release_set[release.name].merges),
                    "base_releases": path_base_releases,
                    "base_releases_qnt": len(path_base_releases),
                    "range_commits": len(range_commits),
                    "range_base_releases": range_base_releases,
                    "range_tpos": len(path_commits & range_commits),
                    "range_fpos": len(range_commits - path_commits),
                    "range_fneg": len(path_commits - range_commits),
                    "time_commits": len(time_commits),
                    "time_base_releases": time_base_releases,
                    "time_tpos": len(path_commits & time_commits),
                    "time_fpos": len(time_commits - path_commits),
                    "time_fneg": len(path_commits - time_commits),
                    # "time_naive_commits": len(time_naive_commits),
                    # "time_naive_base_releases": time_naive_base_releases,
                    # "time_naive_tpos": len(path_commits & time_naive_commits),
                    # "time_naive_fpos": len(time_naive_commits - path_commits),
                    # "time_naive_fneg": len(path_commits - time_naive_commits)
                })
        releases = pd.DataFrame(stats)
        print(f"{time.time() - start:10} - {name}") 
        return releases
    except Exception as e:
        print(f" {name} - error: {e}")

if __name__ ==  '__main__':
    projects = pd.read_pickle('projects.zip')

    releases = pd.DataFrame()
    suffix_exception_catalog = {
        "spring-projects/spring-boot": "^.RELEASE$",
        "spring-projects/spring-framework": "^.RELEASE$",
        "netty/netty": "^.Final$",
        "godotengine/godot": "^-stable$",
    }

    release_exception_catalog = {
        "facebook/react": [
            "15.3.1",
            "15.3.2",
            "16.1.0",
            "v15.7.0", #clone
            "v16.14.0" #clone
        ], 
        "facebook/react-native": [
            "0.60.2"
        ],
        "nodejs/node": [
            "heads/tags/v0.5.6"
        ], 
        "vercel/next.js": [
            "v2.4.2"
        ], 
        "ionic-team/ionic-framework": [
            "1.0.0"
        ], 
        "grafana/grafana": [
            "6.1.6",
            "7.0.0",
            "7.2.1"
        ], 
        "vercel/hyper": [
            "v0.7.0",
            "v0.7.1"
        ], 
        "nestjs/nest": [
            "6.3.1"
        ], 
        "apache/dubbo": [
            "2.7.6"
        ], 
        "psf/requests": [
            "2.0"
        ], 
        "huggingface/transformers": [
            "0.1.2",
            "0.5.0",
            "1.0",
            "3.0.1",
            "v0.2.0" #clone
        ], 
        "laravel/laravel": [
            "v4.0.8" # clone
        ], 
        "laravel/framework": [
            "5.3"
        ], 
        "dotnet/efcore": [
            "rel/1.0.1",
            "release/2.2",
            "release/3.0",
            "v2.1.23", #clone
            "v2.1.10", #clone
            "v2.1.13", #clone
            "v2.1.16", #clone
            "v2.1.17", #clone
            "v2.1.19", #clone
            "v2.1.20", #clone
            "v2.1.21", #clone
            "v2.2.7",  #clone
            "v2.2.8"  #clone
        ], 
        "aspnetboilerplate/aspnetboilerplate": [
            "v.5.1.0",
            "v0.7.3.0", # clone
            "v5.10.1",  # clone
            "v5.12"     # clone
        ], 
        "SignalR/SignalR": [
            "v0.3.5",
            "0.5"
        ],
        "AutoMapper/AutoMapper": [
            "3.3.1"
        ], 
        "sinatra/sinatra": [
            "1.0",
            "v1.1.0",
            "v1.1.1",
            "v1.1.2",
            "v1.1.3",
            "v1.1.4",
            "v1.2.0",
            "v1.2.1",
            "v1.2.2",
            "v1.2.3",
            "v1.2.4",
            "v1.2.5",
            "v1.2.6",
            "v1.2.7",
            "v1.2.8",
            "v1.2.9",
            "v1.3.0",
            "v1.3.1",
            "v1.3.2",
            "v1.3.3",
            "v1.3.4",
            "v1.3.5",
            "v1.3.6",
            "v1.4.0",
            "v1.4.1",
            "v1.4.2",
            "v1.4.3"
        ], 
        "hashicorp/terraform": [
            "0.7.7"
        ],
        "rclone/rclone": [
            "v1.46" #clone
        ],
        "istio/istio": [
            "1.0.7", #clone
            "1.1.2"  #clone
        ],
        "XX-net/XX-Net": [
            "1.14.5", #clone
            "1.15.0"  #clone
        ],
        "alibaba/fastjson": [
            "1.2.37" #clone
        ],
        "briannesbitt/Carbon": [
            "1.26.1", #clone
            "1.38.3"  #clone
        ],
        "vuetifyjs/vuetify": [
            "v0.8.3" #clone
        ],
        "microsoft/TypeScript": [
            "v1.5.4" #clone
        ],
        "psf/requests": [
            "v2.16.3" #clone
        ],
        "Wox-launcher/Wox": [
            "v1.0.0.185" #clone
        ],
        "jellyfin/jellyfin": [
            "v10.0.1" #clone
        ],
        "radareorg/radare2": [
            "1.0" #clone
        ],
        "v2ray/v2ray-core": [
            "v0.14.2", #clone
            "v2.19.2", #clone
            "v2.19.6", #clone
            "v2.36.3", #clone
            "v2.40.2", #clone
            "v2.41",   #clone
            "v3.11.3", #clone
            "v3.18",   #clone
            "v3.22",   #clone
            "v3.25", #clone
            "v3.38",   #clone
            "v3.46.4"  #clone
        ]
    }
        
    # pool = mp.Pool(processes=10, maxtasksperchild=10)
    pool = mp.Pool(processes=threads, maxtasksperchild=threads)
    results = [pool.apply_async(analyze_project, args=(project.Index, project.lang, suffix_exception_catalog, release_exception_catalog)) for project in projects.itertuples()]
    data = [p.get() for p in results]
    releases = pd.concat(data)

    releases.commits = pd.to_numeric(releases.commits)
    releases.time = pd.to_datetime(releases.time, utc=True)
    releases.range_commits = pd.to_numeric(releases.range_commits)
    releases.range_tpos = pd.to_numeric(releases.range_tpos)
    releases.range_fpos = pd.to_numeric(releases.range_fpos)
    releases.range_fneg = pd.to_numeric(releases.range_fneg)
    releases.time_commits = pd.to_numeric(releases.time_commits)
    releases.time_tpos = pd.to_numeric(releases.time_tpos)
    releases.time_fpos = pd.to_numeric(releases.time_fpos)
    releases.time_fneg = pd.to_numeric(releases.time_fneg)
    releases = releases.set_index(['project', 'name'])

    releases.to_pickle("raw_releases.zip")
    releases.to_csv("raw_releases.csv")
