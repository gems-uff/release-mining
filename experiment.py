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
    "spring-projects/spring-boot": ".RELEASE",
    "spring-projects/spring-framework": ".RELEASE",
    "netty/netty": ".Final",
    "godotengine/godot": "-stable",
}

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
                "base_releases": path_base_releases,
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
