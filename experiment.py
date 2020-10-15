import pandas as pd
import re
import os
import sys
import multiprocessing as mp
import time

releasy_module = os.path.abspath(os.path.join('..','..','dev','releasy'))
sys.path.insert(0, releasy_module)
    
import releasy
from releasy.miner_git import GitVcs
from releasy.miner import TagReleaseMiner, PathCommitMiner, RangeCommitMiner, TimeCommitMiner, VersionReleaseMatcher, VersionReleaseSorter, TimeReleaseSorter, VersionWoPreReleaseMatcher

projects = pd.read_pickle('projects.zip')

releases = pd.DataFrame()
suffix_exception_catalog = {
    "spring-projects/spring-boot": "^.RELEASE$",
    "spring-projects/spring-framework": "^.RELEASE$",
    "netty/netty": "^.Final$",
    "godotengine/godot": "^-stable$",
}

release_exception_catalog = {}
release_exception_catalog["facebook/react@15.3.1"] = True
release_exception_catalog["facebook/react@15.3.2"] = True
release_exception_catalog["facebook/react@16.1.0"] = True
release_exception_catalog["facebook/react@native 0.60.2"] = True
release_exception_catalog["nodejs/node@heads/tags/v0.5.6"] = True
release_exception_catalog["vercel/next@js v2.4.2"] = True
release_exception_catalog["ionic-team@ionic-framework 1.0.0"] = True
release_exception_catalog["grafana/grafana@6.1.6"] = True
release_exception_catalog["grafana/grafana@7.0.0"] = True
release_exception_catalog["vercel/hyper@v0.7.0"] = True
release_exception_catalog["vercel/hyper@v0.7.1"] = True
release_exception_catalog["nestjs/nest@6.3.1"] = True
release_exception_catalog["apache/dubbo@2.7.6"] = True
release_exception_catalog["psf/requests@2.0"] = True
release_exception_catalog["huggingface/transformers@0.1.2"] = True
release_exception_catalog["huggingface/transformers@0.5.0"] = True
release_exception_catalog["huggingface/transformers@1.0"] = True
release_exception_catalog["huggingface/transformers@3.0.1"] = True
release_exception_catalog["laravel/framework@5.3"] = True
release_exception_catalog["dotnet/efcore@rel/1.0.1"] = True
release_exception_catalog["dotnet/efcore@release/2.2"] = True
release_exception_catalog["dotnet/efcore@release/3.0"] = True
release_exception_catalog["aspnetboilerplate/aspnetboilerplate@v.5.1.0"] = True
release_exception_catalog["AutoMapper/AutoMapper@3.3.1"] = True
release_exception_catalog["sinatra/sinatra@1.0"] = True
release_exception_catalog["sinatra/sinatra@v1.1.0"] = True
release_exception_catalog["sinatra/sinatra@v1.1.1"] = True
release_exception_catalog["sinatra/sinatra@v1.1.2"] = True
release_exception_catalog["sinatra/sinatra@v1.1.3"] = True
release_exception_catalog["sinatra/sinatra@v1.1.4"] = True
release_exception_catalog["sinatra/sinatra@v1.2.0"] = True
release_exception_catalog["sinatra/sinatra@v1.2.1"] = True
release_exception_catalog["sinatra/sinatra@v1.2.2"] = True
release_exception_catalog["sinatra/sinatra@v1.2.3"] = True
release_exception_catalog["sinatra/sinatra@v1.2.4"] = True
release_exception_catalog["sinatra/sinatra@v1.2.5"] = True
release_exception_catalog["sinatra/sinatra@v1.2.6"] = True
release_exception_catalog["sinatra/sinatra@v1.2.7"] = True
release_exception_catalog["sinatra/sinatra@v1.2.8"] = True
release_exception_catalog["sinatra/sinatra@v1.2.9"] = True
release_exception_catalog["sinatra/sinatra@v1.3.0"] = True
release_exception_catalog["sinatra/sinatra@v1.3.1"] = True
release_exception_catalog["sinatra/sinatra@v1.3.2"] = True
release_exception_catalog["sinatra/sinatra@v1.3.3"] = True
release_exception_catalog["sinatra/sinatra@v1.3.4"] = True
release_exception_catalog["sinatra/sinatra@v1.3.5"] = True
release_exception_catalog["sinatra/sinatra@v1.3.6"] = True
release_exception_catalog["sinatra/sinatra@v1.4.0"] = True
release_exception_catalog["sinatra/sinatra@v1.4.1"] = True
release_exception_catalog["sinatra/sinatra@v1.4.2"] = True
release_exception_catalog["sinatra/sinatra@v1.4.3"] = True
release_exception_catalog["hashicorp/terraform@0.7."] = True

def analyze_project(name, lang, suffix_exception_catalog):
    try:
        start = time.time()
        path = os.path.abspath(os.path.join('..','..','repos',name))
        if name in suffix_exception_catalog:
            suffix_exception = suffix_exception_catalog[name]
        else:
            suffix_exception = None
        
        vcs = GitVcs(path)
        release_matcher = VersionWoPreReleaseMatcher(suffix_exception=suffix_exception)
        time_release_sorter = TimeReleaseSorter()
        version_release_sorter = VersionReleaseSorter()

        time_release_miner = TagReleaseMiner(vcs, release_matcher, time_release_sorter)
        time_release_set = time_release_miner.mine_releases()

        version_release_miner = TagReleaseMiner(vcs, release_matcher, version_release_sorter)
        version_release_set = version_release_miner.mine_releases()

        path_miner = PathCommitMiner(vcs, time_release_set)
        range_miner = RangeCommitMiner(vcs, version_release_set)
        time_miner = TimeCommitMiner(vcs, version_release_set)
    
        path_release_set = path_miner.mine_commits()
        time_release_set = time_miner.mine_commits()
        range_release_set = range_miner.mine_commits()
        
        stats = []
        for release in version_release_set:
            if f"{name}@{release.name}" not in release_exception_catalog:
                path_commits = set(path_release_set[release.name].commits)
                range_commits = set(range_release_set[release.name].commits)
                time_commits = set(time_release_set[release.name].commits)
            
                
                path_base_releases = [release.name.value for release in (path_release_set[release.name].base_releases or [])]
                range_base_releases = [release.name.value for release in (range_release_set[release.name].base_releases or [])]
                time_base_releases = [release.name.value for release in (time_release_set[release.name].base_releases or [])]

                stats.append({
                    "project": name,
                    "name": release.name.value,
                    "version": release.name.version,
                    "prefix": release.name.prefix,
                    "suffix": release.name.suffix,
                    "lang": lang,
                    "head": str(release.head.id),
                    "time": release.time,
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
                    "time_fneg": len(path_commits - time_commits)
                })
        releases = pd.DataFrame(stats)
        print(f"{time.time() - start:10} - {name}") 
        return releases
    except Exception as e:
        print(f" {name} - error: {e}")


pool = mp.Pool(processes=10, maxtasksperchild=10)
results = [pool.apply_async(analyze_project, args=(project.Index, project.lang, suffix_exception_catalog)) for project in projects.itertuples()]
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

releases.to_pickle("releases.zip")
releases.to_csv("releases.csv")
