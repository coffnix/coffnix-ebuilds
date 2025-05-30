#!/sr/bin/env python3

from packaging.version import Version

async def generate(hub, **pkginfo):
	name = pkginfo['name']
	download_url = f"https://download.gnome.org/sources/{name}"
	json_data = await hub.pkgtools.fetch.get_page(f"{download_url}/cache.json", is_json=True)
	releases = [Version(v) for v in json_data[2][name]]

	target = pkginfo.get('version')
	if target:
		target = Version(target)
		version = max([v for v in releases if v.major == target.major and v.minor == target.minor])
	else:
		version = max(releases)

	# Update the pkginfo version with the actual version
	pkginfo['version'] = version

	release = json_data[1][name][version.public]
	tarpath = [v for k, v in release.items() if 'tar' in k][0]
	tarball = tarpath.split("/")[1]
	artifact = hub.pkgtools.ebuild.Artifact(url=f"{download_url}/{tarpath}", final_name=tarball)
	
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=[artifact]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
