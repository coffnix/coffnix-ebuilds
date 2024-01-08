#!/usr/bin/python3

from datetime import datetime, timedelta

async def generate(hub, **pkginfo):
	if "qt5_module" not in pkginfo:
		pkginfo["qt5_module"] = pkginfo["name"]
	qt5_module = pkginfo["qt5_module"]
	target_commit = await hub.pkgtools.fetch.get_page(
		f"https://invent.kde.org/api/v4/projects/qt%2Fqt%2F{qt5_module}/repository/branches/kde%2F5.15", is_json=True, refresh_interval=timedelta(days=30)
	)
	commit_date = datetime.strptime(target_commit["commit"]["committed_date"], "%Y-%m-%dT%H:%M:%S.%f%z")
	commit_hash = target_commit["commit"]["id"]
	qt5_ver = pkginfo["version"]
	pkginfo["version"] = qt5_ver + "_p" + commit_date.strftime("%Y%m%d")

	artifact_url = f"https://invent.kde.org/qt/qt/{qt5_module}/-/archive/{commit_hash}/{qt5_module}-{commit_hash}.tar.bz2"
	artifacts = [hub.pkgtools.ebuild.Artifact(url=artifact_url)]
	if pkginfo["name"] == "qtlocation":
		qt5_module += "-mapboxgl"
		mapboxgl_commit = await hub.pkgtools.fetch.get_page(
			f"https://invent.kde.org/api/v4/projects/qt%2Fqt%2F{qt5_module}/repository/branches/upstream%2Fqt-staging", is_json=True, refresh_interval=timedelta(days=30)
		)
		mapboxgl_date = datetime.strptime(mapboxgl_commit["commit"]["committed_date"], "%Y-%m-%dT%H:%M:%S.%f%z")
		mapboxgl_hash = mapboxgl_commit["commit"]["id"]
		mapboxgl_url = f"https://invent.kde.org/qt/qt/{qt5_module}/-/archive/{mapboxgl_hash}/{qt5_module}-{commit_hash}.tar.bz2"
		artifacts.append(hub.pkgtools.ebuild.Artifact(url=mapboxgl_url,final_name=f"{qt5_module}-{qt5_ver}-{commit_hash[0:8]}.tar.bz2"))
		if mapboxgl_date > commit_date:
			pkginfo["version"] = qt5_ver + "_p" + mapboxgl_date.strftime("%Y%m%d")

	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo,qt5_ver=qt5_ver,commit_hash=commit_hash,artifacts=artifacts)
	ebuild.push()


# vim: ts=4 sw=4 noet
