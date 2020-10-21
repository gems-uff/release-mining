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


def match(ground_truth, reference, release):
    base_releases = ground_truth[release.name].base_releases
    if reference[release.name].base_releases:
        match = reference[release.name].base_releases[0] in base_releases
        basename = reference[release.name].base_releases[0]
    else:
        basename = None
        if not base_releases:    
            match = True
        else:
            match = False
    return match, basename


def analyze_reference(name, suffix_exception_catalog, release_exception_catalog):
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

        timeversion_sorter = TimeVersionReleaseSorter()
        version_sorter = VersionReleaseSorter()
        time_sorter = TimeReleaseSorter()
        describe_sorter = DescribeReleaseSorter()

        path_miner = PathCommitMiner(vcs, releases)
       
        path_release_set = path_miner.mine_commits()
        timeversion_releases = timeversion_sorter.sort(releases) 
        version_releases = version_sorter.sort(releases) 
        time_releases = time_sorter.sort(releases) 
        describe_releases = describe_sorter.sort(releases)

        stats = []
        for release in releases:
            if f"{name}@{release.name}" not in release_exception_catalog:
                path_base_releases = [release.name.value for release in (path_release_set[release.name].base_releases or [])]
                base_releases = path_release_set[release.name].base_releases
                qnt = len(base_releases)
                timeversion_match, timeversion_basename = match(path_release_set, timeversion_releases, release)
                version_match, version_basename = match(path_release_set, version_releases, release)
                time_match, time_basename = match(path_release_set, time_releases, release)
                describe_match, describe_basename = match(path_release_set, describe_releases, release)

                stats.append({
                    "project": name,
                    "name": release.name.value,
                    "base_releases": qnd,
                    "basenames": path_base_releases,
                    "timeversion_match": timeversion_match,
                    "timeversion_basename": timeversion_basename,
                    "version_match": version_match,
                    "version_basename": version_basename,
                    "time_match": time_match,
                    "time_basename": time_basename,
                    "describe_match": describe_match,
                    "describe_basename": describe_basename
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
    results = [pool.apply_async(analyze_reference, args=(project.Index, suffix_exception_catalog, release_exception_catalog)) for project in projects.itertuples()]
    data = [p.get() for p in results]
    releases = pd.concat(data)

    releases.base_releases = pd.to_numeric(releases.base_releases)
    releases = releases.set_index(['project', 'name'])

    releases.to_pickle("raw_releases_references.zip")
    releases.to_csv("raw_releases_references.csv")
